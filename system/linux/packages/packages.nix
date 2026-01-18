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
    binutils
    cmake
    clang
    docker
    docker-compose
    gdb
    kmod
    linuxHeaders
  ];

  cliTools = with pkgs; [
    takeBlurredScreenshot
    clipman # clipboard manager
    cliphist
    bc # cli multiplication
    btrfs-progs
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
    socat # to establish socket connections
    slurp
    smartmontools
    sshfs
    wireplumber # sound memes
  ];

  guiTools = with pkgs; [
    wrappedZoom
    alacritty
    # anki
    firefox
    kdePackages.polkit-kde-agent-1
    nemo # gui file manager
    openrgb-with-all-plugins
    qalculate-gtk # good graphical calculator
    rofi
    swaylock # lock screen for wayland
    swayidle # idle management for wayland
    spotify # wrap
    tor
    vlc
    virt-manager # gui for VMs
    (google-chrome.override {
      commandLineArgs = [
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
      ];
    })
  ];

  systemLibsAndPackages = with pkgs; [
    bluez
    libinput
    libsecret # for storing passwords
    nfs-utils # for nfs drives
    OVMFFull # UEFI firmware for QEMU
    pass-secret-service # dbus api for libsecret
    qt5.qtwayland
    qt6.qtwayland
    spice-vdagent
  ];

  daemons = with pkgs; [
    colord
    wpaperd # wallpaper daemon
  ];

  misc = with pkgs; [
    xdg-desktop-portal-hyprland # allows for sharing of screen + audio
    xdg-user-dirs
  ];

  homelab = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
  ];

in
{
  environment.systemPackages =
    guiTools ++ cliTools ++ devDependencies ++ systemLibsAndPackages ++ daemons ++ misc ++ homelab;
}
