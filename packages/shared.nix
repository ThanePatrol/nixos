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
    playerctl # media control - check if needed
    pkg-config # build tools
    rclone
    ripgrep
    rsync
    rustup
    rust-analyzer
    spotify # wrap
    typescript
    unzip
    vim
    zathura # document viewer
    zoom-us # wrap
    zip
    zsh
  ];
}