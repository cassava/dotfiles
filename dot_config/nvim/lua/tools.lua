return {
  { "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = true,
    event = {
      "BufReadPre " .. vim.fn.expand("~/notes/*.md"),
      "BufNewFile " .. vim.fn.expand("~/notes/*.md"),
    },
    cmd = {
      "Obsidian"
    },
    keys = {
      { "<leader>k", "<nop>", desc = "Obsidian" },
      { "<leader>kd", "<cmd>Obsidian dailies<cr>" },
      { "<leader>kk", "<cmd>Obsidian quick_switch<cr>" },
      { "<leader>kn", "<cmd>Obsidian new<cr>" },
      { "<leader>kN", "<cmd>Obsidian new_from_template<cr>" },
      { "<leader>ks", "<cmd>Obsidian search<cr>" },
      { "<leader>kt", "<cmd>Obsidian tags<cr>" },
      { "<leader>k.", "<cmd>Obsidian today<cr>" },
      { "<leader>k<", "<cmd>Obsidian yesterday<cr>" },
      { "<leader>k>", "<cmd>Obsidian tomorrow<cr>" },
      { "<leader>kw", "<cmd>Obsidian workspace<cr>" },
      { "<leader>kx", "<cmd>Obsidian toggle_checkbox<cr>" },
      -- { "<leader>kb", "<cmd>Obsidian backlinks<cr>" }, -- file local
      -- { "<leader>kf", "<cmd>Obsidian follow_link vsplit<cr>" },
      -- { "<leader>kl", "<cmd>Obsidian link<cr>", mode = { "x" } },
      -- { "<leader>kL", "<cmd>Obsidian link_new<cr>", mode = { "x" } },
      -- { "<leader>kH", "<cmd>Obsidian links<cr>"  },
      -- { "<leader>ko", "<cmd>Obsidian open<cr>"  },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    ---@module 'obsidian'
    --@type obsidian.config.ClientOpts
    opts = {
      workspaces = {
        {
          name = "default",
          path = "~/notes",
        },
      },
      callbacks = {
        enter_note = function(_, note)
          require("which-key").add({
            { "<c-k>", "<cmd>Obsidian toggle_checkbox<cr>", desc = "Toggle checkbox", mode = {"n", "x"} },
            buffer = note.bufnr
          })
        end
      },
      completion = {
        nvim_cmp = false,
        blink = true,
      },
      picker = {
        name = "snacks.pick"
      },
      mappings = {
      },
      daily_notes = {
        folder = "dailies",
        default_tags = { "daily" },
        template = "daily.md",
      },
      templates = {
        folder = "templates",
        substitutions = {
          boot_times = function()
            return vim.fn.system([[
              journalctl --list-boots 2>&/dev/null | \
              awk -v yest=$(date -d "yesterday" +"%Y-%m-%d") '$4 ~ yest { print }' | \
              sed -r 's/^.* ([0-9]{2}:[0-9]{2}):[0-9]{2} .* ([0-9]{2}:[0-9]{2}):[0-9]{2}.*$/\1-\2/'
            ]])
          end
        }
      },
      ui = {
        checkboxes = {
          [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
          ["x"] = { char = "", hl_group = "ObsidianDone" },
          [">"] = { char = "", hl_group = "ObsidianRightArrow" },
          ["~"] = { char = "", hl_group = "ObsidianTilde" },
          ["!"] = { char = "", hl_group = "ObsidianImportant" },
        }
      }
    },
  },

  { "chrisgrieser/nvim-rulebook",
    about = [[
      Add inline comments to ignore rules, or lookup rule documentation online.
    ]],
    cmd = "Rulebook",
  },

  { "stevearc/overseer.nvim",
    about = [[
      Task runner and job management plugin.
    ]],
    opts = {},
  },

  { "subnut/nvim-ghost.nvim",
    about = "Bi-directionally edit text content in the browser.",
    cmd = {
      "GhostTextStart",
    },
    init = function()
      vim.g.nvim_ghost_autostart = 0
    end
  },

  { "magicduck/grug-far.nvim",
    about = "Interactive search and replace.",
    opts = {},
    cmd = { "GrugFar" },
  },

  { "RaafatTurki/hex.nvim",
    opts = {},
  },

  { "axieax/urlview.nvim",
    about = [[
      Find and show URLs from the buffer or other contexts.
    ]],
    cmd = "UrlView",
  },

  { "esensar/nvim-dev-container",
    cmd = {
      "DevcontainerStart",
      "DevcontainerAttach",
      "DevcontainerExec",
      "DevcontainerStop",
      "DevcontainerStopAll",
      "DevcontainerRemoveAll",
      "DevcontainerLogs",
      "DevcontainerEditNearestConfig",
    },
    opts = {},
  },

  { "xvzc/chezmoi.nvim",
    cmd = { "ChezmoiEdit" },
    keys = {
      {
        "<leader>sz",
        function()
          local results = require("chezmoi.commands").list({
            args = {
              "--path-style",
              "absolute",
              "--include",
              "files",
              "--exclude",
              "externals",
            },
          })
          local items = {}

          for _, czFile in ipairs(results) do
            table.insert(items, {
              text = czFile,
              file = czFile,
            })
          end

          ---@type snacks.picker.Config
          local opts = {
            items = items,
            confirm = function(picker, item)
              picker:close()
              require("chezmoi.commands").edit({
                targets = { item.text },
                args = { "--watch" },
              })
            end,
          }
          Snacks.picker.pick(opts)
        end,
        desc = "Chezmoi",
      },
    },
    opts = {
      edit = {
        watch = false,
        force = false,
      },
      notification = {
        on_open = true,
        on_apply = true,
        on_watch = false,
      },
      telescope = {
        select = { "<CR>" },
      },
    },
    init = function()
      -- run chezmoi edit on file enter
      vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = { os.getenv("HOME") .. "/.local/share/chezmoi/*" },
        callback = function()
          vim.schedule(require("chezmoi.commands.__edit").watch)
        end,
      })
    end,
  },

  { "folke/snacks.nvim",
    opts = function()
      local Snacks = require("snacks")
      Snacks.toggle.profiler():map("<leader>vpp")
      Snacks.toggle.profiler_highlights():map("<leader>vph")
    end,
    keys = {
      { "<leader>vp", group = "Profiler" },
      { "<leader>vps", function() require("snacks").profiler.scratch() end, desc = "Profiler Scratch Buffer" },
    }
  },

  { "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, require("snacks").profiler.status())
    end,
  },
}
