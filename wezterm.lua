-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- config.font = wezterm.font("Input Mono Condensed")
config.font = wezterm.font("Iosevka Term")
config.font_size = 18.0

config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- config.color_scheme = 'Black Metal (Mayhem) (base16)'
-- take the built-in Black Metal (Bathory) scheme and adjust it
bm = wezterm.color.get_builtin_schemes()['Black Metal (Bathory) (base16)']
bm.brights[1] = '#666666' -- make zsh suggestions a bit brighter
config.color_schemes = {
	['bathory-adjust'] = bm,
}
config.color_scheme = 'bathory-adjust'

config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE|MACOS_FORCE_DISABLE_SHADOW"
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

-- config.debug_key_events = true

config.keys = {
	-- {
	-- 	key = 'w',
	-- 	mods = 'CMD',
	-- 	action = act.CloseCurrentPane { confirm = true },
	-- },
	-- {
	-- 	key = 't',
	-- 	mods = 'CTRL|SHIFT',
	-- 	action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
	-- },
	-- {
	-- 	key = 'h',
	-- 	mods = 'CTRL|SHIFT',
	-- 	action = act.ActivatePaneDirection 'Left',
	-- },
	-- {
	-- 	key = 'l',
	-- 	mods = 'CTRL|SHIFT',
	-- 	action = act.ActivatePaneDirection 'Right',
	-- },
	-- {
	-- 	key = 'j',
	-- 	mods = 'CTRL|SHIFT',
	-- 	action = act.ActivatePaneDirection 'Down',
	-- },
	-- {
	-- 	key = 'k',
	-- 	mods = 'CTRL|SHIFT',
	-- 	action = act.ActivatePaneDirection 'Up',
	-- },
	{
		key = 'E',
		mods = 'CTRL|SHIFT',
		action = act.PromptInputLine {
			description = 'Enter new name for tab',
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:active_tab():set_title(line)
				end
			end),
		},
	},
	-- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
	{ key = 'LeftArrow',  mods = 'OPT',        action = act.SendString '\x1bb' },
	-- Make Option-Right equivalent to Alt-f; forward-word
	{ key = 'RightArrow', mods = 'OPT',        action = act.SendString '\x1bf' },
	-- CTRL-SHIFT-d activates the debug overlay
	{ key = 'D',          mods = 'CTRL|SHIFT', action = wezterm.action.ShowDebugOverlay },
}

-- Swap Cmd <-> Option on macOS
if wezterm.target_triple:match("darwin$") then
	for i = 0, 127 do
		local key = string.char(i)

		for _, mods in ipairs({ "", "|CTRL", "|SHIFT" }) do
			if mods == "" and (key == "c" or key == "v") then
				goto continue
			end
			for from, to in pairs({ CMD = "OPT", OPT = "CMD" }) do
				table.insert(config.keys, {
					key = key,
					mods = from .. mods,
					action = act.SendKey({
						key = key,
						mods = to .. mods,
					}),
				})
			end
			::continue::
		end
	end
end

config.mouse_bindings = {
	{
		event = { Up = { streak = 1, button = 'Left' } },
		mods = 'CTRL',
		action = act.OpenLinkAtMouseCursor,
	},
}

config.window_frame = {
	-- The font used in the tab bar.
	-- Roboto Bold is the default; this font is bundled
	-- with wezterm.
	-- Whatever font is selected here, it will have the
	-- main font setting appended to it to pick up any
	-- fallback fonts you may have used there.
	font = wezterm.font { family = 'Roboto', weight = 'Bold' },

	-- The size of the font in the tab bar.
	-- Default to 10.0 on Windows but 12.0 on other systems
	font_size = 14.0,

	-- The overall background color of the tab bar when
	-- the window is focused
	-- active_titlebar_bg = '#333333',

	-- The overall background color of the tab bar when
	-- the window is not focused
	-- inactive_titlebar_bg = '#333333',
}

-- config.colors = {
--   tab_bar = {
--     -- The color of the inactive tab bar edge/divider
--     inactive_tab_edge = '#575757',
--   },
-- }

-- and finally, return the configuration to wezterm
return config
