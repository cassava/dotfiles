return {
  { "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
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
}
