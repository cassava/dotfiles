return {
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
  -- }
}
