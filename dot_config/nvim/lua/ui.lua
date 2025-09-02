-- ui.lua
--
-- Contains plugins modifying or extending the user interface.
--
-- This module returns a list of plugin specs for lazy.nvim
--

-- Set cursorline in insert mode and unset it when leaving.
-- TODO: Turn this into something that can be toggled on-and-off.
--  Should have: never, always, and insert
vim.api.nvim_create_autocmd({ "InsertLeave" }, {
    callback = function() vim.wo.cursorline = false end,
})
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    callback = function() vim.wo.cursorline = true end,
})

-- Disable blending because it ruins terminal copying
vim.opt.winblend = 0

return {
  { "nvim-tree/nvim-web-devicons" },

  { "folke/noice.nvim",
    about = [[
      Fancy replacement UI for messages, cmdline, and popupmenu.
    ]],
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },

  { "nvim-lualine/lualine.nvim",
    about = [[
      Fancy bottom statusline with information from various sources.
    ]],
    event = "VeryLazy",
    opts = function(_, opts)
      opts = {
        sections = {
          lualine_c = {
            { 'filename', path=1 }
          },
          lualine_x = {
            {
              require("noice").api.statusline.mode.get,
              cond = require("noice").api.statusline.mode.has,
              color = { fg = "#ff9e64" },
            },
          },
          lualine_y = {
            'encoding',
            'fileformat',
            'filetype'
          },
          lualine_z = {
            'selectioncount',
            'progress',
            'location',
          },
        }
      }
      return opts
    end,
  },

  { "b0o/incline.nvim",
    about = [[
      Fancy top windowbar with a smaller floating equivalent.
    ]],
    event = "BufReadPre",
    opts = {
      hide = {
        cursorline = true,
      }
    },
    init = function()
      vim.opt.laststatus = 3
    end,
  },

  { "lewis6991/satellite.nvim",
    about = [[
      Provide a decorated scrollbar with information from the buffer.

      Simpler alternative: petertriho/nvim-scrollbar
    ]],
    event = "VeryLazy",
    opts = {
      handlers = {
        gitsigns = {
          enable = false
        }
      }
    },
  },

  { "folke/which-key.nvim",
    about = "Provides popup reference for your keybindings.",
    version = "*",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      delay = function(ctx) return ctx.plugin and 0 or 500 end,
    },
    keys = {
      { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Show buffer-local keymaps" },
    },
  },

  { "stevearc/quicker.nvim",
    about = [[
      Replacement for quickfix list.
    ]],
    event = "FileType qf",
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {},
  },

  { "stevearc/aerial.nvim",
    about = "Provide a symbol outline.",
    dependencies = {
      "nvim-tree/nvim-web-devicons"
    },
    cmd = {
      "AerialOpen",
      "AerialOpenAll",
      "AerialToggle",
    },
    keys = {
      { ",o", "<cmd>AerialToggle!<cr>", desc = "Toggle outline" }, -- TODO: Update keybinding
    },
    opts = {},
  },

  { "folke/flash.nvim",
    about = [[
      Navigate with search labels, enhanced character motions, and Treesitter integration

      If you are running into problems with <C-;> being weird, see:
      https://unix.stackexchange.com/questions/746574/how-to-disable-the-mapping-of-ctrl-to-underscore-e-in-ubuntu
    ]],
    event = "VeryLazy",
    opts = {},
    keys = {
      { ";", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "<C-;>", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  { "mrjones2014/smart-splits.nvim",
    about = "Seamless navigation between nvim and terminal multiplexers.",
    lazy = false,
    opts = {},
    keys = {
      mode = { "i", "n", "x", "t" },
      { "<A-h>", function() require("smart-splits").move_cursor_left() end, desc = "Goto pane left" },
      { "<A-j>", function() require("smart-splits").move_cursor_down() end, desc = "Goto pane below" },
      { "<A-k>", function() require("smart-splits").move_cursor_up() end, desc = "Goto pane above" },
      { "<A-l>", function() require("smart-splits").move_cursor_right() end, desc = "Goto pane right" },
      { "<A-S-h>", function() require("smart-splits").swap_buf_left() end, desc = "Move pane left" },
      { "<A-S-j>", function() require("smart-splits").swap_buf_down() end, desc = "Move pane below" },
      { "<A-S-k>", function() require("smart-splits").swap_buf_up() end, desc = "Move pane above" },
      { "<A-S-l>", function() require("smart-splits").swap_buf_right() end, desc = "Move pane right" },
      { "<A-o>", "<c-\\><c-n>gt", desc = "Focus next tab" },
      { "<A-w>", "<c-\\><c-n><c-w>c", desc = "Close focused window" },
      { "<A-W>", "<cmd>tabclose<cr>", desc = "Close current tab" },
      { "<A-T>", "<c-\\><c-n><c-w>T", desc = "Make window a tab" },
      { "<A-S-Return>", "<cmd>botright split term://zsh<cr>", desc = "Open new term below" },
      { "<A-Return>", "<cmd>tabe term://zsh<cr>", desc = "Open new term tab" },
    }
  },

  { "sindrets/winshift.nvim",
    about = "Allow full window moving capabilities.",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "<c-w>m", "<cmd>WinShift<cr>", desc = "Shift window" },
      { "<c-w>X", "<cmd>WinShift swap<cr>", desc = "Swap window" },
    }
  },

  -- FIXME: Fix re-folding on changing contents
  { "csams/pretty-fold.nvim",
    enabled = true,
    about = "Improve folding appearance.",
    event = "VeryLazy",
    opts = {},
    dependencies = {
      "anuvyklack/keymap-amend.nvim",
    }
  },

  { "chrisgrieser/nvim-origami",
    enabled = false,
    about = [[
      A collection of Quality-of-life features related to folding.
    ]],
    event = "VeryLazy",
    init = function()
      vim.cmd([[
        augroup folds
        " Don't screw up folds when inserting text that might affect them, until
        " leaving insert mode. Foldmethod is local to the window. Protect against
        " screwing up folding when switching between windows.
        autocmd InsertEnter * if !exists('w:last_fdm') | let w:last_fdm=&foldmethod | setlocal foldmethod=manual | endif
        autocmd InsertLeave,WinLeave * if exists('w:last_fdm') | let &l:foldmethod=w:last_fdm | unlet w:last_fdm | endif
        augroup END
      ]])
    end,
    opts = {},
  },

  { "edeneast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      options = {
        dim_inactive = true,
        styles = {
          comments = "italic",
        }
      },
      palettes = {
        nordfox = {
          bg05 = "#292d38", -- Halfway between bg0 and bg1
          comment = "#8092aa", -- Lighter than original (#60728a)
          original_comment = "#60728a",
        }
      },
      groups = {
        nordfox = {
          CursorLine = { bg = "palette.bg05" },
          Folded = { fg = "palette.original_comment", bg = "palette.bg0" }
        }
      },
    },
    config = function(_, opts)
      require("nightfox").setup(opts)
      vim.cmd "colorscheme nordfox"

      local Snacks = require("snacks")
      Snacks.toggle.new({
        id = "colorscheme",
        name = "Light Colorscheme",
        get = function() return vim.g.colors_name == "dayfox" end,
        set = function() vim.cmd.colorscheme(vim.g.colors_name == "dayfox" and "nordfox" or "dayfox") end
      }):map("<leader>ob")
    end
  },

  { "folke/trouble.nvim",
    about = [[
      A pretty list for showing diagnostics, references, telescope results,
      quickfix and location lists to help you solve all the trouble your code is causing.
    ]],
    opts = {},
    cmd = "Trouble",
    keys = {
      { "<leader>xc", "<cmd>Trouble close<cr>", desc = "Close Trouble", },
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)", },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)", },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)", },
      { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions / references / ... (Trouble)", },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)", },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)", },
      { "]k", function() require("trouble").next() end, desc = "Next trouble" },
      { "[k", function() require("trouble").prev() end, desc = "Previous trouble" },
      { "]K", function() require("trouble").last() end, desc = "Last trouble" },
      { "[K", function() require("trouble").first() end, desc = "First trouble" },
    },
  },

  { "folke/todo-comments.nvim",
    about = [[
      Highlight and search for todo comments like TODO, HACK, BUG in your code base.
    ]],
    event = "VeryLazy",
    opts = {},
    cmd = {
      "TodoQuickFix",
      "TodoLocList",
      "TodoFzfLua",
      "TodoTrouble",
    }
  },

  { "norcalli/nvim-colorizer.lua",
    opts = {},
    cmd = {
      "ColorizerAttachToBuffer",
    }
  }
}
