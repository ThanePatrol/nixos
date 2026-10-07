//! Minimal "Login with Google" flow built on top of `openidconnect`.
//!
//! This is a single Pingora `ServeHttp` app that serves a login form and
//! handles the OpenID Connect authorization-code (PKCE) flow:
//!
//!   GET /          -> the login form (index.html)
//!   GET /login     -> start the flow, redirect the browser to Google
//!   GET /callback  -> Google redirects back here with ?code=...&state=...

use std::collections::HashMap;
use std::num::ParseIntError;
use std::sync::Arc;

use async_trait::async_trait;
use http::{header, HeaderMap, HeaderValue, Response, StatusCode};
use openidconnect::{EndpointMaybeSet, EndpointNotSet, EndpointSet};
use pingora::apps::http_app::{HttpServer, ServeHttp};
use pingora::protocols::http::ServerSession;
use pingora::services::listening::Service;
use tokio::sync::Mutex;
use tracing::info;

use openidconnect::core::{CoreClient, CoreProviderMetadata};
use openidconnect::reqwest;
use openidconnect::{
    AuthorizationCode, ClientId, ClientSecret, CsrfToken, IssuerUrl, Nonce, PkceCodeVerifier,
    RedirectUrl, Scope, TokenResponse,
};

/// Google's OpenID Connect issuer. Discovery hangs off this.
const ISSUER_URL: &str = "https://accounts.google.com";

const SESSION_TTL: std::time::Duration = std::time::Duration::from_hours(24);

/// The login form. Embedded at compile time so there are no runtime path woes.
const INDEX_HTML: &str = include_str!("../index.html");

/// State we need to remember between starting a login and handling the
/// callback. Keyed in the map by the CSRF `state` token.
struct PendingLogin {
    pkce_verifier: PkceCodeVerifier,
    nonce: Nonce,
    expiry_instant: std::time::Instant,
    redirect_to: String,
}
#[derive(Debug)]
pub struct User {
    pub email: openidconnect::EndUserEmail,
    pub expires_at: std::time::Instant,
}

pub struct LoginApp {
    http_client: reqwest::Client,
    client: CoreClient<
        EndpointSet,
        EndpointNotSet,
        EndpointNotSet,
        EndpointNotSet,
        EndpointMaybeSet,
        EndpointMaybeSet,
    >,
    /// In-flight logins, keyed by CSRF state.
    pending: Mutex<HashMap<String, PendingLogin>>,
    allowed_emails: Vec<openidconnect::EndUserEmail>,
    sessions: Arc<SessionStore>,
}

#[derive(PartialEq, Eq, Hash, Debug, Clone)]
pub struct UserKey([u8; 32]);

impl UserKey {
    pub fn new(bytes: [u8; 32]) -> Self {
        Self(bytes)
    }
    pub fn to_string(&self) -> String {
        self.0
            .iter()
            .fold(String::with_capacity(self.0.len()), |mut acc, c| {
                acc.push_str(c.to_string().as_str());
                acc.push(',');
                acc
            })
    }
    pub fn from_string(s: &str) -> Result<Self, ParseIntError> {
        let mut out = [0; 32];
        for (i, c) in s.split(',').enumerate() {
            if c.is_empty() {
                continue;
            }
            let num = c.parse::<u8>()?;
            out[i] = num;
        }
        Ok(UserKey(out))
    }
}
type Token = String;

type Visits = usize;
type Data = (Token, User, Visits);

pub struct SessionStore {
    pub sessions: Mutex<HashMap<UserKey, Data>>,
}

#[derive(Debug, Clone)]
pub struct InitErr {
    pub msg: String,
}

impl InitErr {
    pub fn with_msg(s: &str) -> Self {
        Self { msg: s.to_owned() }
    }
}

