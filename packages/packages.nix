{ pkgs, ... }:

let
  wrappedBitwarden = pkgs.writeShellScriptBin "bitwarden" ''
    exec ${pkgs.bitwarden}/bin/bitwarden --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';

  wrappedSpotify = pkgs.writeShellScriptBin "spotify" ''
    exec ${pkgs.spotify}/bin/spotify --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';
  
  wrappedChrome = pkgs.writeShellScriptBin "google-chrome" ''
    exec ${pkgs.google-chrome}/bin/google-chrome-stable --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';
#
#  wrappedMailspring = pkgs.writeShellScriptBin "mailspring" ''
#    exec ${pkgs.mailspring}/bin/mailspring --enable-features=UseOzonePlatform --ozone-platform=wayland
#  '';
  wrappedZoom= pkgs.writeShellScriptBin "zoom-us" ''
    exec ${pkgs.zoom-us}/bin/zoom-us --enable-features=UseOzonePlatform --ozone-platform=wayland
    '';
  
  #wrappedGhidra = pkgs.writeShellScriptBin "ghidra" ''
  #    export _JAVA_AWT_WM_NONREPARENTING=1
  #    exec ${pkgs.ghidra-bin}/bin/ghidra
  #'';
      
in
{
  # a less boilerplate heavy way of specifying pkgs
  environment.systemPackages = with pkgs; [
    wrappedBitwarden
    (symlinkJoin {
      inherit (brave) name;
      paths = [ brave ];
      buildInputs = [makeWrapper];
      postBuild = ''wrapProgram $out/bin/brave --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland --ozone-platform-hint=auto"'';
    })
    wrappedSpotify
    wrappedChrome
#    wrappedMailspring
    wrappedZoom
    
    #wrappedGhidra
    alacritty
    authy 
    anki
    bat
    bear # compilation database for clang tooling
    bfg-repo-cleaner
    biber
    bison
    binutils
    binutils_nogold
    bitwarden-cli
    bitwarden 
    bluez # bluetooth memes
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
    dnsmasq
    direnv
    discord # chromium wrap
    docker
    docker-compose
    dua
    ethtool
    eza # modern ls
    dunst # notification daemon
    flex # lexical analysis
    firefox
    ffmpeg-full
    flatpak
    gcc
    geckodriver # webdriver automation
    git
    go
    google-chrome #wrap
    graphviz
    grim #screenshot
    gnumake
    ghidra-bin
    gnome.gnome-calendar 
    gnome.nautilus #file viewer
    gnome.sushi #file preview
    gnome.libgnome-keyring #secret manager
    gnome.gnome-keyring
    gzip
    home-manager
    lazygit 
    libclang
    libguestfs
    libinput
    libvirt
    libsecret # for storing password
    linuxHeaders
    llvm_16
    imhex
    jdk
    jetbrains.idea-ultimate
    kmod
#    mailspring #wrap
    mold # fast linker for llvm
    minicom # for serial connections
    mullvad-vpn #wrap
    neofetch
    nettools #cmd line utils like ethtool
    nfs-utils
    obsidian #wrap
    oh-my-zsh
    openrgb
    OVMFFull # UEFI firmware for QEMU
    p7zip #7zip terminal
    pandoc # document conversion
    parted # disk partition tool
    pass-secret-service #dbus api for libsecret
    pciutils # useful pci utils
    playerctl
    picocom
    pkg-config # build tools 
    prismlauncher #minecraft!
    qalculate-gtk # good graphical calculator
    qemu_full
    qt6.qtwayland
    rclone
    ripgrep
    rmlint # remove duplicates
    rofi
    rpi-imager # to add ssid and information into the bootable image
    rsync
    rustup
    rust-analyzer
    screen # for serial communication
    signal-desktop #wrap
    sqlite
    spice-vdagent
    spotify #wrap
    slurp
    sshfs
    tectonic
    texlive.combined.scheme-full # full latex stuff
    thunderbird
    tor
    transmission-gtk
    typescript
    uefi-run
    unzip
    vlc
    vim
    virt-manager
    wl-clipboard
    wpaperd
    xdg-desktop-portal-hyprland
    zathura
    zotero
    zoom-us #wrap
    zip
    zsh
  ];
}
