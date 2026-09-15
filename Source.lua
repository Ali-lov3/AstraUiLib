local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local Lucide
pcall(function()
	Lucide = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/icons.lua"))()
end)

local function ResolveIcon(Icon)
	if type(Icon) == "number" then return "rbxassetid://" .. Icon end
	if type(Icon) == "string" then
		if string.match(Icon, "^rbxassetid://") then return Icon end
		if string.match(Icon, "^%d+$") then return "rbxassetid://" .. Icon end
		local Name = string.lower(Icon)
		if type(Lucide) == "function" then
			local ok, Data = pcall(Lucide, Name)
			if ok and type(Data) == "table" then
				local Id = Data.id or Data.Id or Data[1]
				local Size = Data.imageRectSize or Data.ImageRectSize or Data[2]
				local Offset = Data.imageRectOffset or Data.imageRectPosition or Data.ImageRectOffset or Data[3]
				if Id then return "rbxassetid://" .. tostring(Id), Offset, Size end
			end
		elseif type(Lucide) == "table" then
			for _, Set in { Lucide["48px"], Lucide["256px"], Lucide } do
				if type(Set) == "table" then
					local Data = Set[Name]
					if type(Data) == "table" and Data[1] then
						return "rbxassetid://" .. tostring(Data[1]), Data[3], Data[2]
					end
				end
			end
		end
	end
	return "rbxassetid://0"
end

local function ToVector2(Value)
	if typeof(Value) == "Vector2" then return Value end
	if type(Value) == "table" then return Vector2.new(Value[1] or Value.X or 0, Value[2] or Value.Y or 0) end
	return Vector2.new(0, 0)
end

local function ApplyIcon(Object, Icon)
	if not Icon then return end
	local Image, Offset, Size = ResolveIcon(Icon)
	Object.Image = Image
	if Offset then Object.ImageRectOffset = ToVector2(Offset) end
	if Size then Object.ImageRectSize = ToVector2(Size) end
end

local FONT_REGULAR = Font.new("rbxasset://fonts/families/PlusJakartaSans.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
local FONT_MEDIUM  = Font.new("rbxasset://fonts/families/PlusJakartaSans.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
local FONT_BOLD    = Font.new("rbxasset://fonts/families/PlusJakartaSans.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)

local COLOR_BG           = Color3.fromRGB(12, 12, 14)
local COLOR_BORDER       = Color3.fromRGB(28, 28, 34)
local COLOR_TEXT_WHITE   = Color3.fromRGB(245, 245, 250)
local COLOR_TEXT_MUTED   = Color3.fromRGB(160, 160, 172)
local COLOR_TEXT_SUB     = Color3.fromRGB(90, 90, 102)
local COLOR_ACTIVE_BG    = Color3.fromRGB(22, 22, 28)
local COLOR_SEARCH_BG    = Color3.fromRGB(18, 18, 22)
local COLOR_CARD_BG      = Color3.fromRGB(16, 16, 20)
local COLOR_BOX_INACTIVE = Color3.fromRGB(22, 22, 28)
local COLOR_BOX_BORDER   = Color3.fromRGB(55, 55, 68)

local Astra = {}
Astra.__index = Astra

local function GetParentGui()
	if gethui then return gethui() end
	if syn and syn.protect_gui then
		local sg = Instance.new("ScreenGui")
		syn.protect_gui(sg)
		sg.Parent = CoreGui
		return CoreGui
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

function Astra.new(config)
	config = config or {}
	local self = setmetatable({}, Astra)

	self.Title       = config.Title or "Astra"
	self.ConfigFolder = config.ConfigFolder or "AstraConfigs"
	self.WatermarkText = config.Watermark or self.Title
	self.ShowWatermark = config.ShowWatermark ~= false
	self.Tabs        = {}
	self.TabObjects  = {}
	self.ActiveTabRef     = nil
	self.ActiveSubTabRef  = nil
	self._themeColor = config.ThemeColor or Color3.fromRGB(0, 230, 150)
	self._accentTargets = {}
	self._checkboxAccentTargets = {}
	self.LogoAssetId = config.LogoAssetId
	self._hasLogo = self.LogoAssetId ~= nil
		and tostring(self.LogoAssetId) ~= ""
		and tostring(self.LogoAssetId) ~= "0"
		and tostring(self.LogoAssetId) ~= "rbxassetid://0"
	self.WatermarkStatus = config.WatermarkStatus or "Ready"
	self._autoloadFile = nil

	local ParentGui = GetParentGui()

	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "AstraUI"
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.ScreenGui.Parent = ParentGui

	self:_BuildWatermark()
	self:_BuildNotifContainer()
	self:_BuildMainFrame()
	self:_BuildSidebar()
	self:_BuildContent()
	self:_BuildToggleBtn()
	self:_BuildSettingsTab()

	if not pcall(function() return game:GetService("RunService") end) then return self end

	pcall(function()
		if not isfolder(self.ConfigFolder) then
			makefolder(self.ConfigFolder)
		end
	end)

	self:_LoadAutoload()

	return self
end

function Astra:_RegisterAccent(Object, Property)
	if not Object or not Property then return Object end
	Object[Property] = self._themeColor
	table.insert(self._accentTargets, {
		Object = Object,
		Property = Property
	})
	return Object
end

function Astra:_ApplyThemeColor(color)
	if typeof(color) ~= "Color3" then return end
	self._themeColor = color
	for i = #self._accentTargets, 1, -1 do
		local target = self._accentTargets[i]
		if target.Object and target.Object.Parent then
			pcall(function()
				target.Object[target.Property] = color
			end)
		else
			table.remove(self._accentTargets, i)
		end
	end
	if self.ActiveTabRef and self.ActiveTabRef.Btn then
		self.ActiveTabRef.Btn.BackgroundColor3 = color
	end
	if self.ActiveSubTabRef and self.ActiveSubTabRef.Btn then
		self.ActiveSubTabRef.Btn.BackgroundColor3 = color
	end
	for i = #self._checkboxAccentTargets, 1, -1 do
		local target = self._checkboxAccentTargets[i]
		if target.Box and target.Box.Parent then
			if target.GetState() then
				target.Box.BackgroundColor3 = color
				target.Stroke.Color = color
			end
		else
			table.remove(self._checkboxAccentTargets, i)
		end
	end
end

function Astra:_BuildWatermark()
	local WM = Instance.new("Frame")
	WM.Name = "Watermark"
	WM.Size = UDim2.new(0, 0, 0, 34)
	WM.AutomaticSize = Enum.AutomaticSize.X
	WM.Position = UDim2.new(1, -16, 0, 16)
	WM.AnchorPoint = Vector2.new(1, 0)
	WM.BackgroundColor3 = COLOR_CARD_BG
	WM.BorderSizePixel = 0
	WM.Visible = self.ShowWatermark
	WM.Parent = self.ScreenGui
	self._watermarkFrame = WM

	local WMCorner = Instance.new("UICorner")
	WMCorner.CornerRadius = UDim.new(0, 8)
	WMCorner.Parent = WM

	local WMStroke = Instance.new("UIStroke")
	WMStroke.Color = COLOR_BORDER
	WMStroke.Thickness = 1.2
	WMStroke.Parent = WM
	self:_RegisterAccent(WMStroke, "Color")

	local WMGradient = Instance.new("UIGradient")
	WMGradient.Rotation = 90
	WMGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 35)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 14, 18))
	})
	WMGradient.Parent = WM

	local WMPad = Instance.new("UIPadding")
	WMPad.PaddingLeft  = UDim.new(0, 9)
	WMPad.PaddingRight = UDim.new(0, 11)
	WMPad.Parent = WM

	local WMAccent = Instance.new("Frame")
	WMAccent.Name = "Accent"
	WMAccent.Size = UDim2.new(0, 3, 0, 18)
	WMAccent.BackgroundColor3 = self._themeColor
	WMAccent.BorderSizePixel = 0
	WMAccent.LayoutOrder = 1
	WMAccent.Parent = WM
	self:_RegisterAccent(WMAccent, "BackgroundColor3")

	local WMAccentCorner = Instance.new("UICorner")
	WMAccentCorner.CornerRadius = UDim.new(1, 0)
	WMAccentCorner.Parent = WMAccent

	local WMLayout = Instance.new("UIListLayout")
	WMLayout.SortOrder = Enum.SortOrder.LayoutOrder
	WMLayout.FillDirection = Enum.FillDirection.Horizontal
	WMLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	WMLayout.Padding = UDim.new(0, 7)
	WMLayout.Parent = WM

	local WMLogo = Instance.new("ImageLabel")
	WMLogo.Name = "Logo"
	WMLogo.Size = UDim2.new(0, 18, 0, 18)
	WMLogo.BackgroundTransparency = 1
	WMLogo.ImageColor3 = COLOR_TEXT_WHITE
	WMLogo.LayoutOrder = 2
	ApplyIcon(WMLogo, self.LogoAssetId)
	WMLogo.Visible = self._hasLogo
	WMLogo.Parent = WM
	self._watermarkLogo = WMLogo

	local WMLabel = Instance.new("TextLabel")
	WMLabel.Name = "Title"
	WMLabel.Size = UDim2.new(0, 0, 1, 0)
	WMLabel.AutomaticSize = Enum.AutomaticSize.X
	WMLabel.BackgroundTransparency = 1
	WMLabel.FontFace = FONT_BOLD
	WMLabel.Text = self.WatermarkText
	WMLabel.TextColor3 = COLOR_TEXT_WHITE
	WMLabel.TextSize = 12
	WMLabel.LayoutOrder = 3
	WMLabel.Parent = WM
	self._watermarkLabel = WMLabel

	local WMDivider = Instance.new("Frame")
	WMDivider.Name = "Divider"
	WMDivider.Size = UDim2.new(0, 1, 0, 16)
	WMDivider.BackgroundColor3 = COLOR_BORDER
	WMDivider.BorderSizePixel = 0
	WMDivider.LayoutOrder = 4
	WMDivider.Parent = WM

	local WMStatus = Instance.new("TextLabel")
	WMStatus.Name = "Status"
	WMStatus.Size = UDim2.new(0, 0, 1, 0)
	WMStatus.AutomaticSize = Enum.AutomaticSize.X
	WMStatus.BackgroundTransparency = 1
	WMStatus.FontFace = FONT_MEDIUM
	WMStatus.Text = self.WatermarkStatus
	WMStatus.TextColor3 = COLOR_TEXT_MUTED
	WMStatus.TextSize = 11
	WMStatus.LayoutOrder = 5
	WMStatus.Parent = WM
	self._watermarkStatus = WMStatus
end

function Astra:_BuildNotifContainer()
	local NC = Instance.new("Frame")
	NC.Name = "NotificationContainer"
	NC.Size = UDim2.new(0, 260, 1, -40)
	NC.Position = UDim2.new(1, -20, 1, -20)
	NC.AnchorPoint = Vector2.new(1, 1)
	NC.BackgroundTransparency = 1
	NC.Parent = self.ScreenGui
	self._notifContainer = NC

	local NL = Instance.new("UIListLayout")
	NL.SortOrder = Enum.SortOrder.LayoutOrder
	NL.VerticalAlignment = Enum.VerticalAlignment.Bottom
	NL.Padding = UDim.new(0, 8)
	NL.Parent = NC
