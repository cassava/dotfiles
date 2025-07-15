local wezterm = require("wezterm")

local M = {}

-- Visuals
M.opts = {
    bars = {
        wide = { "_", "⣀", "⣤", "⣶", "⣿" },
        compact = {
            { "_", "⢀", "⢠", "⢰", "⢸" },
            { "⡀", "⣀", "⣠", "⣰", "⣸" },
            { "⡄", "⣄", "⣤", "⣴", "⣼" },
            { "⡆", "⣆", "⣦", "⣶", "⣾" },
            { "⡇", "⣇", "⣧", "⣷", "⣿" },
        },
    },
    colors = {
        "#cdd6f4",
        "#a6e3a1",
        "#f9e2af",
        "#fab387",
        "#eba0ac",
        "#f38ba8",
    },
    offset = 15,
    prefix = " \u{f4bc} ",
    suffix = " ",
    polling_interval = 0.5,
    style = {
        bars = "compact",
        color = true
    }
}

local bar_factor
local bar_offset
local color_factor
local color_offset

local function precompute_offsets()
    bar_factor = (#M.opts.bars[M.opts.style.bars] - 1) / 100
    bar_offset = (M.opts.offset * bar_factor)
    color_factor = (#M.opts.colors - 1) / 100
    color_offset = (M.opts.offset * color_factor)
end

---@param usage number Number between 0 and 100
function M.format_wide_bar(usage)
    local bar = M.opts.bars.wide[math.floor(usage * bar_factor + bar_offset) + 1]
    if M.opts.style.color then
        local color = M.opts.colors[math.floor(usage * color_factor + color_offset) + 1]
        return wezterm.format({
            { Foreground = { Color = color } },
            { Text = bar },
        })
    else
        return wezterm.format({
            { Text = bar },
        })
    end
end

---@param core1 number Number between 0 and 100
---@param core2 number Number between 0 and 100
function M.format_compact_bar(core1, core2)
    local bar = M.opts.bars.compact
        [math.floor(core1 * bar_factor + bar_offset) + 1]
        [math.floor(core2 * bar_factor + bar_offset) + 1]
    if M.opts.style.color then
        local color = M.opts.colors[math.floor((core1 + core2)/2.0 * color_factor + color_offset) + 1]
        return wezterm.format({
            { Foreground = { Color = color } },
            { Text = bar },
        })
    else
        return wezterm.format({
            { Text = bar },
        })
    end
end

-- Data storage
---@type table|nil
local last_cpu_times = {}

-- Store most recent results
local latest_core_usages = {}

-- Reads /proc/stat and returns table of per-core CPU usage %
local function read_cpu_snapshot()
    local f = io.open("/proc/stat", "r")
    if not f then
        return nil
    end

    local usage_per_core = {}

    for line in f:lines() do
        local cpu_id, user, nice, system, idle, iowait, irq, softirq, steal =
            line:match("^(cpu%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")

        if cpu_id then
            local total = 0
            for _, v in ipairs({ user, nice, system, idle, iowait, irq, softirq, steal }) do
                total = total + tonumber(v)
            end
            local idle_all = tonumber(idle) + tonumber(iowait)
            usage_per_core[cpu_id] = { total = total, idle = idle_all }
        end
    end

    f:close()
    return usage_per_core
end

-- Compare two snapshots and return % usage for each core
local function compute_utilization(current, previous)
    local results = {}
    for cpu_id, curr in pairs(current) do
        local prev = previous[cpu_id]
        if prev then
            local delta_total = curr.total - prev.total
            local delta_idle = curr.idle - prev.idle
            local usage = 100 * (delta_total - delta_idle) / delta_total
            table.insert(results, usage)
        end
    end
    return results
end

-- Periodic sampler
local function poll_cpus()
    local snapshot = read_cpu_snapshot()
    if snapshot and next(last_cpu_times) then
        latest_core_usages = compute_utilization(snapshot, last_cpu_times)
    end
    last_cpu_times = snapshot
    wezterm.time.call_after(M.opts.polling_interval, poll_cpus)
end

function M.setup()
    precompute_offsets()
    wezterm.time.call_after(0, poll_cpus)
end

function M.format_graph()
    local parts = {}

    table.insert(parts, M.opts.prefix)
    if M.opts.style.bars == "wide" then
        for _, usage in ipairs(latest_core_usages) do
            table.insert(parts, M.format_wide_bar(usage))
        end
    else
        local left = nil
        for _, usage in ipairs(latest_core_usages) do
            if left then
                table.insert(parts, M.format_compact_bar(left, usage))
                left = nil
            else
                left = usage
            end
        end
    end
    table.insert(parts, M.opts.suffix)

    return table.concat(parts)
end

return M
