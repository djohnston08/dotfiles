return {
	-- Python specific plugins
	{
		"linux-cultist/venv-selector.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"nvim-telescope/telescope.nvim",
			"mfussenegger/nvim-dap-python",
		},
		event = "VeryLazy",
		config = function()
			require("venv-selector").setup({
				name = { "venv", ".venv", "env", ".env" },
				auto_refresh = true,
			})
			vim.keymap.set("n", "<leader>vs", "<cmd>VenvSelect<cr>", { desc = "Select Python venv" })
			vim.keymap.set("n", "<leader>vc", "<cmd>VenvSelectCached<cr>", { desc = "Select cached venv" })
		end,
	},


	-- Python docstrings
	{
		"danymat/neogen",
		dependencies = "nvim-treesitter/nvim-treesitter",
		ft = "python",
		config = function()
			require("neogen").setup({
				enabled = true,
				languages = {
					python = {
						template = {
							annotation_convention = "google_docstrings",
						},
					},
				},
			})
			vim.keymap.set("n", "<leader>pd", "<cmd>Neogen<cr>", { desc = "Generate docstring" })
		end,
	},


	-- Python import sorting
	{
		"stevearc/conform.nvim",
		opts = function(_, opts)
			opts.formatters_by_ft = opts.formatters_by_ft or {}
			opts.formatters_by_ft.python = { "ruff_format", "ruff_organize_imports" }
			return opts
		end,
	},
}