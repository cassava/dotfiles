return {
  -- Primary colorscheme
  { "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      options = {
        dim_inactive = true,
        styles = {
          comments = "italic",
        }
      },
      palettes = {
        nordfox = {
          bg05 = "#292d38", -- Halfway between bg0 and bg1
          comment = "#8092aa", -- Lighter than original (#60728a)
          original_comment = "#60728a",
        }
      },
      groups = {
        nordfox = {
          CursorLine = { bg = "palette.bg05" },
          Folded = { fg = "palette.original_comment", bg = "palette.bg0" }
        }
      },
    },
    config = function(_, opts)
      require("nightfox").setup(opts)
      vim.cmd "colorscheme nordfox"
    end
  },

  { "folke/tokyonight.nvim",
    lazy = true,
  },
}
