return {
  lazy_treesitter_ensure_installed { "rust" },

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
