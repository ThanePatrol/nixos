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
    hyprctl monitors -j | jq -r '.[].name' | rg -q '^DP-[0-9]+'
    if [[ $? ]]; then
      if [[ $1 == "open" ]]; then
        hyprctl keyword monitor "eDP-1,preferred,auto,1"
      else
        hyprctl keyword monitor "eDP-1,disable"
      fi
    fi
  '';

  keepInClamshell = pkgs.writeShellScriptBin "stay-clamshell" ''
    hyprctl monitors -j | jq -r '.[].name' | rg -q '^DP-[0-9]+'
    not_connected=$?
      if [[ $not_connected ]]; then
        hyprctl keyword monitor "eDP-1,preferred,auto,1"
      else
        hyprctl keyword monitor "eDP-1,disable"
      fi
  '';

  mod = "Mod1";

in
{

  wayland.windowManager.sway = {

    enable = false;
    config = {
      bars = [ ]; # Disable bars in preference of waybar.
      assigns = { }; # TODO: For assignig windows to certain workspaces. See https://nix-community.github.io/home-manager/options/home-manager/wayland.html#opt-wayland.windowManager.sway.config.assigns
      bindswitches = {
        "lid:on" = {
          reload = true;
          locked = true;
          action = "output eDP-1 disable"; # TODO: equivalent clamshell, not just plain laptop display.
        };
        "lid:off" = {
          reload = true;
          locked = true;
          action = "output eDP-1 enable";
        };
      };
      startup = [
        {
          command = "systemctl --user restart waybar";
          always = true;
        }
        { command = "dunst"; }
        { command = "kitty"; }
      ];

      keybindings = {

        "$mod+q" = "kill";

      };
      # // builtins.listToAttrs (
      #   lib.forEach (lib.range 1 9)
      # );
      terminal = "kitty";
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    systemd = {
      enable = true;
      variables = [ "-all" ];
    };
    configType = "hyprlang";
    xwayland.enable = true;

    settings = {
      "$mod" = "alt";

      animations = {
        enabled = false;
      };
            general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 1;
      };

      exec-once = [
        "dunst" # notifications
        "rm $HOME/.cache/cliphist/db"
        "waybar &"
        "wl-paste --type text --watch cliphist store"
        "[workspace 1 silent] kitty"
        "[workspace 2 silent] google-chrome"
        "[workspace 3 silent] /opt/google/chrome/google-chrome --profile-directory=Default --app-id=fmgjjmmmlfnkbppncabfkddbjimcfncm" # Gmail
        "[workspace 4 silent] /opt/google/chrome/google-chrome --profile-directory=Default --app-id=kjbdgfilnfhdoflbpgamdcdgpehopbep" # Calendar

        # #set up clipman for copy and paste memes
        # "wl-paste -t text --watch clipman store --no-persist"

      ];

      exec = [
        "${keepInClamshell}/bin/stay-clamshell"
      ];

      bind = [
        "$mod, Q, killactive"
        "$SUPER, SPACE, exec, XDG_DATA_DIRS=/home/hmandalidis/.nix-profile/share:/usr/share:/home/hmandalidis/.local/share wofi --show drun"
        "$mod,H,movefocus,l"
        "$mod,L,movefocus,r"
        "$mod,K,movefocus,u"
        "$mod,J,movefocus,d"
        # Copy color and send to clipboard
        "$mod, p, exec, hyprpicker -a"

        #workspace memes
        "SHIFT + ALT, K, movetoworkspace,+1"
        "SHIFT + ALT, J, movetoworkspace,-1"
        "SHIFT + ALT, 1, movetoworkspace,1"
        "SHIFT + ALT, 2, movetoworkspace,2"
        "SHIFT + ALT, 3, movetoworkspace,3"
        "SHIFT + ALT, 4, movetoworkspace,4"
        "SHIFT + ALT, 5, movetoworkspace,5"
        "SHIFT + ALT, 6, movetoworkspace,6"
        "SHIFT + ALT, 7, movetoworkspace,7"
        "SHIFT + ALT, 8, movetoworkspace,8"
        "SHIFT + ALT, 9, movetoworkspace,9"
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        # move workspaces around
        "$mod, left, movewindow, l"
        "$mod, right, movewindow, r"
        "$mod, up, movewindow, u"
        "$mod, down, movewindow, d"
        ''SUPER + SHIFT,4,exec,grim -g "$(slurp)" - | tee "$(xdg-user-dir PICTURES)/screenshot_$(date '+%Y-%m-%d-%H%M%S.png')" | wl-copy ''

        "$mod + CONTROL, Q, exec, screenshot-background; ${lockScreen}/bin/lock-screen"
      ];
      bindl = [
        # Lid open
        ",switch:off:Lid Switch,exec,${clamshell}/bin/clamshell open"
        # Lid closed
        ",switch:on:Lid Switch,exec,${clamshell}/bin/clamshell closed"
      ];
      # XF86 options https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h
      # playerctl options https://github.com/altdesktop/playerctl
      # binde allows for repeat button presses
      binde = [
        "$mod,XF86AudioLowerVolume,exec,playerctl volume 0.1-" # application level volume controls
        "$mod,XF86AudioRaiseVolume,exec,playerctl volume 0.1+" # ^^
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" # system level volume control
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+" # system level volume control
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86MonBrightnessUp, exec, brightnessctl set +10%"
        ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"

        # Media control
        ",XF86AudioPlay,exec,playerctl play-pause"
        ",XF86AudioPrev,exec,playerctl previous"
        ",XF86AudioNext,exec,playerctl next"
      ];

      env = (
        if isWork then
          [
            "SSH_AUTH_SOCK,/run/user/1415626/openssh_agent"
          ]
        else
          [ ]
      );

      # TODO: Set workspace rules for gmail and calendar
      # windowrule = [
      #   "tile, title:CodeBrowser"
      #   "tile, title:Ghidra:*"
      #   "workspace 9, class:org.kde.kdeconnect.app" # want it available but not somewhere i use all the time
      # ];
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        always_follow_on_dnd = true;
      };
      input = {
        follow_mouse = 1;
        kb_options = "caps:escape";
      };

    };
    extraConfig = ''
      monitor=eDP-1,preferred,auto,1
      monitor=,preferred,auto,1.5
    '';

  };
}
