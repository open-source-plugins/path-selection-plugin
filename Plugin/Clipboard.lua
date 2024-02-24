type ClipboardData = {
	content: { string },
	last_time: number,
	place_id: number,
}

-- Constants
local CLIPBOARD_SETTINGS_KEY = "__PathSelectionClipboard"

-- Module
local Clipboard = {}
Clipboard.__index = Clipboard

function Clipboard.new(plugin: Plugin)
	local self = setmetatable({}, Clipboard)

	self._plugin = plugin

	return self
end

function Clipboard:Copy(content: { string })
	(self._plugin :: Plugin):SetSetting(CLIPBOARD_SETTINGS_KEY, {
		last_time = os.time(),
		content = content,
	})
end

function Clipboard:Read(): ClipboardData
	return (self._plugin :: Plugin):GetSetting(CLIPBOARD_SETTINGS_KEY)
end

function Clipboard:Clear()
	self:Copy({})
end

return Clipboard
