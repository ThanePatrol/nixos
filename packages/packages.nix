{ pkgs, ... }:

let
  wrappedBitwarden = pkgs.writeShellScriptBin "bitwarden" ''
    exec ${pkgs.bitwarden}/bin/bitwarden --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';

  #wrappedAuthy = pkgs.writeShellScriptBin "authy" ''
  #  exec ${pkgs.authy}/bin/authy --enable-features=UseOzonePlatform --ozone-platform=wayland
  #'';
  wrappedBrave = pkgs.writeShellScriptBin "brave" ''
    exec ${pkgs.brave}/bin/brave --enable-features=UseOzonePlatform --ozone-platform=wayland
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
  wrappedZoom= pkgs.writeShellScriptBin "zoom-us" ''
    exec ${pkgs.zoom-us}/bin/zoom-us --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';
in
{
  # a less boilerplate heavy way of specifying pkgs
  environment.systemPackages = with pkgs; [
    wrappedBitwarden
  #  wrappedBrave
    (symlinkJoin {
      inherit (brave) name;
      paths = [ brave ];
      buildInputs = [makeWrapper];
      postBuild = ''wrapProgram $out/bin/brave --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland --ozone-platform-hint=auto"'';
    })
    wrappedSpotify
    wrappedChrome
    wrappedMailspring
    wrappedSignal
    wrappedZoom
    alacritty
    authy 
    anki
    bat
    bear # compilation database for clang tooling
    bfg-repo-cleaner
    biber
    binutils
    binutils_nogold
    bitwarden 
    bluez
  #  brave #todo-chromium wrap
    btop
    chafa
    calibre
    cargo-watch
    chromedriver
    llvmPackages_16.clangUseLLVM
    llvmPackages_rocm.clang
    llvmPackages_rocm.llvm
    cliphist
    colord
    cmake
    clang
    cups
    direnv
    discord # chromium wrap
    docker
    docker-compose
    dua
    ethtool
    eza # modern ls
    dunst # notification daemon
    firefox
    ffmpeg-full
    flatpak
    gcc
    git
    go
    google-chrome #wrap
    graphviz
    grim #screenshot
    gnumake
    gnome.gnome-calendar 
    gnome.nautilus #file viewer
    gnome.sushi #file preview
    gzip
    home-manager
    lazygit 
    libclang
    libinput
    libvirt
    llvm_16
    imhex
    jdk
    jetbrains.idea-ultimate
    kmod
    mailspring #wrap
    mold
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
    pkg-config
    prismlauncher
    qalculate-qt
    qemu
    qt6.qtwayland
    rclone
    ripgrep
    rmlint
    rofi
    rsync
    rustup
    rust-analyzer
    signal-desktop #wrap
    sqlite
    spice-vdagent
    spotify #wrap
    slurp
    tectonic
    tor
    transmission-gtk
    typescript
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
