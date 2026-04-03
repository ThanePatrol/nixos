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
    prettierd # prettier daemon for web
    gofumpt # formatter
    golines # formatter
    nixfmt # autoformat nix files
    shfmt # shell formatter
    luaformatter # format lua
    yamlfmt
    # keep-sorted end
  ];

  devTools = with pkgs; [
    # keep-sorted start
    ast-grep
    gemini-cli
    keep-sorted
    patchelf
    uv
    sqlite
    watchexec
    # keep-sorted end
  ];

  cliTools = with pkgs; [
    # keep-sorted start
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
    # keep-sorted end
  ];

  fatTools = with pkgs; [
    # keep-sorted start
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
