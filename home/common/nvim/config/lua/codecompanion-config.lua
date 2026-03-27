require("codecompanion").setup({
    -- New default from https://github.com/olimorris/codecompanion.nvim/discussions/2643
    interactions = {chat = {adapter = "gemini_cli", model = "auto-gemini-3"}},
    strategies = {
        chat = {
            adapter = "gemini_cli",
            variables = {["buffer"] = {opts = {default_params = 'sync_all'}}}
        },
        inline = {adapter = "gemini_cli"},
        cmd = {adapter = "gemini_cli"}
    },
    display = {chat = {window = {position = 'right'}}},
    adapters = {
        acp = {
            gemini_cli = function()
                return require("codecompanion.adapters").extend("gemini_cli", {
                    defaults = {
                        auth_method = "gemini-api-key", -- Needs to be this and a blank env var for work LOAS
                        model = "auto-gemini-3",
                        timeout = 60000 -- 60 seconds timeout required for work CLI
                    },
                    commands = {
                        default = {
                            "/google/bin/releases/gemini-cli/tools/gemini", -- Absolute path required for work
                            "--devai", "--experimental-acp"
                            -- '--allowed-tools="ShellTool(blaze)"'
                        }
                    }
                })
            end
        }
    }
})
