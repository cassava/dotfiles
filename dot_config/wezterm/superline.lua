local wezterm = require("wezterm")

local M = {}

M.opts = {}

M.tabline_opts = {}

M._format_tab = function(text, tab)
    local domain = tab.active_pane.domain_name
    if tab.tab_title == '_' then
        domain = "minimized"
    elseif tab.tab_title ~= '' then
        domain = domain .. "$"
    end

    if not M.opts.domain_colors[domain] then
        domain = "unknown" .. (tab.tab_title ~= '' and '$' or '')
    end

    --- @type string|table
    local color = M.opts.domain_colors[domain]
    if type(color) == "table" then
        color = color[tab.is_active and "active" or "inactive"]
    end

    return wezterm.format({
        { Foreground = { Color = color } },
        { Text = string.format("%s", text) },
    })
end


M._tab_title = function(tab)
    local txt = tab.tab_title
    if txt == '' then
        if tab.active_pane and tab.active_pane.foreground_process_name then
            txt = tab.active_pane.foreground_process_name
            txt = txt:match('([^/\\]+)[/\\]?$') or txt
        end
    end

    if txt == 'wezterm' or txt == '' then
      txt = tab.active_pane.domain_name ~= 'local' and tab.active_pane.domain_name or 'wezterm'
    end

    local glyph = M.opts.index_glyphs[tab.tab_index+1]
    if txt == '_' then
        txt = glyph
    else
        txt = string.format(" %s %-8s ", glyph, txt)
    end
    return M._format_tab(txt, tab)
end

M._register_toggle_event = function()
    wezterm.on("ToggleTabline", function(window, _)
        local overrides = window:get_config_overrides() or {}
        if not (overrides.hide_tab_bar_if_only_one_tab == false) then
            wezterm.log_info("override config: show tabline always")
            overrides.hide_tab_bar_if_only_one_tab = false
            overrides.enable_tab_bar = true
        elseif overrides.enable_tab_bar == false then
            wezterm.log_info("override config: show tabline with multiple tabs")
            overrides.enable_tab_bar = true
            overrides.hide_tab_bar_if_only_one_tab = true
        else
            wezterm.log_info("override config: hide tabline")
            overrides.enable_tab_bar = false
        end
        window:set_config_overrides(overrides)
    end)
end

local default_opts = {
    ---@type table
    domain_colors = {
        -- Prefer these colors for styling:
        --
        --  *background: #2e3440
        --  *foreground: #cdcecf
        --  *color0:  #3b4252
        --  *color1:  #bf616a
        --  *color2:  #a3be8c
        --  *color3:  #ebcb8b
        --  *color4:  #81a1c1
        --  *color5:  #b48ead
        --  *color6:  #88c0d0
        --  *color7:  #e5e9f0
        --  *color8:  #465780
        --  *color9:  #d06f79
        --  *color10: #b1d196
        --  *color11: #f0d399
        --  *color12: #8cafd2
        --  *color13: #c895bf
        --  *color14: #93ccdc
        --  *color15: #e7ecf4
        ["local"] = {
            inactive = "#cdcecf",
            active = "#81a1c1",
        },
        ["local$"] = {
            inactive = "#ebcb8b",
            active = "#f0d399",
        },
        ["unknown"] = "#d06f79",
        ["unknown$"] = "#bf616a",
        ["wezterm"] = "#c895bf",
        ["minimized"] = "#3b4252",
    },

    --- A table mapping from number to glyph shown for each tab.
    ---@type table|fun(number):string
    index_glyphs = {
        "\u{f03a4}", -- 1
        "\u{f03a7}", -- 2
        "\u{f03aa}", -- 3
        "\u{f03ad}", -- 4
        "\u{f03b1}", -- 5
        "\u{f03b3}", -- 6
        "\u{f03b6}", -- 7
        "\u{f03b9}", -- 8
        "\u{f03bc}", -- 9
        "\u{f037d}", -- 10
    },

    --- Rename a tab to this marker to cause it to be minimized.
    ---@type string
    minimize_marker = '_',

    --- Plugin tabline.
    ---@type table|nil
    tabline = nil,

    ---@type table
    tabline_options = {
        icons_enabled = false,
        theme = "Catppuccin Mocha",
        tabs_enabled = true,
        theme_overrides = {},
        section_separators = "",
        component_separators = "",
        tab_separators = {
            left = wezterm.nerdfonts.ple_lower_left_triangle,
            right = wezterm.nerdfonts.ple_lower_right_triangle,
        },
    },

    ---@type table
    tabline_sections = {
        tabline_a = {
            -- "workspace"
        },
        tabline_b = { "" },
        tabline_c = { " " },
        tab_active = {
            M._tab_title,
            { "zoomed", padding = 0 },
        },
        tab_inactive = {
            M._tab_title,
        },
        tabline_x = {
            { Background = { Color = '#24273a' } },
            require("cpu_graph").format_graph,
        },
        tabline_y = {
            { "datetime", style = "%d.%m.%Y %H:%M:%S" }
        },
        tabline_z = { "domain" },
    },

    ---@type table
    tabline_extensions = {},
}

M.setup = function(opts)
    -- TODO: Fix this
    M.opts = default_opts
    M.tabline_opts = {
        options = M.opts.tabline_options,
        sections = M.opts.tabline_sections,
        extensions = M.opts.tabline_extensions,
    }
    M.tabline = opts.tabline or wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
    M.tabline.setup(M.tabline_opts)
    require("cpu_graph").setup()
end

M.apply_to_config = function(config)
    config.enable_tab_bar = true
    config.hide_tab_bar_if_only_one_tab = true
    M.tabline.apply_to_config(config)
    M._register_toggle_event()
end

return M
