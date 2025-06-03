vim.api.nvim_create_autocmd("FileType", {
  pattern = { "cpp", "c" },
  callback = function()
    -- Continue Doxygen C++ comments automatically
    -- vim.opt_local.comments = "sO:* -,mO:*  ,exO:*/,s1:/*,mb:*,ex:*/,bO:///,O://"
    vim.opt_local.commentstring = "// %s"
    vim.g.load_doxygen_syntax = 1
  end
})

return {
  lazy_treesitter_ensure_installed {
    "asm",
    "c",
    "cpp",
    "nasm",
    "objdump",
  },

  lazy_mason_ensure_installed {
    "clangd",
    "clang-format",
    "codelldb",
  },

  { "ludovicchabant/vim-gutentags",
    about = "Automatically manages the tags for your projects.",
    event = "VeryLazy",
    cond = vim.fn.executable("ctags") ~= 1,
    build = "mkdir -p ~/.local/state/tags",
    init = function()
      vim.g.gutentags_cache_dir = "~/.local/state/tags"
    end,
  },

  { "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cpp = { "clang-format" },
      }
    }
  },
}
