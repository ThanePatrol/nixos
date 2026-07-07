{
  isWork,
  pkgs,
  lib,
  ...
}:

let
  lockScreen = pkgs.writeShellScriptBin "lock-screen" ''
    rm /tmp/lockscreen.png || true
    screenshot-background
    swaylock -i /tmp/lockscreen.png
  '';

  clamshell = pkgs.writeShellScriptBin "clamshell" ''
    if swaymsg -t get_outputs | jq -r '.[].name' | rg -q '^DP-[0-9]+'; then
      if [[ $1 == "open" ]]; then
        swaymsg output eDP-1 enable
      else
        swaymsg output eDP-1 disable
      fi
    fi
  '';

  keepInClamshell = pkgs.writeShellScriptBin "stay-clamshell" ''
    if swaymsg -t get_outputs | jq -r '.[].name' | rg -q '^DP-[0-9]+'; then
      swaymsg output eDP-1 disable
    else
      swaymsg output eDP-1 enable
    fi
  '';

  mod = "Mod1";

in
{
  home.sessionVariables = lib.optionalAttrs isWork {
    SSH_AUTH_SOCK = "/run/user/1415626/openssh_agent";
  };

  wayland.windowManager.sway = {
    enable = true;
    config = {
      modifier = mod;
      bars = [ ]; # Disable bars in preference of waybar.
      assigns = {
        "1" = [ { class = "^kitty$"; } ];
        "2" = [ { class = "^Google-chrome$"; } ];
      };
      bindswitches = {
        "lid:on" = {
          reload = true;
          locked = true;
          action = "exec ${clamshell}/bin/clamshell closed";
        };
        "lid:off" = {
          reload = true;
          locked = true;
          action = "exec ${clamshell}/bin/clamshell open";
        };
      };
      startup = [
        { command = "systemctl --user restart waybar"; always = true; }
        { command = "dunst"; }
        { command = "rm -f $HOME/.cache/cliphist/db && wl-paste --type text --watch cliphist store"; }
        { command = "${keepInClamshell}/bin/stay-clamshell"; }
        { command = "kitty"; }
        { command = "google-chrome"; }
        { command = "/opt/google/chrome/google-chrome --profile-directory=Default --app-id=fmgjjmmmlfnkbppncabfkddbjimcfncm"; }
        { command = "/opt/google/chrome/google-chrome --profile-directory=Default --app-id=kjbdgfilnfhdoflbpgamdcdgpehopbep"; }
      ];
      output = {
        "eDP-1" = {
          scale = "1";
        };
        "*" = {
          scale = "1.5";
        };
      };
      keybindings = lib.mkOptionDefault {
        "$mod+q" = "kill";
        "Mod4+space" = "exec XDG_DATA_DIRS=/home/hmandalidis/.nix-profile/share:/usr/share:/home/hmandalidis/.local/share wofi --show drun";

        "$mod+h" = "focus left";
        "$mod+l" = "focus right";
        "$mod+k" = "focus up";
        "$mod+j" = "focus down";

        "$mod+Left" = "move left";
        "$mod+Right" = "move right";
        "$mod+Up" = "move up";
        "$mod+Down" = "move down";

        "$mod+p" = "exec hyprpicker -a";
        "$mod+Ctrl+q" = "exec screenshot-background; ${lockScreen}/bin/lock-screen";
        "Mod4+Shift+4" = "exec grim -g \"$(slurp)\" - | tee \"$(xdg-user-dir PICTURES)/screenshot_$(date '+%Y-%m-%d-%H%M%S.png')\" | wl-copy";

        "Shift+$mod+k" = "move container to workspace next; workspace next";
        "Shift+$mod+j" = "move container to workspace prev; workspace prev";

        "$mod+1" = "workspace number 1";
        "$mod+2" = "workspace number 2";
        "$mod+3" = "workspace number 3";
        "$mod+4" = "workspace number 4";
        "$mod+5" = "workspace number 5";
        "$mod+6" = "workspace number 6";
        "$mod+7" = "workspace number 7";
        "$mod+8" = "workspace number 8";
        "$mod+9" = "workspace number 9";

        "Shift+$mod+1" = "move container to workspace number 1; workspace number 1";
        "Shift+$mod+2" = "move container to workspace number 2; workspace number 2";
        "Shift+$mod+3" = "move container to workspace number 3; workspace number 3";
        "Shift+$mod+4" = "move container to workspace number 4; workspace number 4";
        "Shift+$mod+5" = "move container to workspace number 5; workspace number 5";
        "Shift+$mod+6" = "move container to workspace number 6; workspace number 6";
        "Shift+$mod+7" = "move container to workspace number 7; workspace number 7";
        "Shift+$mod+8" = "move container to workspace number 8; workspace number 8";
        "Shift+$mod+9" = "move container to workspace number 9; workspace number 9";

        "$mod+XF86AudioLowerVolume" = "exec playerctl volume 0.1-";
        "$mod+XF86AudioRaiseVolume" = "exec playerctl volume 0.1+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86MonBrightnessUp" = "exec brightnessctl set +10%";
        "XF86MonBrightnessDown" = "exec brightnessctl set 10%-";

        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioPrev" = "exec playerctl previous";
        "XF86AudioNext" = "exec playerctl next";
      };
      terminal = "kitty";
    };
  };

  wayland.windowManager.hyprland = {
    enable = false;
  };
}
