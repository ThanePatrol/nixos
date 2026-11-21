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
    luaformatter # format lua
    nixfmt # autoformat nix files
    prettierd # prettier daemon for web
    shfmt # shell formatter
    yamlfmt
    # keep-sorted end
  ];

  devTools = with pkgs; [
    # keep-sorted start
    ast-grep
    keep-sorted
    mermaid-cli
    patchelf
    sqlite
    uv
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
    ncurses # for terminfo stuff
    nodejs_22
    osc
    pciutils # useful pci utils
    pv # Pipeviewer to see progress of pipes.
    rainfrog
    rclone # nice simple backup cli for cloud backups
    ripgrep # nice and fast grep alternative for large codebases
    sops
    unzip
    zip # CLI compression
    zlib
    # keep-sorted end
  ];

  fatTools = with pkgs; [
    # keep-sorted start
    #ffmpeg-full
    antigravity-cli
    cargo-flamegraph # flamegraph tool for many languages
    flex # lexical analysis
    gettext # translations
    imagemagick
    libsixel
    libvirt
    llama-cpp
    localsend
    pandoc # document conversion
    pkg-config # build tools
    sphinx # python docs generator
    texliveFull
    tldr
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
