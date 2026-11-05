# OrcaHub UI

A compact, executor-friendly Roblox UI library focused on a clean dark interface, soft violet accents, and simple script-facing controls.

## Load

Load the library from the repository's `main` branch:

```lua
local OrcaHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/donhubroblox/orcahubui_chatgpt/main/OrcaHub.lua"))()
```

## Quick example

```lua
local OrcaHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/donhubroblox/orcahubui_chatgpt/main/OrcaHub.lua"))()

local Window = OrcaHub:CreateWindow({
    Title = "OrcaHub",
    Footer = "Made for your scripts",
})

local Main = Window:Tab({ Name = "Main", Icon = "house", Description = "Main Features" })
local Player = Main:Section({ Name = "Player", Icon = "user-round", Side = "Left" })

Player:Toggle({
    Name = "Example toggle",
    Flag = "ExampleToggle",
    Default = false,
    Callback = function(enabled)
        print("Example toggle:", enabled)
    end,
})

Player:Button({
    Name = "Print message",
    Callback = function()
        print("Hello from OrcaHub")
    end,
})

Player:Label({ Name = "A clean starting point for your script." })
```

## Lucide icons

Tabs and sections accept Lucide icon names. The library does not download assets automatically; provide an image map once your chosen Lucide image assets are available:

```lua
OrcaHub:LoadIcons({
    ["house"] = "rbxassetid://YOUR_UPLOADED_LUCIDE_ICON_ID",
    ["user-round"] = "rbxassetid://YOUR_UPLOADED_LUCIDE_ICON_ID",
})
```

You may also use the `lucide-` prefix in the map key. Icons are optional; the controls remain usable when an icon is missing.

## Current API

- `OrcaHub:CreateWindow({ Title, Footer, Icon })`
- `Window:Tab({ Name, Icon, Description })`
- `Tab:Section({ Name, Icon, Side = "Left" | "Right" })`
- `Section:Toggle({ Name, Default, Flag, Callback })`
- `Section:Button({ Name, Callback })`
- `Section:Label({ Name })`
- `OrcaHub:LoadIcons(imageMap)`
- Search filters control names on the active tab.
- `Window:SetVisible(boolean)` and `Window:Toggle()`
- `Window:Destroy()`

`Window:Destroy()` disconnects the library's input listeners and removes its UI. Dropdowns, sliders, keybinds, persistence, and theme editing are planned for later iterations.
