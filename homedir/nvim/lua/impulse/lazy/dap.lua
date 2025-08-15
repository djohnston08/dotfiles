return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
			"mfussenegger/nvim-dap-python",
			"jay-babu/mason-nvim-dap.nvim",
		},
		config = function()
			local dap, dapui = require("dap"), require("dapui")

			-- Ensure debugpy is installed via Mason
			require("mason-nvim-dap").setup({
				ensure_installed = { "python" },
				handlers = {},
			})

			-- Setup Python debugging
			local dap_python = require("dap-python")
			dap_python.setup("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
			dap_python.test_runner = "pytest"

			dap.adapters.php = {
				type = "executable",
				command = "node",
				args = { os.getenv("HOME") .. "/projects/dotfiles/vscode-php-debug/out/phpDebug.js" },
			}

			dap.configurations.php = {
				{
					type = "php",
					request = "launch",
					name = "Listen for Xdebug",
					port = 9003,
					pathMappings = {
						["/var/www/html"] = "${workspaceFolder}",
					},
				},
			}

			require("nvim-dap-virtual-text").setup()

			require("dapui").setup({
				layouts = {
					{
						elements = {
							-- { id = "scopes", size = 0.25 },
							{ id = "scopes", size = 0.5 },
							-- "breakpoints",
							-- "stacks",
							"watches",
						},
						size = 100, -- 100 columns
						position = "left",
					},
					{
						elements = {
							"repl",
							"console",
						},
						size = 0.25, -- 25% of total lines
						position = "bottom",
					},
				},
			})

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end

			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end

			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			vim.keymap.set("n", "<F10>", ":lua require'dap'.step_into()<cr>")
			vim.keymap.set("n", "<F9>", ":lua require'dap'.step_over()<cr>")
			vim.keymap.set("n", "<F5>", ":lua require'dap'.continue()<cr>")
			vim.keymap.set("n", "<F6>", ":lua require'dap'.toggle_breakpoint()<cr>")
			vim.keymap.set("n", "<Leader>dt", ":lua require('dapui').toggle()<cr>")

			-- Function to set conditional breakpoint
			function _G.set_conditional_breakpoint()
				-- Prompt for the condition
				vim.ui.input({ prompt = "Breakpoint condition: " }, function(condition)
					if condition then
						dap.set_breakpoint(condition)
					end
				end)
			end

			-- Map it to a key
			-- For example, mapping to <leader>dc for "debug condition"
			vim.keymap.set(
				"n",
				"<leader>dc",
				_G.set_conditional_breakpoint,
				{ desc = "Debug: Set conditional breakpoint" }
			)
		end,
	},
}
