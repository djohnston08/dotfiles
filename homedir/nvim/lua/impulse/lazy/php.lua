return {
	-- PHP Refactoring Tools
	{
		"phpactor/phpactor",
		ft = "php",
		build = "composer install --no-dev --optimize-autoloader",
		config = function()
			vim.keymap.set("n", "<Leader>pm", ":PhpactorContextMenu<CR>")
			vim.keymap.set("n", "<Leader>pn", ":PhpactorClassNew<CR>")
		end,
	},

	-- Project Configuration.
	{
		"tpope/vim-projectionist",
		dependencies = {
			"tpope/vim-dispatch",
		},
		config = function()
			vim.g.projectionist_heuristics = {
				["artisan"] = {
					["*"] = {
						console = "sail artisan tinker",
						logs = "tail -n 200 -f storage/logs/laravel.log",
					},
					["app/*.php"] = {
						type = "source",
						alternate = {
							"tests/Unit/{}Test.php",
							"tests/Feature/{}Test.php",
						},
					},
					["app/Repositories/*.php"] = {
						type = "source",
						alternate = {
							"app/Interfaces/{}Interface.php",
						},
					},
					["app/Interfaces/*Interface.php"] = {
						type = "source",
						alternate = {
							"app/Repositories/{}.php",
						},
					},
					["tests/Feature/*Test.php"] = {
						type = "test",
						alternate = "app/{}.php",
					},
					["tests/Unit/*Test.php"] = {
						type = "test",
						alternate = "app/{}.php",
					},
					["app/Models/*.php"] = {
						type = "model",
					},
					["app/Http/Controllers/*.php"] = {
						type = "controller",
					},
					["routes/*.php"] = {
						type = "route",
					},
					["database/migrations/*.php"] = {
						type = "migration",
					},
				},
				["angular.json"] = {
					["src/*.ts"] = {
						type = "source",
						alternate = {
							"src/{}.html",
						},
					},
					["src/*.html"] = {
						type = "source",
						alternate = {
							"src/{}.ts",
						},
					},
				},
			}

			vim.keymap.set("n", "<C-a>", ":A<CR>")
		end,
	},
	{
		"stevearc/conform.nvim",
		opts = function()
			local util = require("conform.util")
			local opts = {
				format = {
					timeout_ms = 3000,
					async = false,
					quiet = false,
				},
				formatters_by_ft = {
					lua = { "styleua" },
					php = { "pint" },
					sh = { "shfmt" },
					javascript = { "prettierd" },
				},
				formatters = {
					injected = { options = { ignore_errors = true } },
					pint = {
						command = util.find_executable({
							"vendor/bin/pint",
							vim.fn.stdpath("data") .. "/mason/bin/pint",
						}, "pint"),
						args = { "$FILENAME" },
						stdin = false,
					},
				},
				format_on_save = {
					timeout_ms = 3000,
					lsp_fallback = true,
				},
			}
			return opts
		end,
	},
}
