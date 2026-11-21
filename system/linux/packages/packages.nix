{ pkgs, isWork, ... }:

let
  devDependencies = with pkgs; [
    # keep-sorted start
    binutils
    kmod
    linuxHeaders
    # keep-sorted end
  ];

  cliTools = with pkgs; [
    # keep-sorted start
    cliphist
    clipman # clipboard manager
    dig
    discordo
    ethtool
    git
    grim # screenshot
    home-manager
    imagemagick
    lsof
    slurp
    smartmontools
    socat # to establish socket connections
    wireplumber # sound memes
    # keep-sorted end
  ];

  systemLibsAndPackages = with pkgs; [
    # keep-sorted start
    bluez
    libinput
    nfs-utils # for nfs drives
    OVMFFull # UEFI firmware for QEMU
    # keep-sorted end
  ];

  daemons = with pkgs; [
    # keep-sorted start
    colord
    # keep-sorted end
  ];

  guiTools = with pkgs; [
    firefox
    fastmail-desktop
  ];

in
{
  environment.systemPackages =
    cliTools
    ++ devDependencies
    ++ systemLibsAndPackages
    ++ daemons
    ++ (if isWork then [ ] else guiTools);
}
