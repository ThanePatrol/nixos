{
  nixpkgs,
  lib,
  config,
  pkgs,
  customArgs,
  ...
}:

let
  isDarwin = false;
  isWork = customArgs.isWork;
  username = customArgs.username;
  email = customArgs.email;
  gitUserName = customArgs.gitUserName;

  theme = "Catppuccin-mocha";

  homeConfig = import ../../home/home.nix {
    inherit
      email
      isWork
      isDarwin
      username
      gitUserName
      nixpkgs
      pkgs
      config
      lib
      theme
      ;
  };

  syspackages = import ../../system/linux/packages/packages.nix { inherit pkgs; };
in
{
  imports = [
    ./hardware-configuration.nix
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #support 32bit opengl for steam
  hardware.graphics.enable32Bit = true;
  hardware.cpu.amd.updateMicrocode = true;

  #linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # TODO add "video=DP-2:3840x2160" or similar for game streaming
  boot.kernelParams = [
    "transparent_hugepage=madvise"
  ];

  # TODO - not needed anymore? dm_mod required for issue with no graphical display after booting "dm_mod"
  #i2c-dev for brightness control https://wiki.archlinux.org/title/backlight#setpci
  boot.initrd.kernelModules = [
    "i2c-dev"
  ];

  networking.hostName = "zeruel"; # Define your hostname.
  networking.firewall = {
    enable = false;
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
      {
        from = 25565;
        to = 25565;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
      {
        from = 25565;
        to = 25565;
      }
    ];
  };

  # Enable networking
  networking.networkmanager.enable = true;

  programs.hyprland.enable = true;
  programs.zsh.enable = true;
  programs.steam.enable = true;

  # TODO Configure NFS share export
  #fileSystems."/nfs/samsung4tb" = {
  #  device = "10.0.0.15:/mnt/samsung4tb/nas";
  #  fsType = "nfs";
  #  options = [
  #    "auto"
  #    "nofail"
  #    "noatime"
  #    "nolock"
  #    "intr"
  #    "tcp"
  #    "actimeo=1800"
  #  ];
  #};

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # FIXME - do we really want this on a server?
  services.udev = {
    packages = with pkgs; [ via ];
    extraRules = ''
      KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
      ACTION=="add", SUBSYSTEM=="block", SUBSYSTEMS=="usb", ENV{ID_FS_USAGE}=="filesystem", RUN+="${pkgs.systemd}/bin/systemd-mount --no-block --automount=yes --collect $devnode /home/hugh/removable"
    '';
  };

  # Enable clipboard sharing to VM
  services.spice-vdagentd.enable = true;

  # start bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  hardware.keyboard.qmk.enable = true;

  # Enable ssh
  services.openssh.enable = true;

  # to allow swaylock to accept a password
  security.pam.services.swaylock = { };

  security.rtkit.enable = true;

  # Enable sound with pipewire.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    audio.enable = true; # set as default sound server
    pulse.enable = true;
    wireplumber.enable = true;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.users.${username} = homeConfig;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  # Define user account
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "docker"
      "networkmanager"
      "wheel"
      "plugdev"
      "libvirtd"
      "audio"
      "input"
      "lp" # for bluetooth
    ];
    shell = pkgs.zsh;
  };

  environment.systemPackages = syspackages.environment.systemPackages;

  environment.pathsToLink = [
    "/share/zsh"
    "/share/icons" # For Xournalpp not finding icons
    "/share/mime" # https://github.com/NixOS/nixpkgs/issues/163107
  ];

  #docker stuff
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  systemd.services.docker.wantedBy = [ "multi-user.target" ];

  # to get virt-manager working: https://github.com/NixOS/nixpkgs/issues/42433
  programs.dconf.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu.package = pkgs.qemu;
  };

  systemd.services = {
    libvirtd.enable = true;
    virtlogd.enable = true;
  };

  services.passSecretService.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
