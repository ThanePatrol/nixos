{ pkgs, ... }:

let
  wrappedBitwarden = pkgs.writeShellScriptBin "bitwarden" ''
    exec ${pkgs.bitwarden}/bin/bitwarden --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';

  wrappedSpotify = pkgs.writeShellScriptBin "spotify" ''
    exec ${pkgs.spotify}/bin/spotify --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';

  wrappedChrome = pkgs.writeShellScriptBin "google-chrome" ''
    exec ${pkgs.google-chrome}/bin/google-chrome-stable --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';
  wrappedZoom = pkgs.writeShellScriptBin "zoom-us" ''
    exec ${pkgs.zoom-us}/bin/zoom-us --enable-features=UseOzonePlatform --ozone-platform=wayland
  '';

in {
  # a less boilerplate heavy way of specifying pkgs
  environment.systemPackages = with pkgs; [
    wrappedBitwarden
    (symlinkJoin {
      inherit (brave) name;
      paths = [ brave ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/brave --add-flags "--enable-features=UseOzonePlatform --ozone-platform=wayland --ozone-platform-hint=auto"'';
    })
    wrappedSpotify
    wrappedChrome
    wrappedZoom
    anki # flashcards
    bear # compilation database for clang tooling
    binutils
    bitwarden-cli
    bitwarden
    bluez # bluetooth memes
    chafa
    calibre
    cliphist
    colord
    cmake
    clang
    cups
    docker
    docker-compose
    dnsmasq
    discord # chromium wrap
    ethtool
    dunst # notification daemon
    flex # lexical analysis
    firefox
    google-chrome # wrap
    graphviz
    grim # screenshot
    home-manager
    hyprpicker # color picker
    libclang
    libsForQt5.polkit-kde-agent # for apps that want elevated permission
    libsForQt5.kdeconnect-kde # for sharing files with phone
    libguestfs
    libinput
    libsecret # for storing passwords
    linuxHeaders # for kernel dev
    llvm_16
    luaformatter # format lua
    kmod
    minicom # for serial connections
    mullvad-vpn # wrap
    cinnamon.nemo # gui file manager
    nettools # cmd line utils like ethtool
    nfs-utils # for nfs drives
    openrgb # manage rgb devices
    OVMFFull # UEFI firmware for QEMU
    parted # disk partition tool
    pass-secret-service # dbus api for libsecret
    playerctl
    picocom
    prismlauncher # minecraft!
    qalculate-gtk # good graphical calculator
    #qemu_full
    qt5.qtwayland
    qt6.qtwayland
    rofi
    rpi-imager # to add ssid and information into the bootable image
    signal-desktop # wrap
    spice-vdagent
    (lutris.override {
      extraPkgs = pkgs: [
        wineWowPackages.unstableFull
        wineWowPackages.waylandFull
        protontricks
        glxinfo # OpenGL libraries for steamp
        gamescope # steamOS session window manager
        #mesa
        libGLU
        vulkan-tools
        vulkan-validation-layers
        vulkan-loader
        vulkan-headers
      ];
    })
    spotify # wrap
    slurp
    sshfs
    texlive.combined.scheme-full # full latex stuff
    thunderbird
    tor
    transmission-gtk
    #uefi-run
    #udiskie # to allow automatic mounting of USB drives
    vlc
    virt-manager # gui for VMs
    wl-clipboard
    wpaperd # wallpaper daemon
    xdg-desktop-portal-hyprland # allows for sharing of screen + audio
    #zotero # bibliography manager
    zoom-us # wrap
  ];
}
