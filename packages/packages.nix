{ pkgs, ... }:

let
  wrappedBitwarden = pkgs.writeShellScriptBin "bitwarden" ''
    exec ${pkgs.bitwarden}/bin/bitwarden --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';

  wrappedAuthy = pkgs.writeShellScriptBin "authy" ''
    exec ${pkgs.authy}/bin/authy --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';
  wrappedBrave = pkgs.writeShellScriptBin "brave" ''
    exec ${pkgs.brave}/bin/brave --enable-features=UseOzonePlatform --ozone-platform=wayland -use-gl=egl
  '';

  wrappedSpotify = pkgs.writeShellScriptBin "spotify" ''
    exec ${pkgs.spotify}/bin/spotify --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';
  
  wrappedChrome = pkgs.writeShellScriptBin "google-chrome" ''
    exec ${pkgs.google-chrome}/bin/google-chrome-stable --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';

  wrappedMailspring = pkgs.writeShellScriptBin "mailspring" ''
    exec ${pkgs.mailspring}/bin/mailspring --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';
  wrappedSignal = pkgs.writeShellScriptBin "signal-desktop" ''
    exec ${pkgs.signal-desktop}/bin/signal-desktop --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';
in
{
  # a less boilerplate heavy way of specifying pkgs
  environment.systemPackages = with pkgs; [
    wrappedAuthy
    wrappedBitwarden
    (symlinkJoin {
      inherit (brave) name;
      paths = [ brave ];
      buildInputs = [makeWrapper];
      postBuild = ''wrapProgram $out/bin/brave --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland"'';
    })
    wrappedSpotify
    wrappedChrome
    wrappedMailspring
    wrappedSignal
    alacritty
    authy 
    anki
    bat
    biber
    bitwarden 
    bluez
#    brave #todo-chromium wrap
    btop
    chafa
    calibre
    chromedriver
    cliphist
    colord
    cups
    direnv
    discord # chromium wrap
    docker
    docker-compose
    dua
    ethtool
    exa
    firefox
    ffmpeg-full
    flatpak
    gcc
    git
    go
    google-chrome #wrap
    graphviz
    grim
    gzip
    home-manager
    libinput
    libvirt
    imhex
    kmod
    mailspring #wrap
    mullvad-vpn #wrap
    neofetch
    nettools
    nfs-utils
    obsidian #wrap
    oh-my-zsh
    openrgb
    p7zip
    pandoc
    parted
    pciutils
    playerctl
    prismlauncher
    qalculate-qt
    qemu
#    qtwayland
    rclone
    ripgrep
    rmlint
    rofi
    rsync
    rustup
    signal-desktop #wrap
    sqlite
    spice-vdagent
    spotify #wrap
    slurp
    tectonic
    tor
    transmission-gtk
    unzip
    vlc
    vim
    virt-manager
    wl-clipboard
    xdg-desktop-portal-hyprland
    zathura
    zotero
    zoom-us #wrap
    zip
    zsh
  ];
}
