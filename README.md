# OrcaHub UI

A single-file, executor-friendly Roblox UI library with a responsive dark layout, animated violet accents, searchable tabs, and reusable controls. Rerunning `Example.lua` replaces the previous OrcaHub window and disconnects its library-managed input listeners.

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

The complete runnable showcase is in [`Example.lua`](Example.lua). It demonstrates the controls, search, collapsible sections, and window animations.

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

- `OrcaHub.Version` (currently `2.0.0`)
- `OrcaHub:CreateWindow({ Title, Footer, Icon, Width, Height, Theme })`
- `Window:Tab({ Name, Icon, Description })`
- `Tab:Section({ Name, Icon, Side = "Left" | "Right" })`
- `Section:Toggle({ Name, Default, Flag, Callback })`
- `Section:Button({ Name, Callback })`
- `Section:Label({ Name })`
- `Section:Paragraph({ Name, Content, Height })`
- `Section:Slider({ Name, Min, Max, Default, Decimals, Flag, Callback })`
- `Section:Dropdown({ Name, Options, Default, Flag, Callback })`
- `Section:Input({ Name, Placeholder, Default, Flag, Callback })`
- `Section:Keybind({ Name, Default, Flag, Callback })`
- `OrcaHub:LoadIcons(imageMap)`
- Search filters control names on the active tab.
- `Window:SetVisible(boolean)` and `Window:Toggle()`
- `Window:Minimize()`
- `Window:Notify({ Title, Content, Duration })`
- `Window:Destroy()`

Sections collapse from their headers. The layout adapts to the viewport and stacks its columns on narrower screens. Configure colors with `CreateWindow({ Theme = { Accent = Color3.fromRGB(...) } })`. Window entrance, page transitions, controls, minimize/close, and toast notifications are animated. `CreateWindow()` destroys the prior OrcaHub window before creating a new one. `Window:Destroy()` disconnects library-managed listeners and removes the UI.

## Test status

The UI code and example pass the [rbx-ui-testkit](https://github.com/donhubroblox/rbx-ui-testkit) syntax check, desktop and mobile fuzz runs, and targeted interaction checks. The test kit simulates Roblox APIs but does not render the interface, so final visual tuning still needs an in-game check.
