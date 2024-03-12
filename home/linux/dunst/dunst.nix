{ pkgs, ... }:

{
  home.packages = with pkgs; [ dunst ];

  services.dunst = {
    enable = true;
    settings = {
      global = {
        origin = "top-right";
        offset = "60x12";
        separator_height = 2;
        transparency = 10;
        padding = 12;
        horizontal_padding = 12;
        text_icon_padding = 12;
        frame_width = 4;
        separator_color = "frame";
        idle_threshold = 120;
        font = "DaddyTimeMono NF 16";
        line_height = 0;
        format = ''
        %a\n
        <b>%s</b>\n
        %b'';

        min_icon_size = 96;
        max_icon_size = 96;
        alignment = "center";
        #icon_position = "off";
        startup_notification = "false";
        corner_radius = 12;
        frame_color = "#44465c";
        background = "#303241";
        foreground = "#d9e0ee";
        timeout = 3;
      };
    };
  };
}
