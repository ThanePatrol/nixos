local ft = require('guard.filetype')


local gofumpt = {
	cmd = "gofumpt",
	args = {"-w"},
	stdin = true,
	fname = true,
}

local golines = {
	cmd = "golines",
	args = {"-m", "128", "-w"},
	stdin = true,
	fname = true,
}

local wsl = {
	cmd = "wsl",
	args = {"-fix"},
	stdin = true,
	fname = true,
}

-- TODO rust, nix, python + verify this is working
ft('go'):fmt(gofumpt)
		:fmt(golines)
		:fmt(wsl)




-- ft('typescript,javascript,typescriptreact'):fmt('prettier')

require('guard').setup({
	fmt_on_save = true,
})
