{
  pkgs,
  lib,
  minimal,
  ...
}:

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
    patchelf
    mermaid-cli
    uv
    sqlite
    watchexec
  ];

  cliTools = with pkgs; [
    age
    # CLI encryption
    claude-code
    dust # better du
    fzf # fuzzy find
    gcc
    go
    gnumake
    gzip
    jq
    jujutsu
    libsecret # for storing passwords
    osc
    ncurses # for terminfo stuff
    nodejs_22
    pciutils # useful pci utils
    rainfrog
    rmlint
    rclone # nice simple backup cli for cloud backups
    ripgrep # nice and fast grep alternative for large codebases
    unzip
    vim
    zlib
    zip # CLI compression
  ];

  fatTools = with pkgs; [
    cargo-flamegraph # flamegraph tool for many languages
    ffmpeg-full
    geckodriver # webdriver automation
    gettext # translations
    flex # lexical analysis
    imagemagick
    lazygit # git tui
    libvirt
    libsixel
    localsend
    llama-cpp
    ollama
    pandoc # document conversion
    pkg-config # build tools
    qbittorrent
    sphinx # python docs generator
    sshfs # mount remote file systems locally with ssh
    texliveFull
    tldr
    typescript
  ];

in
{
  packages =
    with pkgs;
    [
      zsh
    ]
    ++ (if minimal then cliTools else codeFormattersAndLinters ++ devTools ++ cliTools ++ fatTools);

}
