return {
  s("uuid", {
    f(function(args) return vim.fn.trim(vim.fn.system({"uuidgen"})) end, {}),
  }),
}
