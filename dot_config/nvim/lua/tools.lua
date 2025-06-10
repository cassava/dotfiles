return {
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
