{config, lib, pkgs, ...}:
{
  xdg = {
    mime.enable = true;

    mimeApps = {
      enable = true;
      defaultApplications = {
         "x-scheme-handler/http" = "firefox.desktop";
         "x-scheme-handler/https" = "firefox.desktop";
         "x-scheme-handler/chrome" = "firefox.desktop";
         "text/html" = "firefox.desktop";
         "application/x-extension-htm" = "firefox.desktop";
         "application/x-extension-html" = "firefox.desktop";
         "application/x-extension-shtml" = "firefox.desktop";
         "application/xhtml+xml" = "firefox.desktop";
         "application/x-extension-xhtml" = "firefox.desktop";
         "application/x-extension-xht" = "firefox.desktop";
         "x-content/audio-player" = "vlc.desktop";
         "x-scheme-handler/magnet" = "transmission-gtk.desktop";
         "application/pdf" = "zathura.desktop";
       };
     };
   };
}
