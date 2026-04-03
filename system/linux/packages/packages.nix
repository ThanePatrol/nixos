{ pkgs, ... }:

let
  wrappedZoom = pkgs.writeShellScriptBin "zoom-us" ''
    exec ${pkgs.zoom-us}/bin/zoom-us --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';

  # TODO - consider implementing faster blur  https://github.com/johnae/blur
  takeBlurredScreenshot = pkgs.writeShellScriptBin "screenshot-background" ''
    ${pkgs.grim}/bin/grim /tmp/lockscreen.png
    ${pkgs.imagemagick}/bin/convert -filter Gaussian -resize 25% -blur 0x2.5 -resize 400% /tmp/lockscreen.png /tmp/lockscreen.png
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
    btrfs-progs
    cliphist
    clipman # clipboard manager
    dig
    ethtool
    grim # screenshot
    home-manager
    hyprpicker # color picker
    imagemagick # for cli screenshots
    lsof
    nettools # cmd line utils like ethtool
    parted # disk partition tool
    playerctl
    slurp
    smartmontools
    socat # to establish socket connections
    sshfs
    takeBlurredScreenshot
    wireplumber # sound memes
    # keep-sorted end
  ];

  guiTools = with pkgs; [
    # keep-sorted start
    alacritty
    # anki
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
    OVMFFull # UEFI firmware for QEMU
    bluez
    libinput
    libsecret # for storing passwords
    nfs-utils # for nfs drives
    pass-secret-service # dbus api for libsecret
    qt5.qtwayland
    qt6.qtwayland
    spice-vdagent
    # keep-sorted end
  ];

  daemons = with pkgs; [
    # keep-sorted start
    colord
    wpaperd # wallpaper daemon
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
    # keep-sorted end
  ];

in
{
  environment.systemPackages =
    guiTools ++ cliTools ++ devDependencies ++ systemLibsAndPackages ++ daemons ++ misc ++ homelab;
}
