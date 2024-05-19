local dap = require('dap')

vim.keymap.set('n', '<Leader>dt', dap.toggle_breakpoint, {})
vim.keymap.set('n', '<Leader>dc', dap.continue, {})

local dapui = require('dapui')

dap.listeners.before.attach.dapui_config = function() dapui.open() end
dap.listeners.before.launch.dapui_config = function() dapui.open() end
dap.listeners.before.event_terminated.dapui_config = function() dapui.open() end
dap.listeners.before.event_exited.dapui_config = function() dapui.open() end

require("nvim-dap-virtual-text").setup()

local go_dap = require('dap-go')
go_dap.setup()

