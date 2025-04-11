return {
  { "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "awk",
          "bash",
          "devicetree",
          "diff",
          "ebnf",
          "fish",
          "ini",
          "make",
          "markdown",
          "ninja",
          "perl",
          "regex",
          "rst",
          "toml",
        })
      end
    end
  },
}