end

function Astra:Notify(config)
	config = config or {}
	local title    = config.Title or "Notification"
	local text     = config.Text or ""
	local icon     = config.Icon or "bell"
	local duration = config.Duration or 3

	local Card = Instance.new("Frame")
	Card.Size = UDim2.new(1, 0, 0, 0)
	Card.AutomaticSize = Enum.AutomaticSize.Y
	Card.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Card.BorderSizePixel = 0
	Card.ClipsDescendants = true
	Card.BackgroundTransparency = 1
	Card.Parent = self._notifContainer

	local CC = Instance.new("UICorner")
	CC.CornerRadius = UDim.new(0, 6)
	CC.Parent = Card

	local CG = Instance.new("UIGradient")
	CG.Rotation = 90
	CG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 35)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 20))
	})
	CG.Parent = Card

	local CS = Instance.new("UIStroke")
	CS.Color = Color3.fromRGB(45, 45, 55)
	CS.Thickness = 1.2
	CS.Transparency = 1
	CS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	CS.Parent = Card

	local CP = Instance.new("UIPadding")
	CP.PaddingTop    = UDim.new(0, 10)
	CP.PaddingBottom = UDim.new(0, 18)
	CP.PaddingLeft   = UDim.new(0, 12)
	CP.PaddingRight  = UDim.new(0, 12)
	CP.Parent = Card

	local HF = Instance.new("Frame")
	HF.Size = UDim2.new(1, 0, 0, 16)
	HF.BackgroundTransparency = 1
	HF.Parent = Card

	local HL = Instance.new("UIListLayout")
	HL.SortOrder = Enum.SortOrder.LayoutOrder
	HL.FillDirection = Enum.FillDirection.Horizontal
	HL.VerticalAlignment = Enum.VerticalAlignment.Center
	HL.Padding = UDim.new(0, 8)
	HL.Parent = HF

	local NI = Instance.new("ImageLabel")
	NI.Size = UDim2.new(0, 14, 0, 14)
	NI.BackgroundTransparency = 1
	NI.ImageColor3 = COLOR_TEXT_WHITE
	NI.ImageTransparency = 1
	NI.LayoutOrder = 1
	ApplyIcon(NI, icon)
	NI.Parent = HF

	local TL = Instance.new("TextLabel")
	TL.Size = UDim2.new(1, -22, 1, 0)
	TL.BackgroundTransparency = 1
	TL.FontFace = FONT_BOLD
	TL.Text = title
	TL.TextColor3 = COLOR_TEXT_WHITE
	TL.TextTransparency = 1
	TL.TextSize = 12
	TL.TextXAlignment = Enum.TextXAlignment.Left
	TL.LayoutOrder = 2
	TL.Parent = HF

	local DL = Instance.new("TextLabel")
	DL.Size = UDim2.new(1, 0, 0, 0)
	DL.Position = UDim2.new(0, 0, 0, 20)
	DL.AutomaticSize = Enum.AutomaticSize.Y
	DL.BackgroundTransparency = 1
	DL.FontFace = FONT_REGULAR
	DL.Text = text
	DL.TextColor3 = COLOR_TEXT_MUTED
	DL.TextTransparency = 1
	DL.TextSize = 11
	DL.TextXAlignment = Enum.TextXAlignment.Left
	DL.TextWrapped = true
	DL.Parent = Card

	local PB = Instance.new("Frame")
	PB.Size = UDim2.new(1, 0, 0, 2)
	PB.Position = UDim2.new(0, 0, 1, 12)
	PB.BackgroundColor3 = COLOR_TEXT_WHITE
	PB.BorderSizePixel = 0
	PB.BackgroundTransparency = 1
	PB.Parent = Card

	local PBC = Instance.new("UICorner")
	PBC.CornerRadius = UDim.new(1, 0)
	PBC.Parent = PB

	TweenService:Create(Card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
	TweenService:Create(CS,   TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0}):Play()
	TweenService:Create(NI,   TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
	TweenService:Create(TL,   TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
	TweenService:Create(DL,   TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
	TweenService:Create(PB,   TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.4}):Play()
	TweenService:Create(PB,   TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)}):Play()

	task.delay(duration, function()
		local fo = TweenService:Create(Card, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
		TweenService:Create(CS, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Transparency = 1}):Play()
		TweenService:Create(NI, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {ImageTransparency = 1}):Play()
		TweenService:Create(TL, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
		TweenService:Create(DL, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
		TweenService:Create(PB, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
		fo:Play()
		fo.Completed:Connect(function() Card:Destroy() end)
	end)
end

function Astra:_BuildMainFrame()
	local MF = Instance.new("Frame")
	MF.Name = "MainFrame"
	MF.Size = UDim2.new(0.92, 0, 0.92, 0)
	MF.Position = UDim2.new(0.5, 0, 0.5, 0)
	MF.AnchorPoint = Vector2.new(0.5, 0.5)
	MF.BackgroundColor3 = COLOR_BG
	MF.BorderSizePixel = 0
	MF.Parent = self.ScreenGui
	self.MainFrame = MF

	local MC = Instance.new("UICorner")
	MC.CornerRadius = UDim.new(0, 10)
	MC.Parent = MF

	local MS = Instance.new("UIStroke")
	MS.Color = COLOR_BORDER
	MS.Thickness = 1.2
	MS.Parent = MF

	local AR = Instance.new("UIAspectRatioConstraint")
	AR.AspectRatio = 1.65
	AR.AspectType = Enum.AspectType.FitWithinMaxSize
	AR.DominantAxis = Enum.DominantAxis.Height
	AR.Parent = MF

	local SC = Instance.new("UISizeConstraint")
	SC.MinSize = Vector2.new(620, 360)
	SC.MaxSize = Vector2.new(1400, 900)
	SC.Parent = MF

	local function MakeDraggable(obj)
		local dragging, dragInput, dragStart, startPos = false
		obj.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = obj.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		obj.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - dragStart
				obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	end

	MakeDraggable(MF)
end

function Astra:_BuildToggleBtn()
	local TB = Instance.new("TextButton")
	TB.Name = "MobileToggleBtn"
	TB.Size = UDim2.new(0, 65, 0, 28)
	TB.Position = UDim2.new(0, 15, 0.5, -14)
	TB.BackgroundColor3 = COLOR_CARD_BG
	TB.BorderSizePixel = 0
	TB.FontFace = FONT_BOLD
	TB.Text = "Close"
	TB.TextColor3 = COLOR_TEXT_WHITE
	TB.TextSize = 12
	TB.AutoButtonColor = false
	TB.ZIndex = 100
	TB.Parent = self.ScreenGui

	local TC = Instance.new("UICorner")
	TC.CornerRadius = UDim.new(0, 6)
	TC.Parent = TB

	local TS = Instance.new("UIStroke")
	TS.Color = COLOR_BORDER
	TS.Thickness = 1.2
	TS.Parent = TB

	local function ToggleUI()
		self.MainFrame.Visible = not self.MainFrame.Visible
		TB.Text = self.MainFrame.Visible and "Close" or "Open"
	end

	TB.MouseButton1Click:Connect(ToggleUI)
	UserInputService.InputBegan:Connect(function(input, gp)
		if not gp and input.KeyCode == Enum.KeyCode.RightShift then ToggleUI() end
	end)

	local function MakeDraggable(obj)
		local dragging, dragInput, dragStart, startPos = false
		obj.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = obj.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
		obj.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - dragStart
				obj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	end
	MakeDraggable(TB)
end

function Astra:_BuildSidebar()
	local SB = Instance.new("Frame")
	SB.Name = "Sidebar"
	SB.Size = UDim2.new(0.24, 0, 1, 0)
	SB.BackgroundTransparency = 1
	SB.BorderSizePixel = 0
	SB.Parent = self.MainFrame
	self.Sidebar = SB

	local SD = Instance.new("Frame")
	SD.Size = UDim2.new(0, 1, 1, 0)
	SD.Position = UDim2.new(1, -1, 0, 0)
	SD.BackgroundColor3 = COLOR_BORDER
	SD.BorderSizePixel = 0
	SD.Parent = SB

	local TitleRow = Instance.new("Frame")
	TitleRow.Size = UDim2.new(1, -20, 0, 38)
	TitleRow.Position = UDim2.new(0, 10, 0, 6)
	TitleRow.BackgroundTransparency = 1
	TitleRow.Parent = SB

	local TitleLayout = Instance.new("UIListLayout")
	TitleLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TitleLayout.FillDirection = Enum.FillDirection.Horizontal
	TitleLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	TitleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	TitleLayout.Padding = UDim.new(0, 7)
	TitleLayout.Parent = TitleRow

	local TitleLogo = Instance.new("ImageLabel")
	TitleLogo.Name = "Logo"
	TitleLogo.Size = UDim2.new(0, 20, 0, 20)
	TitleLogo.BackgroundTransparency = 1
	TitleLogo.ImageColor3 = COLOR_TEXT_WHITE
	TitleLogo.LayoutOrder = 1
	ApplyIcon(TitleLogo, self.LogoAssetId)
	TitleLogo.Visible = self._hasLogo
	TitleLogo.Parent = TitleRow
	self._sidebarLogo = TitleLogo

	local TitleLbl = Instance.new("TextLabel")
	TitleLbl.Size = UDim2.new(0, 0, 1, 0)
	TitleLbl.AutomaticSize = Enum.AutomaticSize.X
	TitleLbl.BackgroundTransparency = 1
	TitleLbl.FontFace = FONT_BOLD
	TitleLbl.Text = self.Title
	TitleLbl.TextColor3 = COLOR_TEXT_WHITE
	TitleLbl.TextSize = 17
	TitleLbl.LayoutOrder = 2
	TitleLbl.Parent = TitleRow
	self._sidebarTitle = TitleLbl

	local SearchContainer = Instance.new("Frame")
	SearchContainer.Size = UDim2.new(1, -20, 0, 30)
	SearchContainer.Position = UDim2.new(0, 10, 0, 46)
	SearchContainer.BackgroundColor3 = COLOR_SEARCH_BG
	SearchContainer.BorderSizePixel = 0
	SearchContainer.Parent = SB

	local SCC = Instance.new("UICorner")
	SCC.CornerRadius = UDim.new(0, 6)
	SCC.Parent = SearchContainer

	local SCS = Instance.new("UIStroke")
	SCS.Color = COLOR_BORDER
	SCS.Thickness = 1
	SCS.Parent = SearchContainer

	local SI = Instance.new("ImageLabel")
	SI.Size = UDim2.new(0, 14, 0, 14)
	SI.Position = UDim2.new(0, 8, 0.5, -7)
	SI.BackgroundTransparency = 1
	SI.ImageColor3 = COLOR_TEXT_MUTED
	ApplyIcon(SI, "search")
	SI.Parent = SearchContainer

	local SearchInput = Instance.new("TextBox")
	SearchInput.Size = UDim2.new(1, -28, 1, 0)
	SearchInput.Position = UDim2.new(0, 28, 0, 0)
	SearchInput.BackgroundTransparency = 1
	SearchInput.FontFace = FONT_REGULAR
	SearchInput.PlaceholderText = "Search"
	SearchInput.PlaceholderColor3 = COLOR_TEXT_SUB
	SearchInput.Text = ""
	SearchInput.TextColor3 = COLOR_TEXT_WHITE
	SearchInput.TextSize = 13
	SearchInput.TextXAlignment = Enum.TextXAlignment.Left
	SearchInput.Parent = SearchContainer

	local SearchDivider = Instance.new("Frame")
	SearchDivider.Size = UDim2.new(1, -20, 0, 1)
	SearchDivider.Position = UDim2.new(0, 10, 0, 82)
	SearchDivider.BackgroundColor3 = COLOR_BORDER
	SearchDivider.BorderSizePixel = 0
	SearchDivider.Parent = SB

	local NavContainer = Instance.new("ScrollingFrame")
	NavContainer.Name = "NavContainer"
	NavContainer.Size = UDim2.new(1, -20, 1, -145)
	NavContainer.Position = UDim2.new(0, 10, 0, 90)
	NavContainer.BackgroundTransparency = 1
	NavContainer.BorderSizePixel = 0
	NavContainer.Active = true
	NavContainer.ScrollingEnabled = true
	NavContainer.ScrollBarThickness = 0
	NavContainer.ScrollingDirection = Enum.ScrollingDirection.Y
	NavContainer.ClipsDescendants = true
	NavContainer.Parent = SB
	self.NavContainer = NavContainer

	local NavLayout = Instance.new("UIListLayout")
	NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NavLayout.Padding = UDim.new(0, 3)
	NavLayout.Parent = NavContainer

	NavLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		NavContainer.CanvasSize = UDim2.new(0, 0, 0, NavLayout.AbsoluteContentSize.Y + 10)
	end)

	local UserDivider = Instance.new("Frame")
	UserDivider.Size = UDim2.new(1, -20, 0, 1)
	UserDivider.Position = UDim2.new(0, 10, 1, -52)
	UserDivider.BackgroundColor3 = COLOR_BORDER
	UserDivider.BorderSizePixel = 0
	UserDivider.Parent = SB

	local UserContainer = Instance.new("Frame")
	UserContainer.Size = UDim2.new(1, -20, 0, 42)
	UserContainer.Position = UDim2.new(0, 10, 1, -47)
	UserContainer.BackgroundTransparency = 1
	UserContainer.Parent = SB

	local AvatarBox = Instance.new("Frame")
	AvatarBox.Size = UDim2.new(0, 30, 0, 30)
	AvatarBox.Position = UDim2.new(0, 0, 0.5, -15)
	AvatarBox.BackgroundColor3 = COLOR_SEARCH_BG
	AvatarBox.BorderSizePixel = 0
	AvatarBox.ClipsDescendants = true
	AvatarBox.Parent = UserContainer

	local ABC = Instance.new("UICorner")
	ABC.CornerRadius = UDim.new(0, 6)
	ABC.Parent = AvatarBox

	local ABS = Instance.new("UIStroke")
	ABS.Color = COLOR_BORDER
	ABS.Thickness = 1
	ABS.Parent = AvatarBox

	local AvatarImage = Instance.new("ImageLabel")
	AvatarImage.Size = UDim2.new(1, 0, 1, 0)
	AvatarImage.BackgroundTransparency = 1
	AvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
	AvatarImage.Parent = AvatarBox

	local AIC = Instance.new("UICorner")
	AIC.CornerRadius = UDim.new(0, 6)
	AIC.Parent = AvatarImage

	task.spawn(function()
		local content, isReady = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
		if isReady and content then AvatarImage.Image = content end
	end)

	local UserTitle = Instance.new("TextLabel")
	UserTitle.Size = UDim2.new(1, -38, 0, 15)
	UserTitle.Position = UDim2.new(0, 38, 0, 5)
	UserTitle.BackgroundTransparency = 1
	UserTitle.FontFace = FONT_BOLD
	UserTitle.Text = LocalPlayer.DisplayName
	UserTitle.TextColor3 = COLOR_TEXT_WHITE
	UserTitle.TextSize = 13
	UserTitle.TextXAlignment = Enum.TextXAlignment.Left
	UserTitle.Parent = UserContainer

	local UserBadge = Instance.new("TextLabel")
	UserBadge.Size = UDim2.new(1, -38, 0, 13)
	UserBadge.Position = UDim2.new(0, 38, 0, 21)
	UserBadge.BackgroundTransparency = 1
	UserBadge.FontFace = FONT_MEDIUM
	UserBadge.Text = "BETA"
	UserBadge.TextColor3 = COLOR_TEXT_SUB
	UserBadge.TextSize = 11
	UserBadge.TextXAlignment = Enum.TextXAlignment.Left
	UserBadge.Parent = UserContainer

	SearchInput.Changed:Connect(function()
		local query = string.lower(SearchInput.Text)
		for _, tabObj in ipairs(self.TabObjects) do
			if tabObj._isSettings then continue end
			local name = string.lower(tabObj.Data.Name)
			tabObj.Btn.Visible = query == "" or string.find(name, query, 1, true) ~= nil
		end
	end)
end

function Astra:_BuildContent()
	local CF = Instance.new("Frame")
	CF.Name = "ContentFrame"
	CF.Size = UDim2.new(0.76, 0, 1, 0)
	CF.Position = UDim2.new(0.24, 0, 0, 0)
	CF.BackgroundTransparency = 1
	CF.Parent = self.MainFrame
	self.ContentFrame = CF

	local CHF = Instance.new("Frame")
	CHF.Name = "HeaderFrame"
	CHF.Size = UDim2.new(1, -24, 0, 44)
	CHF.Position = UDim2.new(0, 14, 0, 4)
	CHF.BackgroundTransparency = 1
	CHF.Parent = CF

	local HL = Instance.new("UIListLayout")
	HL.SortOrder = Enum.SortOrder.LayoutOrder
	HL.FillDirection = Enum.FillDirection.Horizontal
	HL.VerticalAlignment = Enum.VerticalAlignment.Center
	HL.Padding = UDim.new(0, 8)
	HL.Parent = CHF

	local CHI = Instance.new("ImageLabel")
	CHI.Size = UDim2.new(0, 18, 0, 18)
	CHI.BackgroundTransparency = 1
	CHI.ImageColor3 = self._themeColor
	CHI.LayoutOrder = 1
	ApplyIcon(CHI, "layout")
	CHI.Parent = CHF
	self._headerIcon = CHI
	self:_RegisterAccent(CHI, "ImageColor3")

	local CH = Instance.new("TextLabel")
	CH.Size = UDim2.new(0, 0, 1, 0)
	CH.AutomaticSize = Enum.AutomaticSize.X
	CH.BackgroundTransparency = 1
	CH.FontFace = FONT_BOLD
	CH.Text = "Tab"
	CH.TextColor3 = COLOR_TEXT_WHITE
	CH.TextSize = 17
	CH.TextXAlignment = Enum.TextXAlignment.Left
	CH.LayoutOrder = 2
	CH.Parent = CHF
	self._headerLabel = CH

	local CHD = Instance.new("Frame")
	CHD.Size = UDim2.new(1, 0, 0, 1)
	CHD.Position = UDim2.new(0, 0, 0, 48)
	CHD.BackgroundColor3 = COLOR_BORDER
	CHD.BorderSizePixel = 0
	CHD.Parent = CF

	local CA = Instance.new("Frame")
	CA.Name = "ContentArea"
	CA.Size = UDim2.new(1, -28, 1, -62)
	CA.Position = UDim2.new(0, 14, 0, 54)
	CA.BackgroundTransparency = 1
	CA.Parent = CF
	self.ContentArea = CA
end

function Astra:_UpdateHeader(title, icon)
	self._headerLabel.Text = title
	ApplyIcon(self._headerIcon, icon or "layout")
end

function Astra:_SetTabActive(tabObj, isActive)
	tabObj.Btn.BackgroundColor3 = isActive and self._themeColor or Color3.fromRGB(0, 0, 0)
	tabObj.Btn.BackgroundTransparency = isActive and 0 or 1
	tabObj.Icon.ImageColor3 = isActive and COLOR_TEXT_WHITE or COLOR_TEXT_MUTED
	tabObj.Label.TextColor3 = isActive and COLOR_TEXT_WHITE or COLOR_TEXT_MUTED
	tabObj.Label.FontFace = isActive and FONT_BOLD or FONT_MEDIUM
	if tabObj.Indicator then tabObj.Indicator.Visible = isActive end
end

function Astra:_SetSubTabActive(subObj, isActive)
	subObj.Btn.BackgroundColor3 = isActive and self._themeColor or Color3.fromRGB(0, 0, 0)
	subObj.Btn.BackgroundTransparency = isActive and 0 or 1
	subObj.Icon.ImageColor3 = isActive and COLOR_TEXT_WHITE or COLOR_TEXT_MUTED
	subObj.Label.TextColor3 = isActive and COLOR_TEXT_WHITE or COLOR_TEXT_MUTED
	subObj.Label.FontFace = isActive and FONT_BOLD or FONT_MEDIUM
	if subObj.Indicator then subObj.Indicator.Visible = isActive end
end

function Astra:AddTab(data)
	local i = #self.TabObjects + 1
	local tabObj = { Data = data, Expanded = false }

	local TabBtn = Instance.new("TextButton")
	TabBtn.Name = "Tab_" .. data.Name
	TabBtn.Size = UDim2.new(1, 0, 0, 30)
	TabBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	TabBtn.BackgroundTransparency = 1
	TabBtn.BorderSizePixel = 0
	TabBtn.AutoButtonColor = false
	TabBtn.Text = ""
	TabBtn.LayoutOrder = i * 10
	TabBtn.Parent = self.NavContainer
	tabObj.Btn = TabBtn

	local TC = Instance.new("UICorner")
	TC.CornerRadius = UDim.new(0, 6)
	TC.Parent = TabBtn

	local AI = Instance.new("Frame")
	AI.Size = UDim2.new(0, 3, 0, 16)
	AI.Position = UDim2.new(0, 0, 0.5, -8)
	AI.BackgroundColor3 = COLOR_TEXT_WHITE
	AI.BorderSizePixel = 0
	AI.Visible = false
	AI.Parent = TabBtn
	tabObj.Indicator = AI
	self:_RegisterAccent(AI, "BackgroundColor3")

	local AIC = Instance.new("UICorner")
	AIC.CornerRadius = UDim.new(0, 2)
	AIC.Parent = AI

	local TI = Instance.new("ImageLabel")
	TI.Size = UDim2.new(0, 15, 0, 15)
	TI.Position = UDim2.new(0, 10, 0.5, -7.5)
	TI.BackgroundTransparency = 1
	TI.ImageColor3 = COLOR_TEXT_MUTED
	ApplyIcon(TI, data.Icon)
	TI.Parent = TabBtn
	tabObj.Icon = TI

	local TL = Instance.new("TextLabel")
	TL.Size = UDim2.new(1, -48, 1, 0)
	TL.Position = UDim2.new(0, 32, 0, 0)
	TL.BackgroundTransparency = 1
	TL.FontFace = FONT_MEDIUM
	TL.Text = data.Name
	TL.TextColor3 = COLOR_TEXT_MUTED
	TL.TextSize = 13
	TL.TextXAlignment = Enum.TextXAlignment.Left
	TL.Parent = TabBtn
	tabObj.Label = TL

	local ContentPage = Instance.new("Frame")
	ContentPage.Name = "Page_" .. data.Name
	ContentPage.Size = UDim2.new(1, 0, 1, 0)
	ContentPage.BackgroundTransparency = 1
	ContentPage.Visible = false
	ContentPage.Parent = self.ContentArea
	tabObj.Page = ContentPage

	if data.SubTabs then
		local ChevronIcon = Instance.new("ImageLabel")
		ChevronIcon.Size = UDim2.new(0, 12, 0, 12)
		ChevronIcon.Position = UDim2.new(1, -16, 0.5, -6)
		ChevronIcon.BackgroundTransparency = 1
		ChevronIcon.ImageColor3 = COLOR_TEXT_MUTED
		ApplyIcon(ChevronIcon, "chevron-down")
		ChevronIcon.Parent = TabBtn
		tabObj.Chevron = ChevronIcon

		local SubContainer = Instance.new("Frame")
		SubContainer.Size = UDim2.new(1, 0, 0, 0)
		SubContainer.AutomaticSize = Enum.AutomaticSize.Y
		SubContainer.BackgroundTransparency = 1
		SubContainer.LayoutOrder = (i * 10) + 1
		SubContainer.Visible = false
		SubContainer.Parent = self.NavContainer
		tabObj.SubContainer = SubContainer

		local SL = Instance.new("UIListLayout")
		SL.SortOrder = Enum.SortOrder.LayoutOrder
		SL.Padding = UDim.new(0, 2)
		SL.Parent = SubContainer

		tabObj.SubObjects = {}

		for j, subData in ipairs(data.SubTabs) do
			local subObj = { Data = subData }

			local SubBtn = Instance.new("TextButton")
			SubBtn.Size = UDim2.new(1, 0, 0, 28)
			SubBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			SubBtn.BackgroundTransparency = 1
			SubBtn.BorderSizePixel = 0
			SubBtn.AutoButtonColor = false
			SubBtn.Text = ""
			SubBtn.LayoutOrder = j
			SubBtn.Parent = SubContainer
			subObj.Btn = SubBtn

			local SBC = Instance.new("UICorner")
			SBC.CornerRadius = UDim.new(0, 6)
			SBC.Parent = SubBtn

			local SBI = Instance.new("Frame")
			SBI.Size = UDim2.new(0, 3, 0, 14)
			SBI.Position = UDim2.new(0, 12, 0.5, -7)
			SBI.BackgroundColor3 = COLOR_TEXT_WHITE
			SBI.BorderSizePixel = 0
			SBI.Visible = false
			SBI.Parent = SubBtn
			subObj.Indicator = SBI
			self:_RegisterAccent(SBI, "BackgroundColor3")

			local SBIC = Instance.new("UICorner")
			SBIC.CornerRadius = UDim.new(0, 2)
			SBIC.Parent = SBI

			local SubIcon = Instance.new("ImageLabel")
			SubIcon.Size = UDim2.new(0, 13, 0, 13)
			SubIcon.Position = UDim2.new(0, 22, 0.5, -6.5)
			SubIcon.BackgroundTransparency = 1
			SubIcon.ImageColor3 = COLOR_TEXT_MUTED
			ApplyIcon(SubIcon, subData.Icon)
			SubIcon.Parent = SubBtn
			subObj.Icon = SubIcon

			local SubLabel = Instance.new("TextLabel")
			SubLabel.Size = UDim2.new(1, -44, 1, 0)
			SubLabel.Position = UDim2.new(0, 42, 0, 0)
			SubLabel.BackgroundTransparency = 1
			SubLabel.FontFace = FONT_MEDIUM
			SubLabel.Text = subData.Name
			SubLabel.TextColor3 = COLOR_TEXT_MUTED
			SubLabel.TextSize = 12
			SubLabel.TextXAlignment = Enum.TextXAlignment.Left
			SubLabel.Parent = SubBtn
			subObj.Label = SubLabel

			local SubPage = Instance.new("Frame")
			SubPage.Name = "SubPage_" .. subData.Name
			SubPage.Size = UDim2.new(1, 0, 1, 0)
			SubPage.BackgroundTransparency = 1
			SubPage.Visible = false
			SubPage.Parent = self.ContentArea
			subObj.Page = SubPage

			SubBtn.MouseButton1Click:Connect(function()
				self:_HideAllPages()
				if self.ActiveTabRef then self:_SetTabActive(self.ActiveTabRef, false) end
				if self.ActiveSubTabRef then self:_SetSubTabActive(self.ActiveSubTabRef, false) end
				self.ActiveTabRef = nil
				self.ActiveSubTabRef = subObj
				self:_SetSubTabActive(subObj, true)
				self:_UpdateHeader(data.Name .. " / " .. subData.Name, subData.Icon)
				subObj.Page.Visible = true
			end)

			table.insert(tabObj.SubObjects, subObj)
		end
	end

	TabBtn.MouseButton1Click:Connect(function()
		if data.SubTabs then
			tabObj.Expanded = not tabObj.Expanded
			tabObj.SubContainer.Visible = tabObj.Expanded
			tabObj.Chevron.Rotation = tabObj.Expanded and 180 or 0
			if tabObj.Expanded and #tabObj.SubObjects > 0 then
				local isSubActive = false
				for _, sub in ipairs(tabObj.SubObjects) do
					if sub == self.ActiveSubTabRef then isSubActive = true break end
				end
				if not isSubActive then
					self:_HideAllPages()
					if self.ActiveTabRef then self:_SetTabActive(self.ActiveTabRef, false) end
					if self.ActiveSubTabRef then self:_SetSubTabActive(self.ActiveSubTabRef, false) end
					self.ActiveTabRef = nil
					self.ActiveSubTabRef = tabObj.SubObjects[1]
					self:_SetSubTabActive(tabObj.SubObjects[1], true)
					self:_UpdateHeader(data.Name .. " / " .. tabObj.SubObjects[1].Data.Name, tabObj.SubObjects[1].Data.Icon)
					tabObj.SubObjects[1].Page.Visible = true
				end
			end
		else
			self:_HideAllPages()
			if self.ActiveTabRef then self:_SetTabActive(self.ActiveTabRef, false) end
			if self.ActiveSubTabRef then self:_SetSubTabActive(self.ActiveSubTabRef, false) end
			self.ActiveSubTabRef = nil
			self.ActiveTabRef = tabObj
			self:_SetTabActive(tabObj, true)
			self:_UpdateHeader(data.Name, data.Icon)
			tabObj.Page.Visible = true
		end
	end)

	table.insert(self.TabObjects, tabObj)
	return tabObj
end

function Astra:_HideAllPages()
	for _, child in ipairs(self.ContentArea:GetChildren()) do
		if child:IsA("Frame") then child.Visible = false end
	end
end

function Astra:SelectFirstTab()
	if #self.TabObjects > 0 then
		local first = self.TabObjects[1]
		if not first._isSettings then
			self.ActiveTabRef = first
			self:_SetTabActive(first, true)
			self:_UpdateHeader(first.Data.Name, first.Data.Icon)
			first.Page.Visible = true
		end
	end
end

function Astra:_MakeGroupboxPair(page)
	local CA = Instance.new("Frame")
	CA.Name = "ContentArea"
	CA.Size = UDim2.new(1, 0, 1, 0)
	CA.BackgroundTransparency = 1
	CA.Parent = page

	local function MakeBox(name, xPos, xSize)
		local GB = Instance.new("Frame")
		GB.Name = name
		GB.Size = UDim2.new(xSize, -6, 1, 0)
		GB.Position = UDim2.new(xPos, xPos == 0 and 0 or 6, 0, 0)
		GB.BackgroundColor3 = COLOR_CARD_BG
		GB.BorderSizePixel = 0
		GB.ClipsDescendants = true
		GB.Parent = CA

		local GBC = Instance.new("UICorner")
		GBC.CornerRadius = UDim.new(0, 8)
		GBC.Parent = GB

		local GBS = Instance.new("UIStroke")
		GBS.Color = COLOR_BORDER
		GBS.Thickness = 1.2
		GBS.Parent = GB

		local GT = Instance.new("TextLabel")
		GT.Size = UDim2.new(1, -40, 0, 34)
		GT.Position = UDim2.new(0, 12, 0, 0)
		GT.BackgroundTransparency = 1
		GT.FontFace = FONT_BOLD
		GT.Text = name
		GT.TextColor3 = COLOR_TEXT_WHITE
		GT.TextSize = 14
		GT.TextXAlignment = Enum.TextXAlignment.Left
		GT.Parent = GB

		local GD = Instance.new("Frame")
		GD.Size = UDim2.new(1, 0, 0, 1)
		GD.Position = UDim2.new(0, 0, 0, 34)
		GD.BackgroundColor3 = COLOR_BORDER
		GD.BorderSizePixel = 0
		GD.Parent = GB

		local GC = Instance.new("ScrollingFrame")
		GC.Name = "Content"
		GC.Size = UDim2.new(1, 0, 1, -35)
		GC.Position = UDim2.new(0, 0, 0, 35)
		GC.BackgroundTransparency = 1
		GC.BorderSizePixel = 0
		GC.Active = true
		GC.ScrollingEnabled = true
		GC.ScrollBarThickness = 3
		GC.ScrollBarImageColor3 = COLOR_BORDER
		GC.ScrollingDirection = Enum.ScrollingDirection.Y
		GC.ClipsDescendants = true
		GC.Parent = GB

		local GCP = Instance.new("UIPadding")
		GCP.PaddingLeft   = UDim.new(0, 12)
		GCP.PaddingRight  = UDim.new(0, 14)
		GCP.PaddingTop    = UDim.new(0, 8)
		GCP.PaddingBottom = UDim.new(0, 12)
		GCP.Parent = GC

		local GCL = Instance.new("UIListLayout")
		GCL.SortOrder = Enum.SortOrder.LayoutOrder
		GCL.Padding = UDim.new(0, 8)
		GCL.Parent = GC

		GCL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			GC.CanvasSize = UDim2.new(0, 0, 0, GCL.AbsoluteContentSize.Y + 20)
		end)

		local ToggleBtn = Instance.new("ImageButton")
		ToggleBtn.Size = UDim2.new(0, 16, 0, 16)
		ToggleBtn.Position = UDim2.new(1, -12, 0, 9)
		ToggleBtn.AnchorPoint = Vector2.new(1, 0)
		ToggleBtn.BackgroundTransparency = 1
		ToggleBtn.ImageColor3 = COLOR_TEXT_MUTED
		ApplyIcon(ToggleBtn, "chevron-down")
		ToggleBtn.Parent = GB

		local isExpanded = true
		ToggleBtn.MouseButton1Click:Connect(function()
			isExpanded = not isExpanded
			GC.Visible = isExpanded
			GD.Visible = isExpanded
			GB.Size = isExpanded and UDim2.new(xSize, -6, 1, 0) or UDim2.new(xSize, -6, 0, 35)
			ToggleBtn.Rotation = isExpanded and 0 or 180
		end)

		return GC, GT
	end

	local LeftContent, LeftTitle = MakeBox("Groupbox", 0, 0.5)
	local RightContent, RightTitle = MakeBox("Groupbox", 0.5, 0.5)

	return {
		Left = LeftContent, LeftTitle = LeftTitle,
		Right = RightContent, RightTitle = RightTitle
	}
end

function Astra:AddGroupbox(page, name, side)
	if side == "full" then
		local GB = Instance.new("Frame")
		GB.Size = UDim2.new(1, 0, 1, 0)
		GB.BackgroundColor3 = COLOR_CARD_BG
		GB.BorderSizePixel = 0
		GB.ClipsDescendants = true
		GB.Parent = page

		local GBC = Instance.new("UICorner")
		GBC.CornerRadius = UDim.new(0, 8)
		GBC.Parent = GB

		local GBS = Instance.new("UIStroke")
		GBS.Color = COLOR_BORDER
		GBS.Thickness = 1.2
		GBS.Parent = GB

		local GT = Instance.new("TextLabel")
		GT.Size = UDim2.new(1, -40, 0, 34)
		GT.Position = UDim2.new(0, 12, 0, 0)
		GT.BackgroundTransparency = 1
		GT.FontFace = FONT_BOLD
		GT.Text = name
		GT.TextColor3 = COLOR_TEXT_WHITE
		GT.TextSize = 14
		GT.TextXAlignment = Enum.TextXAlignment.Left
		GT.Parent = GB

		local GD = Instance.new("Frame")
		GD.Size = UDim2.new(1, 0, 0, 1)
		GD.Position = UDim2.new(0, 0, 0, 34)
		GD.BackgroundColor3 = COLOR_BORDER
		GD.BorderSizePixel = 0
		GD.Parent = GB

		local GC = Instance.new("ScrollingFrame")
		GC.Size = UDim2.new(1, 0, 1, -35)
		GC.Position = UDim2.new(0, 0, 0, 35)
		GC.BackgroundTransparency = 1
		GC.BorderSizePixel = 0
		GC.Active = true
		GC.ScrollingEnabled = true
		GC.ScrollBarThickness = 3
		GC.ScrollBarImageColor3 = COLOR_BORDER
		GC.ScrollingDirection = Enum.ScrollingDirection.Y
		GC.ClipsDescendants = true
		GC.Parent = GB

		local GCP = Instance.new("UIPadding")
		GCP.PaddingLeft   = UDim.new(0, 12)
		GCP.PaddingRight  = UDim.new(0, 14)
		GCP.PaddingTop    = UDim.new(0, 8)
		GCP.PaddingBottom = UDim.new(0, 12)
		GCP.Parent = GC

		local GCL = Instance.new("UIListLayout")
		GCL.SortOrder = Enum.SortOrder.LayoutOrder
		GCL.Padding = UDim.new(0, 8)
		GCL.Parent = GC

		GCL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			GC.CanvasSize = UDim2.new(0, 0, 0, GCL.AbsoluteContentSize.Y + 20)
		end)

		return GC
	end
