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

  craneLib = crane.mkLib pkgs;

  # Need to include index.html in build process. This prevents crane from excluding it.
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

  sops.templates."acme-env" = {
    content = ''
      CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder.cloudflare_certbot_api_key}
      LEGO_DISABLE_CNAME_SUPPORT=true'';
    owner = "acme";
    mode = "0400";
  };
  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@mandalidis.com";
    certs = {
      "mandalidis.com" = {
        domain = "*.mandalidis.com";
        group = "pingora";
        dnsProvider = "cloudflare";
        environmentFile = config.sops.templates."acme-env".path;
        reloadServices = [ "rev-proxy" ];
        dnsResolver = "1.1.1.1:53";
      };
    };
  };

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
      GOOGLE_CLIENT_ID="${config.sops.placeholder.google_client_id}"
      GOOGLE_CLIENT_SECRET="${config.sops.placeholder.google_client_secret}"
      GOOGLE_REDIRECT_URI="${config.sops.placeholder.google_redirect_uri}"
      ALLOWED_EMAILS="${config.sops.placeholder.allowed_emails}"
    '';
    owner = "pingora";
    mode = "0400";
  };

  systemd.services.rev-proxy = {
    description = "Reverse proxy for exposing homelab applications.";
    script = ''
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
      StateDirectory = "pingora";
      ExecStartPre = "${pkgs.writeShellScript "copy-cert" ''
        dir="/var/lib/pingora";

        ${pkgs.coreutils}/bin/cp /var/lib/acme/mandalidis.com/fullchain.pem $dir/cert.pem
        ${pkgs.coreutils}/bin/cp /var/lib/acme/mandalidis.com/key.pem $dir/key.pem
      ''}";
    };
  };
}
