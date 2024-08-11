local ft = require('guard.filetype')


-- TODO rust, nix, python
ft('go'):fmt('gofumpt')
		:append('golines')

-- ft('typescript,javascript,typescriptreact'):fmt('prettier')

require('guard').setup({
	fmt_on_save = true,
})
