-- Example usage for OrcaHub UI
-- Load the published library.
local OrcaHub = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/donhubroblox/orcahubui_chatgpt/main/OrcaHub.lua"
))()

-- Optional Lucide icons can be enabled with OrcaHub:LoadIcons({ ["house"] = "rbxassetid://..." })

local Window = OrcaHub:CreateWindow({
	Title = "OrcaHub",
	Footer = "Design preview",
})

local Main = Window:Tab({
	Name = "Main",
	Description = "Main Features",
})

local Player = Main:Section({ Name = "Player", Side = "Left" })
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

local Info = Main:Section({ Name = "About", Side = "Right" })
Info:Label({ Name = "Search filters controls on this tab." })
Info:Button({ Name = "Close window", Callback = function() Window:Destroy() end })
