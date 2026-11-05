-- Example usage for OrcaHub UI
-- Replace this URL after the library file is pushed to your repository.
local OrcaHub = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/donhubroblox/orcahubui_chatgpt/main/OrcaHub.lua"
))()

-- Optional: supply your own uploaded Lucide icon image asset IDs.
OrcaHub:LoadIcons({
	["house"] = "rbxassetid://YOUR_HOUSE_ICON_ASSET_ID",
	["user-round"] = "rbxassetid://YOUR_USER_ICON_ASSET_ID",
	["settings-2"] = "rbxassetid://YOUR_SETTINGS_ICON_ASSET_ID",
})

local Window = OrcaHub:CreateWindow({
	Title = "OrcaHub",
	Footer = "Design preview",
	Icon = "wind",
})

local Main = Window:Tab({
	Name = "Main",
	Icon = "house",
	Description = "Main Features",
})

local Player = Main:Section({ Name = "Player", Icon = "user-round", Side = "Left" })
Player:Label({ Name = "Example controls", Height = 26 })
Player:Toggle({
	Name = "Example toggle",
	Flag = "ExampleToggle",
	Default = false,
	Callback = function(enabled)
		print("Example toggle is", enabled)
	end,
})
Player:Button({
	Name = "Example button",
	Callback = function()
		print("Button pressed")
	end,
})

local Info = Main:Section({ Name = "About", Icon = "sparkles", Side = "Right" })
Info:Label({ Name = "A clean base for future script interfaces." })
Info:Button({ Name = "Close window", Callback = function() Window:Destroy() end })
