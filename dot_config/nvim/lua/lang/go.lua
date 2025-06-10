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

vim.treesitter.query.add_directive("inject-go-tmpl!", function(_, _, source, _, metadata)
  local fname
  if type(source) == "number" then
    fname = vim.api.nvim_buf_get_name(source)
  else
    fname = source
  end
  fname = vim.fn.fnamemodify(fname, ":t:r")
  local ft = vim.filetype.match({ filename = fname })
  if not ft then
    return
  end
  metadata["injection.language"] = ft
end, {})

-- Make sure vim recognizes .tmpl files as gotmpl ft
vim.filetype.add({
  extension = {
    tmpl = "gotmpl",
  },
})

-- Moved query inline
vim.treesitter.query.set(
  "gotmpl",
  "injections",
  [[
    ((text) @injection.content
      (#inject-go-tmpl!)
      (#set! injection.combined))
  ]]
)

return {
  lazy_treesitter_ensure_installed {
    "go",
    "gomod",
    "gosum",
    "gotmpl",
    "gowork",
  },

  -- NOTE: Disabled because:
  --   vim-go now sets the filetype for .tmpl files to gohtmltmpl even if it's already been set.
  --   See relevant Github PR: https://github.com/fatih/vim-go/pull/3146
  --  
  -- { "fatih/vim-go",
  --   ft = "go",
  --   init = function()
  --     vim.g.go_highlight_trailing_whitespace_error = 0
  --     vim.g.go_auto_type_info = 1
  --     vim.g.go_fmt_command = "goimports"
  --     vim.g.go_fmt_experimental = 1
  --   end
  -- },

  -- { "eggplannt/gotmpl.nvim",
  --   opts = {}
  -- },
}
