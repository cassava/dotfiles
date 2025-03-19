return {
  { "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "awk",
          "bash",
          "devicetree",
          "diff",
          "ebnf",
          "fish",
          "ini",
          "make",
          "markdown",
          "ninja",
          "perl",
          "regex",
          "rst",
          "toml",
        })
      end
    end
  },

  --[[
  { "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      vim.list_extend(opts.sources, {
      })
    end
  },
  --]]

  { "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "shellcheck",
        "shfmt",
      })
    end
  },
}
