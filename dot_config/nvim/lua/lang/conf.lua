return {
  lazy_treesitter_ensure_installed {
    "json",
    "yaml",
    "toml",
    "ini",
    "csv",
    "tsv",
    "jq",
    "json",
    "json5",
    "jsonc",
    "jsonnet",
    "psv",
    "capnp",
    "proto",
    "xml",
    "dtd",
  },

  lazy_mason_ensure_installed {
    "jq",
    "jsonls",
    "yamllint",
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
}
