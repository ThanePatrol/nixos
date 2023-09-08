{ config, lib, pkgs, ... }:

let 
    pointer = config.home.pointerCursor;
    mkService = lib.recursiveUpdate {
        Unit.PartOf = ["graphical-session.target"];
        Unit.After = ["graphical-session.target"];
        Install.WantedBy = ["graphical-session.target"];
    };
in {

    #home.packages = with pkgs;

    #with inputs.xdg-portal-hyprland.packages.${pkgs.system};
    #[
    #    xdg-desktop-portal-hyprland
    #    wl-clip-persist
    #    wl-clipboard
    #    cliphist
    #];
    
    
    wayland.windowManager.hyprland = {
        enable = true;
        systemdIntegration = true;
        xwayland.enable = false;

        settings = {
            "$mod" = "SUPER";
            
            exec-once = [
                "dunst" # notifications
                "waybar" # status bar
                "wl-paste --type text --watch cliphist store"

                #"run-as-service waybar"
            ];

            animations = {
                enabled = true; # we want animations, half the reason why we're on Hyprland innit
            
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
            };

            general = {
                gaps_in = 6;
                gaps_out = 11;
            };

            decoration = {
                rounding = 7;
                multisample_edges = true;

                blur = {
                    enabled = true;
                    size = 4;
                    passes = 1;
                };

                drop_shadow = "yes";
            };

            bind = [
                "$mod, Q, exec, alacritty"
                "$mod, C, killactive"
                "$mod, M, exit"
                "$mod, R, exec, wofi --show drun"

                #vim keybindings for motion
                "$mod,H,movefocus,l"
                "$mod,L,movefocus,r"
                "$mod,K,movefocus,u"
                "$mod,J,movefocus,d"

                "SUPER_SHIFT, H, movetoworkspace,+1"
                "SUPER_SHIFT, L, movetoworkspace,-1"
                #todo - figure out why screenshot isn't working
                '',Print,exec,grim -g "$(slurp)"''
                #clipboard history
#                "$mod, V, exec cliphist list | wofi --dmenu | cliphist decode | wl-copy" 

            ];
            # XF86 options https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms
            # playerctl options https://github.com/altdesktop/playerctl
            bindl = [
                ",XF86AudioPlay,exec,playerctl play-pause"
                ",XF86AudioPrev,exec,playerctl previous"
                ",XF86AudioNext,exec,playerctl next"
            ];
            binde = [
                ",XF86AudioLowerVolume,exec,playerctl volume 0.1-"
                ",XF86AudioRaiseVolume,exec,playerctl volume 0.1+"
            ];
        };


    };
    systemd.user.services = {
        cliphist = mkService {
            Unit.Description = "Clipboard history";
            Service = {
                ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${lib.getBin pkgs.cliphist}/cliphist store";
                Restart = "always";
            };
        };
    };
}
