{ email, gitUserName, theme, ... }:

let DEFAULT_BRANCH = "main";
in {
  # set up auth here: https://cli.github.com/manual/gh_auth_login
  # use --with-token arg
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
      version = 1;
    };
    gitCredentialHelper = {
      enable = true;
      hosts = [ "https://github.com" ];
    };
  };

  programs.git = {
    enable = true;

    userName = gitUserName;
    userEmail = email;

    includes = [{ path = "~/.config/git/gitconfig"; }];

    extraConfig = {
      init.defaultBranch = DEFAULT_BRANCH;
      branch.sort = "-committerdate";
      core.editor = "vim";
      pull.ff = "only";
      push.autoSetupRemote = true;
      tag.gpgSign = true;

      url = {
        "ssh://${gitUserName}@xxx:29418/" = {
          insteadOf = "https://xxx";
        };
        "ssh://${gitUserName}@xxx:29418" = {
          insteadOf = "https://xxx";
        };
        "xxx" = { insteadOf = "xxx"; };
      };
    };

    # global ignores to not include
    ignores =
      [ "**/target/*" "*~" "*.swp" ".DS_Store" "node_modules" ".env" ".envrc" ];

    # git-delta
    # https://github.com/dandavison/delta
    delta = {
      enable = true;
      options = {
        features = "side-by-side line-numbers";
        syntax-theme = theme;
        delta.navigate = true;
      };
    };
  };
}
