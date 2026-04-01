-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()
config.keys = {}
-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

-- or, changing the font size and color scheme.
config.font_size = 12
config.color_scheme = "Catppuccin Mocha"
config.font = wezterm.font("FiraCode Nerd Font Mono")

config.allow_win32_input_mode = false
if string.find(wezterm.target_triple, "windows") then
	config.default_prog = { "pwsh" }
	config.default_domain = "WSL:Ubuntu"

	table.insert(config.keys, {
		key = "<",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SpawnCommandInNewTab({
			domain = { DomainName = "WSL:Ubuntu" },
		}),
	})

	table.insert(config.keys, {
		key = ">",
		mods = "CTRL|SHIFT",
		action = wezterm.action.SpawnCommandInNewTab({
			args = { "pwsh" },
			domain = { DomainName = "local" },
		}),
	})
else
	config.default_prog = { "fish" }
end

for i = 1, 8 do
	-- CTRL+ALT + number to move to that position
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CTRL|ALT",
		action = wezterm.action.MoveTab(i - 1),
	})
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local pane = tab.active_pane
	local domain = pane.domain_name

	local bg, fg
	if string.find(domain, "WSL") then
		bg = "#89b4fa" -- Catppuccin blue (WSL)
		fg = "#1e1e2e"
	else
		bg = "#a6e3a1" -- Catppuccin green (Windows)
		fg = "#1e1e2e"
	end

	local title = tab.active_pane.title

	return {
		{ Background = { Color = bg } },
		{ Foreground = { Color = fg } },
		{ Text = " " .. title .. " " },
	}
end)

wezterm.on("mux-is-process-stateful", function(proc)
	return false
end)

config.window_close_confirmation = "NeverPrompt"
config.enable_wayland = true

-- Finally, return the configuration to wezterm:
return config
