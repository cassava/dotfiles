-- Set cursorline in insert mode and unset it when leaving.
vim.api.nvim_create_autocmd({ "InsertLeave" }, {
    callback = function() vim.wo.cursorline = false end,
})
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    callback = function() vim.wo.cursorline = true end,
})

-- Load exrc files from parent directories
--
-- Make sure that each of these scripts ensures that it is resistant to
-- being run multiple times.
vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  pattern = "*",
  callback = function()
    local dir = vim.v.event.cwd or vim.fn.getcwd()
    for _, f in ipairs(vim.fs.find(
      { ".nvim.lua" },
      { upward = true, path = dir, limit = math.huge }
    )) do
      local src = vim.secure.read(f)
      if src ~= nil then
        dofile(f)
      end
    end
  end
})

-- Set redact options when editing passwords
vim.api.nvim_create_autocmd({ "BufReadPre" }, {
    pattern = {
        "/dev/shm/pass.?*/?*.txt",
        "/tmp/pass.?*/?*.txt",
        (vim.env.TMPDIR or "") .. "/pass.?*/?*.txt",
    },
    callback = function()
        vim.opt.backup = false
        vim.opt.writebackup = false
        vim.opt.swapfile = false
        vim.opt.viminfo = ""
        vim.opt.undofile = false

        vim.notify("Password redaction options set.")
        vim.g.password_redaction = 1
    end
})

-- Open help window in a vertical split to the right.
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = vim.api.nvim_create_augroup("help_window_right", {}),
    pattern = { "*.txt" },
    callback = function()
        if vim.o.filetype == 'help' then
          vim.cmd.wincmd("L")
          vim.api.nvim_win_set_width(0, 80)
        end
    end
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = { "Dockerfile.*" },
    callback = function() vim.bo.filetype = "dockerfile" end,
})

vim.api.nvim_create_autocmd({ "TermOpen" }, {
    pattern = { "*" },
    callback = function() vim.wo.number = false end,
})
