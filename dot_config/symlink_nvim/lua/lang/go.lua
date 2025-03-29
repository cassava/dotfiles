vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = function()
    -- This way I don't add tabs by accident when writing long
    -- strings. The gofmt formatter will convert other spaces to tabs.
    vim.opt_local.expandtab = true

    -- Don't show whitespace like I normally do, because gofmt will handle it.
    -- Occassionally, you should check strings to make sure they don't contain tabs.
    vim.opt_local.list = false
    vim.g.go_auto_type_info = 0
  end
})

return {
  { "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_ensure_installed({ "go", "gomod", "gosum", "gowork" })
      end
    end
  },

  { "fatih/vim-go",
    ft = "go",
    init = function()
      vim.g.go_highlight_trailing_whitespace_error = 0
      vim.g.go_auto_type_info = 1
      vim.g.go_fmt_command = "goimports"
      vim.g.go_fmt_experimental = 1
    end
  },

  { "ngynkvn/gotmpl.nvim",
    opts = {}
  },
}
