{ pkgs, ... }:

let
  wrappedZoom = pkgs.writeShellScriptBin "zoom-us" ''
    exec ${pkgs.zoom-us}/bin/zoom-us --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';

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
    ethtool
    git
    grim # screenshot
    home-manager
    imagemagick
    lsof
    nettools # cmd line utils like ethtool
    parted # disk partition tool
    slurp
    smartmontools
    socat # to establish socket connections
    sshfs
    uv
    wireplumber # sound memes
    # keep-sorted end
  ];

  systemLibsAndPackages = with pkgs; [
    # keep-sorted start
    bluez
    libinput
    libsecret # for storing passwords
    nfs-utils # for nfs drives
    OVMFFull # UEFI firmware for QEMU
    pass-secret-service # dbus api for libsecret
    qt5.qtwayland
    qt6.qtwayland
    spice-vdagent
    # keep-sorted end
  ];

  daemons = with pkgs; [
    # keep-sorted start
    colord
    # keep-sorted end
  ];

in
{
  environment.systemPackages = cliTools ++ devDependencies ++ systemLibsAndPackages ++ daemons;
}
