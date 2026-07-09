{
  pkgs,
  config,
  ports,
  ...
}:

let

  actionAndCodes = [
    {
      name = "turn_ball_on";
      description = "Turn Ball on 🔮";
      data = "0xFFE01F";
      dataLSB = "0xFFE01F";
    }
    {
      name = "turn_ball_off";
      description = "Turn ball off 🔮";
      data = "0xFF609F";
      dataLSB = "0xFF609F";
    }
    {
      name = "turn_ball_pink";
      description = "Turn ball pink";
      data = "0xFF48B7";
      dataLSB = "0xFF12ED";
    }
    {
      name = "turn_ball_violet";
      description = "Turn ball violet";
      data = "0xFF58A7";
      dataLSB = "0xFF1AE5";
    }
    {
      name = "turn_ball_purple";
      description = "Turn ball purple";
      data = "0xFF6897";
      dataLSB = "0xFF16E9";
    }
    {
      name = "turn_ball_azure";
      description = "Turn ball azure";
      data = "0xFF708F";
      dataLSB = "0xFF0EF1";
    }
    {
      name = "turn_ball_blue";
      description = "Turn ball blue";
      data = "0xFF50AF";
      dataLSB = "0xFF0AF5";
    }
    {
      name = "turn_ball_cyan";
      description = "Turn ball cyan";
      data = "0xFF08F7";
      dataLSB = "0xFF10EF";
    }
    {
      name = "turn_ball_sky_blue";
      description = "Turn ball sky blue";
      data = "0xFF18E7";
      dataLSB = "0xFF18E7";
    }
    {
      name = "turn_ball_sky_electric_blue";
      description = "Turn ball electric blue";
      data = "0xFF28D7";
      dataLSB = "0xFF14EB";
    }
    {
      name = "turn_ball_sky_mint";
      description = "Turn ball mint";
      data = "0xFF30CF";
      dataLSB = "0xFF0CF3";
    }
    {
      name = "turn_ball_sky_green";
      description = "Turn ball green";
      data = "0xFF10EF";
      dataLSB = "0xFF08F7";
    }
    {
      name = "turn_ball_sky_citrine";
      description = "Turn ball citrine";
      data = "0xFF8877";
      dataLSB = "0xFF11EE";
    }
    {
      name = "turn_ball_sky_marigold";
      description = "Turn ball marigold";
      data = "0xFF9867";
      dataLSB = "0xFF19E6";
    }
    {
      name = "turn_ball_sky_jonquil";
      description = "Turn ball jonquil";
      data = "0xFFA857";
      dataLSB = "0xFF15EA";
    }
    {
      name = "turn_ball_sky_orange";
      description = "Turn ball orange";
      data = "0xFFB04F";
      dataLSB = "0xFF0DF2";
    }
    {
      name = "turn_ball_sky_red";
      description = "Turn ball red";
      data = "0xFF906F";
      dataLSB = "0xFF09F6";
    }
    {
      name = "turn_ball_sky_white";
      description = "Turn ball white";
      data = "0xFFD02F";
      dataLSB = "0xFF0BF4";
    }
    {
      name = "turn_ball_brightness_down";
      description = "Turn ball brightness down";
      data = "0xFF20DF";
      dataLSB = "0xFF04FB";
    }
    {
      name = "turn_ball_brightness_up";
      description = "Turn ball brightness up";
      data = "0xFFA05F";
      dataLSB = "0xFF05FA";
    }
    {
      name = "turn_ball_into_smooth_fade";
      description = "Turn ball into smooth fade";
      data = "0xFFC837";
      dataLSB = "0xFF13EC";
    }
    # TODO: more than the bottom three colors.
  ];

  ballScripts = builtins.listToAttrs (
    map (inst: {
      name = inst.name;
      value = {
        alias = "${inst.name}";
        description = "${inst.description} ";
        sequence = [
          {
            service = "mqtt.publish";
            data = {
              topic = "cmnd/tasmota_ir/irsend";
              payload = ''{"Protocol":"NEC","Bits":32,"Data":"${inst.data}","DataLSB":"${inst.dataLSB}","Repeat":0}'';
              retain = false;
            };
          }
        ];
      };
    }) actionAndCodes
  );

  tvActionsAndCodes = [
    {
      name = "tv_change_source";
      description = "TV change source";
      bits = 12;
      data = "0xA50";
      dataLSB = "0x500A";
    }
    {
      name = "tv_left_numpad";
      description = "TV left numpad";
      bits = 12;
      data = "0x2D0";
      dataLSB = "0x400B";
    }
    {
      name = "tv_right_numpad";
      description = "TV right numpad";
      bits = 12;
      data = "0xCD0";
      dataLSB = "0x300B";
    }
    {
      name = "tv_up_numpad";
      description = "TV up numpad";
      bits = 12;
      data = "0x2F0";
      dataLSB = "0x400F";
    }
    {
      name = "tv_down_numpad";
      description = "TV down numpad";
      bits = 12;
      data = "0xAF0";
      dataLSB = "0x500F";
    }
    {
      name = "tv_enter_numpad";
      description = "TV enter numpad";
      bits = 12;
      data = "0xA70";
      dataLSB = "0x500E";
    }
    {
      name = "tv_volume_up";
      description = "TV volume up";
      bits = 12;
      data = "0x490";
      dataLSB = "0x2009";
    }
    {
      name = "tv_volume_down";
      description = "TV volume down";
      bits = 12;
      data = "0xC90";
      dataLSB = "0x3009";
    }
    {
      name = "tv_volume_mute";
      description = "TV volume mute";
      bits = 12;
      data = "0x290";
      dataLSB = "0x4009";
    }
    {
      name = "tv_back";
      description = "TV back button";
      bits = 15;
      data = "0x62E9";
      dataLSB = "0x4697";
    }
    {
      name = "tv_next_episode";
      description = "TV next episode button";
      bits = 15;
      data = "0x5EE9";
      dataLSB = "0x7A97";
    }
    {
      name = "tv_prev_episode";
      description = "TV prev episode button";
      bits = 15;
      data = "0x1EE9";
      dataLSB = "0x7897";
    }
    {
      name = "tv_turn_off";
      description = "TV turn off button";
      bits = 12;
      data = "0xA90";
      dataLSB = "0x5009";
    }
  ];
  tvActionsScripts = builtins.listToAttrs (
    map (inst: {
      name = inst.name;
      value = {
        alias = "${inst.name}";
        description = "${inst.description}";
        sequence = [
          {
            service = "mqtt.publish";
            data = {
              topic = "cmnd/tasmota_ir/irsend";
              payload = builtins.toJSON {
                Protocol = "SONY";
                Bits = inst.bits;
                Data = inst.data;
                DataLSB = inst.dataLSB;
                Repeat = 0;
              };
              retain = false;
            };
          }
        ];
      };
    }) tvActionsAndCodes
  );

  turnOnOutdoorLights = {
    "turn_on_outdoor_light" = {
      alias = "Turn on outdoor lights";
      description = "Turn on outdoor lights if between 6pm and 6am";
      sequence = [
        {
          condition = "state";
          entity_id = "sun.sun";
          state = "below_horizon";
        }
        {
          action = "light.turn_on";
          target = {
            label_id = "outdoor";
          };
          data = {
            brightness_pct = 50;
            rgb_color = [
              255
              197
              122
            ];
            transition = 2;
          };
        }
      ];
    };
  };

  scripts = ballScripts // tvActionsScripts // turnOnOutdoorLights;

