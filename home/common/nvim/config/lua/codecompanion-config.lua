local function settings()
    if require('utils').is_cloudtop() then
        return {
            interactions = {
                chat = {
                    adapter = "jetski_acp",
                    model = "auto-gemini-3",
                    tools = {
                        ["run_command"] = {
                            opts = {
                                require_approval_before = false,
                                require_cmd_approval = false
                            }
                        },
                        ["read_file"] = {
                            opts = {
                                require_approval_before = false,
                                require_cmd_approval = false
                            }
                        }
                    }
                }
            },
            strategies = {
                chat = {
                    adapter = "jetski_acp",
                    variables = {
                        ["buffer"] = {opts = {default_params = 'sync_all'}}
                    }
                },
                inline = {adapter = "jetski_acp"},
                cmd = {adapter = "jetski_acp"}
            },
            display = {chat = {window = {position = 'right'}}},
            adapters = {
                acp = {
                    jetski_acp = function()
                        return require("codecompanion.adapters").extend(
                                   "gemini_cli", {
                                name = "jetski_acp",
                                defaults = {
                                    auth_method = "gemini-api-key", -- Needs to be this and a blank env var for work LOAS
                                    timeout = 120000, -- 120 seconds timeout required for work CLI
                                    session_config_options = {
                                        model = "auto-gemini-3"
                                    }
                                },
                                commands = {
                                    default = {
                                        "/usr/local/google/home/hmandalidis/.local/bin/jetski_acp",
                                        "--is_google3_workspace"
                                    }
                                }
                            })
                    end
                }
            },
            opts = {
                log_level = "TRACE" -- TRACE|DEBUG|ERROR|INFO
            }
        }

    else
        -- TODO add acp for home.
        return {}

    end
end

require("codecompanion").setup(settings())
