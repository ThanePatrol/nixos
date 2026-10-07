mod login;

use async_trait::async_trait;
use bytes::Bytes;
use http::header;
use pingora::listeners::tls::TlsSettings;
use pingora::prelude::*;
use pingora::server::RunArgs;
use pingora::server::ShutdownSignal;
use pingora::server::UnixShutdownSignalWatch;
use std::collections::HashMap;
use std::ops::DerefMut;
use std::sync::Arc;
use std::time::Duration;
use tokio::sync::Mutex;

use http::{Response, StatusCode};
use once_cell::sync::Lazy;
use pingora::apps::http_app::HttpServer;
use pingora::apps::http_app::ServeHttp;
use pingora::protocols::http::ServerSession;
use pingora::services::listening::Service;
use prometheus::{register_int_counter, IntCounter};

use serde::{Deserialize, Serialize};
use tracing::{debug, info, Level};
use tracing_subscriber::FmtSubscriber;

use crate::login::SessionStore;
use crate::login::UserKey;

static REQ_COUNTER: Lazy<IntCounter> =
    Lazy::new(|| register_int_counter!("reg_counter", "Number of requests").unwrap());

pub struct HttpEchoApp;

static ROUTE_CONFIG: &'static str = include_str!("../config.json");

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct ProxyRoute {
    pub hostname: String,
    pub target: RouteTarget,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct RouteTarget {
    pub endpoint: String,
    pub is_tls: bool,
    pub sni: String,
}

#[async_trait]
impl ServeHttp for HttpEchoApp {
    async fn response(&self, http_stream: &mut ServerSession) -> Response<Vec<u8>> {
        REQ_COUNTER.inc();
        // read timeout of 2s
        let read_timeout = 2000;
        let body = match timeout(
            Duration::from_millis(read_timeout),
            http_stream.read_request_body(),
        )
        .await
        {
            Ok(res) => match res.unwrap() {
                Some(_bytes) => "pong".as_bytes().into(),
                None => Bytes::from("no body!"),
            },
            Err(_) => {
                panic!("Timed out after {:?}ms", read_timeout);
            }
        };

        Response::builder()
            .status(StatusCode::OK)
            .header(http::header::CONTENT_TYPE, "text/html")
            .header(http::header::CONTENT_LENGTH, body.len())
            .body(body.to_vec())
            .unwrap()
    }
}

pub fn echo_service_http() -> Service<HttpServer<HttpEchoApp>> {
    let server = HttpServer::new_app(HttpEchoApp);
    Service::new("Echo Service HTTP".to_string(), server)
}

pub struct Proxy {
    sessions: Arc<SessionStore>,
    upstreams: HashMap<String, (String, bool, String)>,
}

static CF_CONNECTING_IP: header::HeaderName = header::HeaderName::from_static("cf-connecting-ip");

#[async_trait]
impl ProxyHttp for Proxy {
    /// For this small example, we don't need context storage
    type CTX = ();
    fn new_ctx(&self) -> () {
        ()
    }

    /// Returns Ok(false) if a user should continue, Ok(true) if we already processing the request.
    async fn request_filter(&self, session: &mut Session, _ctx: &mut Self::CTX) -> Result<bool> {
        let host = session
            .get_header(header::HOST)
            .and_then(|h| h.to_str().ok())
            .unwrap_or("");

        let cf_ip = session
            .get_header(&CF_CONNECTING_IP)
            .and_then(|h| h.to_str().ok())
            .unwrap_or("could not determine ip");

        if host == "login.mandalidis.com" {
            return Ok(false);
        }

        // User trying to access something else so we verify if they're logged in here.
        let token = session
            .get_header(header::COOKIE)
            .and_then(|v| v.to_str().ok())
            .and_then(|c| login::get_cookie(c, "session"))
            .map(|s| UserKey::from_string(s));

        // User does have token, that is not expired, allow.
        if let Some(Ok(t)) = token {
            debug!("user with ip: {} presented token: {:?}", cf_ip, t);
            debug!("current sessions are: {:?} ", self.sessions.sessions);

            if let Some(store) = self.sessions.sessions.lock().await.get_mut(&t) {
                debug!("current logins: {:?}", store);
                if store.1.expires_at > std::time::Instant::now() {
                    if store.2 < 1 {
                        store.2 += 1;
                        info!(
                            "Parsed valid token successfully from ip: {cf_ip} for {}",
                            store.1.email.to_ascii_lowercase()
                        );
                    }
                    return Ok(false);
                }
            }
        }
        let original_target = format!("https://{}{}", host, session.req_header().uri.to_string());

        let login_redirect = format!(
            "https://login.mandalidis.com/login?redirect_to={}",
            urlencoding::encode(&original_target)
        );

        info!("User or bot with ip: {cf_ip} did not present a valid token.",);

        let mut resp = ResponseHeader::build(StatusCode::FOUND, None)?;
        resp.insert_header(header::LOCATION, login_redirect)?;
        resp.insert_header(header::CONTENT_LENGTH, "0")?;
        session.write_response_header(Box::new(resp), true).await?;
        Ok(true)
    }

    async fn upstream_peer(&self, session: &mut Session, _ctx: &mut ()) -> Result<Box<HttpPeer>> {
        let host = session
            .get_header(header::HOST)
            .and_then(|h| h.to_str().ok())
            .unwrap_or("");

        let (addr, tls, sni) = self
            .upstreams
            .get(host)
            .ok_or_else(|| pingora::Error::explain(HTTPStatus(404), "unknown host"))?;

        Ok(Box::new(HttpPeer::new(addr.as_str(), *tls, sni.clone())))
    }
}

fn init_logging() {
    let subscriber = FmtSubscriber::builder()
        .with_max_level(Level::TRACE)
        .finish();

    tracing::subscriber::set_global_default(subscriber).expect("setting default subscriber failed");
}

fn main() {
    init_logging();
    let mut my_server = Server::new(None).unwrap();
    my_server.bootstrap();

    let mut options = pingora::listeners::TcpSocketOptions::default();
    options.tcp_fastopen = Some(10);
    options.tcp_keepalive = Some(pingora::protocols::TcpKeepalive {
        idle: Duration::from_secs(60),
        interval: Duration::from_secs(5),
        count: 5,
        user_timeout: Duration::from_secs(85),
    });

    let (cert_path, key_path) = ("/tmp/cert.pem", "/tmp/key.pem");
    let mut login_tls_settings =
        TlsSettings::intermediate(cert_path, key_path).expect("could not create tls settings");
    login_tls_settings
        .deref_mut()
        .deref_mut()
        .set_max_proto_version(Some(pingora::tls::ssl::SslVersion::TLS1_3))
        .unwrap();
    login_tls_settings.enable_h2();
    let mut proxy_tls_settings = TlsSettings::intermediate(cert_path, key_path).unwrap();
    proxy_tls_settings
        .deref_mut()
        .deref_mut()
        .set_max_proto_version(Some(pingora::tls::ssl::SslVersion::TLS1_3))
        .unwrap();
    // tls_setting.enable_h2();

    let store = Arc::new(login::SessionStore {
        sessions: Mutex::new(HashMap::new()),
    });
    let routes: Vec<ProxyRoute> =
        serde_json::from_str(ROUTE_CONFIG).expect("Could not deserialize ROUTE_CONFIG");

    let routes = routes
        .into_iter()
        .fold(HashMap::new(), |mut accumulator, route| {
            accumulator.insert(
                route.hostname,
                (route.target.endpoint, route.target.is_tls, route.target.sni),
            );

            accumulator
        });

    let mut proxy = http_proxy_service(
        &my_server.configuration,
        Proxy {
            sessions: store.clone(),
            upstreams: routes,
        },
    );

    let mut login_service = login::login_service_http(store.clone());
    login_service.add_tls_with_settings(
        "127.0.0.1:8443",
        Some(options.clone()),
        login_tls_settings,
    );
    login_service.add_uds("/tmp/echo.sock", None);

    proxy.add_tls_with_settings("0.0.0.0:443", Some(options.clone()), proxy_tls_settings);

    my_server.add_service(proxy);
    my_server.add_service(login_service);
    let mut args = RunArgs::default();
    args.shutdown_signal = Box::new(UnixShutdownSignalWatch {});

    my_server.run(args);
}
