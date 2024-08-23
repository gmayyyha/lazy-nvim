vim.cmd("let g:netrw_liststyle = 3")

vim.g.bigfile_size = 1024 * 1024 * 1.5 -- 1.5 MB

local opt = vim.opt

opt.relativenumber = true
opt.number = true

opt.title = true

-- tabs & indentation
opt.tabstop = 8 -- 8 spaces for tabs (prettier default)
--opt.expandtab = true -- expand tab to spaces
opt.shiftwidth = 8 -- 8 spaces for indent width
opt.autoindent = true -- copy indent from current line when starting new one
opt.smartindent = true
opt.smarttab = true -- make indenting smarter again
opt.breakindent = true -- indent wrapped lines
opt.list = true -- list mode

opt.undofile = true
opt.backup = false

opt.wrap = false

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

opt.cursorline = true
opt.guicursor = "n-v-c:block-Cursor"

-- turn on termguicolors for tokyonight colorscheme to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be make dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- backspace
opt.backspace = { "indent", "eol", "start" } -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom
