{ config, lib, pkgs, ... }: {
  xdg = {
    
    userDirs = {
      enable = true;
      # note that because we don't actually create the directories we need to create Doenloads and Pictures directory
      # ourselves
      # TODO make this automatic
      createDirectories = false;
    };


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
        "x-scheme-handler/mailto" = "thunderbird.desktop";
        "inode/directory" = "nemo.desktop";
        "application/pdf" = "zathura.desktop";
      };
    };
  };
}