end

function Astra:CreateLabel(parent, labelText)
	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, 0, 0, 18)
	Container.BackgroundTransparency = 1
	Container.Parent = parent

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, 0, 1, 0)
	Label.BackgroundTransparency = 1
	Label.FontFace = FONT_MEDIUM
	Label.Text = labelText
	Label.TextColor3 = COLOR_TEXT_MUTED
	Label.TextSize = 12
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Container

	return Container, Label
end

function Astra:CreateCheckbox(parent, labelText, defaultState, callback)
	local state = defaultState or false

	local ToggleBtn = Instance.new("TextButton")
	ToggleBtn.Size = UDim2.new(1, 0, 0, 22)
	ToggleBtn.BackgroundTransparency = 1
	ToggleBtn.Text = ""
	ToggleBtn.AutoButtonColor = false
	ToggleBtn.Parent = parent

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -24, 1, 0)
	Label.BackgroundTransparency = 1
	Label.FontFace = FONT_MEDIUM
	Label.Text = labelText
	Label.TextColor3 = state and COLOR_TEXT_WHITE or COLOR_TEXT_MUTED
	Label.TextSize = 12
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = ToggleBtn

	local Box = Instance.new("Frame")
	Box.Size = UDim2.new(0, 16, 0, 16)
	Box.Position = UDim2.new(1, 0, 0.5, 0)
	Box.AnchorPoint = Vector2.new(1, 0.5)
	Box.BackgroundColor3 = state and self._themeColor or COLOR_BOX_INACTIVE
	Box.BorderSizePixel = 0
	Box.Parent = ToggleBtn

	local BC = Instance.new("UICorner")
	BC.CornerRadius = UDim.new(0, 4)
	BC.Parent = Box

	local BS = Instance.new("UIStroke")
	BS.Color = state and self._themeColor or COLOR_BOX_BORDER
	BS.Thickness = 1
	BS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	BS.Parent = Box

	local CI = Instance.new("ImageLabel")
	CI.Size = UDim2.new(0, 10, 0, 10)
	CI.Position = UDim2.new(0.5, 0, 0.5, 0)
	CI.AnchorPoint = Vector2.new(0.5, 0.5)
	CI.BackgroundTransparency = 1
	CI.ImageColor3 = COLOR_BG
	CI.ImageTransparency = state and 0 or 1
	ApplyIcon(CI, "check")
	CI.Parent = Box

	local function UpdateState()
		Box.BackgroundColor3 = state and self._themeColor or COLOR_BOX_INACTIVE
		BS.Color = state and self._themeColor or COLOR_BOX_BORDER
		CI.ImageTransparency = state and 0 or 1
		Label.TextColor3 = state and COLOR_TEXT_WHITE or COLOR_TEXT_MUTED
	end

	ToggleBtn.MouseButton1Click:Connect(function()
		state = not state
		UpdateState()
		if callback then callback(state) end
	end)

	table.insert(self._checkboxAccentTargets, {
		Box = Box,
		Stroke = BS,
		GetState = function() return state end
	})

	return ToggleBtn, function(v)
		state = v
		UpdateState()
	end
