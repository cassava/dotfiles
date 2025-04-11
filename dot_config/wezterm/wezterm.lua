local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.adjust_window_size_when_changing_font_size = false
config.window_decorations = "RESIZE"
config.color_scheme = "nordfox"
config.font = wezterm.font { family = "FiraCode Nerd Font" }
config.font_rules = {
  {
    intensity = "Bold",
    italic = true,
    font = wezterm.font {
      family = "VictorMono Nerd Font",
      weight = "Bold",
      style = "Italic",
    },
  },
  {
    italic = true,
    intensity = "Half",
    font = wezterm.font {
      family = "VictorMono Nerd Font",
      weight = "DemiBold",
      style = "Italic",
    },
  },
  {
    italic = true,
    intensity = "Normal",
    font = wezterm.font {
      family = "VictorMono Nerd Font",
      style = "Italic",
    },
  },
}
config.pane_focus_follows_mouse = true
config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 2000 }
config.keys = {
    { mods = "LEADER|SHIFT", key = "\"",    action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" } },
    { mods = "LEADER|SHIFT", key = "%",     action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { mods = "LEADER",       key = "t",     action = wezterm.action.SpawnTab "CurrentPaneDomain" },
    { mods = "LEADER",       key = "o",     action = wezterm.action.ActivateTabRelative(1) },
    { mods = "ALT",          key = "Enter", action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { mods = "ALT|SHIFT",    key = "Enter", action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" } },
    { mods = "ALT",          key = "w",     action = wezterm.action.CloseCurrentPane { confirm = true } },
}

-- Event: maximize on first startup
wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():perform_action(wezterm.action.ToggleFullScreen, pane)
end)

-- Plugin tabline: provide configurable wezterm topbar in style of lualine.nvim
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
  options = {
    icons_enabled = true,
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
  sections = {
    tabline_a = { "workspace" },
    tabline_b = { "" },
    tabline_c = { " " },
    tab_active = { "index", { "process", padding = { left = 0, right = 1 } }, { "zoomed", padding = 0 } },
    tab_inactive = { "index", { "process", padding = { left = 0, right = 1 } } },
    tabline_x = {},
    tabline_y = {
        { "datetime", style = "%d.%m.%Y %H:%M:%S" }
    },
    tabline_z = { "domain" },
  },
  extensions = {},
})
tabline.apply_to_config(config)

-- Plugin smart-splits: Provide seamless ALT+HJKL movement between panes of wezterm and nvim
local splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
splits.apply_to_config(config, {
    modifiers = {
        move = "ALT",
        resize = "ALT|CTRL",
    }
})

return config
