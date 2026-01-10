{ pkgs, ... }:

# for linux specific user packages
let

in
{
  packages = with pkgs; [
    tor-browser
    wl-clipboard
  ];

}
