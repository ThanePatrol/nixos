{config, lib, pkgs, ...}:
{
    xdg.desktopEntries = {
#        google-chrome-stable = {
#            name = "Google Chrome";
#            exec = "google-chrome-stable --enable-features=UseOzonePlatform --ozone-platform=wayland %U";
#            terminal = false;
#            categories = ["Network" "WebBrowser"];
#            mimeType = ["text/html" "text/xml"];
#        };
#        discord = {
#            name = "discord";
#            exec = "discord --enable-features=UseOzonePlatform --ozone-platform=wayland %U";
#            terminal = false;
#            categories = ["Social"];
#        };

        bitwarden = {
            name = "Bitwarden";
            exec = "bitwarden --enable-features=UseOzonePlatform --ozone-platform=wayland";
            terminal = false;
            categories = ["Applications"];
        };

    };
}
