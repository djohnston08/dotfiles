return {
	{
		"nvim-lua/plenary.nvim",
		name = "plenary",
	},

	-- "github/copilot.vim",

	-- All closing buffers without closing the split window.
	{
		"famiu/bufdelete.nvim",
		config = function()
			vim.keymap.set("n", "<Leader>q", ":Bdelete<CR>")
		end,
	},

	-- Add, change, or delete surrounding text
	{
		"tpope/vim-surround",
	},

	"wakatime/vim-wakatime",
	-- Modern file explorer
	{
		"stevearc/oil.nvim",
		opts = {},
		dependencies = { "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "<leader>o", "<cmd>Oil<cr>", desc = "Open oil file explorer" },
		},
	},

	-- Enhanced terminal management
	{
		"akinsho/toggleterm.nvim",
		config = function()
			require("toggleterm").setup({
				open_mapping = [[<F1>]],
				direction = "float",
				float_opts = { border = "curved" },
			})

			local Terminal = require("toggleterm.terminal").Terminal
			local lazygit = Terminal:new({
				cmd = "lazygit",
				hidden = true,
				direction = "float",
				float_opts = { border = "double" },
			})

			vim.keymap.set("n", "<leader>gl", function()
				lazygit:toggle()
			end, { desc = "Lazygit" })
		end,
	},
	-- {
	--     'voldikss/vim-floaterm',
	--     config = function()
	--         vim.g.floaterm_width = 0.8
	--         vim.g.floaterm_height = 0.8
	--         vim.keymap.set('n', '<F1>', ':FloatermToggle<CR>')
	--         vim.keymap.set('t', '<F1>', '<C-\\><C-n>:FloatermToggle<CR>')
	--         vim.cmd([[
	--       highlight link Floaterm CursorLine
	--       highlight link FloatermBorder CursorLineBg
	--     ]])
	--     end
	-- },
	"tpope/vim-commentary",
}
