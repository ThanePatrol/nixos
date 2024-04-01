{ pkgs, ... }:

# for linux specific user packages
let

in {
  packages = with pkgs; [ eclipses.eclipse-java eww tor-browser ];

}
