{ pkgs, ... }:

# for mac os specific packages
let

in {
  packages = with pkgs; [
    darwin.iproute2mac
    darwin.libiconv
    coreutils-prefixed
    reattach-to-user-namespace
    utm
  ];

}
