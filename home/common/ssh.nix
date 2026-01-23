{ gitUserName, ... }:

{

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "thane" = {
        hostname = "thane.c.googlers.com";
        setEnv = {
          TERM = "xterm-256color";
        };
        forwardAgent = true;
      };
      "azure" = {
        host = "azure";
        hostname = "74.249.58.10";
        user = "azureuser";
        identityFile = "/nfs/samsung4tb/Development/auth/mqcp_leetcode_server.pem";
      };
      "zeruel" = {
        hostname = "10.0.0.3";
        user = "hugh";
        extraOptions = {
          "UseKeychain" = "yes";
          "AddKeysToAgent" = "yes";
        };
      };
      "*" = {
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
        extraOptions = {
          "GSSAPIAuthentication" = "yes";
          "GSSAPIDelegateCredentials" = "no";
          "StrictHostKeyChecking" = "no";
          "HostKeyAlgorithms" = "+ssh-rsa";
          "PubkeyAcceptedKeyTypes" = "+ssh-rsa";
        };
      };
    };
  };

}
