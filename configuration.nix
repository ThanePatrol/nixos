 # Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ nixpkgs, lib, config, pkgs, ... }:

let

  isDarwin = false;
  isWork = true;
  homeConfig = import ./home/home.nix {inherit isWork isDarwin username nixpkgs pkgs config lib; };

  username = "hugh"; #builtins.getEnv "USER"; # TODO Need to export an alternative environment variable as we need to use sudo hence the env will be "root"
  syspackages = import ./system/linux/packages/packages.nix { inherit pkgs; };
  pythonPackages =
    import ./system/linux/packages/python_packages.nix { inherit pkgs; };
  languages = import ./system/linux/packages/languages.nix { inherit pkgs; };
in {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    <home-manager/nixos>
#    ./system/linux/modules/udev-rules.nix
  ];
  # enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.allowUnfree = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #support 32bit opengl for steam
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.driSupport = true;
  hardware.cpu.amd.updateMicrocode = true;
  

  #linux kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ 
    "transparent_hugepage=madvise"
    "video=DP-2:3840x2160"
    "systemd.unified_cgroup_hierarchy=0"
  ];

  # required for issue with no graphical display after booting
  boot.initrd.kernelModules = [ "dm_mod" ];

  # transpartent huge pages for faster rust compilation
  networking.hostName = "nixos"; # Define your hostname.
  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [{
      from = 1714;
      to = 1764;
    } # KDE Connect
      ];
    allowedUDPPortRanges = [{
      from = 1714;
      to = 1764;
    } # KDE Connect
      ];
  };

  # Enable networking
  networking.networkmanager.enable = true;

  programs.hyprland.enable = true;
  programs.zsh.enable = true;

  # to get virt-manager working: https://github.com/NixOS/nixpkgs/issues/42433
  programs.dconf.enable = true;

  # Configure NFS share
  fileSystems."/nfs/samsung4tb" = {
    device = "10.0.0.15:/mnt/samsung4tb/nas";
    fsType = "nfs";
    options =
      [ "auto" "nofail" "noatime" "nolock" "intr" "tcp" "actimeo=1800" ];
  };

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

  # Enable the X11 windowing system.
  #  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  #services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Enable clipboard sharing to VM
  services.spice-vdagentd.enable = true;

  # start bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

 # systemd.services.auto-bluetooth-connection = {
 #   description = "Auto Bluetooth Keyboard Connection";
 #   wantedBy = [ "multi-user.target" ];
 #   path = [ pkgs.bluez ];
 #   script = ''
 #     #!/usr/bin/env bash
 #     ${pkgs.bluez}/bin/bluetoothctl connect 6C:93:08:61:A1:CA  
 #   '';
 #};
  #services.blueman.enable = true;

  # services.flatpak.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "au";
    xkbVariant = "";
  };

  # Enable ssh
  services.openssh.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;
  /*
  hardware.printers = {
    ensurePrinters = [
      {
        name = "Printer"; # hostname of Brother printer
        location = "Study";
        deviceUri = "http://10.0.0.117:631";
        model = ""
        ppdOptions = {
          pageSize = "A4";
        };
      }
    ];
    ensureDefaultPrinter = "Printer";
  };
  */

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.users.${username} = homeConfig;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  # also defings a bunch of packages to use
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [ "docker" "networkmanager" "wheel" "plugdev" "libvirt" "audio" ];
    shell = pkgs.zsh;
  };

  # weird bug fix, kept getting unfree issue
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "google-chrome" ];

  #nix.settings.auto-optimise-store = true; # reduce garbage

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [ wget kitty pythonPackages ]
    ++ syspackages.environment.systemPackages
    ++ languages.environment.systemPackages;

  environment.pathsToLink = [ "/share/zsh" ];

  #docker stuff
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  virtualisation.libvirtd = {
    enable = true;
    qemu.package = pkgs.qemu;
  };

  systemd.services = {
    libvirtd.enable = true;
    virtlogd.enable = true;
  };

  systemd.services.docker.wantedBy = [ "multi-user.target" ];
  #lib secret provider2
  services.passSecretService.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
