{ isWork, ... }:

let
  DEFAULT_BRANCH = "main";
  DEFAULT_BRANCH_OLD = "master";
  DEVELOP_BRANCH = "develop";
  DEVELOP_BRANCH_ABBREV = "dev";
  email = if isWork then "hmandalidis@atlassian.com" else "mandalidis.hugh@gmail.com";
in {
  # set up auth here: https://cli.github.com/manual/gh_auth_login
  programs.gh = {
    enable = true;
  };

  programs.git = {
    enable = true;

    userName = "Hugh Mandalidis";
    userEmail = email;

    includes = [{ path = "~/.config/git/gitconfig"; }];

    extraConfig = {
      init.defaultBranch = DEFAULT_BRANCH;
      branch.sort = "-committerdate";
      core.editor = "vim";
      pull.ff = "only";
      tag.gpgSign = true;
    };

    # global ignores to not include
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
