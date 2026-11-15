{ gitUserName, ... }:

{

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "thane" = {
        HostName = "thane.c.googlers.com";
        SetEnv = {
          TERM = "xterm-256color";
        };
        ForwardAgent = true;
      };
      "zeruel" = {
        Hostname = "10.0.0.3";
        User = "hugh";
        AddKeysToAgent = "yes";
      };
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
        GSSAPIAuthentication = "yes";
        GSSAPIDelegateCredentials = "no";
        StrictHostKeyChecking = "no";
        HostKeyAlgorithms = "+ssh-rsa";
        PubkeyAcceptedKeyTypes = "+ssh-rsa";
      };
    };
  };

}
