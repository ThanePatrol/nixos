{
  programs.swaylock = {
    enable = true;
    package = null; # See https://nix-community.github.io/home-manager/options.xhtml#opt-programs.swaylock.enable
    settings = {
      indicator-idle-visible = true;
      indicator-thickness = 7;
      indicator-radius = 100;
      ring-color = "455a64";
      key-hl-color = "be5046";
      text-color = "ffc107";
      line-color = "00000000";
      inside-color = "00000088";
      separator-color = "00000000";
      show-failed-attempts = true;
    };
  };
}
