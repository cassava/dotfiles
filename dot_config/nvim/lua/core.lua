-- core.lua
--
-- Contains plugins setting up dependencies for other plugins as well as
-- fine-tuning the basics.
--
-- This module returns a list of plugin specs for lazy.nvim
--

return {
  { "nvim-lua/plenary.nvim",
    about = [[
      Lua library for writing modern Neovim plugins.

      Modules:
        plenary.async
        plenary.async_lib
        plenary.job
        plenary.path
        plenary.scandir
        plenary.context_manager
        plenary.test_harness
        plenary.filetype
        plenary.strings

      Required by many plugins.
    ]]
  },

  { "tpope/vim-repeat",
    about = [[
      Extends repeat command . to mappings and plugins.
    ]],
    event = "VeryLazy"
  },

  { "folke/snacks.nvim",
    about = [[
      If you want to profile:
        https://github.com/folke/snacks.nvim/blob/main/docs/profiler.md
    ]],
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = {
        -- Deal with big files.
        enabled = true
      },
      image = { enabled = false },
      input = { enabled = true },
      notifier = { enabled = true },
      picker = { enabled = true },
      quickfile = {
        -- When doing `nvim somefile.txt`, it will render the file as quickly as possible,
        -- before loading other plugins.
        enabled = true
      },
      scratch = {
        zindex = 50,
      },
      scroll = {
        enabled = true,
        animate = {
          duration = { step = 10, total = 100 },
        }
      },
      statuscolumn = {
        enabled = false,
      },
      zen = {
        win = {
          wo = {
            wrap = true
          }
        }
      },
    },
    keys = {
      -- Top Pickers & Explorer
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
      { "<leader>a", function() Snacks.picker.pick("grep", { dirs = { vim.fs.root(0, ".git") } }) end, desc = "Find project files" },
      { "<leader>.", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>*", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
      { "<leader>>", ":lua ", desc = "Run Lua" },
      { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
      { "<leader>u", function() Snacks.picker.undo() end, desc = "Undo History" },
      -- find
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
      { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
      { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
      -- git
      { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
      { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
      { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
      { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
      { "<leader>gt", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
      { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
      -- grep
      { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
      -- vim
      { "<leader>va", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
      { "<leader>vc", function() Snacks.picker.commands() end, desc = "Commands" },
      { "<leader>vC", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>vh", function() Snacks.picker.help() end, desc = "Help Pages" },
      { "<leader>vH", function() Snacks.picker.highlights() end, desc = "Highlights" },
      { "<leader>vk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>vN",
        desc = "Neovim News",
        function()
          Snacks.win({
            file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
            width = 0.6,
            height = 0.6,
            wo = {
              spell = false,
              wrap = false,
              signcolumn = "yes",
              statuscolumn = " ",
              conceallevel = 3,
            },
          })
        end,
      },
      -- search
      { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
      { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search History" },
      { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
      { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
      { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
      { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
      { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
      { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
      { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
      { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
      { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
      { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume Picking" },
      { "<leader>oC", function() Snacks.picker.colorschemes() end, desc = "Colorschemes" }, -- FIXME
      -- LSP
      { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
      { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
      -- { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" }, -- FIXME
      { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
      { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
      { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
      { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
      -- Other
      { "<leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
      { "<leader>Z",  function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
      { "<leader>,",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
      { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
      { "<leader>-R", function() Snacks.rename.rename_file() end, desc = "Rename File" },
      { "<leader>gw", function() Snacks.gitbrowse() end, desc = "Open in Browser", mode = { "n", "v" } },
      -- { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" }, -- FIXME
      { "<c-/>",      function() Snacks.terminal() end, desc = "Toggle Terminal" },
      { "<c-_>",      function() Snacks.terminal() end, desc = "which_key_ignore" },
      { "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
      { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...) Snacks.debug.inspect(...) end
          _G.bt = function() Snacks.debug.backtrace() end
          vim.print = _G.dd -- Override print to use Snacks for `:=` command

          -- Toggle Snack features:
          Snacks.toggle.animate():map("<leader>oa")
          Snacks.toggle.scroll():map("<leader>oS")
          Snacks.toggle.indent():map("<leader>og")

          -- Toggle options:
          Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }):map("<leader>ox")
          Snacks.toggle.option("number", { name = "Number" }):map("<leader>on")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>oN")
          Snacks.toggle.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" }):map("<leader>oA")
          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>oz")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>ow")
          Snacks.toggle.option("expandtab", { name = "Expand Tab" }):map("<leader>ot")
          Snacks.toggle.new({
            id = "colorcolumn",
            name = "Color Column",
            get = function()
              return vim.o.colorcolumn ~= ""
            end,
            set = function()
              local def_width = 80
              if vim.o.colorcolumn == "" then
                if vim.o.textwidth ~= 0 then
                  vim.opt.colorcolumn = { vim.o.textwidth }
                else
                  vim.opt.colorcolumn = { def_width }
                  vim.opt.textwidth = def_width
                end
              else
                vim.opt.colorcolumn = {}
              end
            end
          }):map("<leader>oc")
        end,
      })
    end
  },

  { "nvim-mini/mini.basics",
    about = [[
    ]],
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

  { "nvim-mini/mini.misc",
    config = function()
      require("mini.misc").setup_restore_cursor()
    end
  },

--- FILE MANAGEMENT -----------------------------------------------------------

  { "nvim-mini/mini.starter",
    opts = {},
  },

  { "nvim-mini/mini.sessions",
    opts = {},
  },

  { "tpope/vim-eunuch",
    about = [[
      Sugar for the UNIX shell commands that need it most.
    ]],
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
    },
  },

  { "stevearc/oil.nvim",
    about = "A file explorer that lets you edit your filesystem like a normal Neovim buffer",
    lazy = false,
    keys = {
      { "-", function() require("oil").open(nil) end, desc = "Open parent directory" },
    },
    opts = {},
    init = function()
      -- From folke/snacks.nvim:
      vim.api.nvim_create_autocmd("User", {
        pattern = "OilActionsPost",
        callback = function(event)
            if event.data.actions.type == "move" then
                require("snacks").rename.on_rename_file(event.data.actions.src_url, event.data.actions.dest_url)
            end
        end,
      })
    end
  },

  { "nvim-mini/mini.files",
    opts = {},
    keys = {
      { "_", function() require("mini.files").open() end, desc = "Open file browser" },
    },
    init = function()
      -- From folke/snacks.nvim:
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesActionRename",
        callback = function(event)
          require("snacks").rename.on_rename_file(event.data.from, event.data.to)
        end,
      })
    end
  },
}
