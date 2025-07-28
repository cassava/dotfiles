return {
  { "mg979/vim-visual-multi",
    -- ABOUT: Mutliple cursors.
    -- HELP: visual-multi.txt
    init = function()
      vim.g.VM_leader = "\\"
      vim.g.VM_mouse_mappings = 1
    end,
  },

  { "echasnovski/mini.comment",
    about = "Provide gc keybindings for commenting code.",
    event = "VeryLazy",
    opts = {},
  },

  { "echasnovski/mini.surround",
    opts = {},
    keys = {
      { "s", function() require("which-key").show({ keys = "s" }) end },
      "sa",
      "sd",
      "sf",
      "sF",
      "sh",
      "sr",
      "sn",
    },
  },

  { "echasnovski/mini.move",
    event = "VeryLazy",
    opts = {
      mappings = {
        left = "<c-s-h>",
        right = "<c-s-l>",
        down = "<c-s-j>",
        up = "<c-s-k>",

        -- Move current line in Normal mode
        line_left = "<c-s-h>",
        line_right = "<c-s-l>",
        line_down = "<c-s-j>",
        line_up = "<c-s-k>",
      }
    },
  },

  { "echasnovski/mini.pairs", -- DISABLED
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
    opts = {},
  },

  { "echasnovski/mini.align",
    keys = { "ga", "gA" },
    opts = {},
  },

  { "echasnovski/mini.bracketed",
    event = "VeryLazy",
    opts = {},
  },

  { "echasnovski/mini.diff",
    event = "VeryLazy",
    opts = {},
  },
}
