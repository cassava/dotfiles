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
  { "williamboman/mason.nvim",
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

  { "williamboman/mason-lspconfig.nvim",
    about = [[
      Bridges mason.nvim with the nvim-lspconfig plugin.

      Provides automatic language server setup, see:
        :h mason-lspconfig-automatic-server-setup

      For automatic source installation, see mason-tool-installer.
    ]],
    dependencies = {
      "mason.nvim"
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
      require("mason-lspconfig").setup_handlers {
        function(server_name) -- default handler
          vim.lsp.enable(server_name)
        end
      }
    end
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
    config = true,
    keys = {
      { "<leader>f", "gqip", desc = "Format paragraph" },
      { ",f", function() require("conform").format() end, desc = "Format selection" },
    }
  },

  { "mfussenegger/nvim-lint",
    about = "Lint code using external linters.",
  },

  { "neovim/nvim-lspconfig",
    about = "Built-in LSP configuration mechanism.",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
      { "hrsh7th/cmp-nvim-lsp" },
    },
    init = function()
      -- @since neovim 0.11
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
          end
        end,
      })
    end
  },

  { "hrsh7th/nvim-cmp",
    about = "Provide completion.",
    event = "InsertEnter",
    config = function()
      local cmp = require("cmp")
      cmp.setup {
        mapping = cmp.mapping.preset.insert({
          ['<c-p>'] = cmp.mapping.select_prev_item(),
          ['<c-n>'] = cmp.mapping.select_next_item(),
          ['<c-b>'] = cmp.mapping.scroll_docs(-4),
          ['<c-f>'] = cmp.mapping.scroll_docs(4),
          ['<c-space>'] = cmp.mapping.complete(),
          ['<c-e>'] = cmp.mapping.abort(),
          ['<c-y>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
        }),
        formatting = {
          -- format = require("lspkind").cmp_format({
          --   mode = "symbol_text",
          --   menu = ({
          --     buffer = "[buffer]",
          --     calc = "[calc]",
          --     cmdline = "[cmdline]",
          --     luasnip = "[snip]",
          --     nvim_lsp = "[lsp]",
          --     path = "[path]",
          --   })
          -- }),
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        sources = {
          { name = "nvim_lsp",
            option = {
              markdown_oxide = {
                keyword_pattern = [[\(\k\| \|\/\|#\)\+]]
              }
            }
          },
          { name = "nvim_lsp_signature_help" },
          { name = "luasnip" },
          { name = "path" },
          { name = "calc" },
          { name = "buffer", keyword_length = 5 },
        },
        enabled = function()
          -- While this function will cause it to be disabled in many cases,
          -- you can always still get completion by using <c-space>.
          local in_prompt = vim.api.nvim_buf_get_option(0, "buftype") == "prompt"
          if in_prompt then
            -- this will disable cmp in the Telescope window
            return false
          end
          local context = require("cmp.config.context")
          return not(context.in_treesitter_capture("comment") == true or context.in_syntax_group("Comment"))
        end,
        experimental = {
          ghost_text = {
            hl_group = "LspCodeLens",
          },
        },
      }

      cmp.setup.filetype("gitcommit", {
        sources = cmp.config.sources({
          { name = "cmp_git" },
        }, {
            { name = "buffer" },
        })
      })

      -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline({"/", "?"}, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" }
        },
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" }
        }, {
          { name = "cmdline" }
        })
      })
    end,
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-cmdline" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-calc" },
      { "hrsh7th/cmp-nvim-lsp-signature-help" },
      { "saadparwaiz1/cmp_luasnip" },
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

  -- FIXME: Broken since latest update
  { "L3MON4D3/LuaSnip", -- DISABLED
    about = "Powerful snippet engine.",
    enabled = false,
    event = "InsertEnter",
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    config = function(_, opts)
      require("luasnip").setup(opts)
      require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/snippets"})
      vim.api.nvim_create_user_command("LuaSnipEdit", function() require("luasnip.loaders.from_lua").edit_snippet_files() end, {})
    end,
    keys = {
      {
        "<c-k>",
        function()
          local ls = require("luasnip")
          if ls.expand_or_jumpable() then
              ls.expand_or_jump()
          end
        end,
        mode = {"i", "s"},
        desc = "Expand snippet / Next snippet position"
      },
      {
        "<c-j>",
        function()
          local ls = require("luasnip")
          if ls.jumpable(-1) then
              ls.jump(-1)
          end
        end,
        mode = {"i", "s"},
        desc = "Previous snippet position"
      },
      {
        "<c-l>",
        function()
          local ls = require("luasnip")
          if ls.choice_active() then
              ls.change_choice(1)
              return "<nop>"
          else
            return "<c-l>"
          end
        end,
        expr = true,
        mode = "i",
        desc = "Change snippet choice",
      },
      {
        "<leader>vn",
        "<cmd>source ~/.config/nvim/after/plugin/luasnip.lua<cr>",
        desc = "Reload snippets"
      },
    },
    dependencies = {
      {
        "rafamadriz/friendly-snippets",
        about = "Snippet collection.",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
    },
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
    config = function()
        require("rainbow-delimiters.setup").setup{}
    end,
    keys = {
      {
        "<leader>ob",
        function()
          require("rainbow-delimiters").toggle(0)
          notify_option("Rainbow delimiters", require("rainbow-delimiters").is_enabled(0))
        end,
        desc = "Toggle rainbow delimiters",
      }
    }
  },
}
