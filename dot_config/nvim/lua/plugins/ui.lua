return {
  { "b0o/incline.nvim",
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

  { "rcarriga/nvim-notify",
    about = "Better vim.notify",
    event = "VeryLazy",
    opts = {
      timeout = 5000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      render = function(bufnr, notif, highlights)
        local base = require("notify.render.base")
        local namespace = base.namespace()
        local icon = notif.icon
        local title = notif.title[1]

        local prefix = string.format("%s %s:", icon, title)
        notif.message[1] = string.format("%s %s", prefix, notif.message[1])

        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, notif.message)

        local icon_length = vim.str_utfindex(icon)
        local prefix_length = vim.str_utfindex(prefix)

        vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, 0, {
          hl_group = highlights.icon,
          end_col = icon_length + 1,
          priority = 50,
        })
        vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, icon_length + 1, {
          hl_group = highlights.title,
          end_col = prefix_length + 1,
          priority = 50,
        })
        vim.api.nvim_buf_set_extmark(bufnr, namespace, 0, prefix_length + 1, {
          hl_group = highlights.body,
          end_line = #notif.message,
          priority = 50,
        })
      end
    },
    keys = {
      { "<leader>nn", "<cmd>Telescope notify<cr>", desc = "View notifications" },
      { "<leader>nl", function() require("notify").dismiss({ silent = true, pending = true }) end, desc = "Clear all notifications" },
    },
    init = function()
      vim.notify = function(...) return require("notify").notify(...) end
    end,
    config = function(_, opts)
      require("notify").setup(opts)
      require("telescope").load_extension("notify")
    end,
  },

  { "stevearc/dressing.nvim",
    about = "Better vim.ui",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },

  { "nvim-lualine/lualine.nvim",
    about = "Fancy statusline with information from various sources.",
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

  { "petertriho/nvim-scrollbar",
    event = "VeryLazy",
    config = true,
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    enabled = false,
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
    -- stylua: ignore
    -- keys = {
    --   { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
    --   { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
    --   { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
    --   { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
    --   { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll forward", mode = {"i", "n", "s"} },
    --   { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll backward", mode = {"i", "n", "s"}},
    -- },
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

  { "echasnovski/mini.indentscope",
    version = "*",
    lazy = false,
    keys = {
      {
        "<leader>oi",
        function()
          vim.b.miniindentscope_disable = not vim.b.miniindentscope_disable
          if vim.b.miniindentscope_disable then
            require("mini.indentscope").undraw()
          else
            require("mini.indentscope").draw()
          end
        end,
        desc = "Toggle indentscope"
      }
    },
    opts = function()
      return {
        draw = {
          delay = 250,
          animation = require("mini.indentscope").gen_animation.none()
        },
      }
    end,
    config = function(_, opts)
      vim.api.nvim_create_autocmd({"BufEnter"}, {
        callback = function()
          if vim.b.miniindentscope_disable == nil then
            vim.b.miniindentscope_disable = true
          end
        end
      })
      require("mini.indentscope").setup(opts)
    end,
  },

  { "anuvyklack/pretty-fold.nvim",
    about = "Improve folding appearnce.",
    event = "VeryLazy",
    config = true,
    dependencies = {
      "anuvyklack/keymap-amend.nvim",
    }
  },

  { "kevinhwang91/nvim-hlslens",
    config = function()
      require("scrollbar.handlers.search").setup({
        -- hlslens config overrides
      })
    end
  },

  { "nvim-tree/nvim-web-devicons",
    lazy = true
  },
}
