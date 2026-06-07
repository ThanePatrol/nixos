{
  pkgs,
  lib,
  minimal,
  ...
}:

let
  codeFormattersAndLinters = with pkgs; [
    # keep-sorted start
    black # python formatter
    gofumpt # formatter
    golines # formatter
    luaformatter # format lua
    prettierd # prettier daemon for web
    nixfmt # autoformat nix files
    shfmt # shell formatter
    yamlfmt
    # keep-sorted end
  ];

  devTools = with pkgs; [
    # keep-sorted start
    ast-grep
    gemini-cli
    keep-sorted
    patchelf
    mermaid-cli
    uv
    sqlite
    watchexec
    # keep-sorted end
  ];

  cliTools = with pkgs; [
    # keep-sorted start
    # CLI encryption
    age
    dust # better du
    fzf # fuzzy find
    gcc
    gnumake
    go
    gzip
    jq
    jujutsu
    libsecret # for storing passwords
    ncurses # for terminfo stuff
    nodejs_22
    osc
    pciutils # useful pci utils
    rainfrog
    rclone # nice simple backup cli for cloud backups
    ripgrep # nice and fast grep alternative for large codebases
    rmlint
    sops
    unzip
    vim
    zip # CLI compression
    zlib
    # keep-sorted end
  ];

  fatTools = with pkgs; [
    # keep-sorted start
    cargo-flamegraph # flamegraph tool for many languages
    #ffmpeg-full
    flex # lexical analysis
    geckodriver # webdriver automation
    gettext # translations
    imagemagick
    lazygit # git tui
    libsixel
    libvirt
    llama-cpp
    localsend
    ollama
    pandoc # document conversion
    pkg-config # build tools
    qbittorrent
    sphinx # python docs generator
    sshfs # mount remote file systems locally with ssh
    texliveFull
    tldr
    typescript
    # keep-sorted end
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
