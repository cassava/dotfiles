-- Usage: require("sessions.daily").launch()
--
-- Launch the daily set of notes for tracking and coordinating progress.
--

local M = {}

local obsidian = require("obsidian")

local opts = {
  dailies_dir = vim.fn.expand("~/notes/dailies"),
  today_note = vim.fn.expand(os.date("~/notes/dailies/%Y-%m-%d.md")),
  tasks_note = "~/notes/tasks.md",
  wip_note = "~/notes/wip.md",
}

local function get_index_of(haystack, needle)
  for i, f in ipairs(haystack) do
    if f == needle then
      return i
    end
  end
  return nil
end

local function get_previous_note()
  local files = vim.fn.globpath(opts.dailies_dir, "*.md", false, true)
  if not vim.fn.filereadable(opts.today_note) then
    -- Today's note hasn't been created yet, so pretend it has
    files:append(opts.today_note)
  end

  table.sort(files)
  local idx = get_index_of(files, opts.today_note)
  assert(idx, "today's note should be in the list of files above")

  if idx == 1 then
    -- No previous note exists, so return nil
    return nil
  end
  return files[idx - 1]
end

function M.launch()
  -- Create and open today's note first
  vim.cmd("Obsidian today")
  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = opts.today_note,
    once = true,
    callback = function()
      local prev_note = get_previous_note()
      if prev_note then
        vim.cmd("topleft vsplit " .. prev_note)
        vim.cmd("setfiletype markdown")
        vim.cmd("wincmd h | belowright split " .. opts.tasks_note)
        vim.cmd("setfiletype markdown")
      else
        vim.cmd("topleft vsplit " .. opts.tasks_note)
        vim.cmd("setfiletype markdown")
      end
      vim.cmd("wincmd l | belowright split " .. opts.wip_note)
      vim.cmd("setfiletype markdown")
    end,
  })
end

return M
