-- highlight piccolo files
vim.filetype.add({pattern = {
	['.*pi'] = 'python',
	['*.gcl'] = 'python',
}})

-- https://user.git.corp.google.com/cnieves/critique-nvim/
require("critique.comments").setup({
    -- Automatically fetch comments after setup and on BufEnter events.
    auto_fetch = true,
    -- If true, unresolved comments are automatically rendered when a buffer is opened.
    auto_render = true,
    -- Debounce time for throttling stubby requests to Critique, in milliseconds. Default is 10 seconds.
    debounce = 10000,
    display = {
        -- Max width in character to render a comment's text before wrapping to a newline.
        max_comment_width = 110,
        -- Render comment threads marked as resolved?
        render_resolved_threads = true
    },
    -- Debug message level
    debug = 0,
    -- Whether or not the new comments notification includes file names.
    verbose_notifications = true
})
-- https://g3doc.corp.google.com/experimental/users/fentanes/googlepaths.nvim/README.md?cl=head
require("googlepaths").setup()

-- http://g3doc.corp.google.com/experimental/users/vintharas/goog-terms.nvim/README.md?cl=head
require('goog-terms').setup({
    tooltip_key = "<Leader>gt", -- Key to show tooltip
    action_key = "<Leader>ga", -- Key to perform action
    highlight_blocklist = {
        "^%s*%-%-%-" -- Lua type annotations
    },
    -- Customize the tooltip styles
    tooltip_styles = {
        border = 'single',
        focusable = false,
        wrap = true,
        max_width = 200,
        max_height = 50
    },
    -- To enable highlighting when pasting enable this option
    enable_highlighting_when_pasting = true
})
--

-- https://g3doc.corp.google.com/experimental/users/vicentecaycedo/cmp-buganizer/README.md?cl=head
require('cmp-buganizer').setup()

-- https://g3doc.corp.google.com/experimental/users/vicentecaycedo/cmp-buganizer/README.md?cl=head
require('cmp-googlers').setup()
