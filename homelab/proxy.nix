{
  pkgs,
  lib,
  config,
  ports,
  crane,
  ...
}:

let
  portsAsRouteConfig = builtins.mapAttrs (
    name: service:
    (builtins.removeAttrs service [ "port" ])
    // {
      target = {
        endpoint = "127.0.0.1:${toString service.port}";
      };
    }
  ) ports.exposeProxy;

  certbotConf = lib.attrsets.attrsToList (
    builtins.mapAttrs (
      name: service:
      (builtins.removeAttrs service [
        "port"
      ])
    ) ports.exposeProxy
  );

  craneLib = crane.mkLib pkgs;

  htmlFilter = path: _type: builtins.match ".*html$" path != null;
  inputFiles = path: type: (htmlFilter path type) || (craneLib.filterCargoSources path type);

  pingora = craneLib.buildPackage {
    pname = "rev-proxy";
    version = "0.1.0";
    src = lib.cleanSourceWith {
      src = ./proxy;
      filter = inputFiles;
      name = "source";
    };
    nativeBuildInputs = [
      pkgs.cmake
      pkgs.pkg-config

      pkgs.rustPlatform.bindgenHook
      pkgs.boringssl
      pkgs.git

      pkgs.openssl
      pkgs.libsodium

      pkgs.zlib
      pkgs.binutils
      pkgs.llvmPackages.libclang
      pkgs.llvmPackages.clang
      pkgs.llvmPackages.bintools
      pkgs.llvmPackages.clang-tools

    ];
    preBuild = ''
      echo "Running pre-build script..."
      ${pkgs.coreutils}/bin/env
      cat << 'EOF' > config.json
      ${builtins.toJSON (lib.attrValues portsAsRouteConfig)}
      EOF
      echo "______"
    '';
    LD_FOR_BUILD = "ld";
    LD_FOR_TARGET = "ld";
    LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
    BINDGEN_EXTRA_CLANG_ARGS = "-isystem ${pkgs.llvmPackages.libclang.lib}/lib/clang/${lib.getVersion pkgs.clang}/include";
    PROMETHEUS_PINGORA_PORT = "127.0.0.1:${builtins.toString ports.noFirewall.pingoraPrometheus}";
    LOGIN_PINGORA_PORT = "127.0.0.1:${builtins.toString ports.exposeProxy.pingoraLogin.port}";
  };

in
{
  # Certbot write out to ini
  environment.etc."certbot/cloudflare.json".text = lib.generators.toJSON { } certbotConf;

  users.users.pingora = {
    isSystemUser = true;
    group = "pingora";
    # Do not have any shell for this user.
    # This is already the default when isSystemUser = true
    # but we set it explicitly so the ground around us changing is fine.
    shell = "${pkgs.shadow}/bin/nologin";
  };
  users.groups.pingora = { };

  sops.templates."pingora-env" = {
    content = ''
      PROXY_SSL_KEY_PEM="${config.sops.placeholder.proxy_ssl_key_pem}"
      PROXY_CERT_PEM="${config.sops.placeholder.proxy_cert_pem}"
      GOOGLE_CLIENT_ID="${config.sops.placeholder.google_client_id}"
      GOOGLE_CLIENT_SECRET="${config.sops.placeholder.google_client_secret}"
      GOOGLE_REDIRECT_URI="${config.sops.placeholder.google_redirect_uri}"
      ALLOWED_EMAILS="${config.sops.placeholder.allowed_emails}"
    '';
    owner = "pingora";
  };

  systemd.services.certbot-copy = {
    description = "Copy certbot certs to temporarily readable place.";

    script = ''

    '';

  };

  systemd.services.rev-proxy = {
    description = "Reverse proxy for exposing homelab applications.";
    script = ''
      source ${config.sops.templates."pingora-env".path};
      newline_ssl="$(echo $PROXY_SSL_KEY_PEM | tr ' ' '\n')"
      printf -- "-----BEGIN PRIVATE KEY-----\n%s\n-----END PRIVATE KEY-----\n" "$newline_ssl" > /tmp/key.pem
      newline_cert="$(echo $PROXY_CERT_PEM | tr ' ' '\n')"
      printf -- "-----BEGIN CERTIFICATE-----\n%s\n-----END CERTIFICATE-----\n" "$newline_cert" > /tmp/cert.pem
      ${pingora}/bin/rev-proxy
    '';
    after = [
      "network.target"
    ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      EnvironmentFile = config.sops.templates."pingora-env".path;
      User = "pingora";
      Restart = "on-failure";
      RestartSec = 5;

      NoNewPrivileges = true;
      KillSignal = "SIGKILL";
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
    };
  };
}
