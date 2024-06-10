{ lib, pkgs, ... }:

# For packages in home-manager that are common across macos and linux
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
    act # github actions locally
    bison
    bear # for clangd
    bazelisk # frontend for bazel build tools
    chafa
    cargo-cross # cross compilation for rust
    cargo-flamegraph # flamegraph tool for many languages
    cmake
    cups
    direnv # https://direnv.net
    delve # go debugger
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
    gradle_7 # javabuild tool
    gnumake
    gzip
    halloy # IRC client
    helix
    hyperledger-fabric
    hyperfine # cli benchmarking
    lazygit # git tui
    libvirt
    lldb # for rust debugging
    libsecret # for storing passwords
    luaformatter # format lua
    jdt-language-server
    jq
    jdk
    jupyter-all
    mold # fast linker for llvm
    neofetch
    nixfmt # autoformat nix files
    nomacs # image viewer
    notcurses # terminal bling
    pandoc # document conversion
    #prismlauncher # minecraft!
    pciutils # useful pci utils
    pkg-config # build tools
    qalculate-qt

    qbittorrent
    rclone # nice simple backup cli for cloud backups
    ripgrep # nice and fast grep alternative for large codebases
    rsync
    sphinx # python docs generator
    shfmt # shell formatter
    sshfs # mount remote file systems locally with ssh
    terraform # Infra As Code
    terraform-providers.signalfx
    typescript
    texliveFull
    unzip
    wget
    vim
    zlib
    zip # CLI compression
    zig
    zsh
  ]; # ++ pythonPkgs;

}
