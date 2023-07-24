local lsp = require("lsp-zero")

lsp.preset("recommended")

lsp.ensure_installed({
    'intelephense',
    'volar',
    'lua_ls'
  })

-- Fix undefined global 'vim'
lsp.nvim_workspace()

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()
local luasnip = require('luasnip')
local lspkind = require('lspkind')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
  ['<CR>'] = cmp.mapping.confirm({
    -- documentation says this is important.
    -- I don't know why.
    behavior = cmp.ConfirmBehavior.Replace,
    select = false,
  })
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

require('luasnip/loaders/from_snipmate').lazy_load()

lsp.setup_nvim_cmp({
  mapping = cmp_mappings,
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  formatting = {
    format = lspkind.cmp_format(),
  },
  sources = {
    { name = 'copilot' },
    { name = 'nvim_lsp' },
    { name = 'nvim_lsp_signature_help' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'path' },
  },
})

lsp.set_preferences({
    suggest_lsp_servers = false
})

lsp.set_sign_icons({
    error = '',
    warn = '',
    hint = '',
    info = ''
})

lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set('n', '<Leader>d', '<cmd>lua vim.diagnostic.open_float()<CR>')
  vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
  vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>')
  vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
  vim.keymap.set('n', 'gi', ':Telescope lsp_implementations<CR>')
  vim.keymap.set('n', 'gr', ':Telescope lsp_references<CR>')
  vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
  vim.keymap.set('n', '<C-K>', '<cmd>lua vim.lsp.buf.signature_help()<CR>')
  vim.keymap.set('n', '<Leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
  vim.keymap.set('n', '<Leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')
  vim.keymap.set('n', '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<CR>')
end)

lsp.format_on_save({
    format_opts = {
      async = false,
      timeout_ms = 10000,
    },
    servers = {
      ['null-ls'] = {'php', 'lua'},
    }
  })

lsp.setup()

-- Setup Mason to automatically install LSP servers
require('mason').setup()
require('mason-lspconfig').setup({ automatic_installation = true })

-- local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- PHP
-- require('lspconfig').intelephense.setup({ capabilities = capabilities })
-- require('lspconfig').intelephense.setup({})

-- Angular, Javascript, TypeScript
-- local languageServerPath = '/Users/djohnston/projects/js/rf-ui/node_modules'
-- local cmd = {"/Users/djohnston/projects/js/rf-ui/node_modules/.bin/ngserver", "--stdio", "--tsProbeLocations", languageServerPath, "--ngProbeLocations", languageServerPath}
-- require('lspconfig').angularls.setup({
--     cmd = cmd,
--     on_new_config = function(new_config, new_root_dir)
--       new_config.cmd = cmd
--     end,
--   })

-- Lua
-- require('lspconfig').lua_ls.setup {
--   settings = {
--     Lua = {
--       runtime = {
--         -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
--         version = 'LuaJIT',
--       },
--       diagnostics = {
--         -- Get the language server to recognize the `vim` global
--         globals = {'vim'},
--       },
--       workspace = {
--         -- Make the server aware of Neovim runtime files
--         library = vim.api.nvim_get_runtime_file("", true),
--       },
--       -- Do not send telemetry data containing a randomized but unique identifier
--       telemetry = {
--         enable = false,
--       },
--     },
--   },
-- }

-- Vue, JavaScript, TypeScript
require('lspconfig').volar.setup({
    -- capabilities = capabilities,
    -- Enable "Take Over Mode" where volar will provide all JS/TS LSP services
    -- This drastically improves the responsiveness of diagnostic updates on change
    filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
})

-- Tailwind CSS
-- require('lspconfig').tailwindcss.setup({ capabilities = capabilities })
-- require('lspconfig').tailwindcss.setup({})

-- JSON
require('lspconfig').jsonls.setup({
  -- capabilities = capabilities,
  settings = {
    json = {
      schemas = require('schemastore').json.schemas(),
    },
  },
})

-- null-ls
require('null-ls').setup({
    sources = {
      require('null-ls').builtins.diagnostics.eslint_d.with({
          condition = function(utils)
            return utils.root_has_file({ '.eslintrc.js' })
          end,
        }),
      require('null-ls').builtins.diagnostics.trail_space.with({ disabled_filetypes = { 'NvimTree' } }),
      require('null-ls').builtins.formatting.eslint_d.with({
          condition = function(utils)
            return utils.root_has_file({ '.eslintrc.js' })
          end,
        }),
      require('null-ls').builtins.formatting.prettierd,
      require('null-ls').builtins.formatting.pint.with({
          condition = function(utils)
            return utils.root_has_file({ 'vendor/bin/pint' })
          end,
        }),
    },
  })

require('mason-null-ls').setup({ automatic_installation = true })

-- Keymaps
-- vim.keymap.set('n', '<Leader>d', '<cmd>lua vim.diagnostic.open_float()<CR>')
-- vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
-- vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>')
-- vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>')
-- vim.keymap.set('n', 'gi', ':Telescope lsp_implementations<CR>')
-- vim.keymap.set('n', 'gr', ':Telescope lsp_references<CR>')
-- vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
-- vim.keymap.set('n', '<C-K>', '<cmd>lua vim.lsp.buf.signature_help()<CR>')
-- vim.keymap.set('n', '<Leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
-- vim.keymap.set('n', '<Leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')

-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = false,
  float = {
    source = true,
  }
})

-- Commands
-- vim.api.nvim_create_user_command('Format', vim.lsp.buf.format, {})

-- -- Sign configuration
-- vim.fn.sign_define('DiagnosticSignError', { text = '', texthl = 'DiagnosticSignError' })
-- vim.fn.sign_define('DiagnosticSignWarn', { text = '', texthl = 'DiagnosticSignWarn' })
-- vim.fn.sign_define('DiagnosticSignInfo', { text = '', texthl = 'DiagnosticSignInfo' })
-- vim.fn.sign_define('DiagnosticSignHint', { text = '', texthl = 'DiagnosticSignHint' })
