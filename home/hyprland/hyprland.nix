{ config, lib, pkgs, ... }:

let 
    pointer = config.home.pointerCursor;
in {
    
    
    wayland.windowManager.hyprland = {
        enable = true;
        systemdIntegration = true;
        xwayland.enable = true;

#        plugins = [

#        ];

        settings = {
            "$mod" = "SUPER";
            
            exec-once = [
               
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
                "$mod, V, togglefloating"


                #vim keybindings for motion
                "$mod,H,movefocus,l"
                "$mod,L,movefocus,r"
                "$mod,K,movefocus,u"
                "$mod,J,movefocus,d"




            ];
        };


    };


}
