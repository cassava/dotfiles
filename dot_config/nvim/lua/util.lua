local util = {}

-- Automatically install Lazy if it has not been installed yet.
function util.bootstrap()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
      vim.fn.system({ "git", "-C", lazypath, "checkout", "tags/stable" })
    end
    vim.opt.rtp:prepend(lazypath)
end

-- Return a keymapper, preferably which-key.
function util.keymapper()
    local ok, key = pcall(require, "which-key")
    if ok then
        return key
    else
        print("Warning: cannot load which-key, user-mappings disabled.")
        return {
            execute = function() end,
            load = function() end,
            add = function(_, _) end,
            reset = function() end,
            setup = function() end,
            show = function() end,
            show_command = function() end,
        }
    end
end

-- @brief Return the current project directory, which is the toplevel of a Git
-- project if we are in a git project, or the CWD if not in a git project.
-- @param cwd Optional directory to start from.
function util.project_dir(cwd)
  local stdout, ret, _ = require("telescope.utils").get_os_command_output({"git", "rev-parse", "--show-toplevel"}, cwd)
  if ret == 0 then
    print(stdout[1])
    return stdout[1]
  else
    print(vim.fn.getcwd())
    return vim.fn.getcwd()
  end
end

function util.get_visual_selection()
  local mode = vim.fn.mode()
  if mode ~= "v" or mode ~= "V" or mode ~= "CTRL-V" then
    return nil
  end
  vim.cmd [[visual]]
  local _, start_row, start_col, _ = unpack(vim.fn.getpos "'<")
  local _, end_row, end_col, _ = unpack(vim.fn.getpos "'>")
  if start_row > end_row or (start_row == end_row and start_col > end_col) then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end
  local lines = vim.fn.getline(start_row, end_row)
  local n = 0
  for _ in pairs(lines) do
    n = n + 1
  end
  if n <= 0 then
    return nil
  end
  lines[n] = string.sub(lines[n], 1, end_col)
  lines[1] = string.sub(lines[1], start_col)
  return table.concat(lines, "\n")
end

function util.make()
  local lines = {""}
  local winnr = vim.fn.win_getid()
  local bufnr = vim.api.nvim_win_get_buf(winnr)

  local makeprg = vim.bo[bufnr].makeprg or vim.o.makeprg
  if not makeprg then
    return
  end

  local cmd = vim.fn.expandcmd(makeprg)
  vim.notify("Running: " .. cmd)
  local function on_event(job_id, data, event)
    if event == "stdout" or event == "stderr" then
      if data then
        vim.list_extend(lines, data)
      end
    end

    if event == "exit" then
      vim.fn.setqflist({}, "r", {
        title = cmd,
        lines = lines,
        -- efm = vim.bo[bufnr].errorformat or vim.o.errorformat
      })
      vim.api.nvim_command("doautocmd QuickFixCmdPost")
    end
  end

  local job_id = vim.fn.jobstart(cmd, {
    on_stderr = on_event,
    on_stdout = on_event,
    on_exit = on_event,
    stdout_buffered = true,
    stderr_buffered = true,
  })
end

return util
