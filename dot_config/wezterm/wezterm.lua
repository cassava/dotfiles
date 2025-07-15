-- Wezterm configuration
-- See: https://wezterm.org/config/lua/config/index.html
--
local wezterm = require("wezterm")
local config = wezterm.config_builder()
local act = wezterm.action

local usercfg = {}

config.adjust_window_size_when_changing_font_size = false
config.tab_max_width = 24
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
config.term = "xterm-256color"

-- Use a domain by default to allow multiplexing
config.unix_domains = {
    { name = 'unix' },
}

-- Key bindings:
config.disable_default_key_bindings = true
config.leader = { key = "Space", mods = "SUPER", timeout_milliseconds = 2000 }
config.keys = {
    -- Font size:
    { key = '0',          mods = 'CTRL',           action = act.ResetFontSize },
    { key = '-',          mods = 'CTRL',           action = act.DecreaseFontSize },
    { key = '=',          mods = 'CTRL',           action = act.IncreaseFontSize },

    -- Domain management:
    { key = 'Pause',      mods = 'ALT',            action = act.DetachDomain 'CurrentPaneDomain' },
    { key = 'Pause',      mods = 'SHIFT|ALT',      action = act.AttachDomain 'localhost' },

    -- Tab navigation & management:
    { key = '=',          mods = 'ALT',            action = act.SpawnTab 'CurrentPaneDomain' },
    { key = '1',          mods = 'ALT',            action = act.ActivateTab(0) },
    { key = '2',          mods = 'ALT',            action = act.ActivateTab(1) },
    { key = '3',          mods = 'ALT',            action = act.ActivateTab(2) },
    { key = '4',          mods = 'ALT',            action = act.ActivateTab(3) },
    { key = '5',          mods = 'ALT',            action = act.ActivateTab(4) },
    { key = '6',          mods = 'ALT',            action = act.ActivateTab(5) },
    { key = '7',          mods = 'ALT',            action = act.ActivateTab(6) },
    { key = '8',          mods = 'ALT',            action = act.ActivateTab(7) },
    { key = '9',          mods = 'ALT',            action = act.ActivateTab(-1) },
    { key = 'Tab',        mods = 'ALT',            action = act.ActivateTabRelative(1) },
    { key = 'Tab',        mods = 'SHIFT|ALT',      action = act.ActivateTabRelative(-1) },
    { key = '[',          mods = 'ALT',            action = act.ActivateTabRelative(-1) },
    { key = ']',          mods = 'ALT',            action = act.ActivateTabRelative(1) },
    { key = '[',          mods = 'SHIFT|ALT',      action = act.MoveTabRelative(-1) },
    { key = ']',          mods = 'SHIFT|ALT',      action = act.MoveTabRelative(1) },
    {
        key = "'",
        mods = 'ALT',
        action = act.PromptInputLine {
            description = 'Enter new name for tab',
            action = wezterm.action_callback(function(window, pane, line)
                if line then
                    window:active_tab():set_title(line)
                end
            end),
        },
    },

    -- Pane navigation:
    -- Movement is provided by smart-splits.nvim plugin
    { key = ";",          mods = "ALT",            action = act.PaneSelect },
    { key = ":",          mods = "ALT|SHIFT",      action = act.PaneSelect { mode = "SwapWithActive" } },
    { key = "j",          mods = "CTRL|ALT",       action = act.PaneSelect { mode = "MoveToNewWindow" } },
    { key = "k",          mods = "CTRL|ALT",       action = act.PaneSelect { mode = "MoveToNewTab" } },
    { key = "h",          mods = "CTRL|ALT",       action = act.RotatePanes 'CounterClockwise' },
    { key = "l",          mods = "CTRL|ALT",       action = act.RotatePanes 'Clockwise' },

    -- Pane management:
    { key = "|",          mods = "ALT|SHIFT",      action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = "_",          mods = "ALT|SHIFT",      action = act.SplitVertical { domain = "CurrentPaneDomain" } },
    { key = '\\',         mods = 'ALT',            action = act.TogglePaneZoomState },
    { key = '?',          mods = 'ALT',            action = act.EmitEvent 'ToggleTabline' },
    { key = 'w',          mods = 'ALT|SHIFT',      action = act.CloseCurrentPane { confirm = true } },
    { key = 'Backspace',  mods = 'ALT',            action = act.CloseCurrentPane { confirm = true } },
    { key = 'DownArrow',  mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize { 'Down', 1 } },
    { key = 'LeftArrow',  mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize { 'Left', 1 } },
    { key = 'RightArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize { 'Right', 1 } },
    { key = 'UpArrow',    mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize { 'Up', 1 } },

    -- Clipboard:
    { key = 'c',          mods = 'SUPER',          action = act.CopyTo 'Clipboard' },
    { key = 'v',          mods = 'SUPER',          action = act.PasteFrom 'Clipboard' },
    { key = 'Insert',     mods = 'SHIFT',          action = act.PasteFrom 'PrimarySelection' },
    { key = 'Insert',     mods = 'CTRL',           action = act.CopyTo 'PrimarySelection' },
    { key = 'Insert',     mods = 'ALT',            action = act.ActivateCopyMode },
    { key = 'phys:Space', mods = 'ALT|SHIFT',            action = act.ActivateCopyMode },
    { key = 'phys:Space', mods = 'ALT',            action = act.QuickSelect },

    -- Scrollback:
    { key = 'Escape',     mods = 'ALT',            action = act.ClearSelection },
    { key = '/',          mods = 'ALT',            action = act.Search 'CurrentSelectionOrEmptyString' },
    { key = 'Delete',     mods = 'ALT',            action = act.Multiple { act.ClearScrollback 'ScrollbackAndViewport', act.SendKey { key = 'L', mods = 'CTRL' } } },
    { key = 'Home',       mods = 'ALT',            action = act.ScrollToTop },
    { key = 'End',        mods = 'ALT',            action = act.ScrollToBottom },
    { key = 'PageUp',     mods = 'ALT',            action = act.ScrollByPage(-1) },
    { key = 'PageDown',   mods = 'ALT',            action = act.ScrollByPage(1) },

    -- Other:
    { key = '`',          mods = 'ALT',            action = act.ActivateCommandPalette },
    { key = '~',          mods = 'ALT|SHIFT',      action = act.ShowDebugOverlay },
}
config.key_tables = {
    copy_mode = {
        { key = 'Tab',        mods = 'NONE',  action = act.CopyMode 'MoveForwardWord' },
        { key = 'Tab',        mods = 'SHIFT', action = act.CopyMode 'MoveBackwardWord' },
        { key = 'Enter',      mods = 'NONE',  action = act.CopyMode 'MoveToStartOfNextLine' },
        { key = 'Escape',     mods = 'NONE',  action = act.CopyMode 'Close' },
        { key = 'Space',      mods = 'NONE',  action = act.CopyMode { SetSelectionMode = 'Cell' } },
        { key = '$',          mods = 'SHIFT', action = act.CopyMode 'MoveToEndOfLineContent' },
        { key = ',',          mods = 'NONE',  action = act.CopyMode 'JumpReverse' },
        { key = '0',          mods = 'NONE',  action = act.CopyMode 'MoveToStartOfLine' },
        { key = ';',          mods = 'NONE',  action = act.CopyMode 'JumpAgain' },
        { key = 'F',          mods = 'SHIFT', action = act.CopyMode { JumpBackward = { prev_char = false } } },
        { key = 'G',          mods = 'SHIFT', action = act.CopyMode 'MoveToScrollbackBottom' },
        { key = 'H',          mods = 'SHIFT', action = act.CopyMode 'MoveToViewportTop' },
        { key = 'L',          mods = 'SHIFT', action = act.CopyMode 'MoveToViewportBottom' },
        { key = 'M',          mods = 'SHIFT', action = act.CopyMode 'MoveToViewportMiddle' },
        { key = 'O',          mods = 'SHIFT', action = act.CopyMode 'MoveToSelectionOtherEndHoriz' },
        { key = 'T',          mods = 'SHIFT', action = act.CopyMode { JumpBackward = { prev_char = true } } },
        { key = 'V',          mods = 'SHIFT', action = act.CopyMode { SetSelectionMode = 'Line' } },
        { key = '^',          mods = 'SHIFT', action = act.CopyMode 'MoveToStartOfLineContent' },
        { key = 'b',          mods = 'NONE',  action = act.CopyMode 'MoveBackwardWord' },
        { key = 'b',          mods = 'CTRL',  action = act.CopyMode 'PageUp' },
        { key = 'c',          mods = 'CTRL',  action = act.CopyMode 'Close' },
        { key = 'd',          mods = 'CTRL',  action = act.CopyMode { MoveByPage = (0.5) } },
        { key = 'e',          mods = 'NONE',  action = act.CopyMode 'MoveForwardWordEnd' },
        { key = 'f',          mods = 'NONE',  action = act.CopyMode { JumpForward = { prev_char = false } } },
        { key = 'f',          mods = 'CTRL',  action = act.CopyMode 'PageDown' },
        { key = 'g',          mods = 'NONE',  action = act.CopyMode 'MoveToScrollbackTop' },
        { key = 'h',          mods = 'NONE',  action = act.CopyMode 'MoveLeft' },
        { key = 'j',          mods = 'NONE',  action = act.CopyMode 'MoveDown' },
        { key = 'k',          mods = 'NONE',  action = act.CopyMode 'MoveUp' },
        { key = 'l',          mods = 'NONE',  action = act.CopyMode 'MoveRight' },
        { key = 'o',          mods = 'NONE',  action = act.CopyMode 'MoveToSelectionOtherEnd' },
        { key = 'q',          mods = 'NONE',  action = act.CopyMode 'Close' },
        { key = 't',          mods = 'NONE',  action = act.CopyMode { JumpForward = { prev_char = true } } },
        { key = 'u',          mods = 'CTRL',  action = act.CopyMode { MoveByPage = (-0.5) } },
        { key = 'v',          mods = 'NONE',  action = act.CopyMode { SetSelectionMode = 'Cell' } },
        { key = 'v',          mods = 'CTRL',  action = act.CopyMode { SetSelectionMode = 'Block' } },
        { key = 'w',          mods = 'NONE',  action = act.CopyMode 'MoveForwardWord' },
        { key = 'y',          mods = 'NONE',  action = act.Multiple { { CopyTo = 'ClipboardAndPrimarySelection' }, { CopyMode = 'Close' } } },
        { key = 'PageUp',     mods = 'NONE',  action = act.CopyMode 'PageUp' },
        { key = 'PageDown',   mods = 'NONE',  action = act.CopyMode 'PageDown' },
        { key = 'End',        mods = 'NONE',  action = act.CopyMode 'MoveToEndOfLineContent' },
        { key = 'Home',       mods = 'NONE',  action = act.CopyMode 'MoveToStartOfLine' },
        { key = 'LeftArrow',  mods = 'NONE',  action = act.CopyMode 'MoveLeft' },
        { key = 'LeftArrow',  mods = 'ALT',   action = act.CopyMode 'MoveBackwardWord' },
        { key = 'RightArrow', mods = 'NONE',  action = act.CopyMode 'MoveRight' },
        { key = 'RightArrow', mods = 'ALT',   action = act.CopyMode 'MoveForwardWord' },
        { key = 'UpArrow',    mods = 'NONE',  action = act.CopyMode 'MoveUp' },
        { key = 'DownArrow',  mods = 'NONE',  action = act.CopyMode 'MoveDown' },
    },
    search_mode = {
        { key = 'Enter',     mods = 'NONE', action = act.CopyMode 'PriorMatch' },
        { key = 'Escape',    mods = 'NONE', action = act.CopyMode 'Close' },
        { key = 'n',         mods = 'CTRL', action = act.CopyMode 'NextMatch' },
        { key = 'p',         mods = 'CTRL', action = act.CopyMode 'PriorMatch' },
        { key = 'r',         mods = 'CTRL', action = act.CopyMode 'CycleMatchType' },
        { key = 'u',         mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
        { key = 'PageUp',    mods = 'NONE', action = act.CopyMode 'PriorMatchPage' },
        { key = 'PageDown',  mods = 'NONE', action = act.CopyMode 'NextMatchPage' },
        { key = 'UpArrow',   mods = 'NONE', action = act.CopyMode 'PriorMatch' },
        { key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'NextMatch' },
    }
}

-- Event: maximize on first startup
wezterm.on("gui-startup", function(cmd)
    local _, pane, window = wezterm.mux.spawn_window(cmd or {})
    window:gui_window():maximize()
end)
wezterm.on('update-status', function(window, pane)
  local meta = pane:get_metadata() or {}
  if meta.is_tardy then
    local secs = meta.since_last_response_ms / 1000.0
    window:set_right_status(string.format('tardy: %5.1fs⏳', secs))
  end
end)

-- Plugin tabline: provide configurable wezterm topbar in style of lualine.nvim
local superline = require("superline")
usercfg.superline_opts = {
    tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
}

-- Plugin smart-splits: Provide seamless ALT+HJKL movement between panes of wezterm and nvim
local splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")
usercfg.splits_opts = {
    modifiers = {
        move = "ALT",
        resize = "ALT|CTRL|SHIFT",
    }
}

-- Load host-specific lua files, if available:
local plugins = {
    "host." .. wezterm.hostname(),
    "user." .. (os.getenv("USER") or os.getenv("USERNAME")),
}
for _, p in ipairs(plugins) do
    local ok, plugin = pcall(require, p)
    if ok then
        plugin.apply_to_config(config, usercfg)
    end
end

-- Apply plugin configuration:
superline.setup(usercfg.superline_opts)
superline.apply_to_config(config)
splits.apply_to_config(config, usercfg.splits_opts)

return config
