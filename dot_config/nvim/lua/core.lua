return {
  { "nvim-lua/plenary.nvim" },
  { "nvim-lua/popup.nvim" },
  { "echasnovski/mini.misc" },

  { "folke/snacks.nvim",
    opts = {
      bigfile = {},
      input = {},
      notifier = {},
    }
  },

  { "echasnovski/mini.basics",
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

  { "echasnovski/mini.starter",
    opts = {},
  },

  { "echasnovski/mini.sessions",
    opts = {},
  },

  { "tpope/vim-eunuch",
    -- ABOUT: Sugar for the UNIX shell commands that need it most.
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
    }
  },

  { "stevearc/oil.nvim",
    about = "A file explorer that lets you edit your filesystem like a normal Neovim buffer",
    lazy = false,
    keys = {
      { "-", function() require("oil").open(nil) end, desc = "Open parent directory" },
    },
    opts = {},
  },

  { "echasnovski/mini.files",
    opts = {},
    keys = {
      { "_", function() require("mini.files").open() end, desc = "Open file browser" },
    }
  },

  -- TODO: Check if this is necessary.
  { "tpope/vim-repeat",
    about = "Extend repeat command . to mappings and plugins.",
    event = "VeryLazy"
  },
}
