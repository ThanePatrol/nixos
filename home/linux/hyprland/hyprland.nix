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

  mod = "Mod1"; # Alt

  # Hyprland's `movetoworkspace, +1`. Sway's own `workspace next` only cycles
  # through the workspaces that already exist.
  moveToRelativeWorkspace = pkgs.writeShellScript "move-to-relative-workspace" ''
    current=$(swaymsg -t get_workspaces | ${pkgs.jq}/bin/jq '.[] | select(.focused).num')
    target=$((current + $1))
    if [ "$target" -ge 1 ]; then
      swaymsg "move container to workspace number $target; workspace number $target"
    fi
  '';

  gmail = "fmgjjmmmlfnkbppncabfkddbjimcfncm";
  calendar = "kjbdgfilnfhdoflbpgamdcdgpehopbep";
  chromeApp = id: "/opt/google/chrome/google-chrome --profile-directory=Default --app-id=${id}";
  # A Chrome app window is `chrome-<id>-<profile>` on Wayland and `crx_<id>`
  # under XWayland.
  chromeAppCriteria = id: [
    { app_id = "^chrome-${id}-Default$"; }
    { instance = "^crx_${id}$"; }
  ];

in
{

  wayland.windowManager.sway = {

    enable = true;

    # Sway has no `env =`; this runs in the wrapper script before sway starts.
    extraSessionCommands = lib.optionalString isWork ''
      export SSH_AUTH_SOCK=/run/user/1415626/openssh_agent
    '';

    config = {
      modifier = mod;
      bars = [ ]; # Disable bars in preference of waybar.
      defaultWorkspace = "workspace number 1";

      window = {
        titlebar = false;
        border = 1;
      };
      floating = {
        titlebar = false;
        border = 1;
      };
      focus.followMouse = "yes";

      input."type:keyboard".xkb_options = "caps:escape";

      # Sway applies these in order, so the wildcard has to come before the
      # outputs that override it. Home Manager sorts them, which puts "*" first.
      output = {
        "*".scale = "1.5";
        "eDP-1".scale = "1";
      };

      # Unlike `[workspace N silent]` these apply to every window of the app,
      # not just the one opened at startup.
      assigns = {
        "3" = chromeAppCriteria gmail;
        "4" = chromeAppCriteria calendar;
      };
      bindswitches = {
        "lid:on" = {
          reload = true;
          locked = true;
          action = "output eDP-1 disable";
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
        { command = "rm -f $HOME/.cache/cliphist/db && wl-paste --type text --watch cliphist store"; }
        {
          # `[workspace N silent]`: sway opens a window on the workspace its
          # command was launched from, so launch from there and come back.
          command = "swaymsg 'workspace number 2; exec google-chrome; workspace number 1; exec kitty'";
        }
        { command = chromeApp gmail; }
        { command = chromeApp calendar; }
        {
          # The screen-sharing backend. Started here rather than on demand over
          # D-Bus: on a non-NixOS host neither the session bus nor systemd look
          # in the Nix profile, and as a child of sway it gets nixGL's drivers.
          command = "${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr --replace";
        }
      ];

      # Just the Hyprland bindings. Home Manager's default sway bindings are
      # left out: on Alt they would shadow Alt+f, Alt+b, Alt+d and friends.
      keybindings = {
        "${mod}+q" = "kill";
        "Mod4+space" =
          "exec XDG_DATA_DIRS=/home/hmandalidis/.nix-profile/share:/usr/share:/home/hmandalidis/.local/share wofi --show drun";
        "${mod}+h" = "focus left";
        "${mod}+l" = "focus right";
        "${mod}+k" = "focus up";
        "${mod}+j" = "focus down";
        # Copy color and send to clipboard
        "${mod}+p" = "exec hyprpicker -a";

        #workspace memes
        "${mod}+Shift+k" = "exec ${moveToRelativeWorkspace} +1";
        "${mod}+Shift+j" = "exec ${moveToRelativeWorkspace} -1";
        # move windows around
        "${mod}+Left" = "move left";
        "${mod}+Right" = "move right";
        "${mod}+Up" = "move up";
        "${mod}+Down" = "move down";

        "Mod4+Shift+4" =
          ''exec grim -g "$(slurp)" - | tee "$(xdg-user-dir PICTURES)/screenshot_$(date '+%Y-%m-%d-%H%M%S.png')" | wl-copy'';
        "${mod}+Control+q" = "exec ${lockScreen}/bin/lock-screen";

        # XF86 options https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h
        # playerctl options https://github.com/altdesktop/playerctl
        # Sway repeats a binding for as long as the key is held, like `binde`.
        "${mod}+XF86AudioLowerVolume" = "exec playerctl volume 0.1-"; # application level volume controls
        "${mod}+XF86AudioRaiseVolume" = "exec playerctl volume 0.1+"; # ^^
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"; # system level volume control
        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"; # system level volume control
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86MonBrightnessUp" = "exec brightnessctl set +10%";
        "XF86MonBrightnessDown" = "exec brightnessctl set 10%-";

        # Media control
        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioPrev" = "exec playerctl previous";
        "XF86AudioNext" = "exec playerctl next";
      }
      // lib.listToAttrs (
        lib.concatMap (n: [
          (lib.nameValuePair "${mod}+${n}" "workspace number ${n}")
          (lib.nameValuePair "${mod}+Shift+${n}" "move container to workspace number ${n}; workspace number ${n}")
        ]) (map toString (lib.range 1 9))
      );
      terminal = "kitty"; # Only read by Home Manager's default bindings.
    };
  };

  # Screen sharing goes through xdg-desktop-portal-wlr, which sway starts above.
  # Hyprland's module brought its own portal.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    config.sway = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
      "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
    };
  };

  # xdg.portal only adds the backend's definition to the Nix profile, which a
  # non-NixOS host's xdg-desktop-portal doesn't search.
  xdg.dataFile."xdg-desktop-portal/portals/wlr.portal".source =
    "${pkgs.xdg-desktop-portal-wlr}/share/xdg-desktop-portal/portals/wlr.portal";

  # The picker for what to share. Only a dmenu-style one can offer windows as
  # well as outputs. Without a cache file wofi keeps the entries in the order
  # given and doesn't save the titles of shared windows under ~/.cache.
  xdg.configFile."xdg-desktop-portal-wlr/config".text = lib.generators.toINI { } {
    screencast = {
      chooser_type = "dmenu";
      chooser_cmd = "${pkgs.wofi}/bin/wofi --dmenu --prompt='Select a source to share:' --width=50% --cache-file=/dev/null";
    };
  };

  # Disabled now that sway has taken over. Kept so the two can be compared, and
  # swapped back, while the port is being tried out.
  wayland.windowManager.hyprland = {
    enable = false;
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
