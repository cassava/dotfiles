-- core.lua
--
-- Contains plugins setting up dependencies for other plugins as well as
-- fine-tuning the basics.
--
-- This module returns a list of plugin specs for lazy.nvim
--

return {
  { "nvim-lua/plenary.nvim",
    about = [[
      Lua library for writing modern Neovim plugins.

      Modules:
        plenary.async
        plenary.async_lib
        plenary.job
        plenary.path
        plenary.scandir
        plenary.context_manager
        plenary.test_harness
        plenary.filetype
        plenary.strings

      Required by many plugins.
    ]]
  },

  { "tpope/vim-repeat",
    about = [[
      Extends repeat command . to mappings and plugins.
    ]],
    event = "VeryLazy"
  },

  { "folke/snacks.nvim",
    about = [[
      If you want to profile:
        https://github.com/folke/snacks.nvim/blob/main/docs/profiler.md
    ]],
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = {},
      input = {},
      notifier = {},
      toggle = {},
    },
    config = function(_, opts)
      local Snacks = require("snacks")
      Snacks.setup(opts)
      -- Toggle Snack features:
      Snacks.toggle.animate():map("<leader>oa")
      Snacks.toggle.scroll():map("<leader>oS")
      Snacks.toggle.indent():map("<leader>og")

      -- Toggle options:
      Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }):map("<leader>oc")
      Snacks.toggle.option("number", { name = "Number" }):map("<leader>on")
      Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>oN")
      Snacks.toggle.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" }):map("<leader>oA")
      Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>oz")
      Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>ow")
      Snacks.toggle.option("expandtab", { name = "Expand Tab" }):map("<leader>ot")
      Snacks.toggle.new({
        id = "colorcolumn",
        name = "Color Column",
        get = function()
          return vim.o.colorcolumn ~= ""
        end,
        set = function()
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
        end
      }):map("<leader>oc")
    end,
  },

  { "echasnovski/mini.basics",
    about = [[
    ]],
    opts = {
      options = {
        basic = true,
        extra_ui = true,
        win_borders = "single",
      },
      mappings = {
        basic = true,
        option_toggle_prefix = "",
      }
    },
    config = function(_, opts)
      vim.opt.cursorline = false
      vim.opt.smartindent = false
      vim.opt.cindent = false

      require("mini.basics").setup(opts)
    end
  },

  { "echasnovski/mini.misc",
    config = function()
      require("mini.misc").setup_restore_cursor()
    end
  },

--- FILE MANAGEMENT -----------------------------------------------------------

  { "echasnovski/mini.starter",
    opts = {},
  },

  { "echasnovski/mini.sessions",
    opts = {},
  },

  { "tpope/vim-eunuch",
    about = [[
      Sugar for the UNIX shell commands that need it most.
    ]],
    cmd = {
      "Delete",    -- Delete current file from disk
      "Unlink",    -- Delete current file from disk and reload buffer
      "Remove",    -- Alias for :Unlink
      "Move",      -- Like :saveas, but delete the old file afterwards
      "Rename",    -- Like :Move, but relative to current file directory
      "Chmod",     -- Change permissions of current file
      "Mkdir",     -- Create directory [with -p]
      "SudoEdit",  -- Edit a file using sudo
      "SudoWrite", -- Write current file using sudo, uses :SudoEdit
    },
  },

  { "stevearc/oil.nvim",
    about = "A file explorer that lets you edit your filesystem like a normal Neovim buffer",
    lazy = false,
    keys = {
      { "-", function() require("oil").open(nil) end, desc = "Open parent directory" },
    },
    opts = {},
    init = function()
      -- From folke/snacks.nvim:
      vim.api.nvim_create_autocmd("User", {
        pattern = "OilActionsPost",
        callback = function(event)
            if event.data.actions.type == "move" then
                require("snacks").rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
            end
        end,
      })
    end
  },

  { "echasnovski/mini.files",
    opts = {},
    keys = {
      { "_", function() require("mini.files").open() end, desc = "Open file browser" },
    },
    init = function()
      -- From folke/snacks.nvim:
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesActionRename",
        callback = function(event)
          require("snacks").rename.on_rename_file(event.data.from, event.data.to)
        end,
      })
    end
  },
}
