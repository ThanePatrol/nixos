{ pkgs, lib, ... }:

let
  # FIXME - upstream package
  wsl = pkgs.buildGoModule rec {
    pname = "wsl";
    version = "4.4.1";

    src = pkgs.fetchFromGitHub {
      owner = "bombsimon";
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-QvoJuRQBwm4xx7HzW767Bj/OB2WPA7NnMD1kLZQMfn8=";

    };

    vendorHash = "sha256-cz4nWE0+vOW0j6avZgsiqcSo1zwFOn3I8anZsEB2/IA=";

    meta = with lib; {
      description = "A golang whitespace linter";
      homepage = "https://github.com/bombsimon/wsl";
      license = licenses.mit;
      #maintainers = with maintainers; [ meain ];
    };
  };

  codeFormattersAndLinters = with pkgs; [
    black # python formatter
    prettierd # prettier daemon for web
    gofumpt # formatter
    golines # formatter
    wsl # whitespace linter for go
    nixfmt-rfc-style # autoformat nix files
    shfmt # shell formatter
    luaformatter # format lua
    yamlfmt
  ];

  devTools = with pkgs; [
    python312Packages.compiledb
    uv
  ];

in
{
  packages =
    with pkgs;
    [
      age # CLI encryption
      cargo-flamegraph # flamegraph tool for many languages
      du-dust # better du
      flex # lexical analysis
      fzf # fuzzy find
      ffmpeg-full
      gcc
      geckodriver # webdriver automation
      gettext # translations
      go
      gnumake
      gzip
      jq
      jdk
      jupyter-all
      lazygit # git tui
      libvirt
      libsecret # for storing passwords
      libsixel
      localsend
      ollama
      ncurses # for terminfo stuff
      pandoc # document conversion
      prismlauncher # minecraft!
      pciutils # useful pci utils
      pkg-config # build tools
      qbittorrent
      rclone # nice simple backup cli for cloud backups
      ripgrep # nice and fast grep alternative for large codebases
      rmlint
      rsync
      sphinx # python docs generator
      sshfs # mount remote file systems locally with ssh
      texliveFull
      tldr
      typescript
      #ueberzugpp # images in terminal
      unzip
      vim
      zlib
      zip # CLI compression
      zsh
    ]
    ++ codeFormattersAndLinters
    ++ devTools;

}
