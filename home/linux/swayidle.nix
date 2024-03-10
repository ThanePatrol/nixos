{pkgs, ...}:

let 
  # return error code if music is playing
  ifMusicNotPlayingSuspend = pkgs.writeShellScriptBin "if-music-not-playing-suspend" ''
  is_playing=$(playerctl status)
  if [ "$is_playing" == "Playing" ]; then
    exit 1
  else
  ${pkgs.systemd}/bin/systemctl suspend
  fi
  '';
in
{
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 295;
        command = "${pkgs.libnotify}/bin/notify-send 'locking in 5 seconds' -t 5000 -i ";
      }
      {
        timeout = 297;
        command = "rm /tmp/lockscreen.png";
      }
      {
        timeout = 298;
        # Can't use {pkgs.screenshot-background} as the attribute is never found :(
        command = "screenshot-background"; 
      }
      {
        timeout = 300;
        command = "${pkgs.swaylock}/bin/swaylock -f -i /tmp/lockscreen.png";
      }
      {
        # we don't want to suspend if music is playing
        # we use && to short circuit the command 
        timeout = 600;
        command = "${ifMusicNotPlayingSuspend}";
      }
    ];
    events = [
      {
        event = "before-sleep";
        command = "${pkgs.swaylock}/bin/swaylock";
      }
    ];
  };
}
