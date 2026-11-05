--[[
    OrcaHub UI Library - executor-friendly Roblox UI library

    local OrcaHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/donhubroblox/orcahubui_chatgpt/main/OrcaHub.lua"))()
    local Window = OrcaHub:CreateWindow({ Title = "OrcaHub", Footer = "v2.0" })
    local Tab = Window:Tab({ Name = "Main", Icon = "house" })
    local Section = Tab:Section({ Name = "Player", Side = "Left" })
    Section:Toggle({ Name = "Example toggle", Default = false, Callback = function(value) end })
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local SharedEnvironment = _G
if type(getgenv) == "function" then
	local ok, environment = pcall(getgenv)
	if ok and type(environment) == "table" then SharedEnvironment = environment end
end
local ACTIVE_WINDOW_KEY = "__ORCAHUB_ACTIVE_WINDOW"

local Library = {
	Version = "2.0.0",
	Flags = {},
	Icons = {},
	Theme = {
		Background = Color3.fromRGB(13, 14, 18),
		Sidebar = Color3.fromRGB(17, 18, 23),
		Panel = Color3.fromRGB(21, 22, 28),
		Element = Color3.fromRGB(28, 29, 36),
		Hover = Color3.fromRGB(38, 39, 48),
		Stroke = Color3.fromRGB(43, 44, 54),
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
	return make("UIStroke", { Color = color or Library.Theme.Stroke, Transparency = transparency or 0, Thickness = 1 }, object)
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
	local previousWindow
	pcall(function() previousWindow = SharedEnvironment[ACTIVE_WINDOW_KEY] end)
	if type(previousWindow) == "table" and type(previousWindow.Destroy) == "function" then pcall(function() previousWindow:Destroy() end) end
	local theme = {}
	for key, value in pairs(self.Theme) do theme[key] = value end
	for key, value in pairs(options.Theme or {}) do theme[key] = value end
	local guiParent
	if type(gethui) == "function" then
		local ok, result = pcall(gethui)
		if ok then guiParent = result end
	end
	guiParent = guiParent or game:GetService("CoreGui")
	for _, child in ipairs(guiParent:GetChildren()) do
		if child.Name == "OrcaHubUI" then child:Destroy() end
	end
	local gui = make("ScreenGui", { Name = "OrcaHubUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling }, guiParent)
	local root = make("Frame", { Name = "Window", AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(options.Width or 1000, options.Height or 640), BackgroundColor3 = theme.Background, BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true }, gui)
	round(root, 15)
	local rootStroke = outline(root, theme.Stroke, 1)
	local accentLine = make("Frame", { Size = UDim2.new(1, 0, 0, 2), BackgroundColor3 = theme.Accent, BorderSizePixel = 0, ZIndex = 5 }, root)
	make("UIGradient", { Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, theme.Accent), ColorSequenceKeypoint.new(0.55, Color3.fromRGB(108, 123, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(56, 196, 190)) }) }, accentLine)

	local sidebar = make("Frame", { Size = UDim2.new(0, 190, 1, 0), BackgroundColor3 = theme.Sidebar, BorderSizePixel = 0 }, root)
	make("Frame", { Position = UDim2.new(1, -1, 0, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = theme.Stroke, BorderSizePixel = 0 }, sidebar)
	local brand = make("Frame", { Size = UDim2.new(1, 0, 0, 68), BackgroundTransparency = 1 }, sidebar)
	local brandIcon = iconImage(brand, options.Icon or "wind", 23)
	if brandIcon then brandIcon.Position = UDim2.new(0, 18, 0.5, -11); brandIcon.ImageColor3 = theme.Accent end
	local brandName = label(brand, options.Title or "OrcaHub", 17, theme.Text, Enum.Font.GothamBold)
	brandName.Position = UDim2.new(0, brandIcon and 52 or 20, 0, 0); brandName.Size = UDim2.new(1, -60, 1, 0)
	make("Frame", { Position = UDim2.new(0, 16, 1, -1), Size = UDim2.new(1, -32, 0, 1), BackgroundColor3 = theme.Stroke, BorderSizePixel = 0 }, brand)

	local tabList = make("ScrollingFrame", { Position = UDim2.new(0, 10, 0, 80), Size = UDim2.new(1, -20, 1, -130), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(), ScrollingDirection = Enum.ScrollingDirection.Y }, sidebar)
	local tabLayout = make("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, tabList)
	tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() tabList.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y) end)
	local footer = label(sidebar, options.Footer or "", 11, theme.SubText)
	footer.Position = UDim2.new(0, 16, 1, -35); footer.Size = UDim2.new(1, -26, 0, 18)

	local content = make("Frame", { Position = UDim2.new(0, 190, 0, 0), Size = UDim2.new(1, -190, 1, 0), BackgroundTransparency = 1 }, root)
	local topbar = make("Frame", { Size = UDim2.new(1, 0, 0, 76), BackgroundTransparency = 1 }, content)
	local pageTitle = label(topbar, "Main", 19, theme.Text, Enum.Font.GothamBold)
	pageTitle.Position = UDim2.new(0, 25, 0, 10); pageTitle.Size = UDim2.new(0, 260, 0, 25)
	local pageHint = label(topbar, "Main Features", 12, theme.SubText)
	pageHint.Position = UDim2.new(0, 26, 0, 35); pageHint.Size = UDim2.new(0, 260, 0, 18)
	local search = make("TextBox", { Position = UDim2.new(1, -255, 0, 14), Size = UDim2.new(0, 230, 0, 38), BackgroundColor3 = theme.Panel, BorderSizePixel = 0, PlaceholderText = "Search", PlaceholderColor3 = theme.SubText, Text = "", TextColor3 = theme.Text, TextSize = 13, Font = Enum.Font.Gotham, ClearTextOnFocus = false }, topbar)
	round(search, 9); outline(search)
	local scroll = make("ScrollingFrame", { Name = "Pages", Position = UDim2.new(0, 18, 0, 84), Size = UDim2.new(1, -36, 1, -100), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = theme.Accent, CanvasSize = UDim2.new(), ScrollingDirection = Enum.ScrollingDirection.Y }, content)

	local window = { Gui = gui, Root = root, Pages = {}, ActivePage = nil, Connections = {}, NormalSize = nil }
	local minimized = false
	local windowControls
	local notificationHolder
	local function connect(signal, callback)
		local connection
		connection = signal:Connect(function(...)
			if not gui.Parent then connection:Disconnect(); return end
			callback(...)
		end)
		table.insert(window.Connections, connection)
		return connection
	end
	local function fitWindow()
		local camera = workspace.CurrentCamera
		if not camera then return end
		local viewport = camera.ViewportSize
		local width = math.max(300, math.min(options.Width or 1000, viewport.X - 24))
		local height = math.max(300, math.min(options.Height or 640, viewport.Y - 24))
		local sidebarWidth = math.min(190, math.max(126, width * 0.21))
		local normalSize = UDim2.fromOffset(width, height)
		window.NormalSize = normalSize
		if minimized then root.Size = UDim2.fromOffset(width, 76) else root.Size = normalSize end
		sidebar.Size = UDim2.new(0, sidebarWidth, 1, 0)
		content.Position = UDim2.new(0, sidebarWidth, 0, 0)
		content.Size = UDim2.new(1, -sidebarWidth, 1, 0)
		tabList.Size = UDim2.new(1, -20, 1, -130)
		local compactHeader = width - sidebarWidth < 500
		topbar.Size = UDim2.new(1, 0, 0, compactHeader and 112 or 76)
		pageTitle.Position = UDim2.new(0, compactHeader and 16 or 25, 0, 10)
		pageTitle.Size = UDim2.new(compactHeader and 1 or 0.54, compactHeader and -90 or -18, 0, 25)
		pageHint.Visible = not compactHeader
		pageHint.Size = UDim2.new(0.54, -18, 0, 18)
		if compactHeader then
			search.Position = UDim2.new(0, 14, 0, 60)
			search.Size = UDim2.new(1, -88, 0, 36)
			scroll.Position = UDim2.new(0, 18, 0, 120)
			scroll.Size = UDim2.new(1, -36, 1, -136)
		else
			search.Position = UDim2.new(0.54, 0, 0, 14)
			search.Size = UDim2.new(0.30, -8, 0, 38)
			scroll.Position = UDim2.new(0, 18, 0, 84)
			scroll.Size = UDim2.new(1, -36, 1, -100)
		end
		if windowControls then windowControls.Visible = true end
		if notificationHolder then notificationHolder.Size = UDim2.new(0, math.max(220, math.min(320, width - 24)), 0, 300) end
		for _, page in ipairs(window.Pages) do page:UpdateCanvas() end
	end
	local camera = workspace.CurrentCamera
	if camera then connect(camera:GetPropertyChangedSignal("ViewportSize"), fitWindow) end
	connect(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
		local currentCamera = workspace.CurrentCamera
		if currentCamera then
			connect(currentCamera:GetPropertyChangedSignal("ViewportSize"), fitWindow)
			fitWindow()
		end
	end)
	fitWindow()
	windowControls = make("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 19), Size = UDim2.fromOffset(58, 26), BackgroundTransparency = 1 }, topbar)
	local minimizeButton = make("TextButton", { Position = UDim2.new(0, 0, 0, 0), Size = UDim2.fromOffset(26, 26), BackgroundColor3 = theme.Element, BackgroundTransparency = 0.15, BorderSizePixel = 0, Text = "−", TextColor3 = theme.SubText, TextSize = 18, Font = Enum.Font.Gotham, AutoButtonColor = false }, windowControls)
	local closeButton = make("TextButton", { Position = UDim2.new(1, -26, 0, 0), Size = UDim2.fromOffset(26, 26), BackgroundColor3 = theme.Element, BackgroundTransparency = 0.15, BorderSizePixel = 0, Text = "×", TextColor3 = theme.SubText, TextSize = 17, Font = Enum.Font.Gotham, AutoButtonColor = false }, windowControls)
	round(minimizeButton, 7); round(closeButton, 7)
	notificationHolder = make("Frame", { Name = "Notifications", AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -14, 1, -14), Size = UDim2.new(0, math.max(220, math.min(320, root.AbsoluteSize.X - 24)), 0, 300), BackgroundTransparency = 1, ZIndex = 10 }, root)
	make("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom }, notificationHolder)
	local function setPage(page)
		if window.ActivePage then
			local previous = window.ActivePage
			previous.Frame.Visible = false
			tween(previous.Button, 0.16, { BackgroundColor3 = theme.Sidebar })
			tween(previous.Indicator, 0.16, { BackgroundTransparency = 1 })
		end
		window.ActivePage = page
		page.Frame.Visible = true
		page.Frame.Position = UDim2.new(0, 7, 0, 0)
		tween(page.Frame, 0.22, { Position = UDim2.new(0, 0, 0, 0) })
		page:UpdateCanvas()
		page:FilterControls(search.Text)
		pageTitle.Text = page.Name
		pageHint.Text = page.Description or ""
		tween(page.Button, 0.15, { BackgroundColor3 = theme.Hover })
		tween(page.Indicator, 0.18, { BackgroundTransparency = 0 })
	end

	function window:Tab(config)
		config = config or {}
		local page = { Name = config.Name or "Tab", Description = config.Description or "", Sections = {}, ColumnLayouts = {}, Columns = {} }
		page.Button = make("TextButton", { Name = page.Name, Size = UDim2.new(1, 0, 0, 39), BackgroundColor3 = theme.Sidebar, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, tabList)
		round(page.Button, 8)
		page.Indicator = make("Frame", { Position = UDim2.new(0, 0, 0.5, -10), Size = UDim2.fromOffset(3, 20), BackgroundColor3 = theme.Accent, BackgroundTransparency = 1, BorderSizePixel = 0 }, page.Button)
		round(page.Indicator, 3)
		local glyph = iconImage(page.Button, config.Icon or "circle", 17)
		if glyph then glyph.Position = UDim2.new(0, 11, 0.5, -8); glyph.ImageColor3 = theme.SubText end
		local tabName = label(page.Button, page.Name, 13, theme.SubText, Enum.Font.GothamMedium)
		tabName.Position = UDim2.new(0, glyph and 39 or 13, 0, 0); tabName.Size = UDim2.new(1, -45, 1, 0)
		page.Frame = make("Frame", { Name = page.Name .. "Page", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Visible = false }, scroll)
		local columns = {}
		for i, side in ipairs({ "Left", "Right" }) do
			columns[side] = make("Frame", { Position = UDim2.new((i - 1) * 0.5, i == 1 and 0 or 7, 0, 0), Size = UDim2.new(0.5, -7, 1, 0), BackgroundTransparency = 1 }, page.Frame)
			page.Columns[side] = columns[side]
			page.ColumnLayouts[side] = make("UIListLayout", { Padding = UDim.new(0, 11), SortOrder = Enum.SortOrder.LayoutOrder }, columns[side])
			connect(page.ColumnLayouts[side]:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				if window.ActivePage == page then page:UpdateCanvas() end
			end)
		end
		function page:UpdateCanvas()
			local leftHeight = page.ColumnLayouts.Left.AbsoluteContentSize.Y
			local rightHeight = page.ColumnLayouts.Right.AbsoluteContentSize.Y
			local stacked = root.AbsoluteSize.X < 900
			if stacked then
				columns.Left.Position = UDim2.new(0, 0, 0, 0)
				columns.Left.Size = UDim2.new(1, 0, 1, 0)
				columns.Right.Position = UDim2.new(0, 0, 0, leftHeight > 0 and leftHeight + 12 or 0)
				columns.Right.Size = UDim2.new(1, 0, 1, 0)
			else
				columns.Left.Position = UDim2.new(0, 0, 0, 0)
				columns.Left.Size = UDim2.new(0.5, -7, 1, 0)
				columns.Right.Position = UDim2.new(0.5, 7, 0, 0)
				columns.Right.Size = UDim2.new(0.5, -7, 1, 0)
			end
			local contentHeight = stacked and (leftHeight + (rightHeight > 0 and 12 + rightHeight or 0)) or math.max(leftHeight, rightHeight)
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
			local bodyLayout = make("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, body)
			local collapsed = false
			connect(bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				if not collapsed then card.Size = UDim2.new(1, 0, 0, bodyLayout.AbsoluteContentSize.Y + 57) end
			end)
			local collapseButton = make("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -13, 0.5, 0), Size = UDim2.fromOffset(25, 25), BackgroundTransparency = 1, Text = "⌄", TextColor3 = theme.SubText, TextSize = 20, Font = Enum.Font.Gotham, AutoButtonColor = false }, heading)
			connect(collapseButton.MouseButton1Click, function()
				collapsed = not collapsed
				body.Visible = not collapsed
				tween(collapseButton, 0.18, { Rotation = collapsed and -90 or 0 })
				if collapsed then
					tween(card, 0.18, { Size = UDim2.new(1, 0, 0, 43) })
				else
					tween(card, 0.18, { Size = UDim2.new(1, 0, 0, bodyLayout.AbsoluteContentSize.Y + 57) })
				end
			end)
			local function row(name, height)
				local holder = make("Frame", { Size = UDim2.new(1, 0, 0, height or 34), BackgroundTransparency = 1 }, body)
				local text = label(holder, name, 13, theme.Text)
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
			function section:Paragraph(item)
				item = item or {}
				local holder, titleText = row(item.Name or "Information", item.Height or 56)
				titleText.Size = UDim2.new(1, 0, 0, 20)
				local contentText = label(holder, item.Content or "", 12, theme.SubText)
				contentText.Position = UDim2.new(0, 1, 0, 21)
				contentText.Size = UDim2.new(1, -2, 0, (item.Height or 56) - 21)
				contentText.TextWrapped = true
				contentText.TextYAlignment = Enum.TextYAlignment.Top
				return { Set = function(_, value) contentText.Text = tostring(value) end }
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
			function section:Slider(item)
				item = item or {}
				local minimum, maximum = item.Min or 0, item.Max or 100
				if maximum < minimum then minimum, maximum = maximum, minimum end
				local decimals = math.max(0, item.Decimals or 0)
				local holder, titleText = row(item.Name or "Slider", 56)
				titleText.Size = UDim2.new(0.62, 0, 0, 24)
				local valueText = label(holder, "", 12, theme.SubText)
				valueText.TextXAlignment = Enum.TextXAlignment.Right
				valueText.Position = UDim2.new(0.65, 0, 0, 0); valueText.Size = UDim2.new(0.35, 0, 0, 24)
				local track = make("TextButton", { Position = UDim2.new(0, 1, 0, 34), Size = UDim2.new(1, -2, 0, 6), BackgroundColor3 = theme.Element, BorderSizePixel = 0, Text = "", AutoButtonColor = false }, holder)
				round(track, 6)
				local fill = make("Frame", { Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = theme.Accent, BorderSizePixel = 0 }, track)
				round(fill, 6)
				local knob = make("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = theme.Text, BorderSizePixel = 0, ZIndex = 2 }, track)
				round(knob, 20); outline(knob, theme.Accent)
				local value = math.clamp(item.Default or minimum, minimum, maximum)
				local draggingSlider = false
				local function setValue(nextValue, fire)
					local multiplier = 10 ^ decimals
					value = math.clamp(math.floor(nextValue * multiplier + 0.5) / multiplier, minimum, maximum)
					local alpha = maximum == minimum and 0 or (value - minimum) / (maximum - minimum)
					fill.Size = UDim2.new(alpha, 0, 1, 0)
					knob.Position = UDim2.new(alpha, 0, 0.5, 0)
					valueText.Text = tostring(value)
					if item.Flag then Library.Flags[item.Flag] = value end
					if fire and item.Callback then task.spawn(item.Callback, value) end
				end
				local function updateFromInput(input)
					local alpha = math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
					setValue(minimum + (maximum - minimum) * alpha, true)
				end
				connect(track.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						draggingSlider = true; updateFromInput(input)
					end
				end)
				connect(UserInputService.InputChanged, function(input)
					if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateFromInput(input) end
				end)
				connect(UserInputService.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSlider = false end
				end)
				setValue(value, false)
				return { Set = function(_, nextValue) setValue(nextValue, false) end, Get = function() return value end }
			end
			function section:Dropdown(item)
				item = item or {}
				local choices = item.Options or {}
				local holder, titleText = row(item.Name or "Dropdown", 38)
				titleText.Size = UDim2.new(0.40, 0, 1, 0)
				local choiceButton = make("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -1, 0.5, 0), Size = UDim2.new(0.55, 0, 0, 30), BackgroundColor3 = theme.Element, BorderSizePixel = 0, Text = tostring(item.Default or "Select"), TextColor3 = theme.Text, TextSize = 12, Font = Enum.Font.Gotham, AutoButtonColor = false }, holder)
				round(choiceButton, 7); outline(choiceButton, theme.Stroke)
				local menu = make("ScrollingFrame", { Position = UDim2.new(0, 0, 0, 42), Size = UDim2.new(1, 0, 0, math.min(#choices, 5) * 30), BackgroundColor3 = theme.Element, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = theme.Accent, CanvasSize = UDim2.new(0, 0, 0, #choices * 30), Visible = false }, holder)
				round(menu, 7); outline(menu, theme.Stroke)
				local menuLayout = make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, menu)
				local selected = item.Default
				local opened = false
				local function setOpen(open)
					opened = open
					menu.Visible = opened
					holder.Size = UDim2.new(1, 0, 0, opened and (44 + math.min(#choices, 5) * 30) or 38)
				end
				for _, choice in ipairs(choices) do
					local option = make("TextButton", { Size = UDim2.new(1, -4, 0, 28), BackgroundColor3 = theme.Element, BorderSizePixel = 0, Text = tostring(choice), TextColor3 = theme.SubText, TextSize = 12, Font = Enum.Font.Gotham, AutoButtonColor = false }, menu)
					connect(option.MouseEnter, function() tween(option, 0.12, { BackgroundColor3 = theme.Hover, TextColor3 = theme.Text }) end)
					connect(option.MouseLeave, function() tween(option, 0.12, { BackgroundColor3 = theme.Element, TextColor3 = theme.SubText }) end)
					connect(option.MouseButton1Click, function()
						selected = choice; choiceButton.Text = tostring(choice); setOpen(false)
						if item.Flag then Library.Flags[item.Flag] = selected end
						if item.Callback then task.spawn(item.Callback, selected) end
					end)
				end
				connect(choiceButton.MouseButton1Click, function() setOpen(not opened) end)
				if item.Flag then Library.Flags[item.Flag] = selected end
				return { Set = function(_, nextValue) selected = nextValue; choiceButton.Text = tostring(nextValue); if item.Flag then Library.Flags[item.Flag] = selected end end, Get = function() return selected end }
			end
			function section:Input(item)
				item = item or {}
				local holder, titleText = row(item.Name or "Input", 38)
				titleText.Size = UDim2.new(0.40, 0, 1, 0)
				local input = make("TextBox", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -1, 0.5, 0), Size = UDim2.new(0.55, 0, 0, 30), BackgroundColor3 = theme.Element, BorderSizePixel = 0, PlaceholderText = item.Placeholder or "Enter text", PlaceholderColor3 = theme.SubText, Text = tostring(item.Default or ""), TextColor3 = theme.Text, TextSize = 12, Font = Enum.Font.Gotham, ClearTextOnFocus = false }, holder)
				round(input, 7); outline(input, theme.Stroke)
				if item.Flag then Library.Flags[item.Flag] = input.Text end
				connect(input.FocusLost, function(enterPressed)
					if item.Flag then Library.Flags[item.Flag] = input.Text end
					if item.Callback then task.spawn(item.Callback, input.Text, enterPressed) end
				end)
				return { Set = function(_, value) input.Text = tostring(value) end, Get = function() return input.Text end }
			end
			function section:Keybind(item)
				item = item or {}
				local holder = row(item.Name or "Keybind", 34)
				holder:FindFirstChildOfClass("TextLabel").Size = UDim2.new(1, -116, 1, 0)
				local key = item.Default or Enum.KeyCode.RightShift
				local listening = false
				local button = make("TextButton", { AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -1, 0.5, 0), Size = UDim2.fromOffset(104, 28), BackgroundColor3 = theme.Element, BorderSizePixel = 0, Text = key.Name, TextColor3 = theme.SubText, TextSize = 11, Font = Enum.Font.GothamMedium, AutoButtonColor = false }, holder)
				round(button, 7); outline(button, theme.Stroke)
				connect(button.MouseButton1Click, function() listening = true; button.Text = "Press a key..."; tween(button, 0.12, { TextColor3 = theme.Accent }) end)
				connect(UserInputService.InputBegan, function(input, processed)
					if listening and input.UserInputType == Enum.UserInputType.Keyboard then
						key = input.KeyCode; listening = false; button.Text = key.Name; tween(button, 0.12, { TextColor3 = theme.SubText })
						if item.Flag then Library.Flags[item.Flag] = key end
					elseif not listening and not processed and input.KeyCode == key then
						if item.Callback then task.spawn(item.Callback, key) end
					end
				end)
				if item.Flag then Library.Flags[item.Flag] = key end
				return { Set = function(_, nextKey) key = nextKey; button.Text = key.Name; if item.Flag then Library.Flags[item.Flag] = key end end, Get = function() return key end }
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
		pcall(function()
			if SharedEnvironment[ACTIVE_WINDOW_KEY] == window then SharedEnvironment[ACTIVE_WINDOW_KEY] = nil end
		end)
	end
	function window:SetVisible(visible) gui.Enabled = visible == true end
	function window:Toggle() gui.Enabled = not gui.Enabled end
	function window:Minimize()
		minimized = not minimized
		local target = minimized and UDim2.fromOffset(root.AbsoluteSize.X, 76) or window.NormalSize
		tween(root, 0.24, { Size = target })
		minimizeButton.Text = minimized and "+" or "−"
	end
	function window:Notify(config)
		config = config or {}
		local wrapper = make("Frame", { Size = UDim2.new(1, 0, 0, 78), BackgroundTransparency = 1, ZIndex = 10 }, notificationHolder)
		local toast = make("Frame", { AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 330, 0, 0), Size = UDim2.new(1, 0, 0, 72), BackgroundColor3 = theme.Panel, BorderSizePixel = 0, ZIndex = 11 }, wrapper)
		round(toast, 10); outline(toast, theme.Stroke)
		local accent = make("Frame", { Position = UDim2.new(0, 0, 0, 10), Size = UDim2.new(0, 3, 1, -20), BackgroundColor3 = theme.Accent, BorderSizePixel = 0, ZIndex = 12 }, toast)
		round(accent, 3)
		local toastTitle = label(toast, config.Title or "OrcaHub", 13, theme.Text, Enum.Font.GothamBold)
		toastTitle.Position = UDim2.new(0, 15, 0, 10); toastTitle.Size = UDim2.new(1, -26, 0, 20); toastTitle.ZIndex = 12
		local toastContent = label(toast, config.Content or config.Description or "", 12, theme.SubText)
		toastContent.Position = UDim2.new(0, 15, 0, 32); toastContent.Size = UDim2.new(1, -26, 0, 30); toastContent.TextWrapped = true; toastContent.ZIndex = 12
		tween(toast, 0.28, { Position = UDim2.new(1, 0, 0, 0) })
		task.delay(config.Duration or 3, function()
			if not wrapper.Parent then return end
			tween(toast, 0.2, { Position = UDim2.new(1, 330, 0, 0), BackgroundTransparency = 1 })
			task.delay(0.22, function() if wrapper.Parent then wrapper:Destroy() end end)
		end)
		return wrapper
	end
	connect(minimizeButton.MouseButton1Click, function() window:Minimize() end)
	connect(closeButton.MouseButton1Click, function() window:Destroy() end)
	connect(closeButton.MouseEnter, function() tween(closeButton, 0.12, { BackgroundColor3 = Color3.fromRGB(190, 66, 80), TextColor3 = Color3.new(1, 1, 1) }) end)
	connect(closeButton.MouseLeave, function() tween(closeButton, 0.12, { BackgroundColor3 = theme.Element, TextColor3 = theme.SubText }) end)
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
	window.NormalSize = root.Size
	root.Size = UDim2.fromOffset(root.AbsoluteSize.X * 0.96, root.AbsoluteSize.Y * 0.96)
	tween(root, 0.3, { Size = window.NormalSize, BackgroundTransparency = 0 })
	tween(rootStroke, 0.3, { Transparency = 0 })
	pcall(function() SharedEnvironment[ACTIVE_WINDOW_KEY] = window end)
	return window
end

return Library

