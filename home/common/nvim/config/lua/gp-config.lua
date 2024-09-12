require('gp').setup({
    -- Please start with minimal config possible.
    -- Just openai_api_key if you don't have OPENAI_API_KEY env set up.
    -- Defaults change over time to improve things, options might get deprecated.
    -- It's better to change only things where the default doesn't fit your needs.

    -- required openai api key (string or table with command and arguments)
    -- openai_api_key = { "cat", "path_to/openai_api_key" },
    -- openai_api_key = { "bw", "get", "password", "OPENAI_API_KEY" },
    -- openai_api_key: "sk-...",
    -- openai_api_key = os.getenv("env_name.."),
    openai_api_key = os.getenv("OPENAI_API_KEY"),

    -- at least one working provider is required
    -- to disable a provider set it to empty table like openai = {}
    providers = {
        -- secrets can be strings or tables with command and arguments
        -- secret = { "cat", "path_to/openai_api_key" },
        -- secret = { "bw", "get", "password", "OPENAI_API_KEY" },
        -- secret : "sk-...",
        -- secret = os.getenv("env_name.."),
        openai = {
            disable = true,
            endpoint = "https://api.openai.com/v1/chat/completions"
            -- secret = os.getenv("OPENAI_API_KEY"),
        },
        ollama = {
            disable = false,
            endpoint = "http://localhost:11434/v1/chat/completions",
            secret = ""
        },
        lmstudio = {
            disable = true,
            endpoint = "http://localhost:1234/v1/chat/completions",
            secret = "dummy_secret"
        }
    },

    -- prefix for all commands
    cmd_prefix = "Gp",

    -- log file location
    log_file = vim.fn.stdpath("log"):gsub("/$", "") .. "/gp.nvim.log",
    -- write sensitive data to log file for	debugging purposes (like api keys)
    log_sensitive = false,

    -- directory for persisting state dynamically changed by user (like model or persona)
    state_dir = vim.fn.stdpath("data"):gsub("/$", "") .. "/gp/persisted",

    -- default agent names set during startup, if nil last used agent is used
    default_command_agent = nil,
    default_chat_agent = nil,

    -- default command agents (model + persona)
    -- name, model and system_prompt are mandatory fields
    -- to use agent for chat set chat = true, for command set command = true
    -- to remove some default agent completely set it like:
    -- agents = {  { name = "ChatGPT3-5", disable = true, }, ... },
    agents = {
        {name = "ExampleDisabledAgent", disable = true}, {
            name = "ChatGPT4o",
            chat = true,
            command = false,
            disable = true,
            -- string with model name or table with model name and parameters
            model = {model = "gpt-4o", temperature = 1.1, top_p = 1},
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").chat_system_prompt
        }, {
            name = "ChatOllamaLlama3.1-8B",
            provider = "ollama",
            chat = true,
            command = true,
            -- string with model name or table with model name and parameters
            model = {
                model = "llama3.1",
                temperature = 0.4,
                top_p = 1,
                min_p = 0.05
            },
            -- TODO diagnose this: curl http://localhost:11434/v1/chat/completions -d '{ "model": "llama3.1","messages":[ {"role": "user", "content": "Why is the sky blue?"}], "stream": false}'
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = require("gp.defaults").code_system_prompt
        }, {
            provider = "lmstudio",
            name = "ChatLMStudio",
            chat = true,
            command = false,

            disable = true,
            -- string with model name or table with model name and parameters
            model = {
                model = "dummy",
                temperature = 0.97,
                top_p = 1,
                num_ctx = 8192
            },
            -- system prompt (use this to specify the persona/role of the AI)
            system_prompt = "You are a general AI assistant."
        }
    },

    -- directory for storing chat files
    chat_dir = vim.fn.stdpath("data"):gsub("/$", "") .. "/gp/chats",
    -- chat user prompt prefix
    chat_user_prefix = "💬:",
    -- chat assistant prompt prefix (static string or a table {static, template})
    -- first string has to be static, second string can contain template {{agent}}
    -- just a static string is legacy and the [{{agent}}] element is added automatically
    -- if you really want just a static string, make it a table with one element { "🤖:" }
    chat_assistant_prefix = {"🤖:", "[{{agent}}]"},
    -- The banner shown at the top of each chat file.
    chat_template = require("gp.defaults").chat_template,
    -- if you want more real estate in your chat files and don't need the helper text
    -- chat_template = require("gp.defaults").short_chat_template,
    -- chat topic generation prompt
    chat_topic_gen_prompt = "Summarize the topic of our conversation above" ..
        " in two or three words. Respond only with those words.",
    -- chat topic model (string with model name or table with model name and parameters)
    -- explicitly confirm deletion of a chat file
    chat_confirm_delete = true,
    -- conceal model parameters in chat
    chat_conceal_model_params = true,
    -- local shortcuts bound to the chat buffer
    -- (be careful to choose something which will work across specified modes)
    chat_shortcut_respond = {
        modes = {"n", "i", "v", "x"},
        shortcut = "<C-g><C-g>"
    },
    chat_shortcut_delete = {modes = {"n", "i", "v", "x"}, shortcut = "<C-g>d"},
    chat_shortcut_stop = {modes = {"n", "i", "v", "x"}, shortcut = "<C-g>s"},
    chat_shortcut_new = {modes = {"n", "i", "v", "x"}, shortcut = "<C-g>c"},
    -- default search term when using :GpChatFinder
    chat_finder_pattern = "topic ",
    -- if true, finished ChatResponder won't move the cursor to the end of the buffer
    chat_free_cursor = false,
    -- use prompt buftype for chats (:h prompt-buffer)
    chat_prompt_buf_type = false,

    -- how to display GpChatToggle or GpContext
    ---@type "popup" | "split" | "vsplit" | "tabnew"
    toggle_target = "vsplit",

    -- styling for chatfinder
    ---@type "single" | "double" | "rounded" | "solid" | "shadow" | "none"
    style_chat_finder_border = "single",
    -- margins are number of characters or lines
    style_chat_finder_margin_bottom = 8,
    style_chat_finder_margin_left = 1,
    style_chat_finder_margin_right = 2,
    style_chat_finder_margin_top = 2,
    -- how wide should the preview be, number between 0.0 and 1.0
    style_chat_finder_preview_ratio = 0.5,

    -- styling for popup
    ---@type "single" | "double" | "rounded" | "solid" | "shadow" | "none"
    style_popup_border = "single",
    -- margins are number of characters or lines
    style_popup_margin_bottom = 8,
    style_popup_margin_left = 1,
    style_popup_margin_right = 2,
    style_popup_margin_top = 2,
    style_popup_max_width = 160,

    -- in case of visibility colisions with other plugins, you can increase/decrease zindex
    zindex = 49,

    -- command config and templates below are used by commands like GpRewrite, GpEnew, etc.
    -- command prompt prefix for asking user for input (supports {{agent}} template variable)
    command_prompt_prefix_template = "🤖 {{agent}} ~ ",
    -- auto select command response (easier chaining of commands)
    -- if false it also frees up the buffer cursor for further editing elsewhere
    command_auto_select_response = true,

    -- templates
    template_selection = "I have the following from {{filename}}:" ..
        "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}",
    template_rewrite = "I have the following from {{filename}}:" ..
        "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}" ..
        "\n\nRespond exclusively with the snippet that should replace the selection above.",
    template_append = "I have the following from {{filename}}:" ..
        "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}" ..
        "\n\nRespond exclusively with the snippet that should be appended after the selection above.",
    template_prepend = "I have the following from {{filename}}:" ..
        "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}" ..
        "\n\nRespond exclusively with the snippet that should be prepended before the selection above.",
    template_command = "{{command}}",

    -- Audio input
    whisper = {disable = true},

    -- image generation settings
    image = {disable = true},

    -- example hook functions (see Extend functionality section in the README)
    hooks = {
        -- GpInspectPlugin provides a detailed inspection of the plugin state
        InspectPlugin = function(plugin, params)
            local bufnr = vim.api.nvim_create_buf(false, true)
            local copy = vim.deepcopy(plugin)
            local key = copy.config.openai_api_key or ""
            copy.config.openai_api_key = key:sub(1, 3) ..
                                             string.rep("*", #key - 6) ..
                                             key:sub(-3)
            local plugin_info = string.format("Plugin structure:\n%s",
                                              vim.inspect(copy))
            local params_info = string.format("Command params:\n%s",
                                              vim.inspect(params))
            local lines = vim.split(plugin_info .. "\n" .. params_info, "\n")
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
            vim.api.nvim_win_set_buf(0, bufnr)
        end,

        -- GpInspectLog for checking the log file
        InspectLog = function(plugin, params)
            local log_file = plugin.config.log_file
            local buffer = plugin.helpers.get_buffer(log_file)
            if not buffer then
                vim.cmd("e " .. log_file)
            else
                vim.cmd("buffer " .. buffer)
            end
        end,

        -- GpImplement rewrites the provided selection/range based on comments in it
        Implement = function(gp, params)
            local template = "Having following from {{filename}}:\n\n" ..
                                 "```{{filetype}}\n{{selection}}\n```\n\n" ..
                                 "Please rewrite this according to the contained instructions." ..
                                 "\n\nRespond exclusively with the snippet that should replace the selection above."

            local agent = gp.get_command_agent()
            gp.logger.info("Implementing selection with agent: " .. agent.name)

            gp.Prompt(params, gp.Target.rewrite, agent, template, nil, -- command will run directly without any prompting for user input
                      nil -- no predefined instructions (e.g. speech-to-text from Whisper)
            )
        end

        -- your own functions can go here, see README for more examples like
        -- :GpExplain, :GpUnitTests.., :GpTranslator etc.

        -- -- example of making :%GpChatNew a dedicated command which
        -- -- opens new chat with the entire current buffer as a context
        -- BufferChatNew = function(gp, _)
        -- 	-- call GpChatNew command in range mode on whole buffer
        -- 	vim.api.nvim_command("%" .. gp.config.cmd_prefix .. "ChatNew")
        -- end,

        -- -- example of adding command which opens new chat dedicated for translation
        -- Translator = function(gp, params)
        -- 	local chat_system_prompt = "You are a Translator, please translate between English and Chinese."
        -- 	gp.cmd.ChatNew(params, chat_system_prompt)
        --
        -- 	-- -- you can also create a chat with a specific fixed agent like this:
        -- 	-- local agent = gp.get_chat_agent("ChatGPT4o")
        -- 	-- gp.cmd.ChatNew(params, chat_system_prompt, agent)
        -- end,

        -- -- example of adding command which writes unit tests for the selected code
        -- UnitTests = function(gp, params)
        -- 	local template = "I have the following code from {{filename}}:\n\n"
        -- 		.. "```{{filetype}}\n{{selection}}\n```\n\n"
        -- 		.. "Please respond by writing table driven unit tests for the code above."
        -- 	local agent = gp.get_command_agent()
        -- 	gp.Prompt(params, gp.Target.enew, agent, template)
        -- end,

        -- -- example of adding command which explains the selected code
        -- Explain = function(gp, params)
        -- 	local template = "I have the following code from {{filename}}:\n\n"
        -- 		.. "```{{filetype}}\n{{selection}}\n```\n\n"
        -- 		.. "Please respond by explaining the code above."
        -- 	local agent = gp.get_chat_agent()
        -- 	gp.Prompt(params, gp.Target.popup, agent, template)
        -- end,
    }
})
