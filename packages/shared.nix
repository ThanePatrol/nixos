{ pkgs, ... }:

# For packages in home-manager that are common across macos and linux
let
  wrappedBitwarden = pkgs.writeShellScriptBin "bitwarden" ''
    exec ${pkgs.bitwarden}/bin/bitwarden --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';

in {
  home.packages = with pkgs; [
    act # github actions locally
    anki # flashcards
    bear # compilation database for clang tooling
    biber
    bison
    binutils
    chafa
    calibre
    cargo-watch
    cmake
    cups
    direnv
    discord # chromium wrap
    docker
    docker-compose
    du-dust # better du
    flex # lexical analysis
    ffmpeg-full
    gcc
    geckodriver # webdriver automation
    git
    go
    gofumpt # formatter
    gnumake
    gzip
    home-manager
    lazygit # git tui
    libclang
    libvirt
    libsecret # for storing passwords
    luaformatter # format lua
    jdk
    mold # fast linker for llvm
    neofetch
    nixfmt # autoformat nix files
    nomacs # image viewer
    pandoc # document conversion
    pass-secret-service # dbus api for libsecret
    pciutils # useful pci utils
    playerctl # TODO - check from here onwards about macos compat + whether they're needed
    picocom
    pkg-config # build tools
    prismlauncher # minecraft!
    qalculate-gtk # good graphical calculator
    #qemu_full
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
    #udiskie # to allow automatic mounting of USB drives
    vlc
    vim
    virt-manager # gui for VMs
    wl-clipboard
    wpaperd # wallpaper daemon
    xdg-desktop-portal-hyprland # allows for sharing of screen + audio
    zathura # document viewer
    #zotero # bibliography manager
    zoom-us # wrap
    zip
    zsh
  ];
}
