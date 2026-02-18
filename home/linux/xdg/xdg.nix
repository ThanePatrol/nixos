{ ... }:

let
  gmailPWA = "chrome-kjbdgfilnfhdoflbpgamdcdgpehopbep-Default.desktop";
  gcalPWA = "chrome-kjbdgfilnfhdoflbpgamdcdgpehopbep-Default.desktop";
in
{
  xdg = {
    mime.enable = true;

    # paths added to XDG_DATA_DIRS
    systemDirs.data = [
      "/home/hmandalidis/.nix-profile/share/applications"
      "/usr/share/applications"
    ];

    mimeApps = {
      enable = true;

      defaultApplications = {
        "text/html" = "google-chrome.desktop";
        "x-scheme-handler/http" = "google-chrome.desktop";
        "x-scheme-handler/https" = "google-chrome.desktop";
        "x-scheme-handler/chrome" = "google-chrome.desktop";
        "x-scheme-handler/unknown" = "google-chrome.desktop";
        "x-content/audio-player" = "vlc.desktop";
        "x-scheme-handler/magnet" = "transmission-gtk.desktop";
        "inode/directory" = "nemo.desktop";
        "application/pdf" = "google-chrome.desktop";
        "x-scheme-handler/webcal" = gcalPWA;
        "text/calendar" = gcalPWA;
        "application/x-extension-ics" = gcalPWA;
        "x-scheme-handler/webcals" = gcalPWA;
        "x-scheme-handler/mailto" = gmailPWA;
      };
    };
  };
}
