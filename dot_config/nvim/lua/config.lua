-- TODO: Can just use vim.keymap.set now I think?
local key = require("util").keymapper()

vim.keymap.set("v", "<", "<gv", { silent = true})
vim.keymap.set("v", ">", ">gv", { silent = true})

-- Vim [v] -------------------------------------------------------------------
key.add({
  { "<leader>v", group = "vim" },
  { "<leader>vc", "<cmd>source $MYVIMRC<cr><cmd>Lazy sync<cr>", desc = "Source config and sync" },
  { "<leader>ve", "<cmd>vsplit $MYVIMRC<cr>", desc = "Edit config" },
  { "<leader>vf", "<cmd>Telescope find_files cwd=~/.config/nvim<cr>", desc = "Find files in config" },
  { "<leader>vh", "<cmd>Telescope help_tags<cr>", desc = "Search help tags" },
  { "<leader>vs", "<cmd>source $MYVIMRC<cr>", desc = "Source Vim configuration" },
  { "<leader>vx", "<cmd>w<cr><cmd>source %<cr>", desc = "Write and source this file" },
})

-- Vim Windows [c-w] ---------------------------------------------------------
key.add({
  { "<c-w>*", "<c-w>_<c-w>|", desc = "Max out width & height" },
})

key.add({
  mode = { "i", "n", "t" },

  -- Focus windows:
  -- { "<a-h>", "<c-\\><c-n><c-w>h", desc = "Focus left window" },
  -- { "<a-j>", "<c-\\><c-n><c-w>j", desc = "Focus below window" },
  -- { "<a-k>", "<c-\\><c-n><c-w>k", desc = "Focus right window" },
  -- { "<a-l>", "<c-\\><c-n><c-w>l", desc = "Focus above window" },
  -- { "<a-o>", "<c-\\><c-n>gt", desc = "Focus next tab" },

  { "<a-w>", "<c-\\><c-n><c-w>c", desc = "Close focused window" },
  { "<a-W>", "<cmd>tabclose<cr>", desc = "Close current tab" },
  { "<a-T>", "<c-\\><c-n><c-w>T", desc = "Make window a tab" },

  { "<a-[>", "<cmd>botright split term://zsh<cr>", desc = "Open new term below" },
  { "<a-]>", "<cmd>botright vsplit term://zsh<cr>", desc = "Open new term right" },
  { "<a-return>", "<cmd>tabe term://zsh<cr>", desc = "Open new term tab" },
})

-- Search [/] ----------------------------------------------------------------
key.add({
  { "<leader>/", group = "Search" },
  { "<leader>//", "<cmd>Telescope<cr>", desc = "Telescope" },
  { "<leader>/g", "<cmd>Telescope git_files<cr>", desc = "Git files" },
  {
    "<leader>*",
    function()
      require("telescope.builtin").grep_string({
        cwd = require("util").project_dir()
      })
    end,
    desc = "Search project for <CWORD>"
  },
  {
    "<leader>a",
    function()
      require("telescope.builtin").live_grep({
        cwd = require("util").project_dir()
      })
    end,
    desc = "Search project"
  },
  {
    mode = { "v" },
    {
      "<leader>*",
      function()
        require("telescope.builtin").grep_string({
          search = require("util").get_visual_selection(),
          cwd = require("util").project_dir(),
        })
      end,
      desc = "Search project for selection"
    },
  },
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
local function notify_option(str, value)
  local state = "disabled"
  if value then
    state = "enabled"
  end
  vim.notify(str .. " " .. state .. ".")
end

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
  { "<leader>c", "<cmd>cclose<cr><cmd>lclose<cr>", desc = "Close quicklist" },
  { "<leader>m", function() require("util").make() end, desc = "Make" },
  { ",z", "<cmd>lcd %:p:h<cr><cmd>pwd<cr>", desc = "Cd to file directory" },
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
        if vim.o.filetype == 'help' then
          vim.cmd.wincmd("L")
          vim.api.nvim_win_set_width(0, 80)
        end
    end
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "Dockerfile.*" },
    callback = function() vim.bo.filetype = "dockerfile" end,
})

return true
