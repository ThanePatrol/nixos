-- setup for rust-nvim tools
local opts = {
    tools = {
        runnables = {use_telescope = true},
        inlay_hints = {
            auto = true,
            show_parameter_hints = false,
            parameter_hints_prefix = '',
            other_hints_prefix = ''
        }
    }
}

require('rust-tools').setup(opts)

