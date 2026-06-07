{ pkgs, osConfig, ... }:

{
  home.packages = [ pkgs.rclone ];
  # home.file."./.config/rclone/rclone.conf".text = ''
  #   [b2-ironwolfs]
  #   type = b2
  #   account = ${osConfig.sops.secrets.backblaze_key_id.path}
  #   key = ${osConfig.sops.secrets.backblaze_application_key.path}
  #   hard_delete = true
  # '';
  programs.rclone = {
    enable = true;
    remotes = {
      b2backup = {
        config = {
          type = "b2";
          hard_delete = true;
        };
        secrets = {
          account = osConfig.sops.secrets.backblaze_key_id.path;
          key = osConfig.sops.secrets.backblaze_application_key.path;
        };
      };
    };
  };
}
