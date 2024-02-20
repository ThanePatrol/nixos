{ config, lib, pkgs, ... }:

let
  pointer = config.home.pointerCursor;
  mkService = lib.recursiveUpdate {
    Unit.PartOf = [ "graphical-session.target" ];
    Unit.After = [ "graphical-session.target" ];
    Install.WantedBy = [ "graphical-session.target" ];
  };
in {

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;

    settings = {
      "$mod" = "alt";

      exec-once = [
        # set cursor
        "hyprctl setcursor ${pointer.name} ${toString pointer.size}"
        "dunst" # notifications
        "eww open example"
        "rm $HOME/.cache/cliphist/db"
        "wl-paste --type text --watch cliphist store"
        "wpaperd"
        "~/nixos/home/hyprland/tmux_init.sh"
        # TODO make this work properly
        "udiskie &" # mount usbs in the background
        "kdeconnect-app"
        "[workspace 1 silent] wezterm" 
        "[workspace 2 silent] firefox"
        "[workspace 3 silent] bitwarden"
        "[workspace 3 silent] thunderbird"

        #set up clipman for copy and paste memes
        "wl-paste -t text --watch clipman store --no-persist"

      ];

      animations = {
        enabled = true;

        bezier = [
          "smoothOut, 0.36, 0, 0.66, -0.56"
          "smoothIn, 0.25, 1, 0.5, 1"
          "overshot, 0.4,0.8,0.2,1.2"
        ];

        animation = [
          "windows, 1, 4, overshot, slide"
          "windowsOut, 1, 4, smoothOut, slide"
          "border,1,10,default"

          "fade, 1, 10, smoothIn"
          "fadeDim, 1, 10, smoothIn"
          "workspaces,1,4,overshot,slidevert"
        ];
      };

      input = {
        follow_mouse = 1;
        kb_options = "caps:escape";

      };

      general = {
        gaps_in = 6;
        gaps_out = 11;
      };

      decoration = {
        rounding = 7;

        blur = {
          enabled = true;
          size = 4;
          passes = 1;
        };

        drop_shadow = "yes";
      };

      bind = [
        "$mod, Q, killactive" 
        "$mod, M, exit"
        "$SUPER, SPACE, exec, wofi --show drun" # make it more similar to mac os - shock horror
        "$mod, S, togglesplit, " # split workspace
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

        # locking workspace
        "CTRL + SUPER, Q, exec, rm /tmp/lockscreen.png && screenshot-background && swaylock -i /tmp/lockscreen.png"

        # clipboard
        # TODO - figure out why this isn't working
        # want SUPER + C and SUPER + V for copy and paste globally
        "$SUPER, C, exec, wtype -M ctrl c -m ctrl" # to make this like mac os with CMD + C
        "$SUPER, H, exec, clipman pick -t wofi | wl-copy" # show clipboard history
        #"$SUPER, V, exec, clipman pick -t wofi --err-on-no-selection && wtype -M ctrl -M shift v"

        #Move cursor to start or end of line like Mac os
        "SUPER, left, exec, wtype -P Home"
        "SUPER, right, exec, wtype -P End"
        "SUPER + SHIFT, left, exec, wtype -M shift -P Home"
        "SUPER + SHIFT, right, exec, wtype -M shift -P End"
      ];
      # XF86 options https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h
      # playerctl options https://github.com/altdesktop/playerctl
      bindl = [
        ",XF86AudioPlay,exec,playerctl play-pause"
        ",XF86AudioPrev,exec,playerctl previous"
        ",XF86AudioNext,exec,playerctl next"

      ];
      # binde allows for repeat button presses
      binde = [
        "$mod,XF86AudioLowerVolume,exec,playerctl volume 0.1-" # application level volume controls
        "$mod,XF86AudioRaiseVolume,exec,playerctl volume 0.1+" # ^^
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" # system level volume control
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+" # system level volume control
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];
      bindm = [
        #move and resize windows
        #"$mod, up, movewindow"
        #"$mod, down, resizewindow"
      ];

      windowrulev2 = [
        "tile, title:CodeBrowser"
        "tile, title:Ghidra:*"
        "workspace 9, class:org.kde.kdeconnect.app" # want it available but not somewhere i use all the time
      ];
      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

    };
    extraConfig = ''
      monitor=DP-2,3840x2160@60,0x0,1
    '';

  };
  systemd.user.services = {
    cliphist = mkService {
      Unit.Description = "Clipboard history";
      Service = {
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${
            lib.getBin pkgs.cliphist
          }/cliphist store";
        Restart = "always";
      };
    };
  };
}
