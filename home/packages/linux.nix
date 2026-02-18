{ pkgs, ... }:

# for linux specific user packages
let

in
{
  packages = with pkgs; [
    brightnessctl
    clipman # clipboard manager
    cliphist # clipboard history
    grim # Grabs images
    hyprpicker
    tor-browser
    playerctl # control player via CLI
    slurp # select region
    wl-clipboard # cli clipboard
  ];

}
