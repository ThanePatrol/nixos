local dap = require('dap')

local handle = io.popen('which gdb')
-- TODO nil check
local gdb_path = handle:read('*a')
handle:close()

dap.adapters.gdb = {
  type = 'executable',
  command = 'gdb',
  args = {"-i", "dap"}

}

dap.configurations.rust = {
	name = 'Launch',
	type = 'gdb',
	request = 'launch',

	program = function()

		return vim.fn.input('/run/current-system/sw/bin/gdb', vim.fn.getcwd() .. '/', 'file')
	end,
	cwd = "${workspaceFolder}",
}

-- TODO custom setup
require("dapui").setup()
require("nvim-dap-virtual-text").setup()

local go_dap = require('dap-go')
go_dap.setup()

