require("codecompanion").setup({
    strategies = {
        chat = {adapter = "gemini"},
        inline = {adapter = "gemini"},
        cmd = {adapter = "gemini"}
    },
    display = {chat = {window = {position = 'right'}}}
})