end

function Astra:CreateSlider(parent, labelText, min, max, default, callback)
	local value = math.clamp(default or min, min, max)
	local dragging = false

	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, 0, 0, 34)
	Container.BackgroundTransparency = 1
	Container.Parent = parent

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(0.6, 0, 0, 16)
	Label.BackgroundTransparency = 1
	Label.FontFace = FONT_MEDIUM
	Label.Text = labelText
	Label.TextColor3 = COLOR_TEXT_WHITE
	Label.TextSize = 12
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Container

	local ValueLabel = Instance.new("TextLabel")
	ValueLabel.Size = UDim2.new(0.4, 0, 0, 16)
	ValueLabel.Position = UDim2.new(1, 0, 0, 0)
	ValueLabel.AnchorPoint = Vector2.new(1, 0)
	ValueLabel.BackgroundTransparency = 1
	ValueLabel.FontFace = FONT_REGULAR
	ValueLabel.Text = tostring(value)
	ValueLabel.TextColor3 = COLOR_TEXT_MUTED
	ValueLabel.TextSize = 11
	ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
	ValueLabel.Parent = Container

	local Track = Instance.new("Frame")
	Track.Size = UDim2.new(1, 0, 0, 4)
	Track.Position = UDim2.new(0, 0, 0, 22)
	Track.BackgroundColor3 = COLOR_BOX_INACTIVE
	Track.BorderSizePixel = 0
	Track.Parent = Container

	local TCC = Instance.new("UICorner")
	TCC.CornerRadius = UDim.new(1, 0)
	TCC.Parent = Track

	local TCS = Instance.new("UIStroke")
	TCS.Color = COLOR_BORDER
	TCS.Thickness = 1
	TCS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	TCS.Parent = Track

	local Fill = Instance.new("Frame")
	Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
	Fill.BackgroundColor3 = self._themeColor
	Fill.BorderSizePixel = 0
	Fill.Parent = Track
	self:_RegisterAccent(Fill, "BackgroundColor3")

	local FC = Instance.new("UICorner")
	FC.CornerRadius = UDim.new(1, 0)
	FC.Parent = Fill

	local function UpdateSlider(input)
		local posX = math.clamp(input.Position.X - Track.AbsolutePosition.X, 0, Track.AbsoluteSize.X)
		local pct = math.clamp(posX / Track.AbsoluteSize.X, 0, 1)
		value = math.floor(min + (max - min) * pct + 0.5)
		Fill.Size = UDim2.new(pct, 0, 1, 0)
		ValueLabel.Text = tostring(value)
		if callback then callback(value) end
	end

	Track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			UpdateSlider(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			UpdateSlider(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return Container
end

function Astra:CreateInput(parent, labelText, placeholderText, defaultText, callback)
	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, 0, 0, 48)
	Container.BackgroundTransparency = 1
	Container.Parent = parent

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, 0, 0, 16)
	Label.BackgroundTransparency = 1
	Label.FontFace = FONT_MEDIUM
	Label.Text = labelText
	Label.TextColor3 = COLOR_TEXT_WHITE
	Label.TextSize = 12
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Container

	local BoxContainer = Instance.new("Frame")
	BoxContainer.Size = UDim2.new(1, 0, 0, 24)
	BoxContainer.Position = UDim2.new(0, 0, 0, 18)
	BoxContainer.BackgroundColor3 = COLOR_BOX_INACTIVE
	BoxContainer.BorderSizePixel = 0
	BoxContainer.Parent = Container

	local BCC = Instance.new("UICorner")
	BCC.CornerRadius = UDim.new(0, 5)
	BCC.Parent = BoxContainer

	local BCS = Instance.new("UIStroke")
	BCS.Color = COLOR_BOX_BORDER
	BCS.Thickness = 1
	BCS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	BCS.Parent = BoxContainer

	local TextBox = Instance.new("TextBox")
	TextBox.Size = UDim2.new(1, -16, 1, 0)
	TextBox.Position = UDim2.new(0, 8, 0, 0)
	TextBox.BackgroundTransparency = 1
	TextBox.FontFace = FONT_REGULAR
	TextBox.PlaceholderText = placeholderText or "Type here..."
	TextBox.PlaceholderColor3 = COLOR_TEXT_SUB
	TextBox.Text = defaultText or ""
	TextBox.TextColor3 = COLOR_TEXT_WHITE
	TextBox.TextSize = 11
	TextBox.TextXAlignment = Enum.TextXAlignment.Left
	TextBox.ClearTextOnFocus = false
	TextBox.Parent = BoxContainer

	TextBox.Focused:Connect(function() BCS.Color = COLOR_TEXT_WHITE end)
	TextBox.FocusLost:Connect(function(enterPressed)
		BCS.Color = COLOR_BOX_BORDER
		if callback then callback(TextBox.Text, enterPressed) end
	end)

	return Container, TextBox
