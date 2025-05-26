-- Map Leader
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Buffer Navigation
vim.keymap.set("n", "<leader>{", ":bprev<CR>", { noremap = false })
vim.keymap.set("n", "<leader>}", ":bnext<CR>", { noremap = false })

-- Quit/Save
vim.keymap.set("n", "<leader>q", ":q<CR>", { noremap = false })
vim.keymap.set("n", "<leader>w", ":w<CR>", { noremap = false })
