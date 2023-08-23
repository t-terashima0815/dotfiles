local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.font = wezterm.font { family = 'JetBrains Mono', weight = 'Regular' }
config.font_size = 11

use_fancy_tab_bar = false
config.window_background_opacity = 0.8

config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = wezterm.action({ PasteFrom = "Clipboard" }),
  }
}

return config
