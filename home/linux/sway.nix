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

    # Sway doesn't export env but we can export it manually.
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

      output = {
        "*".scale = "1.5";
        "eDP-1".scale = "1";
      };

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
        { command = "${chromeApp gmail}"; }
        { command = "${chromeApp calendar}"; }
        {
          # The screen-sharing backend. Started here rather than on demand over
          # D-Bus: on a non-NixOS host neither the session bus nor systemd look
          # in the Nix profile, and as a child of sway it gets nixGL's drivers.
          command = "${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr --replace";
        }
      ];

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
      terminal = "kitty";
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
}
