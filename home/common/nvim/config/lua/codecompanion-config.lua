require("codecompanion").setup({
    strategies = {
        chat = {
            adapter = "gemini",
            variables = {["buffer"] = {opts = {default_params = 'sync_all'}}}
        },
        inline = {adapter = "gemini"},
        cmd = {adapter = "gemini"}
    },
    display = {chat = {window = {position = 'right'}}},
    adapters = {
        acp = {
            gemini_cli = function()
                return require("codecompanion.adapters").extend("gemini_cli", {
                    defaults = {auth_method = "gemini-api-key"}
                })
            end
        }
    }
})
