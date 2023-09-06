{lib, pkgs, config, ...}:

pkgs.symlinkJoin {
    name = "bitwarden-w";
    paths = [ pkgs.bitwarden-w ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
        wrapProgram $out/bin/bitwarden --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"
    '';
}
