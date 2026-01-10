{ email, gitUserName, ... }:

let
  DEFAULT_BRANCH = "main";
in
{
  # set up auth here: https://cli.github.com/manual/gh_auth_login
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

  programs.delta = {
    # git-delta
    # https://github.com/dandavison/delta
    enable = true;
    enableGitIntegration = true;
    options = {
      features = "side-by-side line-numbers";
      syntax-theme = "base16";
      delta.navigate = true;
    };
  };

  programs.git = {
    enable = true;

    includes = [ { path = "~/.config/git/gitconfig"; } ];

    settings = {
      user.name = gitUserName;
      user.email = email;
      init.defaultBranch = DEFAULT_BRANCH;
      branch.sort = "-committerdate";
      core.editor = "vim";
      core.hooksPath = ".githooks";
      http.postBuffer = 524288000; # increase size for larger files
      pull.ff = "only";
      push.autoSetupRemote = true;
      tag.gpgSign = true;
      merge.tool = "nvimdiff2";
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
      ".direnv"
    ];

  };
}
