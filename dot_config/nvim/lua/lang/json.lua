return {
  { "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "json", "json5", "jsonc", "jq", "jsonnet", "hjson" })
      end
    end
  },

  { "b0o/schemastore.nvim",
    init = function()
      vim.lsp.config("jsonls", {
        settings = {
            json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
            },
        },
      })
    end
  },

  { "whoissethdaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "jq",
        "jsonls",
      })
    end
  },
}
