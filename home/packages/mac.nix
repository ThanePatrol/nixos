{ pkgs, ... }:

{
  packages = with pkgs; [
    # keep-sorted start
    coreutils-prefixed
    darwin.libiconv
    iproute2mac
    prismlauncher
    reattach-to-user-namespace
    # keep-sorted end
  ];

}