end

function Astra:CreateDropdown(parent, labelText, options, default, callback)
	local selected = default or (options and options[1]) or "None"
	local isOpen = false

	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, 0, 0, 48)
	Container.BackgroundTransparency = 1
	Container.Parent = parent

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, 0, 0, 16)
	Label.BackgroundTransparency = 1
	Label.FontFace = FONT_MEDIUM
	Label.Text = labelText
	Label.TextColor3 = COLOR_TEXT_MUTED
	Label.TextSize = 12
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Container

	local Header = Instance.new("TextButton")
	Header.Size = UDim2.new(1, 0, 0, 26)
	Header.Position = UDim2.new(0, 0, 0, 18)
	Header.BackgroundColor3 = COLOR_BOX_INACTIVE
	Header.BorderSizePixel = 0
	Header.AutoButtonColor = false
	Header.Text = ""
	Header.Parent = Container

	local HC = Instance.new("UICorner")
	HC.CornerRadius = UDim.new(0, 5)
	HC.Parent = Header

	local HS = Instance.new("UIStroke")
	HS.Color = COLOR_BOX_BORDER
	HS.Thickness = 1
	HS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	HS.Parent = Header

	local SelectedText = Instance.new("TextLabel")
	SelectedText.Size = UDim2.new(1, -28, 1, 0)
	SelectedText.Position = UDim2.new(0, 8, 0, 0)
	SelectedText.BackgroundTransparency = 1
	SelectedText.FontFace = FONT_MEDIUM
	SelectedText.Text = selected
	SelectedText.TextColor3 = COLOR_TEXT_WHITE
	SelectedText.TextSize = 12
	SelectedText.TextXAlignment = Enum.TextXAlignment.Left
	SelectedText.Parent = Header

	local Chevron = Instance.new("ImageLabel")
	Chevron.Size = UDim2.new(0, 12, 0, 12)
	Chevron.Position = UDim2.new(1, -8, 0.5, 0)
	Chevron.AnchorPoint = Vector2.new(1, 0.5)
	Chevron.BackgroundTransparency = 1
	Chevron.ImageColor3 = COLOR_TEXT_MUTED
	ApplyIcon(Chevron, "chevron-down")
	Chevron.Parent = Header

	local OptionHolder = Instance.new("Frame")
	OptionHolder.Size = UDim2.new(1, 0, 0, 0)
	OptionHolder.Position = UDim2.new(0, 0, 0, 48)
	OptionHolder.BackgroundColor3 = COLOR_BOX_INACTIVE
	OptionHolder.BorderSizePixel = 0
	OptionHolder.Visible = false
	OptionHolder.ClipsDescendants = true
	OptionHolder.ZIndex = 10
	OptionHolder.Parent = Container

	local OHC = Instance.new("UICorner")
	OHC.CornerRadius = UDim.new(0, 5)
	OHC.Parent = OptionHolder

	local OHS = Instance.new("UIStroke")
	OHS.Color = COLOR_BOX_BORDER
	OHS.Thickness = 1
	OHS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	OHS.Parent = OptionHolder

	local OHL = Instance.new("UIListLayout")
	OHL.SortOrder = Enum.SortOrder.LayoutOrder
	OHL.Padding = UDim.new(0, 2)
	OHL.Parent = OptionHolder

	local OHP = Instance.new("UIPadding")
	OHP.PaddingTop    = UDim.new(0, 4)
	OHP.PaddingBottom = UDim.new(0, 4)
	OHP.PaddingLeft   = UDim.new(0, 4)
	OHP.PaddingRight  = UDim.new(0, 4)
	OHP.Parent = OptionHolder

	local optionButtons = {}
	local currentOptions = options or {}

	local function RebuildOptions()
		for _, v in ipairs(optionButtons) do v:Destroy() end
		optionButtons = {}
		for _, opt in ipairs(currentOptions) do
			local OB = Instance.new("TextButton")
			OB.Size = UDim2.new(1, 0, 0, 22)
			OB.BackgroundColor3 = COLOR_ACTIVE_BG
			OB.BackgroundTransparency = (opt == selected) and 0 or 1
			OB.BorderSizePixel = 0
			OB.FontFace = FONT_REGULAR
			OB.Text = opt
			OB.TextColor3 = (opt == selected) and COLOR_TEXT_WHITE or COLOR_TEXT_MUTED
			OB.TextSize = 11
			OB.TextXAlignment = Enum.TextXAlignment.Left
			OB.AutoButtonColor = false
			OB.Parent = OptionHolder

			local OBP = Instance.new("UIPadding")
			OBP.PaddingLeft = UDim.new(0, 6)
			OBP.Parent = OB

			local OBC = Instance.new("UICorner")
			OBC.CornerRadius = UDim.new(0, 4)
			OBC.Parent = OB

			OB.MouseEnter:Connect(function() OB.BackgroundTransparency = 0; OB.TextColor3 = COLOR_TEXT_WHITE end)
			OB.MouseLeave:Connect(function()
				if OB.Text ~= selected then OB.BackgroundTransparency = 1; OB.TextColor3 = COLOR_TEXT_MUTED end
			end)
			OB.MouseButton1Click:Connect(function()
				selected = opt
				SelectedText.Text = selected
				isOpen = false
				OptionHolder.Visible = false
				Chevron.Rotation = 0
				HS.Color = COLOR_BOX_BORDER
				Container.Size = UDim2.new(1, 0, 0, 48)
				for _, child in ipairs(OptionHolder:GetChildren()) do
					if child:IsA("TextButton") then
						local isSel = (child.Text == selected)
						child.BackgroundTransparency = isSel and 0 or 1
						child.TextColor3 = isSel and COLOR_TEXT_WHITE or COLOR_TEXT_MUTED
					end
				end
				if callback then callback(selected) end
			end)
			table.insert(optionButtons, OB)
		end
	end

	local function ToggleList()
		isOpen = not isOpen
		OptionHolder.Visible = isOpen
		Chevron.Rotation = isOpen and 180 or 0
		HS.Color = isOpen and COLOR_TEXT_WHITE or COLOR_BOX_BORDER
		if isOpen then
			local totalHeight = (#currentOptions * 24) + 8
			OptionHolder.Size = UDim2.new(1, 0, 0, math.min(totalHeight, 120))
			Container.Size = UDim2.new(1, 0, 0, 48 + math.min(totalHeight, 120) + 4)
		else
			Container.Size = UDim2.new(1, 0, 0, 48)
		end
	end

	Header.MouseButton1Click:Connect(ToggleList)
	RebuildOptions()

	local api = {}
	function api:SetOptions(newOptions)
		currentOptions = newOptions
		if not table.find(currentOptions, selected) then
			selected = currentOptions[1] or "None"
			SelectedText.Text = selected
		end
		RebuildOptions()
	end
	function api:GetSelected() return selected end
	function api:SetSelected(val)
		selected = val
		SelectedText.Text = val
	end

	return Container, api
end

function Astra:CreateButton(parent, buttonText, callback)
	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, 0, 0, 24)
	Container.BackgroundTransparency = 1
	Container.Parent = parent

	local BtnBg = Instance.new("Frame")
	BtnBg.Size = UDim2.new(1, 0, 1, 0)
	BtnBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	BtnBg.BorderSizePixel = 0
	BtnBg.Parent = Container

	local BtnC = Instance.new("UICorner")
	BtnC.CornerRadius = UDim.new(0, 5)
	BtnC.Parent = BtnBg

	local BtnG = Instance.new("UIGradient")
	BtnG.Rotation = 90
	BtnG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 35)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 20))
	})
	BtnG.Parent = BtnBg

	local BtnS = Instance.new("UIStroke")
	BtnS.Color = Color3.fromRGB(45, 45, 55)
	BtnS.Thickness = 1.2
	BtnS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	BtnS.Parent = BtnBg

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, 0, 1, 0)
	Button.BackgroundTransparency = 1
	Button.FontFace = FONT_MEDIUM
	Button.Text = string.lower(buttonText)
	Button.TextColor3 = COLOR_TEXT_WHITE
	Button.TextScaled = true
	Button.AutoButtonColor = false
	Button.Parent = Container

	local TC = Instance.new("UITextSizeConstraint")
	TC.MaxTextSize = 13
	TC.MinTextSize = 8
	TC.Parent = Button

	local BP = Instance.new("UIPadding")
	BP.PaddingTop    = UDim.new(0, 4)
	BP.PaddingBottom = UDim.new(0, 4)
	BP.Parent = Button

	Button.MouseEnter:Connect(function()
		BtnG.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 38, 48)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 24, 30))
		})
		BtnS.Color = Color3.fromRGB(65, 65, 80)
	end)
	Button.MouseLeave:Connect(function()
		BtnG.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 35)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 20))
		})
		BtnS.Color = Color3.fromRGB(45, 45, 55)
	end)
	Button.MouseButton1Down:Connect(function()
		BtnG.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 25)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 16))
		})
	end)
	Button.MouseButton1Up:Connect(function()
		BtnG.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 38, 48)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 24, 30))
		})
	end)
	Button.MouseButton1Click:Connect(function()
		if callback then callback() end
	end)

	return Container
