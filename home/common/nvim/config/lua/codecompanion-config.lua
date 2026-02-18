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
    opts = {
        log_level = "TRACE" -- TRACE|DEBUG|ERROR|INFO
    }
})
