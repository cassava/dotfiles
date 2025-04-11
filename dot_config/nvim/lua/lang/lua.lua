return {
  { "neovim/nvim-lspconfig",
    opts = function(_, opts)
      vim.list_extend(opts.servers, {
        lua_ls = {
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
      })
    end
  },

  { "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "lua" })
      end
    end
  },

  { "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "lua_ls",
        "stylua",
      })
    end
  },

  { "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        lua = { "stylua" }
      }
    }
  },
}
