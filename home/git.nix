{ pkgs, ... }:

with builtins;
let
  DEFAULT_BRANCH = "main";
  DEFAULT_BRANCH_OLD = "master";
  DEVELOP_BRANCH = "develop";
  DEVELOP_BRANCH_ABBREV = "dev";

in
{
  # https://github.com/cli/cli/issues/4955
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };

  programs.git = {
    enable = true;

    userName = "ThanePatrol";
    userEmail = "mandalidis.hugh@gmail.com";

    includes = [{ path = "~/.config/git/localconf"; }];

    

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
