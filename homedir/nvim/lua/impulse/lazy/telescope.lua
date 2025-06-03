return {
	"nvim-telescope/telescope.nvim",

	tag = "0.1.8",

	dependencies = {
		"nvim-lua/plenary.nvim",
		"kyazdani42/nvim-web-devicons",
		"nvim-telescope/telescope-live-grep-args.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},

	config = function()
		local actions = require("telescope.actions")
		require("telescope").setup({
			defaults = {
				path_display = { truncate = 1 },
				prompt_prefix = "   ",
				selection_caret = "  ",
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
					"--hidden",
					"--no-ignore-vcs",
				},
				layout_strategy = "vertical",
				layout_config = {
					-- prompt_position = 'top',
					vertical = {
						preview_height = 0.7,
						size = {
							width = "95%",
							height = "95%",
						},
					},
				},
				sorting_strategy = "ascending",
				mappings = {
					i = {
						["<esc>"] = actions.close,
						["<C-Down>"] = actions.cycle_history_next,
						["<C-Up>"] = actions.cycle_history_prev,
					},
				},
				-- file_ignore_patterns = { '.git/' },
			},
			pickers = {
				-- find_files = {
				--     hidden = true,
				-- },
				buffers = {
					previewer = false,
					layout_config = {
						width = 80,
					},
				},
				oldfiles = {
					prompt_title = "History",
				},
				lsp_references = {
					previewer = false,
				},
			},
		})

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>f", [[<cmd>lua require('telescope.builtin').find_files()<CR>]])
		vim.keymap.set(
			"n",
			"<leader>F",
			[[<cmd>lua require('telescope.builtin').find_files({ no_ignore = true, hidden = true, prompt_title = 'All Files' })<CR>]]
		)
		vim.keymap.set("n", "<leader>b", [[<cmd>lua require('telescope.builtin').buffers()<CR>]])
		vim.keymap.set(
			"n",
			"<leader>g",
			[[<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>]]
		)
		vim.keymap.set("n", "<leader>h", [[<cmd>lua require('telescope.builtin').oldfiles()<CR>]])
		vim.keymap.set("n", "<leader>s", [[<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>]])
		-- vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
		vim.keymap.set("n", "<C-p>", builtin.git_files, {})
		vim.keymap.set("n", "<leader>pws", function()
			local word = vim.fn.expand("<cword>")
			builtin.grep_string({ search = word })
		end)
		vim.keymap.set("n", "<leader>pWs", function()
			local word = vim.fn.expand("<cWORD>")
			builtin.grep_string({ search = word })
		end)
		vim.keymap.set("n", "<leader>ps", function()
			builtin.grep_string({ search = vim.fn.input("Grep > ") })
		end)
		vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})
	end,
}
