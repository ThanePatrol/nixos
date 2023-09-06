{ config, pkgs, ... }:

# defines environment vars useful for wayland
# https://github.com/sioodmy/dotfiles/blob/main/modules/wayland/default.nix
{
    home.sessionVariables = {
            NIXOS_OZONE_WL = "1";
            _JAVA_AWT_WM_NONREPARENTING = "1";
            DISABLE_QT5_COMPAT = "0";
            GDK_BACKEND = "wayland,x11";
            ANKI_WAYLAND = "1";
            QT_AUTO_SCREEN_SCALE_FACTOR = "1";
            QT_QPA_PLATFORM = "wayland";
            QT_WAYLAND_DISABLE_WINDOW_DECORATION = "1";
            MOZ_ENABLE_WAYLAND = "1";
            WLR_BACKEND = "vulkan";
            WLR_RENDERER = "vulkan";
            XDG_SESSION_TYPE = "wayland";

    };
}
