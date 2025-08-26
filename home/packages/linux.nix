{ pkgs, ... }:

# for linux specific user packages
let

in
{
  packages = with pkgs; [
    eww
    tor-browser
    wl-clipboard
  ];

}