// TODO: Change to lets encrypt to avoid self signed certs
impl LoginApp {
    pub fn from_env(store: Arc<SessionStore>) -> Result<Self, InitErr> {
        let client_id = ClientId::new(std::env::var("GOOGLE_CLIENT_ID").unwrap_or_default());
        let client_secret =
            ClientSecret::new(std::env::var("GOOGLE_CLIENT_SECRET").unwrap_or_default());
        let redirect_uri = RedirectUrl::new(
            std::env::var("GOOGLE_REDIRECT_URI")
                .map_err(|_| InitErr::with_msg("GOOGLE_REDIRECT_URI not set"))?,
        )
        .map_err(|_| InitErr::with_msg("GOOGLE_REDIRECT_URI not valid url"))?;

        let allowed_emails = std::env::var("ALLOWED_EMAILS")
            .map_err(|_| InitErr::with_msg("ALLOWED_EMAILS not set"))?
            .split(' ')
            .map(|e| openidconnect::EndUserEmail::new(e.to_string()))
            .collect::<Vec<openidconnect::EndUserEmail>>();

        let http_client = reqwest::ClientBuilder::new()
            .redirect(reqwest::redirect::Policy::none())
            .use_rustls_tls()
            .build()
            .map_err(|_| InitErr::with_msg("could not init http_client"))?;

        let issuer = IssuerUrl::new(ISSUER_URL.to_string())
            .map_err(|_| InitErr::with_msg("could not create issuer url"))?;

        let rt = tokio::runtime::Runtime::new().expect("could not create runtime");
        let provider_metadata = rt
            .block_on(CoreProviderMetadata::discover_async(issuer, &http_client))
            .map_err(|_| InitErr::with_msg("err discovering metadata"))?;

        let client =
            CoreClient::from_provider_metadata(provider_metadata, client_id, Some(client_secret))
                .set_redirect_uri(redirect_uri);

        Ok(LoginApp {
            client,
            http_client,
            allowed_emails,
            pending: Mutex::new(HashMap::new()),
            sessions: store,
        })
    }

    async fn start_login(&self, query: Option<&str>) -> Response<Vec<u8>> {
        info!("got query: {:?}", query);
        let redirect_to = query
            .and_then(|q| {
                url::form_urlencoded::parse(q.as_bytes()).find(|(k, _)| k == "redirect_to")
            })
            .map(|(_, v)| v.into_owned())
            .unwrap_or_else(|| "https://login.mandalidis.com/".to_string());

        let (pkce_challenge, pkce_verifier) = openidconnect::PkceCodeChallenge::new_random_sha256();

        let (auth_url, csrf_token, nonce) = self
            .client
            .authorize_url(
                openidconnect::core::CoreAuthenticationFlow::AuthorizationCode,
                CsrfToken::new_random,
                Nonce::new_random,
            )
            .add_scope(Scope::new("email".to_string()))
            .add_scope(Scope::new("profile".to_string()))
            .set_pkce_challenge(pkce_challenge)
            .url();

        let now = std::time::Instant::now();

        self.pending.lock().await.insert(
            csrf_token.secret().clone(),
            PendingLogin {
                pkce_verifier,
                nonce,
                expiry_instant: now + std::time::Duration::from_mins(10),
                redirect_to,
            },
        );

        // Dumb check to prevent pending from growing unbounded.
        self.pending
            .lock()
            .await
            .retain(|_, v| v.expiry_instant > now);

        redirect(auth_url.as_str())
    }

    /// GET /callback?code=...&state=... -> exchange the code for tokens,
    /// verify the ID token, and greet the user.
    async fn handle_callback(&self, query: Option<&str>) -> Response<Vec<u8>> {
        if query.is_none() {
            return error_page("missing 'query' in callback");
        }
        let query = query.unwrap().as_bytes();

        let params: HashMap<String, String> =
            url::form_urlencoded::parse(query).into_owned().collect();

        let code = match params.get("code") {
            Some(c) => c.clone(),
            None => return error_page("missing `code` in callback"),
        };
        let state = match params.get("state") {
            Some(s) => s,
            None => return error_page("missing `state` in callback"),
        };

        // Pull the matching pending login out of the map. If it's not there the
        // state is unknown/forged/expired.
        let pending = match self.pending.lock().await.remove(state) {
            Some(p) => p,
            None => return error_page("unknown or expired login state"),
        };

        let token_response = match self
            .client
            .exchange_code(AuthorizationCode::new(code.to_owned()))
        {
            Ok(req) => match req
                .set_pkce_verifier(pending.pkce_verifier)
                .request_async(&self.http_client)
                .await
            {
                Ok(resp) => resp,
                Err(_) => return error_page(&format!("token exchange failed")),
            },
            Err(_) => return error_page(&format!("token exchange failed")),
        };

        let id_token = match token_response.id_token() {
            Some(t) => t,
            None => return error_page("provider did not return an ID token"),
        };

        let verifier = self.client.id_token_verifier();
        let claims = match id_token.claims(&verifier, &pending.nonce) {
            Ok(c) => c,
            Err(_) => return error_page(&format!("ID token verification failed")),
        };

        let email = match claims.email() {
            Some(e) => e,
            None => return error_page(&format!("no email claims")),
        };

        if claims.email_verified().is_none()
            || !claims.email_verified().unwrap()
            || !self.allowed_emails.contains(&email)
        {
            return error_page(&format!("email not allowed"));
        }

        let now = std::time::Instant::now();
        let session_store_key = UserKey::new(rand::random());
        self.sessions.sessions.lock().await.insert(
            session_store_key.clone(),
            (
                id_token.to_string(),
                User {
                    email: email.clone(),
                    expires_at: now + SESSION_TTL,
                },
                0,
            ),
        );

        self.sessions
            .sessions
            .lock()
            .await
            .retain(|_, v| v.1.expires_at > now);

        Response::builder()
            .status(StatusCode::FOUND)
            .header(header::LOCATION, pending.redirect_to)
            .header(
                header::SET_COOKIE,
                format!(
                    "session={}; HttpOnly; Secure; SameSite=Lax; Path=/; Domain=mandalidis.com",
                    session_store_key.to_string()
                ),
            )
            .header(header::CONTENT_LENGTH, 0)
            .body(Vec::new())
            .unwrap()
    }