end

function Astra:CreateKeybind(parent, labelText, defaultKey, callback)
	local boundKey = defaultKey or Enum.UserInputType.MouseButton3
	local binding = false

	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, 0, 0, 22)
	Container.BackgroundTransparency = 1
	Container.Parent = parent

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -60, 1, 0)
	Label.BackgroundTransparency = 1
	Label.FontFace = FONT_MEDIUM
	Label.Text = labelText
	Label.TextColor3 = COLOR_TEXT_MUTED
	Label.TextSize = 12
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Container

	local KBH = Instance.new("Frame")
	KBH.Size = UDim2.new(0, 36, 0, 20)
	KBH.Position = UDim2.new(1, 0, 0.5, 0)
	KBH.AnchorPoint = Vector2.new(1, 0.5)
	KBH.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	KBH.BorderSizePixel = 0
	KBH.Parent = Container

	local KBHC = Instance.new("UICorner")
	KBHC.CornerRadius = UDim.new(0, 5)
	KBHC.Parent = KBH

	local KBHG = Instance.new("UIGradient")
	KBHG.Rotation = 90
	KBHG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 35)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 20))
	})
	KBHG.Parent = KBH

	local KBHS = Instance.new("UIStroke")
	KBHS.Color = Color3.fromRGB(45, 45, 55)
	KBHS.Thickness = 1.2
	KBHS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	KBHS.Parent = KBH

	local KeyBtn = Instance.new("TextButton")
	KeyBtn.Size = UDim2.new(1, 0, 1, 0)
	KeyBtn.BackgroundTransparency = 1
	KeyBtn.FontFace = FONT_BOLD
	KeyBtn.TextSize = 11
	KeyBtn.TextColor3 = COLOR_TEXT_WHITE
	KeyBtn.AutoButtonColor = false
	KeyBtn.Parent = KBH

	local function FormatKey(key)
		if not key then return "None" end
		if typeof(key) == "EnumItem" then
			if key.EnumType == Enum.KeyCode then
				if key == Enum.KeyCode.Unknown then return "None" end
				return key.Name
			elseif key.EnumType == Enum.UserInputType then
				if key == Enum.UserInputType.MouseButton1 then return "M1" end
				if key == Enum.UserInputType.MouseButton2 then return "M2" end
				if key == Enum.UserInputType.MouseButton3 then return "M3" end
				if key == Enum.UserInputType.MouseButton4 then return "M4" end
				if key == Enum.UserInputType.MouseButton5 then return "M5" end
			end
		end
		return tostring(key)
	end

	local function UpdateText()
		if binding then
			KeyBtn.Text = "..."
			KBHS.Color = COLOR_TEXT_WHITE
			KBHG.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 38, 48)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 24, 30))
			})
			Label.TextColor3 = COLOR_TEXT_WHITE
		else
			KeyBtn.Text = FormatKey(boundKey)
			KBHS.Color = Color3.fromRGB(45, 45, 55)
			KBHG.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 35)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 20))
			})
			Label.TextColor3 = COLOR_TEXT_MUTED
		end
		local ts = TextService:GetTextSize(KeyBtn.Text, 11, Enum.Font.SourceSans, Vector2.new(120, 20))
		KBH.Size = UDim2.new(0, math.max(34, ts.X + 14), 0, 20)
	end

	UpdateText()

	KeyBtn.MouseEnter:Connect(function()
		if not binding then
			KBHG.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 38, 48)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 24, 30))
			})
			KBHS.Color = Color3.fromRGB(65, 65, 80)
		end
	end)
	KeyBtn.MouseLeave:Connect(function()
		if not binding then
			KBHG.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 35)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 20))
			})
			KBHS.Color = Color3.fromRGB(45, 45, 55)
		end
	end)
	KeyBtn.MouseButton1Click:Connect(function()
		binding = true
		UpdateText()
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if binding then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				boundKey = input.KeyCode == Enum.KeyCode.Escape and nil or input.KeyCode
				binding = false
				UpdateText()
				if callback then callback(boundKey) end
			elseif string.find(input.UserInputType.Name, "MouseButton") then
				boundKey = input.UserInputType
				binding = false
				UpdateText()
				if callback then callback(boundKey) end
			end
		end
	end)

	return Container
