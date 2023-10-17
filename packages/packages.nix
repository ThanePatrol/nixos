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
  wrappedZoom = pkgs.writeShellScriptBin "zoom-us" ''
    exec ${pkgs.zoom-us}/bin/zoom-us --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';

  #wrappedGhidra = pkgs.writeShellScriptBin "ghidra" ''
  #    export _JAVA_AWT_WM_NONREPARENTING=1
  #    exec ${pkgs.ghidra-bin}/bin/ghidra
  #'';

  overlay = import ./overlays.nix;
  #myPkgs = import <nixpkgs> {
  #  overlays = [ overlay ];
  #};

in {
  # a less boilerplate heavy way of specifying pkgs
  environment.systemPackages = with pkgs; [
    wrappedBitwarden
    (symlinkJoin {
      inherit (brave) name;
      paths = [ brave ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/brave --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland --ozone-platform-hint=auto"'';
    })
    wrappedSpotify
    wrappedChrome
    #    wrappedMailspring
    wrappedZoom
    alacritty # terminal
    anki # flashcards
    bat # better cat
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
    google-chrome # wrap
    graphviz
    grim # screenshot
    gnumake
    ghidra-bin
    gnome.gnome-calendar
    gnome.nautilus # file viewer
    gnome.sushi # file preview
    gnome.libgnome-keyring # secret manager
    gnome.gnome-keyring
    gzip
    home-manager
    hyprpicker # color picker
    lazygit # git tui
    libclang
    libsForQt5.polkit-kde-agent # for apps that want elevated permission
    libguestfs
    libinput
    libvirt
    libsecret # for storing passwords
    linuxHeaders # for kernel dev
    llvm_16
    luaformatter # format lua
    imhex # rly good hex editor
    jdk
    #jetbrains.idea-ultimate
    kmod
    mold # fast linker for llvm
    minicom # for serial connections
    mullvad-vpn # wrap
    neofetch
    cinnamon.nemo # gui file manager
    nettools # cmd line utils like ethtool
    nfs-utils # for nfs drives
    nixfmt # autoformat nix files
    nomacs # image viewer
    obsidian # wrap
    opendrop # linux airdorp
    openrgb # manage rgb devices
    OVMFFull # UEFI firmware for QEMU
    p7zip # 7zip terminal
    pandoc # document conversion
    parted # disk partition tool
    pass-secret-service # dbus api for libsecret
    pciutils # useful pci utils
    playerctl
    picocom
    pkg-config # build tools
    prismlauncher # minecraft!
    qalculate-gtk # good graphical calculator
    qemu_full
    qt5.qtwayland
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
    signal-desktop # wrap
    sqlite
    spice-vdagent
    spotify # wrap
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
    udiskie # to allow automatic mounting of USB drives
    vlc
    vim
    virt-manager # gui for VMs
    wl-clipboard
    wpaperd # wallpaper daemon
    xdg-desktop-portal-hyprland # allows for sharing of screen + audio
    zathura # document viewer
    zotero # bibliography manager
    zoom-us # wrap
    zip
    zsh
  ];
}
