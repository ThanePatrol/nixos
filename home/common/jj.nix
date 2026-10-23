{
  pkgs,
  isWork,
  email,
  ...
}:

let
  workAliases = {
    what-changes-the-most = [
      "util"
      "exec"
      "--"
      "sh"
      "-c"
      ''
        jj log --no-graph -r recent_trunk_ancestors \
          -T 'self.google_modified_paths().map(|p| p ++ "\n").join("")' \
          -- . \
          | sort | uniq -c | sort -nr | head -20
      ''
    ];
    who-built-this = [
      "util"
      "exec"
      "--"
      "sh"
      "-c"
      ''
        jj log --no-graph -r 'ancestors(trunk()) & ~merges()' \
          -T 'self.author().name() ++ "\n"' \
          -- . \
          | sort | uniq -c | sort -nr
      ''
    ];

    where-do-bugs-cluster = [
      "util"
      "exec"
      "--"
      "sh"
      "-c"
      ''
        jj log --no-graph -r bug_commits \
          -T 'self.google_modified_paths().map(|p| p ++ "\n").join("")' \
          -- . \
          | sort | uniq -c | sort -nr | head -20
      ''
    ];
    is-project-accelerating = [
      "util"
      "exec"
      "--"
      "sh"
      "-c"
      ''
        jj log --no-graph -r 'ancestors(trunk())' \
          -T 'self.committer().timestamp().format("%Y-%m") ++ "\n"' \
          -- . \
          | sort | uniq -c
      ''
    ];
    team-firefighting = [
      "log"
      "--no-graph"
      "-r"
      "firefighter_commits"
      "--"
      "."
    ];

  };

  ossAliases = {
    what-changes-the-most = [
      "util"
      "exec"
      "--"
      "sh"
      "-c"
      ''
        jj log --no-graph -r recent_trunk_ancestors \
          -T 'self.diff().files().map(|f| f.path() ++ "\n").join("")' \
          | sort | uniq -c | sort -nr | head -20
      ''
    ];
    who-built-this = [
      "util"
      "exec"
      "--"
      "sh"
      "-c"
      ''
        jj log --no-graph -r 'ancestors(trunk()) & ~merges()' \
          -T 'self.author().name() ++ "\n"' \
          | sort | uniq -c | sort -nr
      ''
    ];

    where-do-bugs-cluster = [
      "util"
      "exec"
      "--"
      "sh"
      "-c"
      ''
        jj log --no-graph -r bug_commits \
          -T 'self.diff().files().map(|f| f.path() ++ "\n").join("")' \
          | sort | uniq -c | sort -nr | head -20
      ''
    ];
    is-project-accelerating = [
      "util"
      "exec"
      "--"
      "sh"
      "-c"
      ''
        jj log --no-graph -r 'ancestors(trunk())' \
          -T 'self.committer().timestamp().format("%Y-%m") ++ "\n"' \
          | sort | uniq -c
      ''
    ];
    team-firefighting = [
      "log"
      "--no-graph"
      "-r"
      "firefighter_commits"
    ];
    l = [
      "log"
      "-r"
      "trunk()::"
    ];
  };

  commonAliases = {
    more = [
      "log"
      "-r"
      "trunk()::"
      "--no-graph"
      "--template"
    ];

  };

  allAliases = commonAliases // (if isWork then workAliases else ossAliases);

in

{
  programs.jujutsu = {
    enable = true;
    settings = {
      templates = {
        # draft_commit_description is what ends up in the editor.
        draft_commit_description = ''
          concat(
            builtin_draft_commit_description,
            "\nJJ: ignore-rest\n",
            diff.git(),
          )
        '';
      };
      revset-aliases = {
        recent_trunk_ancestors = ''ancestors(trunk()) & committer_date(after:"1 year ago")'';
        bug_commits = ''ancestors(trunk()) & description(regex:"(?i)fix|bug|broken|")'';
        firefighter_commits = ''recent_trunk_ancestors & description(regex:"(?i)revert|hotfix|emergency|rollback|omg|irm")'';
      };
      template-aliases = {
        # Gets a list of files with more than n_lines added that match pattern.
        # Accept a pattern like **/*.py
        "than_n(pattern, n_lines)" = ''
          self.change_id().shortest()  ++

          self.diff(pattern)
            .stat()
            .files()
            .filter(|e| e.lines_added() > n_lines || e.lines_removed() > n_lines)
            .map(|e| " " ++ e.path() ++ " " ++ if(e.lines_added() > n_lines, e.lines_added(), e.lines_removed()) ++ " ")

          ++ "\n"
        '';
      };

      "--scope" = [
        {
          "--when.commands" = [
            "diff"
            "show"
          ];
          ui = {
            pager = "${pkgs.delta}/bin/delta";
            diff-formatter = ":git";
          };
        }
      ];

      ui = {
        diff-editor = "vimdiff";
        merge-editor = "${pkgs.mergiraf}/bin/mergiraf";
        default-command = "status";
      };

      aliases = allAliases;

      user = {
        name = "Hugh Mandalidis";
        email = email;
      };
    };
  };

}
