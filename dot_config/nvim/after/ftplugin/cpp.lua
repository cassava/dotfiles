local key = require("util").keymapper()

key.register({
  [","] = {
    f = { function() vim.lsp.buf.formatting() end, "Format file" },
    m = { "<cmd>Make all<cr>", "Build project" },
  }
}, { silent = false })

key.register({
  [","] = {
    f = { function() vim.lsp.buf.range_formatting() end, "Format range" },
  }
}, { silent = false, mode = "v" })
