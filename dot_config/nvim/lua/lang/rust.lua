return {
  { "nvim-treesitter/nvim-treesitter",
    -- Add Rust to treesitter.
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_ensure_installed({ "rust" })
      end
    end
  },

  { "rust-lang/rust.vim",
    enabled = false,
    ft = "rust",
    init = function()
      vim.g.rustfmt_autosave = 0
    end
  },

  { "simrat39/rust-tools.nvim",
    -- ABOUT: Advanced rust tooling.
    ft = "rust",
    opts = {
      tools = {
        inlay_hints = {
            auto = false
        }
      }
    }
  },
}
