return {
  { "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "yaml" })
      end
    end
  },

  -- { "nvimtools/none-ls.nvim",
  --   opts = function(_, opts)
  --     local nls = require("null-ls")
  --     vim.list_extend(opts.sources, {
  --       nls.builtins.diagnostics.yamllint,
  --     })
  --   end
  -- },
}
