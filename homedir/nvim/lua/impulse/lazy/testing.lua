return {
    "vim-test/vim-test",
    config = function()
        vim.keymap.set("n", "<Leader>gtn", ":TestNearest --group third-party<CR>")
        vim.keymap.set("n", "<Leader>tn", ":TestNearest<CR>")
        vim.keymap.set("n", "<Leader>tf", ":TestFile<CR>")
        vim.keymap.set("n", "<Leader>ts", ":TestSuite<CR>")
        vim.keymap.set("n", "<Leader>tl", ":TestLast<CR>")
        vim.keymap.set("n", "<Leader>tv", ":TestVisit<CR>")

        vim.cmd([[
          function! ToggletermStrategy(cmd)
            lua << EOF
              local Terminal = require('toggleterm.terminal').Terminal
              local cmd = vim.fn.eval('a:cmd')
              local test_term = Terminal:new({
                cmd = cmd,
                direction = 'float',
                close_on_exit = false,
                float_opts = {
                  border = 'curved'
                }
              })
              test_term:toggle()
EOF
          endfunction

          let g:test#custom_strategies = {'toggleterm': function('ToggletermStrategy')}
          let g:test#strategy = 'toggleterm'
          let g:test#runner_commands = ['PHPUnit']
          let g:test#php#phpunit#executable = 'sail artisan test'
        ]])

        vim.keymap.set("n", "<Leader>ds", ":let test#php#phpunit#executable = 'sail debug test'<cr>")
        vim.keymap.set("n", "<Leader>ns", ":let test#php#phpunit#executable = 'sail artisan test'<cr>")
    end,
}
