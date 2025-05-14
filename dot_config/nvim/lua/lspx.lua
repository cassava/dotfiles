-- Disable treesitter modules for large files.
local max_filesize = 256 * 1024
local is_unsupported = function(_, bufnr)
  return vim.fn.getfsize(vim.fn.getbufinfo(bufnr)[1]["name"]) > max_filesize
end

local function notify_option(str, value)
  local state = "disabled"
  if value then
    state = "enabled"
  end
  vim.notify(str .. " " .. state .. ".")
end

vim.api.nvim_create_autocmd({ "BufReadPre" }, {
  pattern = "*",
  callback = function(info)
    if is_unsupported("", info.buf) then
      vim.notify("Large file detected, disabling treesitter.")
      vim.wo.foldmethod = "manual"
      vim.cmd [[ syntax off ]]
      require("gitsigns").detach(info.buf)
    end
  end
})

vim.diagnostic.config {
  virtual_text = true,
  virtual_lines = {
    current_line = true,
  }
}

return {
  { "mason-org/mason.nvim",
    about = "Manage external editor tooling such as for LSP and DAP.",
    version = "*",
    cmd = "Mason",
    opts = {
      ui = {
        backdrop = 0,
        border = "rounded",
      },
    },
  },

  { "mason-org/mason-lspconfig.nvim",
    about = [[
      Bridges mason.nvim with the nvim-lspconfig plugin.

      Provides automatic language server setup, see:
        :h mason-lspconfig-automatic-server-setup

      For automatic source installation, see mason-tool-installer.
    ]],
    dependencies = {
      "mason.nvim"
    },
    opts = {},
  },

  { "whoissethdaniel/mason-tool-installer.nvim",
    about = [[
      Automatically install required tooling for lsp, linting, and formatting.

      Put language-specific sources in here like so:

          { "whoissethdaniel/mason-tool-installer.nvim,
            opts = function(_, opts)
              vim.list_extend(opts.ensure_installed, {
                "stylua"
              })
            end,
          }

    ]],
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        -- Put sources that aren't language specific here.
      }
    }
  },

  { "stevearc/conform.nvim",
    about = "Format code and text using formatters.",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>f", function() require("conform").format({ async = true }) end, desc = "Format selection", mode = { "n", "x" } },
    },
    opts = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
  },

  { "mfussenegger/nvim-lint",
    about = "Lint code using external linters.",
  },

  { "neovim/nvim-lspconfig",
    about = "Built-in LSP configuration mechanism.",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- @since neovim 0.11
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
          end
        end,
      })

      -- keys
      local Snacks = require("snacks")
      Snacks.toggle.diagnostics():map("<leader>od")
      Snacks.toggle.inlay_hints():map("<leader>oh")
      Snacks.toggle.new({
        id = "virtual_text",
        name = "Virtual Text",
        get = function()
          return vim.diagnostics.config().virtual_text
        end,
        set = function()
          vim.diagnostics.config({virtual_text = not vim.diagnostics.config().virtual_text })
        end,
      }):map("<leader>ov")
      Snacks.toggle.new({
        id = "virtual_lines",
        name = "Virtual Lines",
        get = function()
          return vim.diagnostics.config().virtual_lines
        end,
        set = function()
          local value = vim.diagnostics.config().virtual_lines
          if type(value) == "table" then
            vim.diagnostics.config({virtual_lines = false})
          elseif value == true then
            vim.diagnostics.config({virtual_lines = true})
          else
            vim.diagnostics.config({virtual_lines = { current_line = true }})
          end
        end,
      }):map("<leader>oV")
      Snacks.toggle.new({
        id = "lsp",
        name = "LSP",
        get = function()
          return #vim.lsp.get_clients() > 0
        end,
        set = function()
          local clients = vim.lsp.get_clients()
          if #clients > 0 then
            vim.lsp.stop_client(clients)
          else
            vim.cmd "edit"
          end
        end,
      }):map("<leader>oL")
    end,
  },

  { "saghen/blink.cmp",
    website = "https://cmp.saghen.dev/",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "Kaiser-Yang/blink-cmp-git",
    },
    event = "VeryLazy",
    version = "1.*",

    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      -- signature = { enabled = false },
      -- completion = {
      --   documentation = {
      --     auto_show = false
      --   },
      --   ghost_text = { enabled = false },
      -- },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { "lazydev", "git", "lsp", "path", "snippets", "buffer" },
        providers = {
          git = {
            name = "Git",
            module = "blink-cmp-git",
            opts = {
              commit = {
                triggers = { "git:" },
              }
            }
          },
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        }
      },
    },
    opts_extend = { "sources.default" },
    keys = {
      -- All presets have the following mappings:
      -- C-space: Open menu or open docs if already open
      -- C-n/C-p or Up/Down: Select next/previous item
      -- C-e: Hide menu
      -- C-k: Toggle signature help (if signature.enabled = true)
      --
      -- See :h blink-cmp-config-keymap for defining your own keymap
    }
  },

  { "mfussenegger/nvim-dap",
    about = "Client for the Debug Adapter Protocol.",
    keys = {
      -- Initialize & Terminate
      { "<leader>dL", function() require("dap").run_last() end, desc = "Run last" },
      { "<leader>dR", function() require("dap").restart() end, desc = "Restart" },
      { "<leader>dX", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },

      -- Control Flow
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue (F5)" },
      { "<F5>", function() require("dap").continue() end, desc = "Continue (F5)" },
      { "<leader>ds", function() require("dap").step_over() end, desc = "Step over (F10)" },
      { "<F10>", function() require("dap").step_over() end, desc = "Step over (F10)" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into (F11)" },
      { "<F11>", function() require("dap").step_into() end, desc = "Step into (F11)" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step out (F12)" },
      { "<F12>", function() require("dap").step_out() end, desc = "Step out (F12)" },

      -- Breakpoints
      { "<leader>dbb", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dbs", function() require("dap").set_breakpoint() end, desc = "Set breakpoint" },
      { "<leader>dbl", function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, desc = "Set logging breakpoint" },
      { "<leader>dbe", function() require("dap").set_exception_breakpoints() end, desc = "Set exception breakpoint" },
      { "<leader>dbc", function() require("dap").clear_breakpoints() end, desc = "Clear breakpoints" },

      -- Info
      { "<leader>dr", function() require("dap").repl.open() end, desc = "Open REPL" },
      { "<leader>dwh", function() require("dap.ui.widgets").hover() end, mode = {"v", "n"}, desc = "Show hover" },
      { "<leader>dwp", function() require("dap.ui.widgets").preview() end, mode = {"v", "n"}, desc = "Show preview" },
      { "<leader>dwf", function() local widgets = require("dap.ui.widgets"); widgets.centered_float(widgets.frames) end, desc = "Show frames" },
      { "<leader>dws", function() local widgets = require("dap.ui.widgets"); widgets.centered_float(widgets.scopes) end, desc = "Show scopes" },
    },
    dependencies = {
      "theHamsta/nvim-dap-virtual-text"
    }
  },

  { "jay-babu/mason-nvim-dap.nvim",
    about = "Install tools for nvim-dap via Mason.",
    event = "VeryLazy",
    opts = {
      ensure_installed = {},
      handlers = {}
    },
  },

  { "rcarriga/nvim-dap-ui",
    keys = {
      { "<leader>dd", function() require("dapui").toggle() end, desc = "Open UI" },
    },
    config = function(_, opts)
      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
      dapui.setup(opts)
    end
  },

  { "theHamsta/nvim-dap-virtual-text",
    opts = {
      commented = true,
    }
  },

--- TREESITTER ----------------------------------------------------------------

  { "nvim-treesitter/nvim-treesitter",
    about = "Provide fast and accurate language parsing.",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = "all",
      sync_install = false,
      ignore_install = { "comment" },
      highlight = {
        enable = true,
        disable = function(lang, bufnr)
          return is_unsupported(lang, bufnr) or lang == "cmake"
        end,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
        disable = { "yaml" },
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<c-space>",
          node_incremental = "<c-space>",
          node_decremental = "<bs>",
        },
      },
    },
    init = function()
      local Snacks = require("snacks")
      Snacks.toggle.treesitter():map("<leader>oT")
      Snacks.toggle.new({
        id = "indent",
        name = "Treesitter Indenting",
        get = function()
          return vim.opt.indentexpr ~= ""
        end,
        set = function()
          if vim.opt.indentexpr == "" then
            vim.opt.indentexpr = "nvim_treesitter#indent()"
          else
            vim.opt.indentexpr = ""
          end
        end
      }):map("<leader>oI")
    end,
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
      vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
    end,
  },

  { "nvim-treesitter/nvim-treesitter-textobjects",
    -- Manipulate text objects
    keys = { "g>", "g<" },
    config = function()
      require("nvim-treesitter.configs").setup {
        textobjects = {
          disable = is_unsupported,
          swap = {
            enable = true,
            swap_next = {
              ["g>"] = "@parameter.inner",
            },
            swap_previous = {
              ["g<"] = "@parameter.inner",
            },
          },
        },
      }
    end,
  },

  { "nvim-treesitter/nvim-treesitter-refactor",
    event = "VeryLazy",
    config = function()
      require("nvim-treesitter.configs").setup {
        refactor = {
          disable = is_unsupported,
          highlight_definitions = {
            enable = true,
            clear_on_cursor_move = true, -- Set to false if you have an `updatetime` of ~100.
          },
        },
      }
    end,
  },

  { "theHamsta/nvim-treesitter-pairs",
    -- ABOUT: Provide language-specific % pairs
    event = "VeryLazy",
    enabled = false, -- Because according to profile.nvim this takes up so much time
    config = function()
      require("nvim-treesitter.configs").setup {
        pairs = {
          enable = false,
          disable = is_unsupported,
          -- WARNING: ESPECIALLY BAD PERFORMANCE ON "CURSORMOVED":
          highlight_pair_events = {"CursorMoved"}, -- when to highlight the pairs, {} to deactivate highlighting
          highlight_self = true, -- whether to highlight also the part of the pair under cursor (or only the partner)
          goto_right_end = false, -- whether to go to the xend of the right partner or the beginning
          fallback_cmd_normal = "call matchit#Match_wrapper('',1,'n')", -- What command to issue when we can't find a pair (e.g. "normal! %")
          keymaps = {
            goto_partner = "<leader>%",
            delete_balanced = "X",
          },
          delete_balanced = {
            only_on_first_char = false, -- whether to trigger balanced delete when on first character of a pair
            fallback_cmd_normal = nil, -- fallback command when no pair found, can be nil
            longest_partner = false, -- whether to delete the longest or the shortest pair when multiple found.
                                    -- E.g. whether to delete the angle bracket or whole tag in  <pair> </pair>
          }
        },
      }
    end,
  },

  { "nvim-treesitter/playground",
    -- ABOUT: Provide a playground, accessible via :TSPlaygroundToggle
    cmd = "TSPlaygroundToggle",
    config = function()
      require "nvim-treesitter.configs".setup {
        playground = {
          enable = true,
          disable = {},
          updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
          persist_queries = false, -- Whether the query persists across vim sessions
          keybindings = {
            toggle_query_editor = 'o',
            toggle_hl_groups = 'i',
            toggle_injected_languages = 't',
            toggle_anonymous_nodes = 'a',
            toggle_language_display = 'I',
            focus_language = 'f',
            unfocus_language = 'F',
            update = 'R',
            goto_node = '<cr>',
            show_help = '?',
          },
        }
      }
    end,
  },

  { "HiPhish/rainbow-delimiters.nvim",
    about = "Highlight parenthesis to matching pairs.",
    event = "VeryLazy",
    submodules = false,
    init = function()
      local Snacks = require("snacks")
      Snacks.toggle.new({
        id = "rainbow_delimiters",
        name = "Rainbow Delimiters",
        get = function() return require("rainbow-delimiters").is_enabled(0) end,
        set = function() require("rainbow-delimiters").toggle() end,
      }):map("<leader>oR")
    end,
  },
}
