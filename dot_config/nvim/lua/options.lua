-- Configuration -------------------------------------------------------------

vim.g.mapleader = " "
vim.g.localmapleader = "\\"

vim.opt.exrc = true

-- vim.opt.undofile = true     -- support persistent undo via undodir=~/.local/share/nvim/undo
vim.opt.startofline = false -- when opening a file, restore to last column of line, not the beginning of the line
vim.opt.gdefault = true     -- search/replace globally in a line by default
vim.opt.autowriteall = true -- auto save whenever moving out of buffer or quitting
-- vim.opt.more = false        -- do not pipe output through more

vim.opt.title = true        -- set the title of the terminal
-- vim.opt.mouse = "a"         -- enable mouse support in normal and visual mode
-- If your terminal supports true colors, you can get nice things!
-- if vim.env.COLORTERM == "truecolor" then
--     vim.opt.termguicolors = true
-- end

-- vim.opt.number = true       -- show current line number
-- vim.opt.showcmd = true      -- show incomplete commands
vim.opt.visualbell = true   -- disable sounds
-- vim.opt.splitright = true   -- split new vertical windows to the right of the current
-- vim.opt.splitbelow = true   -- split new horizontal windows below the current

-- Display options
vim.opt.showmatch = true    -- show matching parenthesis
vim.opt.scrolloff = 4       -- keep 4 lines off the edges of the screen when scrolling
-- vim.opt.wrap = false        -- do not wrap by default
-- vim.opt.linebreak = true    -- wrap words instead of characters
-- vim.opt.list = true         -- show tabs and spaces, with the following characters:
vim.opt.listchars = {
  extends = '…',
  precedes = '…',
  nbsp = '␣',
  tab = '– ',
  trail = '·',
}
vim.opt.inccommand = "split" -- show substitution results incrementally (in a split)
vim.opt.undolevels = 10000   -- support 10000 instead of 1000 undos

-- Folding:
vim.opt.foldlevelstart = -1  -- show all folds open initially
vim.opt.foldmethod = "expr"  -- use whatever foldexpr says, e.g. treesitter
vim.opt.foldnestmax = 5      -- don't fold forever

-- Text options:
vim.opt.autoindent = true   -- automatically adjust indentation
vim.opt.smartindent = false -- apparently deprecated for cindent
vim.opt.cindent = false     -- react to syntax for indentation
vim.opt.expandtab = true    -- don't insert tabs
vim.opt.tabstop = 4         -- a tab is four spaces
vim.opt.shiftwidth = 4      -- number of spaces to use for auto-indenting
vim.opt.softtabstop = 4     -- number of spaces to remove on backspace
vim.opt.shiftround = true   -- use multiple of shiftwidth when indenting with < and >
vim.opt.completeopt = {
  "menu",       -- Use a popup menu to show possible completions
  "menuone",    -- Use the popup menu even if there is only one option
  "preview",    -- Provide extra information in a preview window
  "noselect",   -- Do not auto-select a match in the menu
  "noinsert",   -- Do not auto-insert first match in menu
}

-- Formatting
vim.opt.formatoptions:append("1")  -- don't end wrapping paragraphs' lines with 1-letter
vim.opt.joinspaces = false       -- don't trail a period with two spaces when formatting
vim.opt.fileformats = { "unix", "dos", "mac" }

-- Diff settings
vim.opt.diffopt:append("vertical")

-- Replace grep program with rg or ag.
if vim.fn.executable("rg") > 0 then
    vim.opt.grepprg = "rg --vimgrep --no-heading"
    vim.opt.grepformat = { "%f:%l:%c:%m", "%f:%l:%m" }
elseif vim.fn.executable("ag") > 0 then
    vim.opt.grepprg = "ag --nogroup --nocolor --ignore-case --column"
    vim.opt.grepformat = { "%f:%l:%c:%m", "%f:%l:%m" }
end

if vim.fn.has("nvim-0.8") == 1 then
    vim.opt.backup = true
    vim.opt.backupdir = vim.fn.stdpath("state") .. "/backup"
end

vim.opt.timeoutlen = 500

-- vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- Open preview in vertical split
vim.g.netrw_preview = 1

vim.opt.suffixes = {
    ".log", ".swp", ".bak", ".info", "~",
    ".svg", ".jpg", ".jpeg", ".png",
    ".zip", ".tar", ".gz", ".bz2", ".zst", ".7z",
    ".a", ".i", ".o", ".obj", ".so", ".out", ".plist",
    ".aux", ".fdb_latexmk", ".fls", ".idx", ".ilg", ".ind", ".toc", ".xdy", ".ist",
    ".pyc",
}

-- Disable OSC52 clipboard use until wezterm supports it
vim.g.termfeatures = vim.g.termfeatures or {}
vim.g.termfeatures.osc52 = false

-- Neovide configuration
--
-- See https://neovide.dev/configuration.html for a discussion of available
-- values and how they are used. Some of the values below are the default;
-- they are included for ease-of-access and are commented out.

vim.o.guifont = "FiraMono Nerd Font:h10.75"

-- vim.g.neovide_scale_factor = 1.0
-- vim.g.neovide_underline_automatic_scaling = false

vim.g.neovide_cursor_animation_length = 0.02
vim.g.neovide_cursor_trail_size = 0.3
-- vim.g.neovide_cursor_antialiasing = true
-- vim.g.neovide_cursor_unfocused_outline_width = 0.125

-- vim.g.neovide_scroll_animation_length = 0.3

-- vim.g.neovide_fullscreen = true
-- vim.g.neovide_refresh_rate = 60
-- vim.g.neovide_refresh_rate_idle = 5

vim.g.neovide_hide_mouse_when_typing = true

return true
