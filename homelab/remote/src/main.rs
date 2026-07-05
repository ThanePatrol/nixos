//! A small web-based TV remote.
//!
//! Serves a single HTML page laid out like a remote control. Every button press
//! POSTs to `/api/press/{action}`, which publishes a Tasmota IR command over
//! MQTT to `cmnd/tasmota_ir/irsend` — the same topic/payload the Home Assistant
//! scripts in `homelab/home-assistant.nix` use.
//!
//! Configuration comes entirely from the environment:
//!   MQTT_BROKER         mqtt:// URL of the broker      (default mqtt://127.0.0.1:1883)
//!   MQTT_USERNAME       broker username                (required)
//!   MQTT_PASSWORD       broker password                (required)
//!   REMOTE_LISTEN_ADDR  host:port to serve HTTP on     (default 0.0.0.0:8099)

use std::{env, sync::Arc};

use axum::{
    extract::{Path, State},
    http::StatusCode,
    response::{Html, IntoResponse},
    routing::{get, post},
    Router,
};
use mqtt5::{ConnectOptions, MqttClient};

/// Tasmota IR command topic
const TOPIC: &str = "cmnd/tasmota_ir/irsend";

/// A single Sony TV IR command
struct IrCommand {
    /// Action id used in the URL (`/api/press/{action}`) and the HTML buttons.
    action: &'static str,
    bits: u16,
    data: &'static str,
    data_lsb: &'static str,
}

/// The remote's button -> IR code mapping.
///
/// Note: there is no captured IR code for a dedicated play/pause button, so the
/// UI renders it disabled. Fast-forward/rewind reuse the TV's next/previous
/// episode codes, which is the closest available transport control.
const COMMANDS: &[IrCommand] = &[
    IrCommand {
        action: "power",
        bits: 12,
        data: "0xA90",
        data_lsb: "0x5009",
    }, // tv_turn_off
    IrCommand {
        action: "up",
        bits: 12,
        data: "0x2F0",
        data_lsb: "0x400F",
    },
    IrCommand {
        action: "down",
        bits: 12,
        data: "0xAF0",
        data_lsb: "0x500F",
    },
    IrCommand {
        action: "left",
        bits: 12,
        data: "0x2D0",
        data_lsb: "0x400B",
    },
    IrCommand {
        action: "right",
        bits: 12,
        data: "0xCD0",
        data_lsb: "0x300B",
    },
    IrCommand {
        action: "enter",
        bits: 12,
        data: "0xA70",
        data_lsb: "0x500E",
    },
    IrCommand {
        action: "back",
        bits: 15,
        data: "0x62E9",
        data_lsb: "0x4697",
    },
    IrCommand {
        action: "volume_up",
        bits: 12,
        data: "0x490",
        data_lsb: "0x2009",
    },
    IrCommand {
        action: "volume_down",
        bits: 12,
        data: "0xC90",
        data_lsb: "0x3009",
    },
    IrCommand {
        action: "mute",
        bits: 12,
        data: "0x290",
        data_lsb: "0x4009",
    },
    IrCommand {
        action: "fast_forward",
        bits: 15,
        data: "0x1CE9",
        data_lsb: "0x3897",
    },
    IrCommand {
        action: "rewind",
        bits: 15,
        data: "0x6CE9",
        data_lsb: "0x3697",
    },
];

/// The embedded remote-control page.
const INDEX_HTML: &str = include_str!("../static/index.html");

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt()
        .with_env_filter(
            tracing_subscriber::EnvFilter::try_from_default_env()
                .unwrap_or_else(|_| "remote=info,warn".into()),
        )
        .init();

    let broker = env::var("MQTT_BROKER").unwrap_or_else(|_| "mqtt://127.0.0.1:1883".into());
    let username = env::var("MQTT_USERNAME").expect("MQTT_USERNAME must be set");
    let password = env::var("MQTT_PASSWORD").expect("MQTT_PASSWORD must be set");
    let listen = env::var("REMOTE_LISTEN_ADDR").unwrap_or_else(|_| "0.0.0.0:8099".into());

    let options = ConnectOptions::new("tv-remote")
        .with_credentials(username, password)
        .with_automatic_reconnect(true);

    let client = MqttClient::with_options(options);
    client
        .connect(&broker)
        .await
        .expect("failed to connect to MQTT broker");
    tracing::info!(%broker, "connected to MQTT broker");

    let app = Router::new()
        .route("/", get(index))
        .route("/api/press/{action}", post(press))
        .with_state(Arc::new(client));

    let listener = tokio::net::TcpListener::bind(&listen)
        .await
        .expect("failed to bind listen address");
    tracing::info!(%listen, "serving TV remote");
    axum::serve(listener, app).await.expect("server error");
}

/// Serves the remote-control page.
async fn index() -> Html<&'static str> {
    Html(INDEX_HTML)
}

/// Publishes the IR command for `action` over MQTT.
async fn press(
    State(client): State<Arc<MqttClient>>,
    Path(action): Path<String>,
) -> impl IntoResponse {
    let Some(cmd) = COMMANDS.iter().find(|c| c.action == action) else {
        return (StatusCode::NOT_FOUND, format!("unknown action: {action}"));
    };

    let payload = format!(
        r#"{{"Protocol":"SONY","Bits":{},"Data":"{}","DataLSB":"{}","Repeat":0}}"#,
        cmd.bits, cmd.data, cmd.data_lsb,
    );

    match client.publish(TOPIC, payload.into_bytes()).await {
        Ok(_) => {
            tracing::info!(%action, "sent IR command");
            (StatusCode::OK, "ok".to_string())
        }
        Err(err) => {
            tracing::error!(%action, %err, "failed to publish IR command");
            (StatusCode::BAD_GATEWAY, format!("failed to publish: {err}"))
        }
    }
}
