vim.api.nvim_create_autocmd("FileType", {
    pattern = {'*'},
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        local lang = vim.treesitter.language.get_lang(ft)

        -- Ignore languages that treesitter fails on
        local available_langs = require('nvim-treesitter').get_available()
        local is_available = vim.tbl_contains(available_langs, lang)
        if not is_available then return end

        local lang_to_install = lang
        if lang == 'conf' then lang_to_install = 'pbtxt' end
        require('nvim-treesitter').install(lang_to_install)
        vim.treesitter.language.add(lang_to_install)
        vim.treesitter.start(args.buf, lang_to_install)
        vim.bo[args.buf].indentexpr =
            "v:lua.require'nvim-treesitter'.indentexpr()"
    end
})
