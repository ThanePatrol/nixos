{ pkgs, lib, ... }:

let
  codeFormattersAndLinters = with pkgs; [
    black # python formatter
    prettierd # prettier daemon for web
    gofumpt # formatter
    golines # formatter
    nixfmt-rfc-style # autoformat nix files
    shfmt # shell formatter
    luaformatter # format lua
    yamlfmt
  ];

  devTools = with pkgs; [
    #python312Packages.compiledb
    ast-grep
    gemini-cli
    uv
    sqlite
  ];

in
{
  packages =
    with pkgs;
    [
      age # CLI encryption
      cargo-flamegraph # flamegraph tool for many languages
      dust # better du
      flex # lexical analysis
      fzf # fuzzy find
      ffmpeg-full
      gcc
      geckodriver # webdriver automation
      gettext # translations
      go
      gnumake
      gzip
      imagemagick
      jq
      #jujutsu
      lazygit # git tui
      libvirt
      libsecret # for storing passwords
      libsixel
      localsend
      llama-cpp
      ollama
      osc
      ncurses # for terminfo stuff
      nodejs_22
      pandoc # document conversion
      pciutils # useful pci utils
      pkg-config # build tools
      qbittorrent
      rainfrog
      rclone # nice simple backup cli for cloud backups
      ripgrep # nice and fast grep alternative for large codebases
      rmlint
      rsync
      sphinx # python docs generator
      sshfs # mount remote file systems locally with ssh
      # texliveFull TODO - renable once build issue is fixed
      tldr
      typescript
      unzip
      vim
      zlib
      zip # CLI compression
      zsh
    ]
    ++ codeFormattersAndLinters
    ++ devTools;

}
