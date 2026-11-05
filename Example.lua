-- Example usage for OrcaHub UI
-- Remove a visible copy before loading. CreateWindow also shuts down the prior
-- OrcaHub instance, including its input listeners, when this example is rerun.
local uiParent
if type(gethui) == "function" then
	local ok, result = pcall(gethui)
	if ok then uiParent = result end
end
uiParent = uiParent or game:GetService("CoreGui")
for _, child in ipairs(uiParent:GetChildren()) do
	if child.Name == "OrcaHubUI" then child:Destroy() end
end

local OrcaHub = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/donhubroblox/orcahubui_chatgpt/main/OrcaHub.lua"
))()

-- Optional Lucide icons can be enabled with OrcaHub:LoadIcons({ ["house"] = "rbxassetid://..." })

local Window = OrcaHub:CreateWindow({
	Title = "OrcaHub",
	Footer = "UI Library  •  v2.0",
	Theme = {
		Accent = Color3.fromRGB(163, 121, 255),
	},
})
Window:Notify({ Title = "OrcaHub ready", Content = "The new window replaced any previous instance.", Duration = 4 })

local Main = Window:Tab({
	Name = "Main",
	Description = "Main Features",
})

local Player = Main:Section({ Name = "Player", Side = "Left" })
Player:Label({ Name = "Player controls", Height = 26 })
Player:Toggle({
	Name = "Enable feature",
	Flag = "EnableFeature",
	Default = true,
	Callback = function(enabled)
		print("Feature enabled:", enabled)
	end,
})
Player:Slider({
	Name = "Walk speed",
	Flag = "WalkSpeed",
	Min = 8,
	Max = 32,
	Default = 16,
	Callback = function(value)
		print("Walk speed:", value)
	end,
})
Player:Dropdown({
	Name = "Mode",
	Flag = "Mode",
	Options = { "Balanced", "Fast", "Quiet" },
	Default = "Balanced",
	Callback = function(value)
		print("Selected mode:", value)
	end,
})

local Utilities = Main:Section({ Name = "Utilities", Side = "Right" })
Utilities:Input({
	Name = "Player name",
	Placeholder = "Type a name",
	Callback = function(value)
		print("Input:", value)
	end,
})
Utilities:Keybind({
	Name = "Action key",
	Default = Enum.KeyCode.H,
	Callback = function(key)
		print("Pressed:", key.Name)
	end,
})
Utilities:Button({ Name = "Show notification", Callback = function()
	Window:Notify({ Title = "Action complete", Content = "Notifications slide in and dismiss automatically." })
end })

local About = Window:Tab({ Name = "About", Description = "A few useful details" })
local Details = About:Section({ Name = "Window", Side = "Left" })
Details:Paragraph({ Name = "Search", Content = "Search filters control names on the current tab." })
Details:Paragraph({ Name = "Navigation", Content = "Click a section heading to collapse it. Drag the top bar to move the window." })
Details:Button({ Name = "Destroy window", Callback = function() Window:Destroy() end })
