--[[
    OrcaHub UI Library - executor-friendly Roblox UI library

    local OrcaHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/donhubroblox/orcahubui_chatgpt/main/OrcaHub.lua"))()
    local Window = OrcaHub:CreateWindow({ Title = "OrcaHub", Footer = "v1.0" })
    local Tab = Window:Tab({ Name = "Main", Icon = "house" })
    local Section = Tab:Section({ Name = "Player", Side = "Left" })
    Section:Toggle({ Name = "Example toggle", Default = false, Callback = function(value) end })
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = {
	Flags = {},
	Icons = {},
	Theme = {
		Background = Color3.fromRGB(12, 13, 16),
		Sidebar = Color3.fromRGB(16, 17, 21),
		Panel = Color3.fromRGB(19, 20, 25),
		Element = Color3.fromRGB(25, 26, 32),
		Hover = Color3.fromRGB(34, 35, 43),
		Stroke = Color3.fromRGB(40, 41, 50),
		Text = Color3.fromRGB(239, 239, 245),
		SubText = Color3.fromRGB(147, 149, 162),
		Accent = Color3.fromRGB(157, 116, 255),
		ToggleOff = Color3.fromRGB(57, 58, 68),
	},
}

local function make(class, props, parent)
	local object = Instance.new(class)
	for key, value in pairs(props or {}) do object[key] = value end
	object.Parent = parent
	return object
end

local function round(object, radius)
	make("UICorner", { CornerRadius = UDim.new(0, radius or 9) }, object)
end

local function outline(object, color, transparency)
	make("UIStroke", { Color = color or Library.Theme.Stroke, Transparency = transparency or 0, Thickness = 1 }, object)
end

local function tween(object, duration, properties)
	TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties):Play()
end

local function label(parent, text, size, color, font)
	return make("TextLabel", {
		BackgroundTransparency = 1, Text = text or "", TextSize = size or 13,
		TextColor3 = color or Library.Theme.Text, Font = font or Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center,
	}, parent)
end

function Library:LoadIcons(map)
	if type(map) ~= "table" then return end
	for name, image in pairs(map) do self.Icons[name] = image end
end

local function iconImage(parent, name, size)
	local asset = Library.Icons[name] or Library.Icons["lucide-" .. tostring(name)]
	if not asset then return nil end
	return make("ImageLabel", { BackgroundTransparency = 1, Image = asset, ImageColor3 = Library.Theme.SubText, Size = UDim2.fromOffset(size or 17, size or 17), ScaleType = Enum.ScaleType.Fit }, parent)
end

function Library:CreateWindow(options)
	options = options or {}
	local theme = self.Theme
	local guiParent
	if type(gethui) == "function" then
		local ok, result = pcall(gethui)
		if ok then guiParent = result end
	end
	guiParent = guiParent or game:GetService("CoreGui")
	local gui = make("ScreenGui", { Name = "OrcaHubUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, guiParent)
	local root = make("Frame", { Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(780, 500), BackgroundColor3 = theme.Background, BorderSizePixel = 0, ClipsDescendants = true }, gui)
	round(root, 13); outline(root, theme.Stroke)

	local sidebar = make("Frame", { Size = UDim2.new(0, 190, 1, 0), BackgroundColor3 = theme.Sidebar, BorderSizePixel = 0 }, root)
	make("Frame", { Position = UDim2.new(1, -1, 0, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = theme.Stroke, BorderSizePixel = 0 }, sidebar)
	local brand = make("Frame", { Size = UDim2.new(1, 0, 0, 68), BackgroundTransparency = 1 }, sidebar)
	local brandIcon = iconImage(brand, options.Icon or "wind", 23)
	if brandIcon then brandIcon.Position = UDim2.new(0, 18, 0.5, -11); brandIcon.ImageColor3 = theme.Accent end
	local brandName = label(brand, options.Title or "OrcaHub", 17, theme.Text, Enum.Font.GothamSemibold)
	brandName.Position = UDim2.new(0, brandIcon and 52 or 20, 0, 0); brandName.Size = UDim2.new(1, -60, 1, 0)
	make("Frame", { Position = UDim2.new(0, 16, 1, -1), Size = UDim2.new(1, -32, 0, 1), BackgroundColor3 = theme.Stroke, BorderSizePixel = 0 }, brand)

	local tabList = make("Frame", { Position = UDim2.new(0, 10, 0, 80), Size = UDim2.new(1, -20, 1, -130), BackgroundTransparency = 1 }, sidebar)
	local tabLayout = make("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, tabList)
	local footer = label(sidebar, options.Footer or "", 11, theme.SubText)
	footer.Position = UDim2.new(0, 16, 1, -35); footer.Size = UDim2.new(1, -26, 0, 18)

	local content = make("Frame", { Position = UDim2.new(0, 190, 0, 0), Size = UDim2.new(1, -190, 1, 0), BackgroundTransparency = 1 }, root)
	local topbar = make("Frame", { Size = UDim2.new(1, 0, 0, 68), BackgroundTransparency = 1 }, content)
	local pageTitle = label(topbar, "Main", 19, theme.Text, Enum.Font.GothamSemibold)
	pageTitle.Position = UDim2.new(0, 25, 0, 10); pageTitle.Size = UDim2.new(0, 260, 0, 25)
	local pageHint = label(topbar, "Main Features", 12, theme.SubText)
	pageHint.Position = UDim2.new(0, 26, 0, 35); pageHint.Size = UDim2.new(0, 260, 0, 18)
	local search = make("TextBox", { Position = UDim2.new(1, -255, 0, 14), Size = UDim2.new(0, 230, 0, 38), BackgroundColor3 = theme.Panel, BorderSizePixel = 0, PlaceholderText = "Search", PlaceholderColor3 = theme.SubText, Text = "", TextColor3 = theme.Text, TextSize = 13, Font = Enum.Font.Gotham, ClearTextOnFocus = false }, topbar)
	round(search, 9); outline(search)
	local scroll = make("ScrollingFrame", { Name = "Pages", Position = UDim2.new(0, 18, 0, 76), Size = UDim2.new(1, -36, 1, -92), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = theme.Accent, CanvasSize = UDim2.new() }, content)

	local window = { Gui = gui, Root = root, Pages = {}, ActivePage = nil, Connections = {} }
	local function connect(signal, callback)
		local connection = signal:Connect(callback)
		table.insert(window.Connections, connection)
		return connection
	end
	local function setPage(page)
		if window.ActivePage then window.ActivePage.Frame.Visible = false; tween(window.ActivePage.Button, 0.15, { BackgroundColor3 = theme.Sidebar }) end
		window.ActivePage = page
		page.Frame.Visible = true
		page:UpdateCanvas()
		page:FilterControls(search.Text)
		pageTitle.Text = page.Name
		pageHint.Text = page.Description or ""
		tween(page.Button, 0.15, { BackgroundColor3 = theme.Hover })
	end

	function window:Tab(config)
		config = config or {}
		local page = { Name = config.Name or "Tab", Description = config.Description or "", Sections = {}, ColumnLayouts = {} }
		page.Button = make("TextButton", { Name = page.Name, Size = UDim2.new(1, 0, 0, 39), BackgroundColor3 = theme.Sidebar, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, tabList)
		round(page.Button, 8)
		local glyph = iconImage(page.Button, config.Icon or "circle", 17)
		if glyph then glyph.Position = UDim2.new(0, 11, 0.5, -8); glyph.ImageColor3 = theme.SubText end
		local tabName = label(page.Button, page.Name, 13, theme.SubText, Enum.Font.GothamMedium)
		tabName.Position = UDim2.new(0, glyph and 39 or 13, 0, 0); tabName.Size = UDim2.new(1, -45, 1, 0)
		page.Frame = make("Frame", { Name = page.Name .. "Page", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false }, scroll)
		local columns = {}
		for i, side in ipairs({ "Left", "Right" }) do
			columns[side] = make("Frame", { Position = UDim2.new((i - 1) * 0.5, i == 1 and 0 or 7, 0, 0), Size = UDim2.new(0.5, -7, 1, 0), BackgroundTransparency = 1 }, page.Frame)
			page.ColumnLayouts[side] = make("UIListLayout", { Padding = UDim.new(0, 11), SortOrder = Enum.SortOrder.LayoutOrder }, columns[side])
			connect(page.ColumnLayouts[side]:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				if window.ActivePage == page then page:UpdateCanvas() end
			end)
		end
		function page:UpdateCanvas()
			local contentHeight = math.max(page.ColumnLayouts.Left.AbsoluteContentSize.Y, page.ColumnLayouts.Right.AbsoluteContentSize.Y)
			local height = math.max(scroll.AbsoluteSize.Y, contentHeight)
			page.Frame.Size = UDim2.new(1, 0, 0, height)
			if window.ActivePage == page then scroll.CanvasSize = UDim2.new(0, 0, 0, height) end
		end
		function page:FilterControls(query)
			query = string.lower(query or "")
			for _, section in ipairs(page.Sections) do
				local matches = 0
				for _, entry in ipairs(section.Items) do
					local visible = query == "" or string.find(string.lower(entry.Name), query, 1, true) ~= nil
					entry.Frame.Visible = visible
					if visible then matches = matches + 1 end
				end
				section.Frame.Visible = query == "" or matches > 0
			end
			page:UpdateCanvas()
		end
		connect(page.Button.MouseButton1Click, function() setPage(page) end)
		function page:Section(sectionOptions)
			sectionOptions = sectionOptions or {}
			local card = make("Frame", { Name = sectionOptions.Name or "Section", Size = UDim2.new(1, 0, 0, 40), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = theme.Panel, BorderSizePixel = 0 }, columns[sectionOptions.Side == "Right" and "Right" or "Left"])
			local section = { Frame = card, Items = {} }
			table.insert(page.Sections, section)
			round(card, 11); outline(card)
			local heading = make("Frame", { Size = UDim2.new(1, 0, 0, 43), BackgroundTransparency = 1 }, card)
			local headingIcon = iconImage(heading, sectionOptions.Icon or "box", 18)
			if headingIcon then headingIcon.Position = UDim2.new(0, 14, 0.5, -9); headingIcon.ImageColor3 = theme.Accent end
			local title = label(heading, sectionOptions.Name or "Section", 14, theme.Text, Enum.Font.GothamMedium)
			title.Position = UDim2.new(0, headingIcon and 42 or 15, 0, 0); title.Size = UDim2.new(1, -55, 1, 0)
			local body = make("Frame", { Position = UDim2.new(0, 12, 0, 45), Size = UDim2.new(1, -24, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 }, card)
			local bodyLayout = make("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, body)
			connect(bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function() card.Size = UDim2.new(1, 0, 0, bodyLayout.AbsoluteContentSize.Y + 57) end)
			local function row(name, height)
				local holder = make("Frame", { Size = UDim2.new(1, 0, 0, height or 34), BackgroundTransparency = 1 }, body)
				local text = label(holder, name, 13, theme.SubText)
				text.Position = UDim2.new(0, 1, 0, 0); text.Size = UDim2.new(1, -45, 1, 0)
				table.insert(section.Items, { Frame = holder, Name = tostring(name or "") })
				return holder, text
			end
			function section:Label(item)
				item = type(item) == "table" and item or { Name = tostring(item) }
				local holder, text = row(item.Name, item.Height or 30)
				text.TextColor3 = theme.SubText
				return { Set = function(_, value) text.Text = tostring(value) end }
			end
			function section:Button(item)
				item = item or {}
				local button = make("TextButton", { Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = theme.Element, BorderSizePixel = 0, Text = item.Name or "Button", TextColor3 = theme.Text, TextSize = 12, Font = Enum.Font.GothamMedium, AutoButtonColor = false }, body)
				round(button, 7); outline(button, theme.Stroke)
				table.insert(section.Items, { Frame = button, Name = tostring(item.Name or "Button") })
				connect(button.MouseEnter, function() tween(button, 0.12, { BackgroundColor3 = theme.Hover }) end)
				connect(button.MouseLeave, function() tween(button, 0.12, { BackgroundColor3 = theme.Element }) end)
				connect(button.MouseButton1Click, function() if item.Callback then task.spawn(item.Callback) end end)
				return button
			end
			function section:Toggle(item)
				item = item or {}
				local holder, text = row(item.Name or "Toggle", 34)
				local state = item.Default == true
				local track = make("Frame", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -2, 0.5, 0), Size = UDim2.fromOffset(34, 19), BackgroundColor3 = state and theme.Accent or theme.ToggleOff, BorderSizePixel = 0 }, holder)
				round(track, 20)
				local knob = make("Frame", { Position = UDim2.new(0, state and 17 or 3, 0, 3), Size = UDim2.fromOffset(13, 13), BackgroundColor3 = Color3.fromRGB(246, 246, 250), BorderSizePixel = 0 }, track)
				round(knob, 20)
				local hit = make("TextButton", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = "" }, holder)
				local function set(value, fire)
					state = value == true
					tween(track, 0.16, { BackgroundColor3 = state and theme.Accent or theme.ToggleOff })
					tween(knob, 0.16, { Position = UDim2.new(0, state and 17 or 3, 0, 3) })
					if item.Flag then Library.Flags[item.Flag] = state end
					if fire and item.Callback then task.spawn(item.Callback, state) end
				end
				connect(hit.MouseButton1Click, function() set(not state, true) end)
				set(state, false)
				return { Set = function(_, value) set(value, false) end, Get = function() return state end }
			end
			return section
		end
		table.insert(self.Pages, page)
		if not self.ActivePage then setPage(page) end
		return page
	end

	connect(search:GetPropertyChangedSignal("Text"), function()
		if window.ActivePage then window.ActivePage:FilterControls(search.Text) end
	end)
	function window:Destroy()
		for _, connection in ipairs(window.Connections) do connection:Disconnect() end
		table.clear(window.Connections)
		gui:Destroy()
	end
	function window:SetVisible(visible) gui.Enabled = visible == true end
	function window:Toggle() gui.Enabled = not gui.Enabled end
	local dragging, dragStart, startPos
	connect(topbar.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = root.Position end
	end)
	connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)
	return window
end

return Library

