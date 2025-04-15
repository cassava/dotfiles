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

  -- { "RaafatTurki/hex.nvim",
  --   config = true,
  -- },

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

  { "dstein64/vim-startuptime",
    about = "Measure startup time.",
    cmd = "StartupTime",
    config = function()
      vim.g.startuptime_tries = 10
    end,
  },

  { "stevearc/profile.nvim",
    about = [[
      Gigantic hack to profile Lua in neovim by monkeypatching all functions.

      0. Enable this plugin.
      1. Start with: NVIM_PROFILE=1 nvim ...
      2. Press <F1> to start.
      3. Do stuff.
      4. Press <F1> to stop and save.

      Keep #3 as short as possible. Each second is about 100M of data.
    ]],
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
    end,
    keys = {
      {
        "<F1>",
        function()
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
        end,
        desc = "Start/Stop Profiling"
      }
    },
  }
}
