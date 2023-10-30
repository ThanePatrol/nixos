{ pkgs, ... }:

# for mac os specific packages
let

in {
  packages = with pkgs;
    [
      # for docker on mac os
      # https://stackoverflow.com/questions/44084846/cannot-connect-to-the-docker-daemon-on-macos
      docker-client
    ];

}
