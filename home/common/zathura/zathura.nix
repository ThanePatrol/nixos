{ theme, ... }: {
  programs.zathura = {
    enable = true;
    options = {
      font = "Iosevka 15";

      statusbar-h-padding = 10;
      statusbar-v-padding = 10;
      selection-notification = true;
      recolor = true;
      selection-clipboard = "clipboard";
      adjust-open = "best-fit";
      pages-per-row = "1";
      scroll-page-aware = "true";
      scroll-full-overlap = "0.01";
      scroll-step = "100";
      zoom-min = "10";
      guioptions = "none";
    };
    extraConfig = ''
      include ${theme}
    '';
  };

  xdg.configFile.zathura = {
    source = ./themes;
    recursive = true;
  };
}
