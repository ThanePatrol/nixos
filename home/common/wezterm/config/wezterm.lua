local wezterm = require 'wezterm'
local config = {}


config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font "JetBrains Mono"

config.font_size = 16.0

-- proper color inside tmux
config.set_environment_variables = {
	TERM = "tmux-256color"
}

config.window_background_opacity = 0.7

-- i prefer tmux for handling this
config.enable_tab_bar = false

return config
