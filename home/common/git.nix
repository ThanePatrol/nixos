{ pkgs, ... }:

let
  DEFAULT_BRANCH = "main";
  DEFAULT_BRANCH_OLD = "master";
  DEVELOP_BRANCH = "develop";
  DEVELOP_BRANCH_ABBREV = "dev";
in {
  # set up auth here: https://cli.github.com/manual/gh_auth_login
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "https";
    };
    gitCredentialHelper = {
      enable = true;
      hosts = [
        "https://github.com"
      ];
    };
  };

  programs.git = {
    enable = true;

    userName = "ThanePatrol";
    userEmail = "mandalidis.hugh@gmail.com";

    includes = [{ path = "~/.config/git/gitconfig"; }];

    extraConfig = {
      init.defaultBranch = DEFAULT_BRANCH;
      branch.sort = "-committerdate";
      core.editor = "vim";
      pull.ff = "only";
      tag.gpgSign = true;
    };

    # global ignore
    ignores = [ 
      "**/target/*"
      "*~"
      "*.swp"
      ".DS_Store"
      "node_modules"
      ".env"
      ".envrc"
    ];

    # git-delta
    # https://github.com/dandavison/delta
    delta = {
      enable = true;
      options = {
        features = "side-by-side line-numbers";
        syntax-theme = "base16";
        delta.navigate = true;
      };
    };
  };
}
