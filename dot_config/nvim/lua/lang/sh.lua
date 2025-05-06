return {
  { "whoissethdaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "bash-language-server",
        "shfmt",
        "shellcheck",
      })
    end,
  },
}
