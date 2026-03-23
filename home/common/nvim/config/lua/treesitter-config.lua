vim.api.nvim_create_autocmd("FileType", {
    pattern = {'*'},
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        local lang = vim.treesitter.language.get_lang(ft)
        if lang == 'TelescopeResults' or lang == 'TelescopePrompt' then
            return
        end
        require('nvim-treesitter').install(lang)
        vim.treesitter.language.add(lang)
        vim.treesitter.start(args.buf, lang)
        vim.bo[args.buf].indentexpr =
            "v:lua.require'nvim-treesitter'.indentexpr()"
    end
})
