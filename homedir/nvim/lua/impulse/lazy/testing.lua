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
          function! FloatermStrategy(cmd)
            execute 'silent FloatermKill'
            execute 'FloatermNew! '.a:cmd.' |less -X'
          endfunction

          let g:test#custom_strategies = {'floaterm': function('FloatermStrategy')}
          let g:test#strategy = 'floaterm'
          let g:test#runner_commands = ['PHPUnit']
          let g:test#php#phpunit#executable = 'sail artisan test'
        ]])

		vim.keymap.set("n", "<Leader>ds", ":let test#php#phpunit#executable = 'sail debug test'<cr>")
		vim.keymap.set("n", "<Leader>ns", ":let test#php#phpunit#executable = 'sail artisan test'<cr>")
	end,
}
