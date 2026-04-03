vim.api.nvim_create_autocmd("FileType", {
    pattern = {'*'},
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        local lang = vim.treesitter.language.get_lang(ft)
        -- Ignore languages that treesitter fails on
        ignore_langs = {
            ["TelescopeResults"] = true,
            ["TelescopePrompt"] = true,
            ["cmp_menu"] = true,
            ["cmp_docs"] = true,
            ["fyler"] = true,
            ["jjdescription"] = true,
            ["conf"] = true,
            ["nvim-undotree"] = true
        }
        if ignore_langs[lang] then return end

        local lang_to_install = lang
        if lang == 'conf' then lang_to_install = 'pbtxt' end
        require('nvim-treesitter').install(lang_to_install)
        vim.treesitter.language.add(lang_to_install)
        vim.treesitter.start(args.buf, lang_to_install)
        vim.bo[args.buf].indentexpr =
            "v:lua.require'nvim-treesitter'.indentexpr()"
    end
})
