{ lib, pkgs, ... }:

# For packages in home-manager that are common across macos and linux
let 

in {
  # Add more unfree packages if desired
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "terraform"
  ];
  packages = with pkgs;
    [
      act # github actions locally
      bison
      bazelisk # frontend for bazel build tools 
      chafa
      cargo-cross # cross compilation for rust
      cmake
      cups 
      direnv # https://direnv.net
      delve # go debugger
      du-dust # better du
      flex # lexical analysis
      ffmpeg-full 
      gcc
      geckodriver # webdriver automation
      gettext # translations 
      go
      gofumpt # formatter
      gnumake
      gnused
      gzip
      halloy # IRC client
      helix
      lazygit # git tui
      imagemagick_light # for cli screenshots
      libvirt
      lldb # for rust debugging
      libsecret # for storing passwords
      luaformatter # format lua
      jq # 
      jdk
      jupyter-all
      mold # fast linker for llvm
      neofetch
      nixfmt # autoformat nix files
      nomacs # image viewer
      notcurses # terminal bling
      pandoc # document conversion
      prismlauncher # minecraft!
      pciutils # useful pci utils
      pkg-config # build tools
      rclone # nice simple backup cli for cloud backups
      ripgrep # nice and fast grep alternative for large codebases
      rsync
      sphinx #python docs generator
      terraform # Infra As Code
      terraform-providers.signalfx
      typescript
      texliveFull
      unzip
      vim
      zlib
      zip # CLI compression
      zsh 
    ];
}
