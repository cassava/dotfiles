return {
  { "folke/neodev.nvim",
    opts = {
      experimental = {
        pathStrict = true
      },
      library = {
        plugins = {
          "nvim-dap-ui"
        },
        types = true
      },
    }
  },

  { "neovim/nvim-lspconfig",
    about = "Built-in LSP configuration mechanism.",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "folke/neoconf.nvim", cmd = "Neoconf", config = true },
      { "folke/neodev.nvim" },
      { "mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "lvimuser/lsp-inlayhints.nvim", config = true },
    },
    opts = {
      -- Automatically format on save
      autoformat = false,

      -- Options for vim.diagnostic.config()
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 4, prefix = "●" },
        severity_sort = true,
      },

      -- Options for vim.lsp.buf.format
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },

      -- LSP Server Settings
      servers = {},
      setup = {},
    },
    config = function(_, opts)
      require("lspconfig.ui.windows").default_options.border = "rounded"

      -- Enable completion triggered by <c-x><c-o>
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          if not (args.data and args.data.client_id) then
            return
          end
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)

          require("lsp-inlayhints").on_attach(client, bufnr)
          vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

          require("util").keymapper().register({
            -- Replace Vim standard keybindings to use LSP:
            ["gD"] = { vim.lsp.buf.declaration, "Goto declaration [lsp]" },
            ["gd"] = { vim.lsp.buf.definition, "Goto definition [lsp]" },
            ["gi"] = { vim.lsp.buf.implementation, "Goto implementation [lsp]" },
            ["gr"] = { vim.lsp.buf.references, "Show references [lsp]" },
            ["K"] = { vim.lsp.buf.hover, "Hover entity [lsp]" },
            ["<c-e>"] = { vim.lsp.buf.signature_help, "Show signature help [lsp]" },
            [",e"] = { vim.diagnostic.open_float, "Open diagnostics [lsp]" },
            [",q"] = { vim.diagnostic.setloclist, "Send diagnostics to QuickList [lsp]" },
            [",wa"] = { vim.lsp.buf.add_workspace_folder, "Add workspace folder [lsp]" },
            [",wr"] = { vim.lsp.buf.remove_workspace_folder, "Remove workspace folder [lsp]" },
            [",wl"] = { function() print(vim.inspectp.buf.list_workspace_folders()) end, "Show workspace folders [lsp]" },
            [",d"] = { vim.lsp.buf.type_definition, "Goto type definition [lsp]" },
            [",r"] = { vim.lsp.buf.rename, "Rename entity [lsp]" },
            [",c"] = { vim.lsp.buf.code_action, "Code actions [lsp]" },
            [",s"] = { "<cmd>Telescope lsp_document_symbols<cr>", "Search symbols [lsp]" },
            [",f"] = { function() vim.lsp.buf.format() end, "Format file [lsp]" },
          })
          vim.cmd "command! LspFormat execute 'lua vim.lsp.buf.formatting()'"
        end
      })

      -- diagnostics
      -- for name, icon in pairs(require("lazyvim.config").icons.diagnostics) do
      --   name = "DiagnosticSign" .. name
      --   vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
      -- end
      vim.diagnostic.config(opts.diagnostics)

      local servers = opts.servers
      local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
        }, servers[server] or {})

        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then
            return
          end
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then
            return
          end
        end
        require("lspconfig")[server].setup(server_opts)
      end

      local mlsp = require("mason-lspconfig")
      local available = mlsp.get_available_servers()

      local ensure_installed = {} ---@type string[]
      for server, server_opts in pairs(servers) do
        if server_opts then
          server_opts = server_opts == true and {} or server_opts
          -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
          if server_opts.mason == false or not vim.tbl_contains(available, server) then
            setup(server)
          else
            ensure_installed[#ensure_installed + 1] = server
          end
        end
      end

      require("mason-lspconfig").setup({ ensure_installed = ensure_installed })
      require("mason-lspconfig").setup_handlers({ setup })
    end
  },

  { "williamboman/mason.nvim",
    about = "Manage external editor tooling such as for LSP and DAP.",
    version = "*",
    cmd = "Mason",
    opts = {
      ui = {
        border = "rounded"
      },
      ensure_installed = {
        -- Put sources that aren't language specific here.
      }
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      for _, tool in ipairs(opts.ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end,
  },

  { "onsails/lspkind-nvim",
    about = "Provide fancy icons for LSP information, in particular for nvim-cmp.",
  },

  { "jose-elias-alvarez/null-ls.nvim",
    about = "Provide LSP diagnostics, formatting, and code actions from non-LSP tools.",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      sources = {
        -- Put sources that aren't language specific here.
      }
    },
    dependencies = {
      { "jay-babu/mason-null-ls.nvim",
        about = "Install tools for null-ls via Mason.",
        config = true,
      },
    }
  },

  { "tami5/lspsaga.nvim",
    about = "LSP enhancer.",
    enabled = false,
    config = true
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
          format = require("lspkind").cmp_format({
            mode = "symbol_text",
            menu = ({
              buffer = "[buffer]",
              calc = "[calc]",
              cmdline = "[cmdline]",
              luasnip = "[snip]",
              nvim_lsp = "[lsp]",
              path = "[path]",
            })
          }),
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        sources = {
          { name = "nvim_lsp" },
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

  { "L3MON4D3/LuaSnip",
    about = "Powerful snippet engine.",
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

  { "echasnovski/mini.comment",
    about = "Provide gc keybindings for commenting code.",
    dependencies = {
      { "JoosepAlviste/nvim-ts-context-commentstring", lazy = true },
    },
    event = "VeryLazy",
    opts = {
      hooks = {
        pre = function()
          require("ts_context_commentstring.internal").update_commentstring({})
        end,
      },
    },
    config = function(_, opts)
      require("mini.comment").setup(opts)
    end,
  },

  { "stevearc/aerial.nvim",
    about = "Provide a symbol outline.",
    cmd = {
      "AerialOpen",
      "AerialOpenAll",
      "AerialToggle",
    },
    keys = {
      { ",o", "<cmd>AerialToggle!<cr>", desc = "Toggle outline" },
    },
    config = true,
  }
}
