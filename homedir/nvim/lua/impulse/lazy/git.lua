return {
    -- Git integration.
    {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
            vim.keymap.set('n', ']h', ':Gitsigns next_hunk<CR>')
            vim.keymap.set('n', '[h', ':Gitsigns prev_hunk<CR>')
            vim.keymap.set('n', 'gs', ':Gitsigns stage_hunk<CR>')
            vim.keymap.set('n', 'gS', ':Gitsigns undo_stage_hunk<CR>')
            vim.keymap.set('n', 'gp', ':Gitsigns preview_hunk<CR>')
            vim.keymap.set('n', 'gb', ':Gitsigns blame_line<CR>')
        end,
    },
    -- 'tpope/vim-rhubarb',
    -- {
    --     'tpope/vim-fugitive',
    --     config = function()
    --     vim.cmd [[
    --         nnoremap <leader>vs :G<CR>
    --         nnoremap <leader>vc :G commit<CR>
    --         nnoremap <leader>vp :G push<CR>
    --         nnoremap <leader>vd :G diff<CR>
    --         nnoremap <leader>vb :G blame<CR>
    --         nnoremap <leader>vl :G log<CR>
    --         nnoremap <leader>vw :G write<CR>
    --         nnoremap <leader>vW :G write!<CR>
    --         nnoremap <leader>vq :G quit<CR>
    --         nnoremap <leader>vQ :G quit!<CR>
    --     ]]
    --     end
    -- },
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",  -- required
            "sindrets/diffview.nvim", -- optional - Diff integration

            -- Only one of these is needed.
            "nvim-telescope/telescope.nvim", -- optional
        },
        config = true
    },
}
