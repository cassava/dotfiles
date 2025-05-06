return {
  { "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- TODO: Remove this work-around when the underlying issue is fixed.
      --       Fixes syntax-highlighting flickering when inserting text.
      --       See: https://github.com/neovim/neovim/issues/32660
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown" },
        callback = function()
          vim.g._ts_force_sync_parsing = true
        end
      })
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "markdown" })
      end
    end
  },

  { "iamcco/markdown-preview.nvim",
    build = function() vim.fn["mkdp#util#install"]() end,
    init = function()
      if vim.fn.executable("microsoft-edge") then
        vim.g.mkdp_browser = "microsoft-edge"
      elseif vim.fn.executable("firefox") then
        vim.g.mkdp_browser = "firefox"
      elseif vim.fn.executable("chromium") then
        vim.g.mkdp_browser = "chromium"
      else
        vim.g.mkdp_browser = nil
      end
      if vim.g.mkdp_browser ~= "" then
        vim.cmd [[
          function OpenMarkdownPreview (url)
            execute "silent ! " . g:mkdp_browser . " --new-window " . a:url
          endfunction
          let g:mkdp_browserfunc = 'OpenMarkdownPreview'
        ]]
      end
    end,
    ft = "markdown",
    cmd = { "MarkdownPreview", "MarkdownPreviewToggle" },
    keys = {
      { ",m", "<cmd>MarkdownPreviewToggle<cr>", "Toggle Markdown preview" },
    },
  },

  { "jghauser/follow-md-links.nvim" },

  { "neovim/nvim-lspconfig",
    init = function()
        vim.lsp.config("markdown_oxide", {
          capabilities = {
            workspace = {
              didChangeWatchedFiles = {
                dynamicRegistration = true
              }
            }
          }
        })
    end,
  },
}
