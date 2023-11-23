{ lib, pkgs, ... }:

# For packages in home-manager that are common across macos and linux
let unfreePackages = with pkgs; [ terraform ];

in {
  packages = with pkgs;
    [
      act # github actions locally
      #bear # compilation database for clang tooling
      biber
      bison
      chafa
      cargo-cross # cross compilation
      cmake
      cups
      direnv
      delve # go debugger
      du-dust # better du
      flex # lexical analysis
      ffmpeg-full
      gcc
      geckodriver # webdriver automation
      gettext
      go
      gofumpt # formatter
      gnumake
      gzip
      lazygit # git tui
      libvirt
      lldb # for rust debugging
      libsecret # for storing passwords
      luaformatter # format lua
      jdk
      mold # fast linker for llvm
      neofetch
      nixfmt # autoformat nix files
      nomacs # image viewer
      notcurses # terminal bling
      pandoc # document conversion
      prismlauncher # minecraft!
      pciutils # useful pci utils
      pkg-config # build tools
      rclone
      ripgrep
      rsync
      typescript
      texlive.combined.scheme-tetex
      unzip
      vim
      zip
      zsh
    ] ++ unfreePackages;
}
