{ pkgs, ... }:

{
  home.packages = [ pkgs.rustup pkgs.cargo-watch ];

  # use mold by default for all projects
  home.file.".cargo/config.toml".text = ''
    [target.x86_64-unknown-linux-gnu]
    rustflags = ["-C", "link-arg=-fuse-ld=${pkgs.mold}/bin/mold"]  

    # improves compilation time: https://kobzol.github.io/rust/rustc/2023/10/21/make-rust-compiler-5percent-faster.html
    #[env]
    #MALLOC_CONF = "thp:always,metadata_thp:always"
  '';
}

