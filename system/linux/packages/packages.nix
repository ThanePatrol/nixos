{ pkgs, ... }:

let
  wrappedZoom = pkgs.writeShellScriptBin "zoom-us" ''
    exec ${pkgs.zoom-us}/bin/zoom-us --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';

  devDependencies = with pkgs; [
    # keep-sorted start
    binutils
    clang
    cmake
    docker
    docker-compose
    gdb
    kmod
    linuxHeaders
    # keep-sorted end
  ];

  cliTools = with pkgs; [
    # keep-sorted start
    bc # cli multiplication
    cliphist
    clipman # clipboard manager
    dig
    ethtool
    grim # screenshot
    home-manager
    hyprpicker # color picker
    imagemagick
    llama-cpp
    lsof
    nettools # cmd line utils like ethtool
    parted # disk partition tool
    playerctl
    slurp
    smartmontools
    socat # to establish socket connections
    sshfs
    wireplumber # sound memes
    # keep-sorted end
  ];

  guiTools = with pkgs; [
    # keep-sorted start
    # anki
    alacritty
    firefox
    kdePackages.polkit-kde-agent-1
    nemo # gui file manager
    openrgb-with-all-plugins
    qalculate-gtk # good graphical calculator
    rofi
    spotify # wrap
    swayidle # idle management for wayland
    swaylock # lock screen for wayland
    tor
    virt-manager # gui for VMs
    vlc
    wrappedZoom
    # keep-sorted end
    (google-chrome.override {
      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
      ];
    })
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

  misc = with pkgs; [
    # keep-sorted start
    xdg-desktop-portal-hyprland # allows for sharing of screen + audio
    xdg-user-dirs
    # keep-sorted end
  ];

  homelab = with pkgs; [
    # keep-sorted start
    jellyfin
    jellyfin-ffmpeg
    jellyfin-web
    prometheus-node-exporter
    # keep-sorted end
  ];

in
{
  environment.systemPackages =
    guiTools ++ cliTools ++ devDependencies ++ systemLibsAndPackages ++ daemons ++ misc ++ homelab;
}
