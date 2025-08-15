local get_intelephense_license = function()
	local f = assert(io.open(os.getenv("HOME") .. "/intelephense/license.txt", "rb"))

	local content = f:read("*a")

	f:close()

	return string.gsub(content, "%s+", "")
end

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/nvim-cmp",
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*",
			build = "make install_jsregexp",
		},
		"saadparwaiz1/cmp_luasnip",
		"j-hui/fidget.nvim",
	},

	config = function()
		local cmp = require("cmp")
		local cmp_lsp = require("cmp_nvim_lsp")
		local capabilities = vim.tbl_deep_extend(
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			cmp_lsp.default_capabilities()
		)

		require("fidget").setup({
			notification = {
				filter = vim.log.levels.DEBUG,
			},
		})
		require("mason").setup()
		require("mason-lspconfig").setup({
			ensure_installed = {
				"intelephense",
				"vue_ls",
				"lua_ls",
				"gopls",
				"ts_ls",
				"angularls",
				"pyright",
				"ruff_lsp",
			},
			handlers = {
				function(server_name) -- default handler (optional)
					require("lspconfig")[server_name].setup({
						capabilities = capabilities,
					})
				end,

				["lua_ls"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.lua_ls.setup({
						capabilities = capabilities,
						settings = {
							Lua = {
								diagnostics = {
									globals = { "vim", "it", "describe", "before_each", "after_each" },
								},
							},
						},
					})
				end,
				["intelephense"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.intelephense.setup({
						capabilities = capabilities,
						init_options = {
							licenceKey = get_intelephense_license(),
						},
					})
				end,
				["pyright"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.pyright.setup({
						capabilities = capabilities,
						settings = {
							python = {
								analysis = {
									autoSearchPaths = true,
									typeCheckingMode = "standard",
									useLibraryCodeForTypes = true,
									diagnosticMode = "workspace",
								},
							},
						},
					})
				end,
				["ruff_lsp"] = function()
					local lspconfig = require("lspconfig")
					lspconfig.ruff_lsp.setup({
						capabilities = capabilities,
						init_options = {
							settings = {
								args = {},
							},
						},
					})
				end,
				["angularls"] = function()
					local lspconfig = require("lspconfig")
					local ok, mason_registry = pcall(require, "mason-registry")
					if not ok then
						vim.notify("mason-registry could not be loaded")
						return
					end

					local angularls_path = mason_registry.get_package("angular-language-server"):get_install_path()

					local cmd = {
						"ngserver",
						"--stdio",
						"--tsProbeLocations",
						table.concat({
							angularls_path,
							vim.uv.cwd(),
						}, ","),
						"--ngProbeLocations",
						table.concat({
							angularls_path .. "/node_modules/@angular/language-server",
							vim.uv.cwd(),
						}, ","),
					}
					lspconfig.angularls.setup({
						capabilities = capabilities,
						cmd = cmd,
						on_new_config = function(new_config, new_root_dir)
							new_config.cmd = cmd
						end,
					})
				end,
			},
		})

		require("luasnip/loaders/from_snipmate").lazy_load()

		local cmp_select = { behavior = cmp.SelectBehavior.Select }

		cmp.setup({
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
				["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete(),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" }, -- For luasnip users.
			}, {
				{ name = "buffer" },
			}),
		})

		local function setup_worktree_lsp()
			local cwd = vim.fn.getcwd()
			local worktree_root = vim.fn.trim(vim.fn.system("git rev-parse --show-toplevel 2>/dev/null"))

			if vim.v.shell_error == 0 and worktree_root ~= cwd then
				-- Add the worktree root as a workspace folder for better LSP support
				vim.lsp.buf.add_workspace_folder(worktree_root)
			end
		end

		vim.diagnostic.config({
			-- update_in_insert = true,
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
		})
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				setup_worktree_lsp()

				-- Enable completion triggered by <c-x><c-o>
				vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts = { buffer = ev.buf }
				vim.keymap.set("n", "<Leader>d", "<cmd>lua vim.diagnostic.open_float()<CR>")
				vim.keymap.set("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
				vim.keymap.set("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>")
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
				vim.keymap.set("n", "gdv", ":vsplit | lua vim.lsp.buf.definition()<CR>", opts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
				vim.keymap.set("n", "<C-h>", vim.lsp.buf.signature_help, opts)
				vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
				vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
				vim.keymap.set("n", "<space>wl", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, opts)
				vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
				vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
				vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
				vim.keymap.set("n", "<space>cf", function()
					vim.lsp.buf.format({ async = true })
				end, opts)
			end,
		})
	end,
}
