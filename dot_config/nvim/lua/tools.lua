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

  { "qpkorr/vim-renamer",
    about = "Rename files in the system with: nvim +Renamer",
    cmd = "Renamer",
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
