{ pkgs, ... }:

let
  #pythonPkgs = with pkgs.python3Packages; [
  #  matplotlib
  #  numpy
  #  scipy 
  #  pandas 
  #  requests
  #];
in {
  packages = with pkgs; [
    age # CLI encryption
    cargo-cross # cross compilation for rust
    cargo-flamegraph # flamegraph tool for many languages
    cmake
    du-dust # better du
    #eww
    flex # lexical analysis
    fzf # fuzzy find
    ffmpeg-full
    gcc
    geckodriver # webdriver automation
    gettext # translations
    go
    gofumpt # formatter
    gnumake
    gzip
    lazygit # git tui
    libvirt
    libsecret # for storing passwords
    luaformatter # format lua
    jq
    jdk
    jupyter-all
    mold # fast linker for llvm
    nixfmt # autoformat nix files
    nomacs # image viewer
    pandoc # document conversion
    #prismlauncher # minecraft!
    pciutils # useful pci utils
    pkg-config # build tools
    qbittorrent
    rclone # nice simple backup cli for cloud backups
    ripgrep # nice and fast grep alternative for large codebases
    rsync
    sphinx # python docs generator
    shfmt # shell formatter
    sshfs # mount remote file systems locally with ssh
    terraform # Infra As Code
    typescript
    texliveFull
    unzip
    wget
    vim
    zlib
    zip # CLI compression
    zsh
  ]; # ++ pythonPkgs;

}
