return {
  { "folke/which-key.nvim",
    about = "Provides popup reference for your keybindings.",
    version = "*",
    event = "VeryLazy",
    opts = {
      plugins = {
        spelling = {
          enabled = true,
        },
      },
      key_labels = {
        ["<space>"] = "SPC",
        ["<cr>"] = "RET",
        ["<tab>"] = "TAB",
      },
      window = {
        border = "single",
        position = "top",
        margin = { 0, 0, 1, 0 },
        winblend = 0
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register({
        mode = { "n", "v" },
        ["g"] = { name = "+goto" },
        ["s"] = { name = "+surround" },
        ["]"] = { name = "+next" },
        ["["] = { name = "+prev" },
        ["<leader>d"] = { name = "+dap" },
        ["<leader>db"] = { name = "+breakpoints" },
        -- ["<leader><tab>"] = { name = "+tabs" },
        -- ["<leader>b"] = { name = "+buffer" },
        -- ["<leader>c"] = { name = "+code" },
        -- ["<leader>f"] = { name = "+file/find" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>gh"] = { name = "+hunks" },
        -- ["<leader>q"] = { name = "+quit/session" },
        -- ["<leader>s"] = { name = "+search" },
        ["<leader>n"] = { name = "+notify" },
        -- ["<leader>w"] = { name = "+windows" },
        -- ["<leader>x"] = { name = "+diagnostics/quickfix" },
      })
    end,
  },

  { "ethanholz/nvim-lastplace",
    opts = {
      lastplace_ignore_buftype = {"quickfix", "nofile", "help"},
      lastplace_ignore_filetype = {"gitcommit", "gitrebase", "svn", "hgcommit"},
      lastplace_open_folds = true
    }
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
      }
    }
  },

  { "folke/trouble.nvim",
    -- ABOUT: Error and warnings list.
    config = function()
      local key = require("util").keymapper()
      key.register({
        ["]k"]   = {
          function()
            require("trouble").next({skip_groups = true, jump = true});
          end,
          "Next Trouble"
        },

        ["[k"] = {
          function()
            require("trouble").previous({skip_groups = true, jump = true});
          end,
          "Previous Trouble"
        },

        ["[K"] = {
          function()
            require("trouble").first({skip_groups = true, jump = true});
          end,
          "First Trouble"
        },

        ["]K"] = {
          function()
            require("trouble").last({skip_groups = true, jump = true});
          end,
          "Last Trouble"
        }
      })
    end
  },

  { "folke/todo-comments.nvim",
    event = "VeryLazy",
    config = true,
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
    config = function(_, opts) require("mini.starter").setup(opts) end,
  },

  { "echasnovski/mini.sessions",
    config = function(_, opts) require("mini.sessions").setup(opts) end,
  },

  { "echasnovski/mini.surround",
    keys = { "sa", "sd", "sf" , "sF", "sh", "sr", "sn" },
    config = function(_, opts) require("mini.surround").setup(opts) end,
  },

  { "echasnovski/mini.move",
    event = "VeryLazy",
    opts = {
      mappings = {
        left = '<c-s-h>',
        right = '<c-s-l>',
        down = '<c-s-j>',
        up = '<c-s-k>',

        -- Move current line in Normal mode
        line_left = '<c-s-h>',
        line_right = '<c-s-l>',
        line_down = '<c-s-j>',
        line_up = '<c-s-k>',
      }
    },
    config = function(_, opts) require("mini.move").setup(opts) end,
  },

  { "echasnovski/mini.pairs",
    event = "VeryLazy",
    enabled = false,
    opts = {
      -- In which modes mappings from this `config` should be created
      modes = { insert = true, command = false, terminal = false },
      -- Global mappings. Each right hand side should be a pair information, a
      -- table with at least these fields (see more in |MiniPairs.map|):
      -- - <action> - one of "open", "close", "closeopen".
      -- - <pair> - two character string for pair to be used.
      -- By default pair is not inserted after `\`, quotes are not recognized by
      -- `<CR>`, `'` does not insert pair after a letter.
      -- Only parts of tables can be tweaked (others will use these defaults).
      -- 
      mappings = {
        ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\].' },
        ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\].' },
        ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\].' },
        [')'] = { action = 'close', pair = '()', neigh_pattern = '[^\\].' },
        [']'] = { action = 'close', pair = '[]', neigh_pattern = '[^\\].' },
        ['}'] = { action = 'close', pair = '{}', neigh_pattern = '[^\\].' },
        ['"'] = { action = 'closeopen', pair = '""', neigh_pattern = '[^%a\\].', register = { cr = false } },
        ["'"] = { action = 'closeopen', pair = "''", neigh_pattern = '[^%a\\].', register = { cr = false } },
        ['`'] = { action = 'closeopen', pair = '``', neigh_pattern = '[^%a\\].', register = { cr = false } },
      },
    },
    config = function(_, opts)
      require("mini.pairs").setup(opts)

      vim.keymap.set("i", "<c-v>",
        function()
          vim.g.minipairs_disable = true
          vim.api.nvim_create_autocmd("InsertLeave", {
            callback = function()
              vim.g.minipairs_disable = false
              return true
            end
          })
          return "<c-v>"
        end,
        { silent = true, noremap = true, expr = true, desc = "Temporarily disable auto-pairing" }
      )
    end,
  },

  { "echasnovski/mini.ai",
    event = "VeryLazy",
    config = function(_, opts) require("mini.ai").setup(opts) end,
  },

  { "echasnovski/mini.align",
    keys = { "ga", "gA" },
    config = function(_, opts) require("mini.align").setup(opts) end,
  },

  { "echasnovski/mini.bracketed",
    event = "VeryLazy",
    config = function(_, opts) require("mini.bracketed").setup(opts) end,
  },

  { "tpope/vim-unimpaired",
    -- ABOUT: Pairs of handy bracket mappings
    event = "VeryLazy",
    enabled = false,
    config = function()
      local key = require("util").keymapper()

      -- Next and Previous builtins
      key.register({
        ["[a"]     = ":previous",
        ["]a"]     = ":next",
        ["[A"]     = ":first",
        ["]A"]     = ":last",
        ["[b"]     = ":bprevious",
        ["]b"]     = ":bnext",
        ["[B"]     = ":bfirst",
        ["]B"]     = ":blast",
        ["[l"]     = ":lprevious",
        ["]l"]     = ":lnext",
        ["[L"]     = ":lfirst",
        ["]L"]     = ":llast",
        ["[<C-L>"] = ":lpfile",
        ["]<C-L>"] = ":lnfile",
        ["[q"]     = ":cprevious",
        ["]q"]     = ":cnext",
        ["[Q"]     = ":cfirst",
        ["]Q"]     = ":clast",
        ["[t"]     = ":tprevious",
        ["]t"]     = ":tnext",
        ["[T"]     = ":tfirst",
        ["]T"]     = ":tlast",
        ["[<C-T>"] = ":ptprevious",
        ["]<C-T>"] = ":ptnext",
      }, { preset = true })

      key.register({
        ["[f"] = "Previous file",
        ["]f"] = "Next file",
        ["[n"] = "Previous SCM conflict",
        ["]n"] = "Next SCM conflict",
      }, { preset = true })

      -- Line operations:
      key.register({
        ["[<space>"] = "Add [count] blank lines above",
        ["]<space>"] = "Add [count] blank lines below",

        ["[e"] = "Exchange line with [count] lines above",
        ["]e"] = "Exchange line with [count] lines below",
      }, { preset = true })

      -- Option toggling:
      key.register({
        ["yo"] = {
          name = "toggle options",
          b = "Toggle background",
          c = "Toggle cursorline",
          d = "Toggle diff",
          h = "Toggle hlsearch",
          i = "Toggle ignorecase",
          l = "Toggle list",
          n = "Toggle number",
          r = "Toggle relativenumber",
          p = "Toggle paste",
          u = "Toggle cursorcolumn",
          v = "Toggle virtualedit",
          w = "Toggle wrap",
          x = "Toggle cursorline + cursorcolumn",
        }
      }, { preset = true })

      -- Encoding and decoding:
      local encoding_maps = {
        ["[x"] = "XML encode",
        ["]x"] = "XML decode",
        ["[u"] = "URL encode",
        ["]u"] = "URL decode",
        ["[y"] = "C-String encode",
        ["]y"] = "C-String decode",
        ["[C"] = "C-String encode",
        ["]C"] = "C-String decode",
      }
      key.register(encoding_maps, { mode = "n", preset = true })
      key.register(encoding_maps, { mode = "x", preset = true })

      -- Personal
      key.register({
        ["<m-,>"] = { "[q", "Previous issue" },
        ["<m-.>"] = { "]q", "Next issue" },
      })
    end
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
    config = true,
  },

  { "mg979/vim-visual-multi",
    -- ABOUT: Mutliple cursors.
    -- HELP: visual-multi.txt
    init = function()
      vim.g.VM_leader = "\\"
      vim.g.VM_mouse_mappings = 1
    end,
  },

  { "gpanders/editorconfig.nvim",
    version = "*",
    lazy = false,
    enabled = function() return vim.fn.has("nvim-0.9") == 0 end,
  },
}
