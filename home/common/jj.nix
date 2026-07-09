{ isWork, ... }:

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

      aliases =
        if isWork then
          {
            # Google3 optimized aliases (works for both Git and Piper repos on work machine)
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
          }
        else
          {
            # Standard/open-source aliases
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
          };
    };
  };

}
