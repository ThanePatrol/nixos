{ pkgs, ... }:

{
  home.packages = [ pkgs.rustup pkgs.cargo-watch pkgs.cargo-cross ];

  # use mold by default for all projects - broken as of 2023/11/2
    home.file.".cargo/config.toml".text = ''
      [target.x86_64-unknown-linux-gnu]
      rustflags = ["-C", "link-arg=-fuse-ld=${pkgs.mold}/bin/mold"]  
    '';
}

