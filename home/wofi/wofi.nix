{ pkgs, lib, config, ...}:


let 
    dummy = pkgs.writeShellScriptbin "dummyScript" ''
        #!/usr/bin/env bash
        # todo make a proper script
    '';
in {

    programs.wofi = {
        enable = true;
        settings = {
            location = "center";
            allow_markup = true;
            width = 250;
        };
    };

}
