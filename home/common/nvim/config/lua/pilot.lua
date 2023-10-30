-- https://github.com/zbirenbaum/copilot-cmp
require('copilot').setup({
    suggestion = { enabled = false },
    panel = { enabled = false },
    filetypes = { yaml = false, norg = false, ['.norg'] = false },
})

require('copilot_cmp').setup()
