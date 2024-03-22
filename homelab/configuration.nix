# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let user = "hugh";
in {
  imports = [ 
    ./hardware-configuration.nix
    #./router.nix # TODO - figure out why this doesn't work

    ./content/content-aggregation.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "lenovo-m710q-nixos";
  # Enable networking
  networking.networkmanager.enable = true;

  # Enable ssh
  services.openssh.enable = true;

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

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

  services.xserver = {
    layout = "au";
    xkbVariant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${user} = {
    isNormalUser = true;
    description = user;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ ];
    shell = pkgs.zsh;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableLsColors = true;
    autosuggestions.enable = true;
    shellAliases = {
      update = ''
        sudo cp -r /home/${user}/nixos/homelab/* /etc/nixos && \
              sudo nix-channel --update && \
              sudo nixos-rebuild switch && source ~/.zshrc'';
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [ btop vim zsh git sabnzbd ];

  virtualisation.libvirtd = {
    enable = true;
    qemu.package = pkgs.qemu;
  };

  systemd.services = {
    libvirtd.enable = true;
    virtlogd.enable = true;
  };

  fileSystems."/nfs/samsung4tb" = {
    device = "10.0.0.15:/mnt/samsung4tb/nas";
    fsType = "nfs";
    options =
      [ "auto" "nofail" "noatime" "nolock" "intr" "tcp" "actimeo=1800" ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}

