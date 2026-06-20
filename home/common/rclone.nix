{ osConfig, ... }:

{
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
