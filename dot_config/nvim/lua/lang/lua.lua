return {
  lazy_treesitter_ensure_installed { "lua", "luadoc" },
  lazy_mason_ensure_installed { "lua_ls", "stylua" },

  { "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" }
      }
    }
  },

  { "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
}
