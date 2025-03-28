local key = require("util").keymapper()
key.register({
  [","] = {
    a = { ":Cargo add ", "Add dependency" },
    e = { "<cmd>RustOpenCargo<cr>", "Edit Cargo.toml" },
    f = { "<cmd>RustFmt<cr>", "Format file" },
    m = { "<cmd>Cargo build<cr>", "Build project (debug)" },
    M = { "<cmd>Cargo build --release<cr>", "Build project (release)" },
    r = { ":Cargo run ", "Build project (debug)" },
    t = { "<cmd>RustTest<cr>", "Run test under cursor" },
    T = { "<cmd>RustTest!<cr>", "Run all tests" },
  }
}, { silent = false })

vim.g.makeprg = "cargo build"
