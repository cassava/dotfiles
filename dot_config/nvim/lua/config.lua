local key = require("util").keymapper()

vim.keymap.set("v", "<", "<gv", { silent = true})
vim.keymap.set("v", ">", ">gv", { silent = true})

-- Vim [v] -------------------------------------------------------------------
key.register({
  ["<leader>v"] = {
    name = "vim",
    c = { "<cmd>source $MYVIMRC<cr><cmd>Lazy sync<cr>", "Source config and sync" },
    e = { "<cmd>vsplit $MYVIMRC<cr>", "Edit config" },
    f = { "<cmd>Telescope find_files cwd=~/.config/nvim<cr>", "Find files in config" },
    h = { "<cmd>Telescope help_tags<cr>", "Search help tags" },
    s = { "<cmd>source $MYVIMRC<cr>", "Source Vim configuration" },
    x = { "<cmd>w<cr><cmd>source %<cr>", "Write and source this file" },
  },
})

-- Vim Windows [c-w] ---------------------------------------------------------
key.register({
  -- Add to help
  ["<c-w>"] = {
    ["*"] = { "<c-w>_<c-w>|", "Max out width & height" },
  }
})

key.register({
  -- Focus windows:
  ["<a-h>"] = { "<c-\\><c-n><c-w>h", "Focus left window" },
  ["<a-j>"] = { "<c-\\><c-n><c-w>j", "Focus below window" },
  ["<a-k>"] = { "<c-\\><c-n><c-w>k", "Focus right window" },
  ["<a-l>"] = { "<c-\\><c-n><c-w>l", "Focus above window" },

  ["<a-T>"] = { "<c-\\><c-n><c-w>T", "Make window a tab" },
  ["<a-o>"] = { "<c-\\><c-n>gt", "Focus next tab"},

  ["<a-return>"] = { "<cmd>tabe term://zsh<cr>", "Open new term tab" },
  ["<a-]>"] = { "<cmd>botright vsplit term://zsh<cr>", "Open new term right" },
  ["<a-[>"] = { "<cmd>botright split term://zsh<cr>", "Open new term below" },

  ["<a-w>"] = { "<c-\\><c-n><c-w>c", "Close focused window" },
  ["<a-W>"] = { "<cmd>tabclose<cr>", "Close current tab" },
}, { mode = {"n", "t", "i"}, silent = true })

-- Search [/] ----------------------------------------------------------------
key.register({
  ["<leader>/"] = {
    name = "Search",
    ["/"] = { "<cmd>Telescope<cr>", "Telescope" },
    ["g"] = { "<cmd>Telescope git_files<cr>", "Git files" },
  }
})
key.register({
  ["<leader>*"] = {
    function()
      require("telescope.builtin").grep_string({
        cwd = require("util").project_dir()
      })
    end,
    "Search project for <CWORD>"
  },
  ["<leader>a"] = {
    function()
      require("telescope.builtin").live_grep({
        cwd = require("util").project_dir()
      })
    end,
    "Search project"
  },
})
key.register({
  ["<leader>*"] = {
    function()
      require("telescope.builtin").grep_string({
        search = require("util").get_visual_selection(),
        cwd = require("util").project_dir(),
      })
    end,
    "Search project for selection"
  },
}, { mode = "v" })

-- Git [g] -------------------------------------------------------------------
key.register({
  ["<leader>g"] = {
    -- Misc
    z = {
      function()
        local fid = vim.fn.expand("%:p:h")
        local cwd = require("util").project_dir(fid)
        vim.cmd("lcd "..cwd)
        vim.notify("Changed directory to: "..cwd, vim.log.levels.INFO, {
          title = "cwd",
          timeout = 2000,
        })
      end,
      "Cd to project directory"
    },
  }
})

-- Options [o] ---------------------------------------------------------------
key.register({
  ["<leader>o"] = {
    name = "editor",
    c = {
      function()
        local def_width = 80
        if vim.o.colorcolumn == "" then
          if vim.o.textwidth ~= 0 then
            vim.opt.colorcolumn = { vim.o.textwidth }
          else
            vim.opt.colorcolumn = { def_width }
            vim.opt.textwidth = def_width
          end
        else
          vim.opt.colorcolumn = {}
        end
      end,
      "Toggle colorcolumn"
    },
    w = { function() vim.opt.wrap = not vim.o.wrap end, "Toggle wrap" },
    n = { function() vim.opt.number = not vim.o.number end, "Toggle number" },
    r = { function() vim.opt.relativenumber = not vim.o.relativenumber end, "Toggle relativenumber" },
    t = { function() vim.opt.expandtab = not vim.o.expandtab end, "Toggle expandtab" },
    [">"] = { -- character '>'
      function()
        vim.opt.tabstop = vim.o.tabstop + 2
        vim.opt.shiftwidth = vim.o.tabstop
      end,
      "Increase tab width by 2"
    },
    ["<"] = { -- character '<'
      function()
        if vim.o.tabstop >= 2 then
          vim.opt.tabstop = vim.o.tabstop - 2
          vim.opt.shiftwidth = vim.o.tabstop
        end
      end,
      "Reduce tab width by 2",
    },
  }
})

-- Miscellaneous -------------------------------------------------------------
key.register({
  ["<leader>"] = {
    c = { "<cmd>cclose<cr><cmd>lclose<cr>", "Close quicklist" },
    f = { "gqip", "Format paragraph" },
    m = { function() require("util").make() end, "Make" },
  },
  [",z"] = { "<cmd>lcd %:p:h<cr><cmd>pwd<cr>", "Cd to file directory" },
}, { silent = false })

-- Set cursorline in insert mode and unset it when leaving.
vim.api.nvim_create_autocmd({ "InsertLeave" }, {
    callback = function() vim.wo.cursorline = false end,
})
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    callback = function() vim.wo.cursorline = true end,
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

-- Set redact options when editing passwords
vim.api.nvim_create_autocmd({ "BufReadPre" }, {
    pattern = {
        "/dev/shm/pass.?*/?*.txt",
        "/tmp/pass.?*/?*.txt",
        (vim.env.TMPDIR or "") .. "/pass.?*/?*.txt",
    },
    callback = function()
        vim.opt.backup = false
        vim.opt.writebackup = false
        vim.opt.swapfile = false
        vim.opt.viminfo = ""
        vim.opt.undofile = false

        vim.notify("Password redaction options set.")
        vim.g.password_redaction = 1
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

vim.api.nvim_create_autocmd({ "TermOpen" }, {
    pattern = { "*" },
    callback = function() vim.wo.number = false end,
})

return true
