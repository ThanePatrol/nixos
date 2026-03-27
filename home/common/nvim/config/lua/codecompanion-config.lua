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
                        auth_method = "gemini-api-key",
                        model = "auto-gemini-3"
                    }
                })
            end
        }
    }
})
