{ pkgs, ... }:

let
  # return error code if music is playing
  ifMusicNotPlayingSuspend = pkgs.writeShellScriptBin "if-music-not-playing-suspend" ''
    is_playing=$(${pkgs.playerctl}/bin/playerctl status)
    if [ "$is_playing" == "Playing" ]; then
      exit 1
    else
    ${pkgs.systemd}/bin/systemctl suspend
    fi
  '';
  # TODO - consider implementing faster blur  https://github.com/johnae/blur
  takeBlurredScreenshot = pkgs.writeShellScriptBin "screenshot-background" ''
    ${pkgs.grim}/bin/grim /tmp/lockscreen.png
    ${pkgs.imagemagick}/bin/magick convert -filter Gaussian -resize 25% -blur 0x2.5 -resize 400% /tmp/lockscreen.png /tmp/lockscreen.png
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
        command = "${pkgs.swaylock}/bin/swaylock -f -i /tmp/lockscreen.png";
      }
      {
        timeout = 600;
        command = "${pkgs.systemd}/bin/systemctl suspend";
      }
    ];
    events = {
      #      "before-sleep" = "${pkgs.swaylock}/bin/swaylock -f -i /tmp/lockscreen.png";
    };
  };
}
