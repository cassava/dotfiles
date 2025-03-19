-- Disable treesitter modules for large files.
local max_filesize = 256 * 1024
local is_unsupported = function(_, bufnr)
  return vim.fn.getfsize(vim.fn.getbufinfo(bufnr)[1]["name"]) > max_filesize
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

return {

-- Coding

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

  { "nvimtools/none-ls.nvim",
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

  -- FIXME: Broken since latest update
  { "L3MON4D3/LuaSnip",
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

  { "echasnovski/mini.comment",
    about = "Provide gc keybindings for commenting code.",
    event = "VeryLazy",
    config = true,
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
  },


-- Colorscheme

  { "EdenEast/nightfox.nvim",
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
    end
  },

  { "folke/tokyonight.nvim",
    lazy = true,
  },

-- Core

  { "folke/which-key.nvim",
    about = "Provides popup reference for your keybindings.",
    version = "*",
    event = "VeryLazy",
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
    keys = {
      { 
        "]k",
        function()
          require("trouble").next({skip_groups = true, jump = true});
        end,
        desc = "Next Trouble"
      },

      {
        "[k",
        function()
          require("trouble").previous({skip_groups = true, jump = true});
        end,
        desc = "Previous Trouble"
      },

      {
        "[K",
        function()
          require("trouble").first({skip_groups = true, jump = true});
        end,
        desc = "First Trouble"
      },

      {
        "]K",
        function()
          require("trouble").last({skip_groups = true, jump = true});
        end,
        desc = "Last Trouble"
      },
    },
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

      -- FIXME: Update these

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

-- Tools
  { "xvzc/chezmoi.nvim",
    about = "Automatically apply chezmoi-managed files.",
    init = function()
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
          pattern = { os.getenv("HOME") .. "/.local/share/chezmoi/*" },
          callback = function(ev)
              local bufnr = ev.buf
              local edit_watch = function()
                  require("chezmoi.commands.__edit").watch(bufnr)
              end
              vim.schedule(edit_watch)
          end,
      })
    end,
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = true,
  },

  { "qpkorr/vim-renamer",
    about = "Rename files in the system with: nvim +Renamer",
    cmd = "Renamer",
  },

  { "raghur/vim-ghost",
    about = "Bi-directionally edit text content in the browser.",
    build = function()
      vim.fn.system "python3 -m pip install --user --upgrade neovim"
      vim.cmd "GhostInstall"
    end,
    cmd = {
      "GhostStart",
      "GhostInstall",
    },
    init = function()
      vim.g.ghost_autostart = 0
    end
  },

  { "windwp/nvim-spectre",
    about = "Interactive search and replace.",
    cmd = { "Spectre" },
    config = true,
  },

  -- { "RaafatTurki/hex.nvim",
  --   config = true,
  -- },

-- Treesitter

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

  { "p00f/nvim-ts-rainbow",
    about = "Highlight parenthesis to matching pairs.",
    enabled = false, -- not working correctly...
    event = "VeryLazy",
    config = function()
      require("nvim-treesitter.configs").setup {
        rainbow = {
          enable = true,
          disable = is_unsupported,
          -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
          extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
          max_file_lines = nil, -- Do not enable for files with more than n lines, int
          -- colors = {}, -- table of hex strings
          -- termcolors = {} -- table of colour name strings
        },
      }
    end,
  },

  { "theHamsta/nvim-treesitter-pairs",
    -- ABOUT: Provide language-specific % pairs
    event = "VeryLazy",
    config = function()
      require("nvim-treesitter.configs").setup {
        pairs = {
          enable = true,
          disable = is_unsupported,
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

-- User Interface

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

  { "csams/pretty-fold.nvim",
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

-- Util

  { "dstein64/vim-startuptime",
    about = "Measure startup time.",
    cmd = "StartupTime",
    config = function()
      vim.g.startuptime_tries = 10
    end,
  },

  { "nvim-lua/plenary.nvim",
    about = "Library used by other plugins.",
    lazy = true
  },

  { "tpope/vim-repeat",
    about = "Extend repeat command . to mappings and plugins.",
    event = "VeryLazy"
  },

  { "nvim-lua/popup.nvim",
    about = "Popup API implmentation is a plugin until merged into neovim.",
    lazy = true
  },

  { "echasnovski/mini.misc",
    about = "Miscellaneous useful functions.",
    lazy = true
  },

  { "stevearc/profile.nvim",
    lazy = false,
    enabled = false,
    config = function()
      local should_profile = os.getenv("NVIM_PROFILE")
      if should_profile then
        require("profile").instrument_autocmds()
        if should_profile:lower():match("^start") then
          require("profile").start("*")
        else
          require("profile").instrument("*")
        end
      end

      local function toggle_profile()
        local prof = require("profile")
        if prof.is_recording() then
          prof.stop()
          vim.ui.input({ prompt = "Save profile to:", completion = "file", default = "profile.json" }, function(filename)
            if filename then
              prof.export(filename)
              vim.notify(string.format("Wrote %s", filename))
            end
          end)
        else
          vim.notify("Start profiling...")
          prof.start("*")
        end
      end
      vim.keymap.set("", "<f1>", toggle_profile)
    end
  }
}
