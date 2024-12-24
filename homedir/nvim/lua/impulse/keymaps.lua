-- Space is my leader.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Return to explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Join lines
vim.keymap.set("n", "J", "mzJ`z")

-- Keep cursor centered when scrolling by half page
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- When text is wrapped, move by terminal rows, not lines, unless a count is provided.
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true })

-- Reselect visual selection after indenting.
vim.keymap.set('v', '<', '<gv')
vim.keymap.set('v', '>', '>gv')

-- Maintain the cursor position when yanking a visual selection.
-- http://ddrscott.github.io/blog/2016/yank-without-jank/
vim.keymap.set('v', 'y', 'myy`y')

-- Disable annoying command line typo.
vim.keymap.set('n', 'q:', ':q')

-- Delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- copy to system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Paste replace visual selection without copying it.
vim.keymap.set('x', '<leader>p', '"_dP')

-- Easy insertion of a trailing ; or , from insert mode.
vim.keymap.set('i', ';;', '<Esc>A;')
vim.keymap.set('i', ',,', '<Esc>A,')

-- Easy drop back to normal mode from insert
vim.keymap.set('i', 'jj', '<Esc>')

-- Quickly clear search highlighting.
vim.keymap.set('n', '<leader>w', ':nohlsearch<CR>')

-- Move lines up and down.
vim.keymap.set('v', 'J', ":move '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":move '<-2<CR>gv=gv")

vim.keymap.set("n", "Q", "<nop>")

-- Open new tmux session
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- Format buffer via LSP
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- Quickfix navigation
--
-- I don't love these first two
vim.keymap.set("n", "<leader>qf", "<cmd>copen<CR>zz")
vim.keymap.set("n", "<leader>cqf", "<cmd>cclose<CR>zz")
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>sp", ":vsplit ~/.scratchpad<CR>")
