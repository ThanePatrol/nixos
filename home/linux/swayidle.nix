{ pkgs, ... }:

let
  # TODO - consider implementing faster blur  https://github.com/johnae/blur
  takeBlurredScreenshot = pkgs.writeShellScriptBin "screenshot-background" ''
    ${pkgs.grim}/bin/grim /tmp/lockscreen.png
    ${pkgs.imagemagick}/bin/magick convert -filter Gaussian -resize 25% -blur 0x2.5 -resize 400% /tmp/lockscreen.png /tmp/lockscreen.png
  '';

  # The distro's swaylock where there is one: the Nix build can't authenticate
  # against a non-NixOS PAM stack, so it would lock and never unlock (see
  # swaylock.nix).
  swaylock = pkgs.writeShellScript "swaylock" ''
    for dir in /usr/local/bin /usr/bin; do
      if [ -x "$dir/swaylock" ]; then
        exec "$dir/swaylock" "$@"
      fi
    done
    exec ${pkgs.swaylock}/bin/swaylock "$@"
  '';

in
{
  home.packages = [ takeBlurredScreenshot ];
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 295;
        command = "${pkgs.libnotify}/bin/notify-send 'locking in 5 seconds' -t 5000 -i ";
      }
      {
        timeout = 297;
        command = "${pkgs.coreutils}/bin/rm /tmp/lockscreen.png || true";
      }
      {
        timeout = 298;
        command = "${takeBlurredScreenshot}/bin/screenshot-background";
      }
      {
        timeout = 300;
        command = "${swaylock} -f -i /tmp/lockscreen.png";
      }
      {
        timeout = 600;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
  };
}
