-- ui.lua
--
-- Contains plugins modifying or extending the user interface.
--
-- This module returns a list of plugin specs for lazy.nvim
--

-- Set cursorline in insert mode and unset it when leaving.
vim.api.nvim_create_autocmd({ "InsertLeave" }, {
    callback = function() vim.wo.cursorline = false end,
})
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    callback = function() vim.wo.cursorline = true end,
})

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
          ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
      },
      views = {
      },
    },
    keys = {
      { "<leader>nn", function() require("noice").cmd("history") end, desc = "Noice History" },
      { "<leader>na", function() require("noice").cmd("all") end, desc = "Noice All" },
    },
    dependencies = { "MunifTanjim/nui.nvim" },
  },

  { "nvim-lualine/lualine.nvim",
    about = [[
      Fancy bottom statusline with information from various sources.
    ]],
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        sections = {
          lualine_c = {
            { 'filename', path=1 }
          }
        }
      })
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
    opts = {},
  },

  { "folke/which-key.nvim",
    about = "Provides popup reference for your keybindings.",
    version = "*",
    event = "VeryLazy",
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
      { ",o", "<cmd>AerialToggle!<cr>", desc = "Toggle outline" },
    },
    opts = {},
  },

  { "sindrets/winshift.nvim",
    about = "Allow full window moving capabilities.",
    event = "VeryLazy",
    config = true,
    keys = {
      { "<c-w>m", "<cmd>WinShift<cr>", desc = "Shift window" },
      { "<c-w>X", "<cmd>WinShift swap<cr>", desc = "Swap window" },
      { "<a-H>", "<cmd>WinShift left<cr>", desc = "Move window left" },
      { "<a-J>", "<cmd>WinShift down<cr>", desc = "Move window down" },
      { "<a-K>", "<cmd>WinShift up<cr>", desc = "Move window up" },
      { "<a-L>", "<cmd>WinShift right<cr>", desc = "Move window right" },
    }
  },

  { "folke/flash.nvim",
    about = "Navigate with search labels, enhanced character motions, and Treesitter integration",
    replaces = { "leap.nvim", "hop.nvim" },
    event = "VeryLazy",
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  { "mrjones2014/smart-splits.nvim",
    about = "Seamless navigation between nvim and terminal multiplexers.",
    lazy = false,
    config = true,
    keys = {
      { "<A-h>", function() require("smart-splits").move_cursor_left() end, desc = "Goto pane left" },
      { "<A-j>", function() require("smart-splits").move_cursor_down() end, desc = "Goto pane below" },
      { "<A-k>", function() require("smart-splits").move_cursor_up() end, desc = "Goto pane above" },
      { "<A-l>", function() require("smart-splits").move_cursor_right() end, desc = "Goto pane right" },
      { "<A-S-h>", function() require("smart-splits").swap_buf_left() end, desc = "Goto pane left" },
      { "<A-S-j>", function() require("smart-splits").swap_buf_down() end, desc = "Goto pane below" },
      { "<A-S-k>", function() require("smart-splits").swap_buf_up() end, desc = "Goto pane above" },
      { "<A-S-l>", function() require("smart-splits").swap_buf_right() end, desc = "Goto pane right" },
    }
  },

  -- FIXME: Fix re-folding on changing contents
  { "csams/pretty-fold.nvim",
    enabled = true,
    about = "Improve folding appearnce.",
    event = "VeryLazy",
    config = true,
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

  { "kevinhwang91/nvim-hlslens",
    event = "VeryLazy",
    -- config = function()
    --   require("scrollbar.handlers.search").setup({
    --     -- hlslens config overrides
    --   })
    -- end
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

  { "nvim-telescope/telescope.nvim",
    about = "Universal fuzzy finder.",
    version = "*",
    cmd = "Telescope",
    opts = {
      defaults = {
        preview = {
          filesize_limit = 1
        }
      }
    },
    keys = {
      {"<leader>b", "<cmd>Telescope buffers<cr>", desc = "Search buffers" },
      {"<leader>h", "<cmd>Telescope help_tags<cr>", desc = "Search help tags"},
    },
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        config = function()
          require("telescope").load_extension("fzf")
        end
      },
      { "debugloop/telescope-undo.nvim",
        keys = {
          {"<leader>u", "<cmd>Telescope undo<cr>", desc = "Search undo history" },
        },
        config = function()
          require("telescope").load_extension("undo")
        end
      },
      { "nvim-telescope/telescope-dap.nvim",
        config = function()
          require("telescope").load_extension("dap")
        end
      },
      { "nvim-telescope/telescope-project.nvim",
        config = function()
          require("telescope").load_extension("project")
        end
      },
      { "nvim-telescope/telescope-live-grep-args.nvim",
        config = function()
          require("telescope").load_extension("live_grep_args")
        end
      },
      { "fdschmidt93/telescope-egrepify.nvim",
        config = function()
          require("telescope").load_extension("egrepify")
        end
      },
    }
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
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)", },
      { "<leader>cl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "LSP Definitions / references / ... (Trouble)", },
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
      "TodoTelescope", -- cwd=PATH keywords=TODO,FIX
      "TodoQuickFix",
      "TodoLocList",
      "TodoFzfLua",
      "TodoTrouble",
    }
  },
}