end

function Astra:CreateColorPicker(parent, labelText, defaultColor, callback)
	local color = defaultColor or Color3.fromRGB(0, 230, 150)
	local h, s, v = color:ToHSV()
	local isOpen = false

	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, 0, 0, 24)
	Container.BackgroundTransparency = 1
	Container.Parent = parent

	local TopHeader = Instance.new("Frame")
	TopHeader.Size = UDim2.new(1, 0, 0, 24)
	TopHeader.BackgroundTransparency = 1
	TopHeader.Parent = Container

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -45, 1, 0)
	Label.BackgroundTransparency = 1
	Label.FontFace = FONT_MEDIUM
	Label.Text = labelText
	Label.TextColor3 = COLOR_TEXT_MUTED
	Label.TextSize = 12
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = TopHeader

	local CPB = Instance.new("TextButton")
	CPB.Size = UDim2.new(0, 32, 0, 16)
	CPB.Position = UDim2.new(1, 0, 0.5, 0)
	CPB.AnchorPoint = Vector2.new(1, 0.5)
	CPB.BackgroundColor3 = color
	CPB.BorderSizePixel = 0
	CPB.Text = ""
	CPB.AutoButtonColor = false
	CPB.Parent = TopHeader

	local CPBC = Instance.new("UICorner")
	CPBC.CornerRadius = UDim.new(0, 4)
	CPBC.Parent = CPB

	local CPBS = Instance.new("UIStroke")
	CPBS.Color = COLOR_BOX_BORDER
	CPBS.Thickness = 1
	CPBS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	CPBS.Parent = CPB

	local PP = Instance.new("Frame")
	PP.Size = UDim2.new(1, 0, 0, 142)
	PP.Position = UDim2.new(0, 0, 0, 28)
	PP.BackgroundColor3 = COLOR_BOX_INACTIVE
	PP.BorderSizePixel = 0
	PP.Visible = false
	PP.ClipsDescendants = true
	PP.ZIndex = 12
	PP.Parent = Container

	local PPC = Instance.new("UICorner")
	PPC.CornerRadius = UDim.new(0, 6)
	PPC.Parent = PP

	local PPS = Instance.new("UIStroke")
	PPS.Color = COLOR_BOX_BORDER
	PPS.Thickness = 1
	PPS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	PPS.Parent = PP

	local SVBox = Instance.new("Frame")
	SVBox.Size = UDim2.new(1, -36, 0, 95)
	SVBox.Position = UDim2.new(0, 8, 0, 8)
	SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
	SVBox.BorderSizePixel = 0
	SVBox.Parent = PP

	local SVBC = Instance.new("UICorner")
	SVBC.CornerRadius = UDim.new(0, 4)
	SVBC.Parent = SVBox

	local WGF = Instance.new("Frame")
	WGF.Size = UDim2.new(1, 0, 1, 0)
	WGF.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	WGF.BorderSizePixel = 0
	WGF.Parent = SVBox

	local WGFC = Instance.new("UICorner")
	WGFC.CornerRadius = UDim.new(0, 4)
	WGFC.Parent = WGF

	local WG = Instance.new("UIGradient")
	WG.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
	WG.Parent = WGF

	local BGF = Instance.new("Frame")
	BGF.Size = UDim2.new(1, 0, 1, 0)
	BGF.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	BGF.BorderSizePixel = 0
	BGF.Parent = SVBox

	local BGFC = Instance.new("UICorner")
	BGFC.CornerRadius = UDim.new(0, 4)
	BGFC.Parent = BGF

	local BG = Instance.new("UIGradient")
	BG.Rotation = 90
	BG.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})
	BG.Parent = BGF

	local SVC = Instance.new("Frame")
	SVC.Size = UDim2.new(0, 10, 0, 10)
	SVC.AnchorPoint = Vector2.new(0.5, 0.5)
	SVC.Position = UDim2.new(s, 0, 1 - v, 0)
	SVC.BackgroundColor3 = color
	SVC.BorderSizePixel = 0
	SVC.ZIndex = 2
	SVC.Parent = SVBox

	local SVCC = Instance.new("UICorner")
	SVCC.CornerRadius = UDim.new(1, 0)
	SVCC.Parent = SVC

	local SVCS = Instance.new("UIStroke")
	SVCS.Color = Color3.fromRGB(255, 255, 255)
	SVCS.Thickness = 1.5
	SVCS.Parent = SVC

	local HueBar = Instance.new("Frame")
	HueBar.Size = UDim2.new(0, 12, 0, 95)
	HueBar.Position = UDim2.new(1, -18, 0, 8)
	HueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	HueBar.BorderSizePixel = 0
	HueBar.Parent = PP

	local HBC = Instance.new("UICorner")
	HBC.CornerRadius = UDim.new(0, 4)
	HBC.Parent = HueBar

	local HBG = Instance.new("UIGradient")
	HBG.Rotation = 90
	HBG.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
	})
	HBG.Parent = HueBar

	local HC = Instance.new("Frame")
	HC.Size = UDim2.new(1, 4, 0, 4)
	HC.AnchorPoint = Vector2.new(0.5, 0.5)
	HC.Position = UDim2.new(0.5, 0, h, 0)
	HC.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	HC.BorderSizePixel = 0
	HC.ZIndex = 2
	HC.Parent = HueBar

	local HCC = Instance.new("UICorner")
	HCC.CornerRadius = UDim.new(1, 0)
	HCC.Parent = HC

	local HCS = Instance.new("UIStroke")
	HCS.Color = Color3.fromRGB(0, 0, 0)
	HCS.Thickness = 1
	HCS.Parent = HC

	local CVB = Instance.new("TextBox")
	CVB.Size = UDim2.new(1, -16, 0, 22)
	CVB.Position = UDim2.new(0, 8, 0, 110)
	CVB.BackgroundColor3 = COLOR_SEARCH_BG
	CVB.BorderSizePixel = 0
	CVB.FontFace = FONT_MEDIUM
	CVB.Text = string.format("rgb(%d, %d, %d)", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
	CVB.TextColor3 = COLOR_TEXT_WHITE
	CVB.TextSize = 11
	CVB.ClearTextOnFocus = false
	CVB.Parent = PP

	local CVBC = Instance.new("UICorner")
	CVBC.CornerRadius = UDim.new(0, 4)
	CVBC.Parent = CVB

	local CVBS = Instance.new("UIStroke")
	CVBS.Color = COLOR_BOX_BORDER
	CVBS.Thickness = 1
	CVBS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	CVBS.Parent = CVB

	local function UpdateColor()
		color = Color3.fromHSV(h, s, v)
		SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		SVC.Position = UDim2.new(s, 0, 1 - v, 0)
		SVC.BackgroundColor3 = color
		HC.Position = UDim2.new(0.5, 0, h, 0)
		CPB.BackgroundColor3 = color
		CVB.Text = string.format("rgb(%d, %d, %d)", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
		if callback then callback(color) end
	end

	local draggingSV, draggingHue = false, false

	local function UpdateSV(input)
		local px = math.clamp(input.Position.X - SVBox.AbsolutePosition.X, 0, SVBox.AbsoluteSize.X)
		local py = math.clamp(input.Position.Y - SVBox.AbsolutePosition.Y, 0, SVBox.AbsoluteSize.Y)
		s = px / SVBox.AbsoluteSize.X
		v = 1 - (py / SVBox.AbsoluteSize.Y)
		UpdateColor()
	end

	local function UpdateHue(input)
		local py = math.clamp(input.Position.Y - HueBar.AbsolutePosition.Y, 0, HueBar.AbsoluteSize.Y)
		h = py / HueBar.AbsoluteSize.Y
		UpdateColor()
	end

	SVBox.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSV = true; UpdateSV(input)
		end
	end)
	HueBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingHue = true; UpdateHue(input)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if draggingSV then UpdateSV(input) end
			if draggingHue then UpdateHue(input) end
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSV = false; draggingHue = false
		end
	end)

	CVB.FocusLost:Connect(function()
		local r, g, b = CVB.Text:match("rgb%s*%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)")
		if r and g and b then
			color = Color3.fromRGB(math.clamp(tonumber(r), 0, 255), math.clamp(tonumber(g), 0, 255), math.clamp(tonumber(b), 0, 255))
			h, s, v = color:ToHSV()
			UpdateColor()
		else
			local hex = CVB.Text:gsub("#", "")
			if #hex == 6 then
				local hr, hg, hb = tonumber(hex:sub(1,2), 16), tonumber(hex:sub(3,4), 16), tonumber(hex:sub(5,6), 16)
				if hr and hg and hb then
					color = Color3.fromRGB(hr, hg, hb)
					h, s, v = color:ToHSV()
					UpdateColor()
				end
			end
		end
	end)

	CPB.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		PP.Visible = isOpen
		Container.Size = isOpen and UDim2.new(1, 0, 0, 172) or UDim2.new(1, 0, 0, 24)
	end)

	return Container, function(c)
		color = c
		h, s, v = c:ToHSV()
		UpdateColor()
	end
end

function Astra:_GetConfigList()
	local list = {}
	pcall(function()
		for _, name in ipairs(listfiles(self.ConfigFolder)) do
			local clean = name:match("([^/\\]+)%.json$") or name:match("([^/\\]+)%.txt$")
			if clean then table.insert(list, clean) end
		end
	end)
	return list
end

function Astra:SaveConfig(name)
	if not name or name == "" then return false, "No name provided" end
	local data = { _autoload = self._autoloadFile == name }
	local path = self.ConfigFolder .. "/" .. name .. ".json"
	pcall(function() writefile(path, game:GetService("HttpService"):JSONEncode(data)) end)
	return true
