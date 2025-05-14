-- TODO: Can just use vim.keymap.set now I think?
local key = require("util").keymapper()

vim.keymap.set("v", "<", "<gv", { silent = true})
vim.keymap.set("v", ">", ">gv", { silent = true})

-- Vim Windows [c-w] ---------------------------------------------------------
key.add({
  { "<c-w>*", "<c-w>_<c-w>|", desc = "Max out width & height" },
})

-- Git [g] -------------------------------------------------------------------
key.add({
  {
    "<leader>gz",
    function()
      local fid = vim.fn.expand("%:p:h")
      local cwd = require("util").project_dir(fid)
      vim.cmd("lcd "..cwd)
      vim.notify("Changed directory to: "..cwd, vim.log.levels.INFO, {
        title = "cwd",
        timeout = 2000,
      })
    end,
    desc = "Cd to project directory"
  },
})

-- Options [o] ---------------------------------------------------------------

key.add({
  { "<leader>o", group = "editor" },
  {
    "<leader>o>",
    function()
      vim.opt.tabstop = vim.o.tabstop + 2
      vim.opt.shiftwidth = vim.o.tabstop
    end,
    desc = "Increase tab width by 2"
  },
  {
    "<leader>o<",
    function()
      if vim.o.tabstop >= 2 then
        vim.opt.tabstop = vim.o.tabstop - 2
        vim.opt.shiftwidth = vim.o.tabstop
      end
    end,
    desc = "Reduce tab width by 2",
  },
})

-- Miscellaneous -------------------------------------------------------------
key.add({
  silent = false,
  { "<leader>c", "<cmd>cclose<cr><cmd>lclose<cr>",      desc = "Close quicklist" },
  { "<leader>m", function() require("util").make() end, desc = "Make" },
  { ",z",        "<cmd>lcd %:p:h<cr><cmd>pwd<cr>",      desc = "Cd to file directory" },
  { ",",         "<nop>" },
})

-- System clipboard
key.add({
  { "<C-c>", "\"+y", desc = "Copy to system clipboard",    mode = { "x" } },
  { "<C-c>", "\"+Y", desc = "Copy to system clipboard",    mode = { "n" } },
  { "<C-v>", "+",  desc = "Paste from system clipboard", mode = { "i" } },      -- Use Ctrl-Q as alternative to Ctrl-v
  { "<C-S-v>", "\"+p", desc = "Paste from system clipboard", mode = { "x", "n" } },
})

-- Load exrc files from parent directories
-- 
-- Make sure that each of these scripts ensures that it is resistant to
-- being run multiple times.
vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  pattern = "*",
  callback = function()
    local dir = vim.v.event.cwd or vim.fn.getcwd()
    for _, f in ipairs(vim.fs.find(
      { ".nvim.lua" },
      { upward = true, path = dir, limit = math.huge }
    )) do
      local src = vim.secure.read(f)
      if src ~= nil then
        dofile(f)
      end
    end
  end
})

-- Open help window in a vertical split to the right.
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = vim.api.nvim_create_augroup("help_window_right", {}),
    pattern = { "*.txt" },
    callback = function()
        if vim.o.filetype == "help" then
          vim.cmd.wincmd("L")
          vim.api.nvim_win_set_width(0, 86)
        end
    end
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "Dockerfile.*" },
    callback = function() vim.bo.filetype = "dockerfile" end,
})

return true
