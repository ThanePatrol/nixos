{pkgs, ...}:
{
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 295;
        command = "${pkgs.libnotify}/bin/notify-send 'locking in 5 seconds' -t 5000 -i ";
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
        timeout = 600;
        command = "${pkgs.systemd}/bin/systemctl suspend";
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
