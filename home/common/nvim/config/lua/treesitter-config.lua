vim.api.nvim_create_autocmd("FileType", {
    pattern = {'*'},
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        local lang = vim.treesitter.language.get_lang(ft)
        -- Ignore languages that treesitter fails on
        if lang == 'TelescopeResults' or lang == 'TelescopePrompt' or lang ==
            'cmp_menu' or lang == 'cmp_docs' or lang == 'fyler' or lang ==
            'jjdescription' or lang == 'conf' then return end

        local lang_to_install = lang
        if lang == 'conf' then lang_to_install = 'pbtxt' end
        require('nvim-treesitter').install(lang_to_install)
        vim.treesitter.language.add(lang_to_install)
        vim.treesitter.start(args.buf, lang_to_install)
        vim.bo[args.buf].indentexpr =
            "v:lua.require'nvim-treesitter'.indentexpr()"
    end
})
