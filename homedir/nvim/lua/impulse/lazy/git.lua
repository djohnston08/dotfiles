return {
	-- Git worktree plugin
	{
		"polarmutex/git-worktree.nvim",
		version = "^2",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			-- Configure git-worktree using vim global variables
			vim.g.git_worktree = {
				change_directory_command = "cd",
				update_on_change = true,
				update_on_change_command = "e .",
				clearjumps_on_change = true,
				confirm_telescope_deletions = true,
				autopush = false,
			}

			-- Load the telescope extension
			require("telescope").load_extension("git_worktree")
			
			-- Set up hooks to update ToggleTerm when switching worktrees
			local Hooks = require("git-worktree.hooks")
			
			-- Update ToggleTerm directory when switching worktrees
			Hooks.register(Hooks.type.SWITCH, function(path, prev_path)
				-- Update all open terminals to the new directory
				local ok, toggleterm = pcall(require, "toggleterm.terminal")
				if ok then
					local terms = toggleterm.get_all()
					for _, term in pairs(terms) do
						if term:is_open() then
							term:change_dir(path)
						end
					end
				end
			end)

			-- Create keymaps
			vim.keymap.set("n", "<leader>gw", function()
				vim.cmd("Telescope git_worktree")
			end, { desc = "Git worktrees" })

			vim.keymap.set("n", "<leader>gW", function()
				local git_worktree = require("git-worktree")

				-- First, ask for the branch name
				vim.ui.input({ prompt = "New worktree branch name: " }, function(branch)
					if not branch or branch == "" then
						return
					end

					-- Then ask for the base branch (default to main/master)
					vim.ui.input({
						prompt = "Base branch (leave empty for main/master): ",
						default = "",
					}, function(base)
						-- If no base specified, try to detect main/master
						if not base or base == "" then
							-- Check if origin/main exists
							local main_exists = vim.fn.system("git show-ref --verify --quiet refs/remotes/origin/main")
							if vim.v.shell_error == 0 then
								base = "origin/main"
							else
								base = "origin/master"
							end
						elseif not base:match("^origin/") then
							-- Add origin/ prefix if not present
							base = "origin/" .. base
						end

						-- Get the repository root
						local repo_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("%s+$", "")
						local is_bare = vim.fn.system("git rev-parse --is-bare-repository"):gsub("%s+$", "") == "true"
						
						-- Determine worktree path
						local worktree_path
						if is_bare then
							-- For bare repos, create at the root level
							worktree_path = branch
						else
							-- For normal repos, create as sibling directory
							local parent_dir = vim.fn.fnamemodify(repo_root, ":h")
							local repo_name = vim.fn.fnamemodify(repo_root, ":t")
							worktree_path = parent_dir .. "/" .. repo_name .. "-" .. branch
						end
						
						-- Create the worktree
						git_worktree.create_worktree(worktree_path, base, branch)
						vim.notify("Creating worktree '" .. branch .. "' at " .. worktree_path .. " from " .. base)
					end)
				end)
			end, { desc = "Create git worktree" })
		end,
	},
	-- Branch-aware session management
	{
		"olimorris/persisted.nvim",
		lazy = false, -- Load immediately to handle sessions
		config = function()
			require("persisted").setup({
				use_git_branch = true,
				autoload = true,
				on_autoload_no_session = function()
					vim.notify("No session found", vim.log.levels.INFO)
				end,
				should_autosave = function()
					-- Don't save if we're in a git worktree outside main project
					if vim.fn.argc() > 0 then
						return false
					end
					return true
				end,
			})
		end,
	},
	-- Git integration.
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				on_attach = function(bufnr)
					local gitsigns = require("gitsigns")

					local function map(mode, l, r, opts)
						opts = opts or {}
						opts.buffer = bufnr
						vim.keymap.set(mode, l, r, opts)
					end

					-- Navigation
					map("n", "]c", function()
						if vim.wo.diff then
							vim.cmd.normal({ "]c", bang = true })
						else
							gitsigns.nav_hunk("next")
						end
					end)

					map("n", "[c", function()
						if vim.wo.diff then
							vim.cmd.normal({ "[c", bang = true })
						else
							gitsigns.nav_hunk("prev")
						end
					end)

					-- Actions
					map("n", "<leader>hs", gitsigns.stage_hunk)
					map("n", "<leader>hr", gitsigns.reset_hunk)
					map("v", "<leader>hs", function()
						gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end)
					map("v", "<leader>hr", function()
						gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
					end)
					map("n", "<leader>hS", gitsigns.stage_buffer)
					map("n", "<leader>hu", gitsigns.undo_stage_hunk)
					map("n", "<leader>hR", gitsigns.reset_buffer)
					map("n", "<leader>hp", gitsigns.preview_hunk)
					map("n", "<leader>hb", function()
						gitsigns.blame_line({ full = true })
					end)
					map("n", "<leader>tb", gitsigns.toggle_current_line_blame)
					map("n", "<leader>hd", gitsigns.diffthis)
					map("n", "<leader>hD", function()
						gitsigns.diffthis("~")
					end)
					map("n", "<leader>td", gitsigns.toggle_deleted)

					-- Text object
					map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
				end,
			})
		end,
	},
	"tpope/vim-rhubarb",
	{
		"tpope/vim-fugitive",
		config = function()
			vim.cmd([[
            nnoremap <leader>vs :G<CR>
            nnoremap <leader>vc :G commit<CR>
            nnoremap <leader>vp :G push<CR>
            nnoremap <leader>vd :G diff<CR>
            nnoremap <leader>vb :G blame<CR>
            nnoremap <leader>vl :G log<CR>
            nnoremap <leader>vw :G write<CR>
            nnoremap <leader>vW :G write!<CR>
            nnoremap <leader>vq :G quit<CR>
            nnoremap <leader>vQ :G quit!<CR>
        ]])
		end,
	},
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional - Diff integration

			-- Only one of these is needed.
			"nvim-telescope/telescope.nvim", -- optional
		},
		config = true,
	},
}