    async fn main_page(&self, headers: &HeaderMap<HeaderValue>) -> Response<Vec<u8>> {
        if let Some(Ok(session_token)) = headers
            .get(header::COOKIE)
            .and_then(|v| v.to_str().ok())
            .and_then(|c| get_cookie(c, "session"))
            .map(|s| UserKey::from_string(s))
        {
            if let Some((_token, user, _visits)) =
                self.sessions.sessions.lock().await.get(&session_token)
            {
                if user.expires_at < std::time::Instant::now() {
                    html_page(StatusCode::OK, INDEX_HTML)
                } else {
                    let duration_till_expiry = user
                        .expires_at
                        .duration_since(std::time::Instant::now())
                        .as_secs();
                    html_page(
                        StatusCode::OK,
                        format!(
                            "<h1>User {} logged in for {} more seconds</h1>",
                            user.email.clone().as_str(),
                            duration_till_expiry
                        )
                        .as_str(),
                    )
                }
            } else {
                html_page(StatusCode::OK, INDEX_HTML)
            }
        } else {
            html_page(StatusCode::OK, INDEX_HTML)
        }
    }
}

pub fn get_cookie<'a>(cookie_header: &'a str, name: &str) -> Option<&'a str> {
    cookie_header.split(';').find_map(|pair| {
        let (k, v) = pair.trim().split_once('=')?;
        (k == name).then_some(v)
    })
}

#[async_trait]
impl ServeHttp for LoginApp {
    async fn response(&self, http_stream: &mut ServerSession) -> Response<Vec<u8>> {
        let req = http_stream.req_header();
        let path = req.uri.path().to_string();
        let query = req.uri.query().map(|q| q.to_string());

        info!("headers: {:?} path: {:?} query: {:?}", req, path, query);

        match path.as_str() {
            "/" => self.main_page(&req.headers).await,
            "/login" => self.start_login(query.as_deref()).await,
            "/callback" => self.handle_callback(query.as_deref()).await,
            _ => html_page(StatusCode::NOT_FOUND, "<h1>404</h1>"),
        }
    }
}

/// Build the Pingora service that runs the login app.
pub fn login_service_http(store: Arc<SessionStore>) -> Service<HttpServer<LoginApp>> {
    let app = match LoginApp::from_env(store) {
        Ok(a) => a,
        Err(e) => panic!("got err initializing app: {}", e.msg),
    };
    let server = HttpServer::new_app(app);
    Service::new("Login Service HTTP".to_string(), server)
}

// --- small response helpers -------------------------------------------------

fn html_page(status: StatusCode, body: &str) -> Response<Vec<u8>> {
    let bytes = body.as_bytes().to_vec();
    Response::builder()
        .status(status)
        .header(header::CONTENT_TYPE, "text/html; charset=utf-8")
        .header(header::CONTENT_LENGTH, bytes.len())
        .body(bytes)
        .unwrap()
}

fn redirect(location: &str) -> Response<Vec<u8>> {
    Response::builder()
        .status(StatusCode::FOUND)
        .header(header::LOCATION, location)
        .header(header::CONTENT_LENGTH, 0)
        .body(Vec::new())
        .unwrap()
}

fn error_page(msg: &str) -> Response<Vec<u8>> {
    html_page(
        StatusCode::INTERNAL_SERVER_ERROR,
        &format!("<h1>Login error</h1><p>{msg}</p>"),
    )
}