in
{

  services.home-assistant = {
    enable = true;
    configDir = "/var/lib/hass"; # Is default but override because we use it elsewhere.
    extraComponents = [
      "analytics"
      "google_translate"
      "met"
      "radio_browser"
      "shopping_list"
      "isal"
      "spotify"
      "mqtt"
      "zha"
      "tasmota"
      "unifi"
      "syslog"
      "command_line"
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = { };
      homeassistant = {
        name = "Home";
        latitude = "!secret latitude";
        longitude = "!secret longitude";
        radius = 20;
        unit_system = "metric";
        time_zone = "!secret timeZone";
      };
      script = scripts;
      automation = "!include automations.yaml";
      mqtt = [
        {
          binary_sensor = {
            name = "Phones Home MQTT";
            state_topic = "wap/presence";
            payload_on = "true";
            payload_off = "false";
          };
        }
      ];
    };
  };

  systemd.services.home-assistant.preStart = ''
    ${pkgs.coreutils}/bin/ln -sf /run/secrets/rendered/ha-secrets.yaml /var/lib/hass/secrets.yaml
  '';
  services.mosquitto = {
    enable = true;
    listeners = [
      {
        acl = [ "pattern readwrite #" ];
        users.iot = {
          passwordFile = "${config.sops.secrets.mosquitto_password.path}";
        };
      }
    ];
  };

  services.zigbee2mqtt = {
    enable = true;
    settings = {
      homeassistant.enabled = true;
      mqtt = {
        user = "iot";
        password = "!secret.yaml password";
        base_topic = "zigbee2mqtt";
        server = "mqtt://10.0.0.3:1883";
      };
      serial = {
        port = "tcp://10.0.0.5:6638";
        adapter = "ezsp";
        baudrate = 115200;
        disable_led = false;
      };
      permit_join = true;
      frontend = {
        enabled = true;
        port = ports.openFirewall.zigbee2MQTT;
      };
      advanced = {
        transmit_power = 20;
        channel = 11;
        pan_id = 34591;
        network_key = [
          186
          143
          91
          213
          11
          0
          186
          20
          175
          7
          86
          27
          97
          109
          106
          13
        ];

        ext_pan_id = [
          192
          90
          0
          132
          81
          255
          148
          202
        ];
      };
    };
  };
  systemd.services.zigbee2mqtt.preStart = ''
    ${pkgs.coreutils}/bin/ln -sf /run/secrets/rendered/zigbee2mqttsecrets.yaml /var/lib/zigbee2mqtt/secret.yaml
  '';

  systemd.services.get-connected-clients = {
    description = "Get clients connected to WAP";
    serviceConfig = {
      StateDirectory = "wap-presence";
      StateDirectoryMode = "0755"; # world-readable
      UMask = "0022"; # files written are 0644
    };
    script = ''
      source ${config.sops.templates."wap-env".path}
      cookie_path="/tmp/wap_cookie.txt"

      function login() {
          ${pkgs.curl}/bin/curl -sS 'http://10.0.0.242/' \
            -X POST \
            -H "$USER_AGENT" \
            -H 'Accept: application/json, text/javascript, */*; q=0.01' \
            -H 'Accept-Language: en-US,en;q=0.9' \
            -H 'Accept-Encoding: gzip, deflate' \
            -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
            -H 'X-Requested-With: XMLHttpRequest' \
            -H 'Origin: http://10.0.0.242' \
            -H 'DNT: 1' \
            -H 'Connection: keep-alive' \
            -H 'Referer: http://10.0.0.242/logout.html' \
            -H 'Priority: u=0' \
            --data-raw "$WAP_PASSWORD_PAYLOAD" -c "$cookie_path"
      }

      function fetch_clients_raw() {
          ${pkgs.curl}/bin/curl -sS 'http://10.0.0.242/data/status.client.user.json?operation=load&_=1779879188339' \
            -H "$USER_AGENT" \
            -H 'Accept: application/json, text/javascript, */*; q=0.01' \
            -H 'Accept-Language: en-US,en;q=0.9' \
            -H 'Accept-Encoding: gzip, deflate' \
            -H 'X-Requested-With: XMLHttpRequest' \
            -H 'DNT: 1' \
            -H 'Connection: keep-alive' \
            -H 'Referer: http://10.0.0.242/' \
            -b "$cookie_path"
      }

      function get_connected_devices() {
          local response
          response=$(fetch_clients_raw)

          local status
          status=$(echo "$response" | ${pkgs.jq}/bin/jq -r '.status // -1')

          if [ "$status" = "-1" ]; then
              login >/dev/null
              response=$(fetch_clients_raw)
          fi

          local match
          match=$(echo "$response" | ${pkgs.jq}/bin/jq --arg a "$WESTO_MAC" --arg b "$THANE_MAC" \
              '[.data[]? | select(.MAC | IN($a, $b))] | length')

          if [ "$match" -gt 0 ]; then
            ${pkgs.mosquitto}/bin/mosquitto_pub -h localhost -t "wap/presence" -m "true" -u iot -P "$MQTT_PASSWORD" -r 
          else
            ${pkgs.mosquitto}/bin/mosquitto_pub -h localhost -t "wap/presence" -m "false" -u iot -P "$MQTT_PASSWORD" -r 
          fi
      }

      get_connected_devices
    '';
  };

  systemd.timers.get-connected-clients = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5s";
      OnUnitActiveSec = "5s";
      Unit = "get-connected-clients.service";
    };
  };

}
