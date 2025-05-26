local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true
opt.scrolloff = 10

-- Tabs
opt.shiftwidth = 4
opt.tabstop = 4
opt.autoindent = true
opt.expandtab = true

-- Wrap
opt.wrap = true

-- Search
opt.ignorecase = true
opt.smartcase = true

-- Cursor
opt.cursorline = true

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- Backspace
opt.backspace = "indent,eol,start"

-- Clipboard
opt.clipboard:append("unnamedplus")

-- Swapfile
opt.swapfile = false

-- Netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
