local function trim(str)
  return str:gsub("^%s*(.-)%s*$", "%1")
end

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
      { "<leader>k", "<nop>", desc = "obsidian" },
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
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    ---@module 'obsidian'
    --@type obsidian.config.ClientOpts
    opts = {
      legacy_commands = false,
      workspaces = {
        {
          name = "default",
          path = "~/notes",
        },
      },
      callbacks = {
        enter_note = function(note)
          require("which-key").add({
            { "<c-k>", "<cmd>Obsidian toggle_checkbox<cr>", mode = {"n", "x"} },
            { "<leader>km", "<cmd>Obsidian template<cr>" },
            { "<leader>kb", "<cmd>Obsidian backlinks<cr>" },
            { "<leader>kf", "<cmd>Obsidian follow_link vsplit<cr>" },
            { "<leader>kl", "<cmd>Obsidian link<cr>", mode = { "x" } },
            { "<leader>kL", "<cmd>Obsidian link_new<cr>", mode = { "x" } },
            { "<leader>kH", "<cmd>Obsidian links<cr>"  },
            { "<leader>ko", "<cmd>Obsidian open<cr>"  },
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
      daily_notes = {
        folder = "dailies",
        default_tags = { "daily" },
        template = "daily.md",
      },
      templates = {
        folder = "templates",
        substitutions = {
          boot_times = function()
            local result = vim.fn.system([[
              journalctl -q --list-boots | \
              awk -v today=$(date -d "today" +"%Y-%m-%d") '$4 ~ today { print }' | \
              sed -r 's/^.* ([0-9]{2}:[0-9]{2}):[0-9]{2} .* ([0-9]{2}:[0-9]{2}):[0-9]{2}.*$/\1-\2/'
            ]])
            return trim(result)
          end,
          date_human = function()
            local result = vim.fn.system([[
              date +"%A %d %B %Y" | awk '{
                split($0, a, " ");
                day=a[2]+0;
                # Determine suffix
                if (day % 10 == 1 && day != 11) s="st";
                else if (day % 10 == 2 && day != 12) s="nd";
                else if (day % 10 == 3 && day != 13) s="rd";
                else s="th";
                printf "%s, %d%s of %s, %s\n", a[1], day, s, a[3], a[4];
              }'
            ]])
            return trim(result)
          end,
        }
      },
      checkbox = {
        order = { " ", "x", "~", ">", "!" }
      },
      statusline = { enabled = false },
      footer = { enabled = false },
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
        callback = function(ctx)
          if string.match(ctx.match, "/[.]git/") then
            -- Ignore unmanaged files
            return
          end
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

  { "olimorris/codecompanion.nvim",
    opts = {
      strategies = {
        chat = {
          adapter = "copilot",
          model = "claude-sonnet-4",
        },
        inline = {
          adapter = "copilot"
        }
      }
    },
    keys = {
      { "<leader>c", "<nop>", desc = "+ai" },
      { "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", desc = "Toggle Chat" },
      { "<leader>cn", "<cmd>CodeCompanionChat<cr>", desc = "Open Chat" },
      { "<leader>ca", "<cmd>CodeCompanionActions<cr>", desc = "Open Actions" },
      { "<leader>ck", "<cmd>CodeCompanion /explain<cr>", desc = "Explain", mode = {"x", "n"} },
      { "<leader>ci", ":CodeCompanion ", desc = "Perform ...", mode = {"x", "n"} },
    },
  }
}
