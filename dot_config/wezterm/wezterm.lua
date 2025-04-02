local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Settings:
config.adjust_window_size_when_changing_font_size = false
config.window_decorations = "RESIZE"
config.color_scheme = "nordfox"
config.font = wezterm.font_with_fallback{
    "FiraCode Nerd Font",
    "Fira Code",
    -- built-in:
    "JetBrains Mono",
    "Noto Color Emoji",
    "Symbols Nerd Font Mono",
}

-- Plugins:
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
  options = {
    icons_enabled = true,
    theme = 'Catppuccin Mocha',
    tabs_enabled = true,
    theme_overrides = {},
    section_separators = '',
    component_separators = '',
    tab_separators = {
      left = wezterm.nerdfonts.ple_lower_left_triangle,
      right = wezterm.nerdfonts.ple_lower_right_triangle,
    },
  },
  sections = {
    tabline_a = { 'workspace' },
    tabline_b = { '' },
    tabline_c = { ' ' },
    tab_active = {
      'index',
      { 'parent', padding = 0 },
      '/',
      { 'cwd', padding = { left = 0, right = 1 } },
      { 'zoomed', padding = 0 },
    },
    tab_inactive = { 'index', { 'process', padding = { left = 0, right = 1 } } },
    tabline_x = {},
    tabline_y = {
        { "datetime", style = "%d.%m.%Y %H:%M:%S" }
    },
    tabline_z = { "domain" },
  },
  extensions = {},
})
tabline.apply_to_config(config)

return config
