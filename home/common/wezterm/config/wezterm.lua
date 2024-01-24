local wezterm = require 'wezterm'
local config = {}


config.color_scheme = "PLACEHOLDER_THEME" -- this is substituted by home-manager
config.font = wezterm.font "JetBrains Mono"

local res = io.popen("uname -a")
local font_size = 1.0
local operating_system = 'Linux'
if res ~= nil then
	operating_system = res:read('a')
end
if string.find(operating_system, 'Darwin') then
	font_size = 12.0
else
	font_size = 16.0
end
config.font_size = font_size

-- proper color inside tmux
config.set_environment_variables = {
	TERM = "tmux-256color"
}


config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

config.window_background_opacity = 0.9

-- prefer tmux for handling this
config.enable_tab_bar = false

return config
