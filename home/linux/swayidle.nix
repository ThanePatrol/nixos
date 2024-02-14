{pkgs, ...}:
let 

  take_blurred_screen_shot = pkgs.writeShellScriptBin "screenshot" ''
    #!/usr/bin/env bash
    grim /tmp/lockscreen.png
    convert -filter Gaussian -resize 20% -blur 0x2.5 -resize 500% /tmp/lockscreen.png /tmp/lockscreen.png
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
        timeout = 300;
        command = "${take_blurred_screen_shot} && ${pkgs.swaylock}/bin/swaylock -f -i /tmp/lockscreen.png";
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
