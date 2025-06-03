return {
	"epwalsh/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	ft = "markdown",
	-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
	-- event = {
	--   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
	--   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
	--   "BufReadPre path/to/my-vault/**.md",
	--   "BufNewFile path/to/my-vault/**.md",
	-- },
	dependencies = {
		-- Required.
		"nvim-lua/plenary.nvim",

		-- see below for full list of optional dependencies 👇
	},
	opts = {
		workspaces = {
			{
				name = "datasink",
				path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/datasink",
			},
		},
		notes_subdir = "Inbox",
		new_notes_location = "notes_subdir",

		disable_frontmatter = true,
		templates = {
			subdir = "templates",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M:%S",
		},

		-- see below for full list of options 👇
		daily_notes = {
			folder = "dailies",
			date_format = "%Y-%m-%d",
			template = nil,
		},

		completion = {
			nvim_cmp = true,
			min_chars = 2,
		},

		picker = {
			name = "telescope.nvim",
			mappings = {
				new = "<C-x>",
				insert_link = "<C-l>",
			},
		},

		-- key mappings, below are the defaults
		mappings = {
			-- overrides the 'gf' mapping to work on markdown/wiki links within your vault
			["gf"] = {
				action = function()
					return require("obsidian").util.gf_passthrough()
				end,
				opts = { noremap = false, expr = true, buffer = true },
			},
			-- toggle check-boxes
			-- ["<leader>ch"] = {
			--   action = function()
			--     return require("obsidian").util.toggle_checkbox()
			--   end,
			--   opts = { buffer = true },
			-- },
		},
		ui = {
			-- Disable some things below here because I set these manually for all Markdown files using treesitter
			checkboxes = {},
			bullets = {},
		},
		sort_by = "modified",
		sort_reversed = true,
	},
}
