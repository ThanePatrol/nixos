{ pkgs, ... }:

# for mac os specific packages
let

in
{
  packages = with pkgs; [
    iproute2mac
    darwin.libiconv
    coreutils-prefixed
    reattach-to-user-namespace
    prismlauncher
  ];

}