end

function Astra:LoadConfig(name)
	if not name or name == "" then return false end
	local path = self.ConfigFolder .. "/" .. name .. ".json"
	local ok, content = pcall(readfile, path)
	if not ok then return false end
	pcall(function()
		game:GetService("HttpService"):JSONDecode(content)
	end)
	return true
end

function Astra:SetAutoload(name)
	self._autoloadFile = name
	local marker = self.ConfigFolder .. "/_autoload.txt"
	pcall(function() writefile(marker, name or "") end)
end

function Astra:_LoadAutoload()
	local marker = self.ConfigFolder .. "/_autoload.txt"
	local ok, name = pcall(readfile, marker)
	if ok and name and name ~= "" then
		self._autoloadFile = name
		self:LoadConfig(name)
	end
end

function Astra:_BuildSettingsTab()
	local settingsData = { Name = "UI Settings", Icon = "settings" }
	local i = 999

	local TabBtn = Instance.new("TextButton")
	TabBtn.Name = "Tab_UISettings"
	TabBtn.Size = UDim2.new(1, 0, 0, 30)
	TabBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	TabBtn.BackgroundTransparency = 1
	TabBtn.BorderSizePixel = 0
	TabBtn.AutoButtonColor = false
	TabBtn.Text = ""
	TabBtn.LayoutOrder = i * 10
	TabBtn.Parent = self.NavContainer

	local STC = Instance.new("UICorner")
	STC.CornerRadius = UDim.new(0, 6)
	STC.Parent = TabBtn

	local STI_frame = Instance.new("Frame")
	STI_frame.Size = UDim2.new(0, 3, 0, 16)
	STI_frame.Position = UDim2.new(0, 0, 0.5, -8)
	STI_frame.BackgroundColor3 = COLOR_TEXT_WHITE
	STI_frame.BorderSizePixel = 0
	STI_frame.Visible = false
	STI_frame.Parent = TabBtn
	self:_RegisterAccent(STI_frame, "BackgroundColor3")

	local STIC = Instance.new("UICorner")
	STIC.CornerRadius = UDim.new(0, 2)
	STIC.Parent = STI_frame

	local STIcon = Instance.new("ImageLabel")
	STIcon.Size = UDim2.new(0, 15, 0, 15)
	STIcon.Position = UDim2.new(0, 10, 0.5, -7.5)
	STIcon.BackgroundTransparency = 1
	STIcon.ImageColor3 = COLOR_TEXT_MUTED
	ApplyIcon(STIcon, "settings")
	STIcon.Parent = TabBtn

	local STLabel = Instance.new("TextLabel")
	STLabel.Size = UDim2.new(1, -48, 1, 0)
	STLabel.Position = UDim2.new(0, 32, 0, 0)
	STLabel.BackgroundTransparency = 1
	STLabel.FontFace = FONT_MEDIUM
	STLabel.Text = "UI Settings"
	STLabel.TextColor3 = COLOR_TEXT_MUTED
	STLabel.TextSize = 13
	STLabel.TextXAlignment = Enum.TextXAlignment.Left
	STLabel.Parent = TabBtn

	local settingsTabObj = {
		Data = settingsData,
		Btn = TabBtn,
		Icon = STIcon,
		Label = STLabel,
		Indicator = STI_frame,
		_isSettings = true
	}

	local Page = Instance.new("Frame")
	Page.Size = UDim2.new(1, 0, 1, 0)
	Page.BackgroundTransparency = 1
	Page.Visible = false
	Page.Parent = self.ContentArea
	settingsTabObj.Page = Page

	local CA = Instance.new("Frame")
	CA.Size = UDim2.new(1, 0, 1, 0)
	CA.BackgroundTransparency = 1
	CA.Parent = Page

	local function MakeSettingsBox(name, xPos, xSize)
		local GB = Instance.new("Frame")
		GB.Size = UDim2.new(xSize, -6, 1, 0)
		GB.Position = UDim2.new(xPos, xPos == 0 and 0 or 6, 0, 0)
		GB.BackgroundColor3 = COLOR_CARD_BG
		GB.BorderSizePixel = 0
		GB.ClipsDescendants = true
		GB.Parent = CA

		local GBC = Instance.new("UICorner")
		GBC.CornerRadius = UDim.new(0, 8)
		GBC.Parent = GB

		local GBS = Instance.new("UIStroke")
		GBS.Color = COLOR_BORDER
		GBS.Thickness = 1.2
		GBS.Parent = GB

		local GT = Instance.new("TextLabel")
		GT.Size = UDim2.new(1, -40, 0, 34)
		GT.Position = UDim2.new(0, 12, 0, 0)
		GT.BackgroundTransparency = 1
		GT.FontFace = FONT_BOLD
		GT.Text = name
		GT.TextColor3 = COLOR_TEXT_WHITE
		GT.TextSize = 14
		GT.TextXAlignment = Enum.TextXAlignment.Left
		GT.Parent = GB

		local GD = Instance.new("Frame")
		GD.Size = UDim2.new(1, 0, 0, 1)
		GD.Position = UDim2.new(0, 0, 0, 34)
		GD.BackgroundColor3 = COLOR_BORDER
		GD.BorderSizePixel = 0
		GD.Parent = GB

		local GC = Instance.new("ScrollingFrame")
		GC.Size = UDim2.new(1, 0, 1, -35)
		GC.Position = UDim2.new(0, 0, 0, 35)
		GC.BackgroundTransparency = 1
		GC.BorderSizePixel = 0
		GC.Active = true
		GC.ScrollingEnabled = true
		GC.ScrollBarThickness = 3
		GC.ScrollBarImageColor3 = COLOR_BORDER
		GC.ScrollingDirection = Enum.ScrollingDirection.Y
		GC.ClipsDescendants = true
		GC.Parent = GB

		local GCP = Instance.new("UIPadding")
		GCP.PaddingLeft   = UDim.new(0, 12)
		GCP.PaddingRight  = UDim.new(0, 14)
		GCP.PaddingTop    = UDim.new(0, 8)
		GCP.PaddingBottom = UDim.new(0, 12)
		GCP.Parent = GC

		local GCL = Instance.new("UIListLayout")
		GCL.SortOrder = Enum.SortOrder.LayoutOrder
		GCL.Padding = UDim.new(0, 8)
		GCL.Parent = GC

		GCL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			GC.CanvasSize = UDim2.new(0, 0, 0, GCL.AbsoluteContentSize.Y + 20)
		end)

		return GC
	end

	local ThemeBox  = MakeSettingsBox("Theme", 0, 0.5)
	local ConfigBox = MakeSettingsBox("Config", 0.5, 0.5)

	self:CreateCheckbox(ThemeBox, "Enable Watermark", self.ShowWatermark, function(state)
		self.ShowWatermark = state
		self._watermarkFrame.Visible = state
	end)

	self:CreateColorPicker(ThemeBox, "Accent Color", self._themeColor, function(c)
		self:_ApplyThemeColor(c)
	end)

	self:CreateLabel(ThemeBox, "UI Title")

	local _, TitleBox = self:CreateInput(ThemeBox, "Title", "UI name...", self.Title, function(text)
		if text ~= "" then
			self.Title = text
			self._sidebarTitle.Text = text
		end
	end)

	self:CreateLabel(ThemeBox, "Watermark Text")
	local _, WMBox = self:CreateInput(ThemeBox, "Watermark", "Watermark text...", self.WatermarkText, function(text)
		self.WatermarkText = text
		self._watermarkLabel.Text = text
	end)

	self:CreateLabel(ConfigBox, "Config Name")
	local _, configNameBox = self:CreateInput(ConfigBox, "Name", "Enter config name...", "", nil)

	local configDropdownContainer, configDropdownApi

	local function RefreshDropdown()
		local list = self:_GetConfigList()
		if configDropdownApi then
			configDropdownApi:SetOptions(#list > 0 and list or {"(none)"})
		end
	end

	self:CreateButton(ConfigBox, "Save Config", function()
		local name = configNameBox.Text
		if name == "" then
			self:Notify({ Title = "Config", Text = "Enter a config name first.", Icon = "alert-circle", Duration = 3 })
			return
		end
		self:SaveConfig(name)
		RefreshDropdown()
		self:Notify({ Title = "Config Saved", Text = name .. " saved.", Icon = "check", Duration = 3 })
	end)

	self:CreateButton(ConfigBox, "Load Config", function()
		local sel = configDropdownApi and configDropdownApi:GetSelected() or ""
		if sel == "" or sel == "(none)" then
			self:Notify({ Title = "Config", Text = "No config selected.", Icon = "alert-circle", Duration = 3 })
			return
		end
		self:LoadConfig(sel)
		configNameBox.Text = sel
		self:Notify({ Title = "Config Loaded", Text = sel .. " loaded.", Icon = "check", Duration = 3 })
	end)

	local initialList = self:_GetConfigList()
	local ddFrame, ddApi = self:CreateDropdown(ConfigBox, "Saved Configs", #initialList > 0 and initialList or {"(none)"}, nil, nil)
	configDropdownContainer = ddFrame
	configDropdownApi = ddApi

	self:CreateButton(ConfigBox, "Overwrite", function()
		local sel = configDropdownApi and configDropdownApi:GetSelected() or ""
		if sel == "" or sel == "(none)" then return end
		self:SaveConfig(sel)
		self:Notify({ Title = "Config", Text = sel .. " overwritten.", Icon = "check", Duration = 3 })
	end)

	self:CreateButton(ConfigBox, "Set as Autoload", function()
		local sel = configDropdownApi and configDropdownApi:GetSelected() or ""
		if sel == "" or sel == "(none)" then return end
		self:SetAutoload(sel)
		self:Notify({ Title = "Autoload Set", Text = sel .. " will load on start.", Icon = "check", Duration = 3 })
	end)

	self:CreateButton(ConfigBox, "Remove Autoload", function()
		self:SetAutoload(nil)
		self:Notify({ Title = "Autoload", Text = "Autoload removed.", Icon = "check", Duration = 3 })
	end)

	self:CreateButton(ConfigBox, "Delete Config", function()
		local sel = configDropdownApi and configDropdownApi:GetSelected() or ""
		if sel == "" or sel == "(none)" then return end
		pcall(function() delfile(self.ConfigFolder .. "/" .. sel .. ".json") end)
		if self._autoloadFile == sel then self:SetAutoload(nil) end
		RefreshDropdown()
		self:Notify({ Title = "Config Deleted", Text = sel .. " removed.", Icon = "trash", Duration = 3 })
	end)

	TabBtn.MouseButton1Click:Connect(function()
		self:_HideAllPages()
		if self.ActiveTabRef then self:_SetTabActive(self.ActiveTabRef, false) end
		if self.ActiveSubTabRef then self:_SetSubTabActive(self.ActiveSubTabRef, false) end
		self.ActiveTabRef = nil
		self.ActiveSubTabRef = nil
		self:_SetTabActive(settingsTabObj, true)
		self:_UpdateHeader("UI Settings", "settings")
		Page.Visible = true
		RefreshDropdown()
	end)

	table.insert(self.TabObjects, settingsTabObj)
	self._settingsTabObj = settingsTabObj
end

return Astra
