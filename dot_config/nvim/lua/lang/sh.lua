return {
  { "whoissethdaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "bash-language-server",
        "shfmt",
        "shellcheck",
      })
    end,
  },

  -- { "nvimtools/none-ls.nvim",
  --   opts = function(_, opts)
  --     local nls = require("null-ls")
  --     vim.list_extend(opts.sources, {
  --       nls.builtins.formatting.shfmt,
  --     })
  --   end
  -- },
}
