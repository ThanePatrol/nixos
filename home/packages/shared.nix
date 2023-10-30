{ lib, pkgs, ... }:

# For packages in home-manager that are common across macos and linux
let unfreePackages = with pkgs; [ terraform ];

in {
  packages = with pkgs;
    [
      act # github actions locally
      #anki # flashcards
      #bear # compilation database for clang tooling
      biber
      bison
      chafa
      #calibre
      cmake
      cups
      direnv
      du-dust # better du
      flex # lexical analysis
      ffmpeg-full
      gcc
      geckodriver # webdriver automation
      go
      gofumpt # formatter
      gnumake
      gzip
      lazygit # git tui
      libvirt
      #libsecret # for storing passwords
      luaformatter # format lua
      jdk
      mold # fast linker for llvm
      neofetch
      nixfmt # autoformat nix files
      nomacs # image viewer
      pandoc # document conversion
      pciutils # useful pci utils
      #playerctl # media control - check if needed
      pkg-config # build tools
      rclone
      ripgrep
      rsync
      typescript
      unzip
      vim
      zip
      zsh
    ] ++ unfreePackages;
}
