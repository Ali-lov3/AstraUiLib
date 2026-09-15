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

local ParentGui = LocalPlayer:WaitForChild("PlayerGui")
if gethui then
	ParentGui = gethui()
elseif syn and syn.protect_gui then
	local sg = Instance.new("ScreenGui")
	syn.protect_gui(sg)
	ParentGui = CoreGui
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AstraUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = ParentGui

local NotificationContainer = Instance.new("Frame")
NotificationContainer.Name = "NotificationContainer"
NotificationContainer.Size = UDim2.new(0, 260, 1, -40)
NotificationContainer.Position = UDim2.new(1, -20, 1, -20)
NotificationContainer.AnchorPoint = Vector2.new(1, 1)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.Parent = NotificationContainer

local function Notify(config)
	config = config or {}
	local title    = config.Title    or "Notification"
	local text     = config.Text     or ""
	local icon     = config.Icon     or "bell"
	local duration = config.Duration or 3

	local NotifCard = Instance.new("Frame")
	NotifCard.Name = "Notification"
	NotifCard.Size = UDim2.new(1, 0, 0, 0)
	NotifCard.AutomaticSize = Enum.AutomaticSize.Y
	NotifCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	NotifCard.BorderSizePixel = 0
	NotifCard.ClipsDescendants = true
	NotifCard.BackgroundTransparency = 1

	Instance.new("UICorner", NotifCard).CornerRadius = UDim.new(0, 6)

	local NotifGradient = Instance.new("UIGradient")
	NotifGradient.Rotation = 90
	NotifGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 35)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 20))
	})
	NotifGradient.Parent = NotifCard

	local NotifStroke = Instance.new("UIStroke")
	NotifStroke.Color = Color3.fromRGB(45, 45, 55)
	NotifStroke.Thickness = 1.2
	NotifStroke.Transparency = 1
	NotifStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	NotifStroke.Parent = NotifCard

	local Padding = Instance.new("UIPadding")
	Padding.PaddingTop    = UDim.new(0, 10)
	Padding.PaddingBottom = UDim.new(0, 18)
	Padding.PaddingLeft   = UDim.new(0, 12)
	Padding.PaddingRight  = UDim.new(0, 12)
	Padding.Parent = NotifCard

	local HeaderFrame = Instance.new("Frame")
	HeaderFrame.Name = "Header"
	HeaderFrame.Size = UDim2.new(1, 0, 0, 16)
	HeaderFrame.BackgroundTransparency = 1
	HeaderFrame.Parent = NotifCard

	local HeaderLayout = Instance.new("UIListLayout")
	HeaderLayout.SortOrder = Enum.SortOrder.LayoutOrder
	HeaderLayout.FillDirection = Enum.FillDirection.Horizontal
	HeaderLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	HeaderLayout.Padding = UDim.new(0, 8)
	HeaderLayout.Parent = HeaderFrame

	local NotifIcon = Instance.new("ImageLabel")
	NotifIcon.Size = UDim2.new(0, 14, 0, 14)
	NotifIcon.BackgroundTransparency = 1
	NotifIcon.ImageColor3 = COLOR_TEXT_WHITE
	NotifIcon.ImageTransparency = 1
	NotifIcon.LayoutOrder = 1
	ApplyIcon(NotifIcon, icon)
	NotifIcon.Parent = HeaderFrame

	local TitleLbl = Instance.new("TextLabel")
	TitleLbl.Size = UDim2.new(1, -22, 1, 0)
	TitleLbl.BackgroundTransparency = 1
	TitleLbl.FontFace = FONT_BOLD
	TitleLbl.Text = title
	TitleLbl.TextColor3 = COLOR_TEXT_WHITE
	TitleLbl.TextTransparency = 1
	TitleLbl.TextSize = 12
	TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	TitleLbl.LayoutOrder = 2
	TitleLbl.Parent = HeaderFrame

	local DescriptionLbl = Instance.new("TextLabel")
	DescriptionLbl.Size = UDim2.new(1, 0, 0, 0)
	DescriptionLbl.Position = UDim2.new(0, 0, 0, 20)
	DescriptionLbl.AutomaticSize = Enum.AutomaticSize.Y
	DescriptionLbl.BackgroundTransparency = 1
	DescriptionLbl.FontFace = FONT_REGULAR
	DescriptionLbl.Text = text
	DescriptionLbl.TextColor3 = COLOR_TEXT_MUTED
	DescriptionLbl.TextTransparency = 1
	DescriptionLbl.TextSize = 11
	DescriptionLbl.TextXAlignment = Enum.TextXAlignment.Left
	DescriptionLbl.TextWrapped = true
	DescriptionLbl.Parent = NotifCard

	local ProgressBar = Instance.new("Frame")
	ProgressBar.Name = "Progress"
	ProgressBar.Size = UDim2.new(1, 0, 0, 2)
	ProgressBar.Position = UDim2.new(0, 0, 1, 12)
	ProgressBar.BackgroundColor3 = COLOR_TEXT_WHITE
	ProgressBar.BorderSizePixel = 0
	ProgressBar.BackgroundTransparency = 1
	ProgressBar.Parent = NotifCard

	Instance.new("UICorner", ProgressBar).CornerRadius = UDim.new(1, 0)

	NotifCard.Parent = NotificationContainer

	TweenService:Create(NotifCard,      TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
	TweenService:Create(NotifStroke,    TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0}):Play()
	TweenService:Create(NotifIcon,      TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
	TweenService:Create(TitleLbl,       TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
	TweenService:Create(DescriptionLbl, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
	TweenService:Create(ProgressBar,    TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.4}):Play()
	TweenService:Create(ProgressBar,    TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 2)}):Play()

	task.delay(duration, function()
		local fadeOut = TweenService:Create(NotifCard, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
		TweenService:Create(NotifStroke,    TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Transparency = 1}):Play()
		TweenService:Create(NotifIcon,      TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {ImageTransparency = 1}):Play()
		TweenService:Create(TitleLbl,       TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
		TweenService:Create(DescriptionLbl, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
		TweenService:Create(ProgressBar,    TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
		fadeOut:Play()
		fadeOut.Completed:Connect(function() NotifCard:Destroy() end)
	end)
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0.92, 0, 0.92, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = COLOR_BG
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = COLOR_BORDER
MainStroke.Thickness = 1.2
MainStroke.Parent = MainFrame

local AspectRatio = Instance.new("UIAspectRatioConstraint")
AspectRatio.AspectRatio = 1.65
AspectRatio.AspectType = Enum.AspectType.FitWithinMaxSize
AspectRatio.DominantAxis = Enum.DominantAxis.Height
AspectRatio.Parent = MainFrame

local SizeConstraint = Instance.new("UISizeConstraint")
SizeConstraint.MinSize = Vector2.new(620, 360)
SizeConstraint.MaxSize = Vector2.new(1400, 900)
SizeConstraint.Parent = MainFrame

local MobileToggleBtn = Instance.new("TextButton")
MobileToggleBtn.Name = "MobileToggleBtn"
MobileToggleBtn.Size = UDim2.new(0, 65, 0, 28)
MobileToggleBtn.Position = UDim2.new(0, 15, 0.5, -14)
MobileToggleBtn.BackgroundColor3 = COLOR_CARD_BG
MobileToggleBtn.BorderSizePixel = 0
MobileToggleBtn.FontFace = FONT_BOLD
MobileToggleBtn.Text = "Close"
MobileToggleBtn.TextColor3 = COLOR_TEXT_WHITE
MobileToggleBtn.TextSize = 12
MobileToggleBtn.AutoButtonColor = false
MobileToggleBtn.ZIndex = 100
MobileToggleBtn.Parent = ScreenGui

Instance.new("UICorner", MobileToggleBtn).CornerRadius = UDim.new(0, 6)

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = COLOR_BORDER
ToggleStroke.Thickness = 1.2
ToggleStroke.Parent = MobileToggleBtn

local function ToggleUI()
	MainFrame.Visible = not MainFrame.Visible
	MobileToggleBtn.Text = MainFrame.Visible and "Close" or "Open"
end

MobileToggleBtn.MouseButton1Click:Connect(ToggleUI)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
		ToggleUI()
	end
end)

local function MakeDraggable(guiObject)
	local dragging = false
	local dragInput, dragStart, startPos

	guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)

	guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			guiObject.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

MakeDraggable(MainFrame)
MakeDraggable(MobileToggleBtn)

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0.24, 0, 1, 0)
Sidebar.BackgroundTransparency = 1
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarDivider = Instance.new("Frame")
SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
SidebarDivider.Position = UDim2.new(1, -1, 0, 0)
SidebarDivider.BackgroundColor3 = COLOR_BORDER
SidebarDivider.BorderSizePixel = 0
SidebarDivider.Parent = Sidebar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, -20, 0, 38)
TitleLabel.Position = UDim2.new(0, 10, 0, 6)
TitleLabel.BackgroundTransparency = 1
TitleLabel.FontFace = FONT_BOLD
TitleLabel.Text = "Astra"
TitleLabel.TextColor3 = COLOR_TEXT_WHITE
TitleLabel.TextSize = 17
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
TitleLabel.Parent = Sidebar

local SearchContainer = Instance.new("Frame")
SearchContainer.Name = "SearchContainer"
SearchContainer.Size = UDim2.new(1, -20, 0, 30)
SearchContainer.Position = UDim2.new(0, 10, 0, 46)
SearchContainer.BackgroundColor3 = COLOR_SEARCH_BG
SearchContainer.BorderSizePixel = 0
SearchContainer.Parent = Sidebar

Instance.new("UICorner", SearchContainer).CornerRadius = UDim.new(0, 6)

local SearchStroke = Instance.new("UIStroke")
SearchStroke.Color = COLOR_BORDER
SearchStroke.Thickness = 1
SearchStroke.Parent = SearchContainer

local SearchIcon = Instance.new("ImageLabel")
SearchIcon.Size = UDim2.new(0, 14, 0, 14)
SearchIcon.Position = UDim2.new(0, 8, 0.5, -7)
SearchIcon.BackgroundTransparency = 1
SearchIcon.ImageColor3 = COLOR_TEXT_MUTED
ApplyIcon(SearchIcon, "search")
SearchIcon.Parent = SearchContainer

local SearchInput = Instance.new("TextBox")
SearchInput.Name = "Input"
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
SearchDivider.Parent = Sidebar

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
NavContainer.Parent = Sidebar

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
UserDivider.Parent = Sidebar

local UserContainer = Instance.new("Frame")
UserContainer.Name = "UserContainer"
UserContainer.Size = UDim2.new(1, -20, 0, 42)
UserContainer.Position = UDim2.new(0, 10, 1, -47)
UserContainer.BackgroundTransparency = 1
UserContainer.Parent = Sidebar

local AvatarBox = Instance.new("Frame")
AvatarBox.Size = UDim2.new(0, 30, 0, 30)
AvatarBox.Position = UDim2.new(0, 0, 0.5, -15)
AvatarBox.BackgroundColor3 = COLOR_SEARCH_BG
AvatarBox.BorderSizePixel = 0
AvatarBox.ClipsDescendants = true
AvatarBox.Parent = UserContainer

Instance.new("UICorner", AvatarBox).CornerRadius = UDim.new(0, 6)

local AvatarStroke = Instance.new("UIStroke")
AvatarStroke.Color = COLOR_BORDER
AvatarStroke.Thickness = 1
AvatarStroke.Parent = AvatarBox

local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Size = UDim2.new(1, 0, 1, 0)
AvatarImage.BackgroundTransparency = 1
AvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
AvatarImage.Parent = AvatarBox

Instance.new("UICorner", AvatarImage).CornerRadius = UDim.new(0, 6)

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

local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(0.76, 0, 1, 0)
ContentFrame.Position = UDim2.new(0.24, 0, 0, 0)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

local ContentHeaderFrame = Instance.new("Frame")
ContentHeaderFrame.Name = "HeaderFrame"
ContentHeaderFrame.Size = UDim2.new(1, -24, 0, 44)
ContentHeaderFrame.Position = UDim2.new(0, 14, 0, 4)
ContentHeaderFrame.BackgroundTransparency = 1
ContentHeaderFrame.Parent = ContentFrame

local HeaderLayout = Instance.new("UIListLayout")
HeaderLayout.SortOrder = Enum.SortOrder.LayoutOrder
HeaderLayout.FillDirection = Enum.FillDirection.Horizontal
HeaderLayout.VerticalAlignment = Enum.VerticalAlignment.Center
HeaderLayout.Padding = UDim.new(0, 8)
HeaderLayout.Parent = ContentHeaderFrame

local ContentHeaderIcon = Instance.new("ImageLabel")
ContentHeaderIcon.Name = "HeaderIcon"
ContentHeaderIcon.Size = UDim2.new(0, 18, 0, 18)
ContentHeaderIcon.BackgroundTransparency = 1
ContentHeaderIcon.ImageColor3 = COLOR_TEXT_WHITE
ContentHeaderIcon.LayoutOrder = 1
ApplyIcon(ContentHeaderIcon, "layout")
ContentHeaderIcon.Parent = ContentHeaderFrame

local ContentHeader = Instance.new("TextLabel")
ContentHeader.Name = "HeaderTitle"
ContentHeader.Size = UDim2.new(0, 0, 1, 0)
ContentHeader.AutomaticSize = Enum.AutomaticSize.X
ContentHeader.BackgroundTransparency = 1
ContentHeader.FontFace = FONT_BOLD
ContentHeader.Text = "Main Tab"
ContentHeader.TextColor3 = COLOR_TEXT_WHITE
ContentHeader.TextSize = 17
ContentHeader.TextXAlignment = Enum.TextXAlignment.Left
ContentHeader.LayoutOrder = 2
ContentHeader.Parent = ContentHeaderFrame

local ContentHeaderDivider = Instance.new("Frame")
ContentHeaderDivider.Size = UDim2.new(1, 0, 0, 1)
ContentHeaderDivider.Position = UDim2.new(0, 0, 0, 48)
ContentHeaderDivider.BackgroundColor3 = COLOR_BORDER
ContentHeaderDivider.BorderSizePixel = 0
ContentHeaderDivider.Parent = ContentFrame

local ContentArea = Instance.new("Frame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -28, 1, -62)
ContentArea.Position = UDim2.new(0, 14, 0, 54)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = ContentFrame

local function AddGroupboxToggle(groupbox, divider, content)
	local isExpanded = true

	local ToggleBtn = Instance.new("ImageButton")
	ToggleBtn.Name = "ToggleChevron"
	ToggleBtn.Size = UDim2.new(0, 16, 0, 16)
	ToggleBtn.Position = UDim2.new(1, -12, 0, 9)
	ToggleBtn.AnchorPoint = Vector2.new(1, 0)
	ToggleBtn.BackgroundTransparency = 1
	ToggleBtn.ImageColor3 = COLOR_TEXT_MUTED
	ApplyIcon(ToggleBtn, "chevron-down")
	ToggleBtn.Parent = groupbox

	ToggleBtn.MouseEnter:Connect(function() ToggleBtn.ImageColor3 = COLOR_TEXT_WHITE end)
	ToggleBtn.MouseLeave:Connect(function() ToggleBtn.ImageColor3 = COLOR_TEXT_MUTED end)

	ToggleBtn.MouseButton1Click:Connect(function()
		isExpanded = not isExpanded
		content.Visible = isExpanded
		divider.Visible = isExpanded
		if isExpanded then
			groupbox.Size = UDim2.new(groupbox.Size.X.Scale, groupbox.Size.X.Offset, 1, 0)
			ToggleBtn.Rotation = 0
		else
			groupbox.Size = UDim2.new(groupbox.Size.X.Scale, groupbox.Size.X.Offset, 0, 35)
			ToggleBtn.Rotation = 180
		end
	end)
end

local function MakeGroupbox(parent, title, posX, posY, sizeXScale, sizeXOffset)
	local Box = Instance.new("Frame")
	Box.Size = UDim2.new(sizeXScale or 0.5, sizeXOffset or -6, 1, 0)
	Box.Position = UDim2.new(posX or 0, posY or 0, 0, 0)
	Box.BackgroundColor3 = COLOR_CARD_BG
	Box.BorderSizePixel = 0
	Box.ClipsDescendants = true
	Box.Parent = parent

	Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = COLOR_BORDER
	Stroke.Thickness = 1.2
	Stroke.Parent = Box

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -40, 0, 34)
	Title.Position = UDim2.new(0, 12, 0, 0)
	Title.BackgroundTransparency = 1
	Title.FontFace = FONT_BOLD
	Title.Text = title
	Title.TextColor3 = COLOR_TEXT_WHITE
	Title.TextSize = 14
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Box

	local Divider = Instance.new("Frame")
	Divider.Size = UDim2.new(1, 0, 0, 1)
	Divider.Position = UDim2.new(0, 0, 0, 34)
	Divider.BackgroundColor3 = COLOR_BORDER
	Divider.BorderSizePixel = 0
	Divider.Parent = Box

	local Scroll = Instance.new("ScrollingFrame")
	Scroll.Name = "Content"
	Scroll.Size = UDim2.new(1, 0, 1, -35)
	Scroll.Position = UDim2.new(0, 0, 0, 35)
	Scroll.BackgroundTransparency = 1
	Scroll.BorderSizePixel = 0
	Scroll.Active = true
	Scroll.ScrollingEnabled = true
	Scroll.ScrollBarThickness = 3
	Scroll.ScrollBarImageColor3 = COLOR_BORDER
	Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	Scroll.ClipsDescendants = true
	Scroll.Parent = Box

	local Pad = Instance.new("UIPadding")
	Pad.PaddingLeft   = UDim.new(0, 12)
	Pad.PaddingRight  = UDim.new(0, 14)
	Pad.PaddingTop    = UDim.new(0, 8)
	Pad.PaddingBottom = UDim.new(0, 12)
	Pad.Parent = Scroll

	local Layout = Instance.new("UIListLayout")
	Layout.SortOrder = Enum.SortOrder.LayoutOrder
	Layout.Padding = UDim.new(0, 8)
	Layout.Parent = Scroll

	Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
	end)

	AddGroupboxToggle(Box, Divider, Scroll)

	return Box, Scroll
end

local function CreateLabel(parent, labelText)
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

	return Container
end

local function CreateCheckbox(parent, labelText, defaultState, callback)
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
	Box.BackgroundColor3 = state and COLOR_TEXT_WHITE or COLOR_BOX_INACTIVE
	Box.BorderSizePixel = 0
	Box.Parent = ToggleBtn

	Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)

	local BoxStroke = Instance.new("UIStroke")
	BoxStroke.Color = state and COLOR_TEXT_WHITE or COLOR_BOX_BORDER
	BoxStroke.Thickness = 1
	BoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	BoxStroke.Parent = Box

	local CheckIcon = Instance.new("ImageLabel")
	CheckIcon.Size = UDim2.new(0, 10, 0, 10)
	CheckIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	CheckIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	CheckIcon.BackgroundTransparency = 1
	CheckIcon.ImageColor3 = COLOR_BG
	CheckIcon.ImageTransparency = state and 0 or 1
	ApplyIcon(CheckIcon, "check")
	CheckIcon.Parent = Box

	local function UpdateState()
		Box.BackgroundColor3 = state and COLOR_TEXT_WHITE or COLOR_BOX_INACTIVE
		BoxStroke.Color = state and COLOR_TEXT_WHITE or COLOR_BOX_BORDER
		CheckIcon.ImageTransparency = state and 0 or 1
		Label.TextColor3 = state and COLOR_TEXT_WHITE or COLOR_TEXT_MUTED
	end

	ToggleBtn.MouseButton1Click:Connect(function()
		state = not state
		UpdateState()
		if callback then callback(state) end
	end)

	return ToggleBtn
end

local function CreateSlider(parent, labelText, min, max, default, callback)
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

	Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

	local TrackStroke = Instance.new("UIStroke")
	TrackStroke.Color = COLOR_BORDER
	TrackStroke.Thickness = 1
	TrackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	TrackStroke.Parent = Track

	local Fill = Instance.new("Frame")
	Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
	Fill.BackgroundColor3 = COLOR_TEXT_WHITE
	Fill.BorderSizePixel = 0
	Fill.Parent = Track

	Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

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

local function CreateInput(parent, labelText, placeholderText, defaultText, callback)
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

	Instance.new("UICorner", BoxContainer).CornerRadius = UDim.new(0, 5)

	local BoxStroke = Instance.new("UIStroke")
	BoxStroke.Color = COLOR_BOX_BORDER
	BoxStroke.Thickness = 1
	BoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	BoxStroke.Parent = BoxContainer

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

	TextBox.Focused:Connect(function() BoxStroke.Color = COLOR_TEXT_WHITE end)
	TextBox.FocusLost:Connect(function(enterPressed)
		BoxStroke.Color = COLOR_BOX_BORDER
		if callback then callback(TextBox.Text, enterPressed) end
	end)

	return Container
end

local function CreateDropdown(parent, labelText, options, default, callback)
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

	Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 5)

	local HeaderStroke = Instance.new("UIStroke")
	HeaderStroke.Color = COLOR_BOX_BORDER
	HeaderStroke.Thickness = 1
	HeaderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	HeaderStroke.Parent = Header

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

	Instance.new("UICorner", OptionHolder).CornerRadius = UDim.new(0, 5)

	local HolderStroke = Instance.new("UIStroke")
	HolderStroke.Color = COLOR_BOX_BORDER
	HolderStroke.Thickness = 1
	HolderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	HolderStroke.Parent = OptionHolder

	local HolderLayout = Instance.new("UIListLayout")
	HolderLayout.SortOrder = Enum.SortOrder.LayoutOrder
	HolderLayout.Padding = UDim.new(0, 2)
	HolderLayout.Parent = OptionHolder

	local HolderPadding = Instance.new("UIPadding")
	HolderPadding.PaddingTop    = UDim.new(0, 4)
	HolderPadding.PaddingBottom = UDim.new(0, 4)
	HolderPadding.PaddingLeft   = UDim.new(0, 4)
	HolderPadding.PaddingRight  = UDim.new(0, 4)
	HolderPadding.Parent = OptionHolder

	local function RefreshOptions()
		for _, child in ipairs(OptionHolder:GetChildren()) do
			if child:IsA("TextButton") then
				local isSel = (child.Text == selected)
				child.BackgroundTransparency = isSel and 0 or 1
				child.TextColor3 = isSel and COLOR_TEXT_WHITE or COLOR_TEXT_MUTED
			end
		end
	end

	local function ToggleList()
		isOpen = not isOpen
		OptionHolder.Visible = isOpen
		Chevron.Rotation = isOpen and 180 or 0
		HeaderStroke.Color = isOpen and COLOR_TEXT_WHITE or COLOR_BOX_BORDER
		if isOpen then
			local totalHeight = (#options * 24) + 8
			OptionHolder.Size = UDim2.new(1, 0, 0, math.min(totalHeight, 120))
			Container.Size = UDim2.new(1, 0, 0, 48 + math.min(totalHeight, 120) + 4)
		else
			Container.Size = UDim2.new(1, 0, 0, 48)
		end
	end

	local api = {}
	function api.SetSelected(opt, silent)
		selected = opt
		SelectedText.Text = opt
		RefreshOptions()
		if not silent and callback then callback(selected) end
	end
	function api.GetSelected() return selected end

	Header.MouseButton1Click:Connect(ToggleList)

	for _, opt in ipairs(options) do
		local OptBtn = Instance.new("TextButton")
		OptBtn.Size = UDim2.new(1, 0, 0, 22)
		OptBtn.BackgroundColor3 = COLOR_ACTIVE_BG
		OptBtn.BackgroundTransparency = (opt == selected) and 0 or 1
		OptBtn.BorderSizePixel = 0
		OptBtn.FontFace = FONT_REGULAR
		OptBtn.Text = opt
		OptBtn.TextColor3 = (opt == selected) and COLOR_TEXT_WHITE or COLOR_TEXT_MUTED
		OptBtn.TextSize = 11
		OptBtn.TextXAlignment = Enum.TextXAlignment.Left
		OptBtn.AutoButtonColor = false
		OptBtn.Parent = OptionHolder

		local OptPadding = Instance.new("UIPadding")
		OptPadding.PaddingLeft = UDim.new(0, 6)
		OptPadding.Parent = OptBtn

		Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)

		OptBtn.MouseEnter:Connect(function()
			OptBtn.BackgroundTransparency = 0
			OptBtn.TextColor3 = COLOR_TEXT_WHITE
		end)

		OptBtn.MouseLeave:Connect(function()
			if opt ~= selected then
				OptBtn.BackgroundTransparency = 1
				OptBtn.TextColor3 = COLOR_TEXT_MUTED
			end
		end)

		OptBtn.MouseButton1Click:Connect(function()
			selected = opt
			SelectedText.Text = selected
			ToggleList()
			RefreshOptions()
			if callback then callback(selected) end
		end)
	end

	return Container, api
end

local function CreateMultiDropdown(parent, labelText, options, defaultSelected, callback)
	local selected = {}
	if type(defaultSelected) == "table" then
		for _, item in ipairs(defaultSelected) do selected[item] = true end
	end
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

	Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 5)

	local HeaderStroke = Instance.new("UIStroke")
	HeaderStroke.Color = COLOR_BOX_BORDER
	HeaderStroke.Thickness = 1
	HeaderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	HeaderStroke.Parent = Header

	local SelectedText = Instance.new("TextLabel")
	SelectedText.Size = UDim2.new(1, -28, 1, 0)
	SelectedText.Position = UDim2.new(0, 8, 0, 0)
	SelectedText.BackgroundTransparency = 1
	SelectedText.FontFace = FONT_MEDIUM
	SelectedText.TextColor3 = COLOR_TEXT_WHITE
	SelectedText.TextSize = 12
	SelectedText.TextXAlignment = Enum.TextXAlignment.Left
	SelectedText.TextTruncate = Enum.TextTruncate.AtEnd
	SelectedText.Parent = Header

	local function FormatSelected()
		local list = {}
		for _, opt in ipairs(options) do
			if selected[opt] then table.insert(list, opt) end
		end
		return #list == 0 and "None" or table.concat(list, ", ")
	end

	SelectedText.Text = FormatSelected()

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

	Instance.new("UICorner", OptionHolder).CornerRadius = UDim.new(0, 5)

	local HolderStroke = Instance.new("UIStroke")
	HolderStroke.Color = COLOR_BOX_BORDER
	HolderStroke.Thickness = 1
	HolderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	HolderStroke.Parent = OptionHolder

	local HolderLayout = Instance.new("UIListLayout")
	HolderLayout.SortOrder = Enum.SortOrder.LayoutOrder
	HolderLayout.Padding = UDim.new(0, 2)
	HolderLayout.Parent = OptionHolder

	local HolderPadding = Instance.new("UIPadding")
	HolderPadding.PaddingTop    = UDim.new(0, 4)
	HolderPadding.PaddingBottom = UDim.new(0, 4)
	HolderPadding.PaddingLeft   = UDim.new(0, 4)
	HolderPadding.PaddingRight  = UDim.new(0, 4)
	HolderPadding.Parent = OptionHolder

	local function ToggleList()
		isOpen = not isOpen
		OptionHolder.Visible = isOpen
		Chevron.Rotation = isOpen and 180 or 0
		HeaderStroke.Color = isOpen and COLOR_TEXT_WHITE or COLOR_BOX_BORDER
		if isOpen then
			local totalHeight = (#options * 24) + 8
			OptionHolder.Size = UDim2.new(1, 0, 0, math.min(totalHeight, 120))
			Container.Size = UDim2.new(1, 0, 0, 48 + math.min(totalHeight, 120) + 4)
		else
			Container.Size = UDim2.new(1, 0, 0, 48)
		end
	end

	Header.MouseButton1Click:Connect(ToggleList)

	for _, opt in ipairs(options) do
		local OptBtn = Instance.new("TextButton")
		OptBtn.Size = UDim2.new(1, 0, 0, 22)
		OptBtn.BackgroundColor3 = COLOR_ACTIVE_BG
		OptBtn.BackgroundTransparency = selected[opt] and 0 or 1
		OptBtn.BorderSizePixel = 0
		OptBtn.FontFace = FONT_REGULAR
		OptBtn.Text = opt
		OptBtn.TextColor3 = selected[opt] and COLOR_TEXT_WHITE or COLOR_TEXT_MUTED
		OptBtn.TextSize = 11
		OptBtn.TextXAlignment = Enum.TextXAlignment.Left
		OptBtn.AutoButtonColor = false
		OptBtn.Parent = OptionHolder

		local OptPadding = Instance.new("UIPadding")
		OptPadding.PaddingLeft = UDim.new(0, 6)
		OptPadding.Parent = OptBtn

		Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)

		OptBtn.MouseButton1Click:Connect(function()
			selected[opt] = not selected[opt]
			OptBtn.BackgroundTransparency = selected[opt] and 0 or 1
			OptBtn.TextColor3 = selected[opt] and COLOR_TEXT_WHITE or COLOR_TEXT_MUTED
			SelectedText.Text = FormatSelected()
			if callback then callback(selected) end
		end)
	end

	return Container
end

local function CreateColorPicker(parent, labelText, defaultColor, callback)
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

	local ColorPreviewBtn = Instance.new("TextButton")
	ColorPreviewBtn.Size = UDim2.new(0, 32, 0, 16)
	ColorPreviewBtn.Position = UDim2.new(1, 0, 0.5, 0)
	ColorPreviewBtn.AnchorPoint = Vector2.new(1, 0.5)
	ColorPreviewBtn.BackgroundColor3 = color
	ColorPreviewBtn.BorderSizePixel = 0
	ColorPreviewBtn.Text = ""
	ColorPreviewBtn.AutoButtonColor = false
	ColorPreviewBtn.Parent = TopHeader

	Instance.new("UICorner", ColorPreviewBtn).CornerRadius = UDim.new(0, 4)

	local PreviewStroke = Instance.new("UIStroke")
	PreviewStroke.Color = COLOR_BOX_BORDER
	PreviewStroke.Thickness = 1
	PreviewStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	PreviewStroke.Parent = ColorPreviewBtn

	local PickerPanel = Instance.new("Frame")
	PickerPanel.Size = UDim2.new(1, 0, 0, 142)
	PickerPanel.Position = UDim2.new(0, 0, 0, 28)
	PickerPanel.BackgroundColor3 = COLOR_BOX_INACTIVE
	PickerPanel.BorderSizePixel = 0
	PickerPanel.Visible = false
	PickerPanel.ClipsDescendants = true
	PickerPanel.ZIndex = 12
	PickerPanel.Parent = Container

	Instance.new("UICorner", PickerPanel).CornerRadius = UDim.new(0, 6)

	local PanelStroke = Instance.new("UIStroke")
	PanelStroke.Color = COLOR_BOX_BORDER
	PanelStroke.Thickness = 1
	PanelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	PanelStroke.Parent = PickerPanel

	local SVBox = Instance.new("Frame")
	SVBox.Size = UDim2.new(1, -36, 0, 95)
	SVBox.Position = UDim2.new(0, 8, 0, 8)
	SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
	SVBox.BorderSizePixel = 0
	SVBox.Parent = PickerPanel

	Instance.new("UICorner", SVBox).CornerRadius = UDim.new(0, 4)

	local WhiteGradFrame = Instance.new("Frame")
	WhiteGradFrame.Size = UDim2.new(1, 0, 1, 0)
	WhiteGradFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	WhiteGradFrame.BorderSizePixel = 0
	WhiteGradFrame.Parent = SVBox

	Instance.new("UICorner", WhiteGradFrame).CornerRadius = UDim.new(0, 4)

	local WhiteGrad = Instance.new("UIGradient")
	WhiteGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	WhiteGrad.Parent = WhiteGradFrame

	local BlackGradFrame = Instance.new("Frame")
	BlackGradFrame.Size = UDim2.new(1, 0, 1, 0)
	BlackGradFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	BlackGradFrame.BorderSizePixel = 0
	BlackGradFrame.Parent = SVBox

	Instance.new("UICorner", BlackGradFrame).CornerRadius = UDim.new(0, 4)

	local BlackGrad = Instance.new("UIGradient")
	BlackGrad.Rotation = 90
	BlackGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0)
	})
	BlackGrad.Parent = BlackGradFrame

	local SVCursor = Instance.new("Frame")
	SVCursor.Size = UDim2.new(0, 10, 0, 10)
	SVCursor.AnchorPoint = Vector2.new(0.5, 0.5)
	SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
	SVCursor.BackgroundColor3 = color
	SVCursor.BorderSizePixel = 0
	SVCursor.ZIndex = 2
	SVCursor.Parent = SVBox

	Instance.new("UICorner", SVCursor).CornerRadius = UDim.new(1, 0)

	local SVCursorStroke = Instance.new("UIStroke")
	SVCursorStroke.Color = Color3.fromRGB(255, 255, 255)
	SVCursorStroke.Thickness = 1.5
	SVCursorStroke.Parent = SVCursor

	local HueBar = Instance.new("Frame")
	HueBar.Size = UDim2.new(0, 12, 0, 95)
	HueBar.Position = UDim2.new(1, -18, 0, 8)
	HueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	HueBar.BorderSizePixel = 0
	HueBar.Parent = PickerPanel

	Instance.new("UICorner", HueBar).CornerRadius = UDim.new(0, 4)

	local HueGrad = Instance.new("UIGradient")
	HueGrad.Rotation = 90
	HueGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,     Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.5,   Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(1,     Color3.fromRGB(255, 0, 0))
	})
	HueGrad.Parent = HueBar

	local HueCursor = Instance.new("Frame")
	HueCursor.Size = UDim2.new(1, 4, 0, 4)
	HueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
	HueCursor.Position = UDim2.new(0.5, 0, h, 0)
	HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	HueCursor.BorderSizePixel = 0
	HueCursor.ZIndex = 2
	HueCursor.Parent = HueBar

	Instance.new("UICorner", HueCursor).CornerRadius = UDim.new(1, 0)

	local HueCursorStroke = Instance.new("UIStroke")
	HueCursorStroke.Color = Color3.fromRGB(0, 0, 0)
	HueCursorStroke.Thickness = 1
	HueCursorStroke.Parent = HueCursor

	local ColorValBox = Instance.new("TextBox")
	ColorValBox.Size = UDim2.new(1, -16, 0, 22)
	ColorValBox.Position = UDim2.new(0, 8, 0, 110)
	ColorValBox.BackgroundColor3 = COLOR_SEARCH_BG
	ColorValBox.BorderSizePixel = 0
	ColorValBox.FontFace = FONT_MEDIUM
	ColorValBox.Text = string.format("rgb(%d, %d, %d)", math.floor(color.R*255+.5), math.floor(color.G*255+.5), math.floor(color.B*255+.5))
	ColorValBox.TextColor3 = COLOR_TEXT_WHITE
	ColorValBox.TextSize = 11
	ColorValBox.ClearTextOnFocus = false
	ColorValBox.Parent = PickerPanel

	Instance.new("UICorner", ColorValBox).CornerRadius = UDim.new(0, 4)

	local ValBoxStroke = Instance.new("UIStroke")
	ValBoxStroke.Color = COLOR_BOX_BORDER
	ValBoxStroke.Thickness = 1
	ValBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ValBoxStroke.Parent = ColorValBox

	local function UpdateColor()
		color = Color3.fromHSV(h, s, v)
		SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
		SVCursor.BackgroundColor3 = color
		HueCursor.Position = UDim2.new(0.5, 0, h, 0)
		ColorPreviewBtn.BackgroundColor3 = color
		ColorValBox.Text = string.format("rgb(%d, %d, %d)", math.floor(color.R*255+.5), math.floor(color.G*255+.5), math.floor(color.B*255+.5))
		if callback then callback(color) end
	end

	local draggingSV, draggingHue = false, false

	SVBox.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSV = true
			local posX = math.clamp(input.Position.X - SVBox.AbsolutePosition.X, 0, SVBox.AbsoluteSize.X)
			local posY = math.clamp(input.Position.Y - SVBox.AbsolutePosition.Y, 0, SVBox.AbsoluteSize.Y)
			s = posX / SVBox.AbsoluteSize.X; v = 1 - (posY / SVBox.AbsoluteSize.Y)
			UpdateColor()
		end
	end)

	HueBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingHue = true
			h = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
			UpdateColor()
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			if draggingSV then
				local posX = math.clamp(input.Position.X - SVBox.AbsolutePosition.X, 0, SVBox.AbsoluteSize.X)
				local posY = math.clamp(input.Position.Y - SVBox.AbsolutePosition.Y, 0, SVBox.AbsoluteSize.Y)
				s = posX / SVBox.AbsoluteSize.X; v = 1 - (posY / SVBox.AbsoluteSize.Y)
				UpdateColor()
			end
			if draggingHue then
				h = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
				UpdateColor()
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSV = false; draggingHue = false
		end
	end)

	ColorValBox.FocusLost:Connect(function()
		local r, g, b = ColorValBox.Text:match("rgb%s*%(%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*%)")
		if r and g and b then
			color = Color3.fromRGB(math.clamp(tonumber(r),0,255), math.clamp(tonumber(g),0,255), math.clamp(tonumber(b),0,255))
			h, s, v = color:ToHSV(); UpdateColor()
		else
			local hex = ColorValBox.Text:gsub("#","")
			if #hex == 6 then
				local hr, hg, hb = tonumber(hex:sub(1,2),16), tonumber(hex:sub(3,4),16), tonumber(hex:sub(5,6),16)
				if hr and hg and hb then
					color = Color3.fromRGB(hr, hg, hb); h, s, v = color:ToHSV(); UpdateColor()
				end
			end
		end
	end)

	ColorPreviewBtn.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		PickerPanel.Visible = isOpen
		Container.Size = isOpen and UDim2.new(1, 0, 0, 172) or UDim2.new(1, 0, 0, 24)
	end)

	return Container
end

local function CreateButton(parent, buttonText, callback)
	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, 0, 0, 24)
	Container.BackgroundTransparency = 1
	Container.Parent = parent

	local BtnBg = Instance.new("Frame")
	BtnBg.Size = UDim2.new(1, 0, 1, 0)
	BtnBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	BtnBg.BorderSizePixel = 0
	BtnBg.Parent = Container

	Instance.new("UICorner", BtnBg).CornerRadius = UDim.new(0, 5)

	local BtnGradient = Instance.new("UIGradient")
	BtnGradient.Rotation = 90
	BtnGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 28, 35)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 16, 20))
	})
	BtnGradient.Parent = BtnBg

	local BtnStroke = Instance.new("UIStroke")
	BtnStroke.Color = Color3.fromRGB(45, 45, 55)
	BtnStroke.Thickness = 1.2
	BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	BtnStroke.Parent = BtnBg

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, 0, 1, 0)
	Button.BackgroundTransparency = 1
	Button.FontFace = FONT_MEDIUM
	Button.Text = string.lower(buttonText)
	Button.TextColor3 = COLOR_TEXT_WHITE
	Button.TextScaled = true
	Button.AutoButtonColor = false
	Button.Parent = Container

	local TextConstraint = Instance.new("UITextSizeConstraint")
	TextConstraint.MaxTextSize = 13
	TextConstraint.MinTextSize = 8
	TextConstraint.Parent = Button

	local BtnPadding = Instance.new("UIPadding")
	BtnPadding.PaddingTop    = UDim.new(0, 4)
	BtnPadding.PaddingBottom = UDim.new(0, 4)
	BtnPadding.Parent = Button

	Button.MouseEnter:Connect(function()
		BtnGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(38,38,48)),ColorSequenceKeypoint.new(1, Color3.fromRGB(24,24,30))})
		BtnStroke.Color = Color3.fromRGB(65,65,80)
	end)
	Button.MouseLeave:Connect(function()
		BtnGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(28,28,35)),ColorSequenceKeypoint.new(1, Color3.fromRGB(16,16,20))})
		BtnStroke.Color = Color3.fromRGB(45,45,55)
	end)
	Button.MouseButton1Down:Connect(function()
		BtnGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(20,20,25)),ColorSequenceKeypoint.new(1, Color3.fromRGB(12,12,16))})
	end)
	Button.MouseButton1Up:Connect(function()
		BtnGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(38,38,48)),ColorSequenceKeypoint.new(1, Color3.fromRGB(24,24,30))})
	end)
	Button.MouseButton1Click:Connect(function() if callback then callback() end end)

	return Container
end

local function CreateKeybind(parent, labelText, defaultKey, callback)
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

	local KeyBtnHolder = Instance.new("Frame")
	KeyBtnHolder.Size = UDim2.new(0, 36, 0, 20)
	KeyBtnHolder.Position = UDim2.new(1, 0, 0.5, 0)
	KeyBtnHolder.AnchorPoint = Vector2.new(1, 0.5)
	KeyBtnHolder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	KeyBtnHolder.BorderSizePixel = 0
	KeyBtnHolder.Parent = Container

	Instance.new("UICorner", KeyBtnHolder).CornerRadius = UDim.new(0, 5)

	local KeyGradient = Instance.new("UIGradient")
	KeyGradient.Rotation = 90
	KeyGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(28,28,35)),ColorSequenceKeypoint.new(1, Color3.fromRGB(16,16,20))})
	KeyGradient.Parent = KeyBtnHolder

	local KeyStroke = Instance.new("UIStroke")
	KeyStroke.Color = Color3.fromRGB(45,45,55)
	KeyStroke.Thickness = 1.2
	KeyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	KeyStroke.Parent = KeyBtnHolder

	local KeyBtn = Instance.new("TextButton")
	KeyBtn.Size = UDim2.new(1, 0, 1, 0)
	KeyBtn.BackgroundTransparency = 1
	KeyBtn.FontFace = FONT_BOLD
	KeyBtn.TextSize = 11
	KeyBtn.TextColor3 = COLOR_TEXT_WHITE
	KeyBtn.AutoButtonColor = false
	KeyBtn.Parent = KeyBtnHolder

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
			KeyStroke.Color = COLOR_TEXT_WHITE
			KeyGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(38,38,48)),ColorSequenceKeypoint.new(1, Color3.fromRGB(24,24,30))})
			Label.TextColor3 = COLOR_TEXT_WHITE
		else
			KeyBtn.Text = FormatKey(boundKey)
			KeyStroke.Color = Color3.fromRGB(45,45,55)
			KeyGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(28,28,35)),ColorSequenceKeypoint.new(1, Color3.fromRGB(16,16,20))})
			Label.TextColor3 = COLOR_TEXT_MUTED
		end
		local textSize = TextService:GetTextSize(KeyBtn.Text, 11, Enum.Font.SourceSans, Vector2.new(120, 20))
		KeyBtnHolder.Size = UDim2.new(0, math.max(34, textSize.X + 14), 0, 20)
	end

	UpdateText()

	KeyBtn.MouseEnter:Connect(function()
		if not binding then
			KeyGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(38,38,48)),ColorSequenceKeypoint.new(1, Color3.fromRGB(24,24,30))})
			KeyStroke.Color = Color3.fromRGB(65,65,80)
		end
	end)
	KeyBtn.MouseLeave:Connect(function()
		if not binding then
			KeyGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(28,28,35)),ColorSequenceKeypoint.new(1, Color3.fromRGB(16,16,20))})
			KeyStroke.Color = Color3.fromRGB(45,45,55)
		end
	end)
	KeyBtn.MouseButton1Click:Connect(function() binding = true; UpdateText() end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if binding then
			if input.UserInputType == Enum.UserInputType.Keyboard then
				boundKey = (input.KeyCode == Enum.KeyCode.Escape) and nil or input.KeyCode
				binding = false; UpdateText()
				if callback then callback(boundKey) end
			elseif string.find(input.UserInputType.Name, "MouseButton") then
				boundKey = input.UserInputType
				binding = false; UpdateText()
				if callback then callback(boundKey) end
			end
		end
	end)

	return Container
end

local CONFIGS_KEY = "AstraConfigs_"
local AUTOLOAD_KEY = "AstraAutoload_"

local function ApplyConfigManager(parent, scriptName)
	local storeKey    = CONFIGS_KEY    .. (scriptName or "default")
	local autoloadKey = AUTOLOAD_KEY   .. (scriptName or "default")

	local function ReadStore()
		local ok, raw = pcall(readfile, storeKey)
		if ok and raw and raw ~= "" then
			local data = pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
			if type(data) == "table" then return data end
		end
		return {}
	end

	local function WriteStore(store)
		pcall(writefile, storeKey, game:GetService("HttpService"):JSONEncode(store))
	end

	local function ReadAutoload()
		local ok, raw = pcall(readfile, autoloadKey)
		if ok and raw and raw ~= "" then return raw end
		return ""
	end

	local function WriteAutoload(name)
		pcall(writefile, autoloadKey, name or "")
	end

	local registered = {}

	local Sep = Instance.new("Frame")
	Sep.Size = UDim2.new(1, 0, 0, 1)
	Sep.BackgroundColor3 = COLOR_BORDER
	Sep.BorderSizePixel = 0
	Sep.Parent = parent

	local SepLabel = Instance.new("TextLabel")
	SepLabel.Size = UDim2.new(1, 0, 0, 14)
	SepLabel.BackgroundTransparency = 1
	SepLabel.FontFace = FONT_MEDIUM
	SepLabel.Text = "Config Manager"
	SepLabel.TextColor3 = COLOR_TEXT_SUB
	SepLabel.TextSize = 10
	SepLabel.TextXAlignment = Enum.TextXAlignment.Left
	SepLabel.Parent = parent

	local nameInputContainer, nameInputAPI
	do
		nameInputContainer = Instance.new("Frame")
		nameInputContainer.Size = UDim2.new(1, 0, 0, 48)
		nameInputContainer.BackgroundTransparency = 1
		nameInputContainer.Parent = parent

		local LabelCfg = Instance.new("TextLabel")
		LabelCfg.Size = UDim2.new(1, 0, 0, 16)
		LabelCfg.BackgroundTransparency = 1
		LabelCfg.FontFace = FONT_MEDIUM
		LabelCfg.Text = "Config Name"
		LabelCfg.TextColor3 = COLOR_TEXT_WHITE
		LabelCfg.TextSize = 12
		LabelCfg.TextXAlignment = Enum.TextXAlignment.Left
		LabelCfg.Parent = nameInputContainer

		local BoxCfg = Instance.new("Frame")
		BoxCfg.Size = UDim2.new(1, 0, 0, 24)
		BoxCfg.Position = UDim2.new(0, 0, 0, 18)
		BoxCfg.BackgroundColor3 = COLOR_BOX_INACTIVE
		BoxCfg.BorderSizePixel = 0
		BoxCfg.Parent = nameInputContainer

		Instance.new("UICorner", BoxCfg).CornerRadius = UDim.new(0, 5)

		local BoxStrokeCfg = Instance.new("UIStroke")
		BoxStrokeCfg.Color = COLOR_BOX_BORDER
		BoxStrokeCfg.Thickness = 1
		BoxStrokeCfg.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		BoxStrokeCfg.Parent = BoxCfg

		local TextBoxCfg = Instance.new("TextBox")
		TextBoxCfg.Size = UDim2.new(1, -16, 1, 0)
		TextBoxCfg.Position = UDim2.new(0, 8, 0, 0)
		TextBoxCfg.BackgroundTransparency = 1
		TextBoxCfg.FontFace = FONT_REGULAR
		TextBoxCfg.PlaceholderText = "Enter a name..."
		TextBoxCfg.PlaceholderColor3 = COLOR_TEXT_SUB
		TextBoxCfg.Text = ""
		TextBoxCfg.TextColor3 = COLOR_TEXT_WHITE
		TextBoxCfg.TextSize = 11
		TextBoxCfg.TextXAlignment = Enum.TextXAlignment.Left
		TextBoxCfg.ClearTextOnFocus = false
		TextBoxCfg.Parent = BoxCfg

		TextBoxCfg.Focused:Connect(function() BoxStrokeCfg.Color = COLOR_TEXT_WHITE end)
		TextBoxCfg.FocusLost:Connect(function() BoxStrokeCfg.Color = COLOR_BOX_BORDER end)

		nameInputAPI = { Box = TextBoxCfg }
	end

	local dropdownFrame = Instance.new("Frame")
	dropdownFrame.Size = UDim2.new(1, 0, 0, 48)
	dropdownFrame.BackgroundTransparency = 1
	dropdownFrame.Parent = parent

	local dropdownLabel = Instance.new("TextLabel")
	dropdownLabel.Size = UDim2.new(1, 0, 0, 16)
	dropdownLabel.BackgroundTransparency = 1
	dropdownLabel.FontFace = FONT_MEDIUM
	dropdownLabel.Text = "Saved Configs"
	dropdownLabel.TextColor3 = COLOR_TEXT_MUTED
	dropdownLabel.TextSize = 12
	dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
	dropdownLabel.Parent = dropdownFrame

	local ddHeader = Instance.new("TextButton")
	ddHeader.Size = UDim2.new(1, 0, 0, 26)
	ddHeader.Position = UDim2.new(0, 0, 0, 18)
	ddHeader.BackgroundColor3 = COLOR_BOX_INACTIVE
	ddHeader.BorderSizePixel = 0
	ddHeader.AutoButtonColor = false
	ddHeader.Text = ""
	ddHeader.Parent = dropdownFrame

	Instance.new("UICorner", ddHeader).CornerRadius = UDim.new(0, 5)

	local ddHeaderStroke = Instance.new("UIStroke")
	ddHeaderStroke.Color = COLOR_BOX_BORDER
	ddHeaderStroke.Thickness = 1
	ddHeaderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ddHeaderStroke.Parent = ddHeader

	local ddSelectedText = Instance.new("TextLabel")
	ddSelectedText.Size = UDim2.new(1, -28, 1, 0)
	ddSelectedText.Position = UDim2.new(0, 8, 0, 0)
	ddSelectedText.BackgroundTransparency = 1
	ddSelectedText.FontFace = FONT_MEDIUM
	ddSelectedText.Text = "None"
	ddSelectedText.TextColor3 = COLOR_TEXT_WHITE
	ddSelectedText.TextSize = 12
	ddSelectedText.TextXAlignment = Enum.TextXAlignment.Left
	ddSelectedText.TextTruncate = Enum.TextTruncate.AtEnd
	ddSelectedText.Parent = ddHeader

	local ddChevron = Instance.new("ImageLabel")
	ddChevron.Size = UDim2.new(0, 12, 0, 12)
	ddChevron.Position = UDim2.new(1, -8, 0.5, 0)
	ddChevron.AnchorPoint = Vector2.new(1, 0.5)
	ddChevron.BackgroundTransparency = 1
	ddChevron.ImageColor3 = COLOR_TEXT_MUTED
	ApplyIcon(ddChevron, "chevron-down")
	ddChevron.Parent = ddHeader

	local ddOptionHolder = Instance.new("Frame")
	ddOptionHolder.Size = UDim2.new(1, 0, 0, 0)
	ddOptionHolder.Position = UDim2.new(0, 0, 0, 48)
	ddOptionHolder.BackgroundColor3 = COLOR_BOX_INACTIVE
	ddOptionHolder.BorderSizePixel = 0
	ddOptionHolder.Visible = false
	ddOptionHolder.ClipsDescendants = true
	ddOptionHolder.ZIndex = 10
	ddOptionHolder.Parent = dropdownFrame

	Instance.new("UICorner", ddOptionHolder).CornerRadius = UDim.new(0, 5)

	local ddOptionStroke = Instance.new("UIStroke")
	ddOptionStroke.Color = COLOR_BOX_BORDER
	ddOptionStroke.Thickness = 1
	ddOptionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ddOptionStroke.Parent = ddOptionHolder

	local ddOptionLayout = Instance.new("UIListLayout")
	ddOptionLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ddOptionLayout.Padding = UDim.new(0, 2)
	ddOptionLayout.Parent = ddOptionHolder

	local ddOptionPad = Instance.new("UIPadding")
	ddOptionPad.PaddingTop    = UDim.new(0, 4)
	ddOptionPad.PaddingBottom = UDim.new(0, 4)
	ddOptionPad.PaddingLeft   = UDim.new(0, 4)
	ddOptionPad.PaddingRight  = UDim.new(0, 4)
	ddOptionPad.Parent = ddOptionHolder

	local ddIsOpen = false
	local ddSelectedName = "None"

	local function RefreshDropdown()
		for _, child in ipairs(ddOptionHolder:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end

		local store = ReadStore()
		local names = {}
		for k in pairs(store) do table.insert(names, k) end
		table.sort(names)

		if #names == 0 then
			ddSelectedText.Text = "None"
			ddSelectedName = "None"
		end

		for _, name in ipairs(names) do
			local OptBtn = Instance.new("TextButton")
			OptBtn.Size = UDim2.new(1, 0, 0, 22)
			OptBtn.BackgroundColor3 = COLOR_ACTIVE_BG
			OptBtn.BackgroundTransparency = (name == ddSelectedName) and 0 or 1
			OptBtn.BorderSizePixel = 0
			OptBtn.FontFace = FONT_REGULAR
			OptBtn.Text = name
			OptBtn.TextColor3 = (name == ddSelectedName) and COLOR_TEXT_WHITE or COLOR_TEXT_MUTED
			OptBtn.TextSize = 11
			OptBtn.TextXAlignment = Enum.TextXAlignment.Left
			OptBtn.AutoButtonColor = false
			OptBtn.ZIndex = 11
			OptBtn.Parent = ddOptionHolder

			local OptPad = Instance.new("UIPadding")
			OptPad.PaddingLeft = UDim.new(0, 6)
			OptPad.Parent = OptBtn

			Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)

			OptBtn.MouseEnter:Connect(function() OptBtn.BackgroundTransparency = 0; OptBtn.TextColor3 = COLOR_TEXT_WHITE end)
			OptBtn.MouseLeave:Connect(function()
				if name ~= ddSelectedName then OptBtn.BackgroundTransparency = 1; OptBtn.TextColor3 = COLOR_TEXT_MUTED end
			end)

			OptBtn.MouseButton1Click:Connect(function()
				ddSelectedName = name
				ddSelectedText.Text = name
				nameInputAPI.Box.Text = name
				ddIsOpen = false
				ddOptionHolder.Visible = false
				ddChevron.Rotation = 0
				ddHeaderStroke.Color = COLOR_BOX_BORDER
				dropdownFrame.Size = UDim2.new(1, 0, 0, 48)
				RefreshDropdown()
			end)
		end

		local totalH = (#names * 24) + 8
		if ddIsOpen then
			ddOptionHolder.Size = UDim2.new(1, 0, 0, math.min(totalH, 120))
			dropdownFrame.Size = UDim2.new(1, 0, 0, 48 + math.min(totalH, 120) + 4)
		end
	end

	ddHeader.MouseButton1Click:Connect(function()
		ddIsOpen = not ddIsOpen
		ddOptionHolder.Visible = ddIsOpen
		ddChevron.Rotation = ddIsOpen and 180 or 0
		ddHeaderStroke.Color = ddIsOpen and COLOR_TEXT_WHITE or COLOR_BOX_BORDER
		RefreshDropdown()
		if not ddIsOpen then
			dropdownFrame.Size = UDim2.new(1, 0, 0, 48)
		end
	end)

	local AutoloadLabel = Instance.new("TextLabel")
	AutoloadLabel.Size = UDim2.new(1, 0, 0, 14)
	AutoloadLabel.BackgroundTransparency = 1
	AutoloadLabel.FontFace = FONT_REGULAR
	AutoloadLabel.Text = "Autoload: none"
	AutoloadLabel.TextColor3 = COLOR_TEXT_SUB
	AutoloadLabel.TextSize = 10
	AutoloadLabel.TextXAlignment = Enum.TextXAlignment.Left
	AutoloadLabel.Parent = parent

	local function RefreshAutoloadLabel()
		local al = ReadAutoload()
		AutoloadLabel.Text = "Autoload: " .. (al ~= "" and al or "none")
	end

	RefreshAutoloadLabel()

	CreateButton(parent, "Save Config", function()
		local name = nameInputAPI.Box.Text
		if name == "" then
			Notify({ Title = "Config Manager", Text = "Enter a config name first.", Icon = "alert-circle", Duration = 3 })
			return
		end

		local store = ReadStore()
		local snapshot = {}
		for key, pair in pairs(registered) do
			local ok, val = pcall(pair.getter)
			if ok then snapshot[key] = val end
		end
		store[name] = snapshot
		WriteStore(store)
		ddSelectedName = name
		ddSelectedText.Text = name
		RefreshDropdown()
		Notify({ Title = "Config Manager", Text = "Saved \"" .. name .. "\".", Icon = "check", Duration = 3 })
	end)

	CreateButton(parent, "Load Config", function()
		local name = ddSelectedName
		if name == "" or name == "None" then
			Notify({ Title = "Config Manager", Text = "Select a config to load.", Icon = "alert-circle", Duration = 3 })
			return
		end

		local store = ReadStore()
		local snapshot = store[name]
		if not snapshot then
			Notify({ Title = "Config Manager", Text = "Config not found.", Icon = "alert-circle", Duration = 3 })
			return
		end

		for key, val in pairs(snapshot) do
			if registered[key] then
				pcall(registered[key].setter, val)
			end
		end
		Notify({ Title = "Config Manager", Text = "Loaded \"" .. name .. "\".", Icon = "check", Duration = 3 })
	end)

	CreateButton(parent, "Overwrite Config", function()
		local name = ddSelectedName
		if name == "" or name == "None" then
			Notify({ Title = "Config Manager", Text = "Select a config to overwrite.", Icon = "alert-circle", Duration = 3 })
			return
		end

		local store = ReadStore()
		local snapshot = {}
		for key, pair in pairs(registered) do
			local ok, val = pcall(pair.getter)
			if ok then snapshot[key] = val end
		end
		store[name] = snapshot
		WriteStore(store)
		Notify({ Title = "Config Manager", Text = "Overwrote \"" .. name .. "\".", Icon = "check", Duration = 3 })
	end)

	CreateButton(parent, "Set as Autoload", function()
		local name = ddSelectedName
		if name == "" or name == "None" then
			Notify({ Title = "Config Manager", Text = "Select a config to set as autoload.", Icon = "alert-circle", Duration = 3 })
			return
		end
		WriteAutoload(name)
		RefreshAutoloadLabel()
		Notify({ Title = "Config Manager", Text = "\"" .. name .. "\" will load on startup.", Icon = "check", Duration = 3 })
	end)

	CreateButton(parent, "Remove Autoload", function()
		WriteAutoload("")
		RefreshAutoloadLabel()
		Notify({ Title = "Config Manager", Text = "Autoload cleared.", Icon = "check", Duration = 3 })
	end)

	local api = {}

	function api:Register(key, getter, setter)
		registered[key] = { getter = getter, setter = setter }
	end

	task.defer(function()
		local al = ReadAutoload()
		if al ~= "" then
			local store = ReadStore()
			local snapshot = store[al]
			if snapshot then
				for key, val in pairs(snapshot) do
					if registered[key] then pcall(registered[key].setter, val) end
				end
				Notify({ Title = "Config Manager", Text = "Autoloaded \"" .. al .. "\".", Icon = "check", Duration = 3 })
			end
		end
	end)

	return api
end

local TabsData = {
	{ Name = "Main Tab", Icon = "layout" },
	{ Name = "Settings", Icon = "sliders" },
	{
		Name = "Visuals",
		Icon = "eye",
		SubTabs = {
			{ Name = "SubTab 1", Icon = "user" },
			{ Name = "SubTab 2", Icon = "globe" },
			{ Name = "SubTab 3", Icon = "sparkles" }
		}
	},
	{ Name = "Tools",  Icon = "terminal" },
	{ Name = "Misc",   Icon = "shield" }
}

local TabObjects = {}
local ActiveTabRef    = nil
local ActiveSubTabRef = nil

local TabPages = {}

local function UpdateHeader(title, icon)
	ContentHeader.Text = title
	ApplyIcon(ContentHeaderIcon, icon)
end

local function ShowPage(name)
	for n, page in pairs(TabPages) do
		page.Visible = (n == name)
	end
end

local function SetTabActive(tabObj, isActive)
	tabObj.Btn.BackgroundColor3 = isActive and COLOR_ACTIVE_BG or Color3.fromRGB(0,0,0)
	tabObj.Btn.BackgroundTransparency = isActive and 0 or 1
	tabObj.Icon.ImageColor3 = isActive and COLOR_TEXT_WHITE or COLOR_TEXT_MUTED
	tabObj.Label.TextColor3 = isActive and COLOR_TEXT_WHITE or COLOR_TEXT_MUTED
	tabObj.Label.FontFace = isActive and FONT_BOLD or FONT_MEDIUM
	if tabObj.Indicator then tabObj.Indicator.Visible = isActive end
end

local function SetSubTabActive(subObj, isActive)
	subObj.Btn.BackgroundColor3 = isActive and COLOR_ACTIVE_BG or Color3.fromRGB(0,0,0)
	subObj.Btn.BackgroundTransparency = isActive and 0 or 1
	subObj.Icon.ImageColor3 = isActive and COLOR_TEXT_WHITE or COLOR_TEXT_MUTED
	subObj.Label.TextColor3 = isActive and COLOR_TEXT_WHITE or COLOR_TEXT_MUTED
	subObj.Label.FontFace = isActive and FONT_BOLD or FONT_MEDIUM
	if subObj.Indicator then subObj.Indicator.Visible = isActive end
end

local function MakePage(name)
	local Page = Instance.new("Frame")
	Page.Name = "Page_" .. name
	Page.Size = UDim2.new(1, 0, 1, 0)
	Page.BackgroundTransparency = 1
	Page.Visible = false
	Page.Parent = ContentArea
	TabPages[name] = Page
	return Page
end

for i, data in ipairs(TabsData) do
	local tabObj = {}
	tabObj.Data = data
	tabObj.Expanded = false

	local TabBtn = Instance.new("TextButton")
	TabBtn.Name = "Tab_" .. data.Name
	TabBtn.Size = UDim2.new(1, 0, 0, 30)
	TabBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
	TabBtn.BackgroundTransparency = 1
	TabBtn.BorderSizePixel = 0
	TabBtn.AutoButtonColor = false
	TabBtn.Text = ""
	TabBtn.LayoutOrder = i * 10
	TabBtn.Parent = NavContainer
	tabObj.Btn = TabBtn

	Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

	local ActiveIndicator = Instance.new("Frame")
	ActiveIndicator.Size = UDim2.new(0, 3, 0, 16)
	ActiveIndicator.Position = UDim2.new(0, 0, 0.5, -8)
	ActiveIndicator.BackgroundColor3 = COLOR_TEXT_WHITE
	ActiveIndicator.BorderSizePixel = 0
	ActiveIndicator.Visible = false
	ActiveIndicator.Parent = TabBtn
	tabObj.Indicator = ActiveIndicator

	Instance.new("UICorner", ActiveIndicator).CornerRadius = UDim.new(0, 2)

	local TabIcon = Instance.new("ImageLabel")
	TabIcon.Size = UDim2.new(0, 15, 0, 15)
	TabIcon.Position = UDim2.new(0, 10, 0.5, -7.5)
	TabIcon.BackgroundTransparency = 1
	TabIcon.ImageColor3 = COLOR_TEXT_MUTED
	ApplyIcon(TabIcon, data.Icon)
	TabIcon.Parent = TabBtn
	tabObj.Icon = TabIcon

	local TabLabel = Instance.new("TextLabel")
	TabLabel.Size = UDim2.new(1, -48, 1, 0)
	TabLabel.Position = UDim2.new(0, 32, 0, 0)
	TabLabel.BackgroundTransparency = 1
	TabLabel.FontFace = FONT_MEDIUM
	TabLabel.Text = data.Name
	TabLabel.TextColor3 = COLOR_TEXT_MUTED
	TabLabel.TextSize = 13
	TabLabel.TextXAlignment = Enum.TextXAlignment.Left
	TabLabel.Parent = TabBtn
	tabObj.Label = TabLabel

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
		SubContainer.Parent = NavContainer
		tabObj.SubContainer = SubContainer

		local SubLayout = Instance.new("UIListLayout")
		SubLayout.SortOrder = Enum.SortOrder.LayoutOrder
		SubLayout.Padding = UDim.new(0, 2)
		SubLayout.Parent = SubContainer

		tabObj.SubObjects = {}

		for j, subData in ipairs(data.SubTabs) do
			local subObj = {}
			subObj.Data = subData

			local SubBtn = Instance.new("TextButton")
			SubBtn.Size = UDim2.new(1, 0, 0, 28)
			SubBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
			SubBtn.BackgroundTransparency = 1
			SubBtn.BorderSizePixel = 0
			SubBtn.AutoButtonColor = false
			SubBtn.Text = ""
			SubBtn.LayoutOrder = j
			SubBtn.Parent = SubContainer
			subObj.Btn = SubBtn

			Instance.new("UICorner", SubBtn).CornerRadius = UDim.new(0, 6)

			local SubIndicator = Instance.new("Frame")
			SubIndicator.Size = UDim2.new(0, 3, 0, 14)
			SubIndicator.Position = UDim2.new(0, 12, 0.5, -7)
			SubIndicator.BackgroundColor3 = COLOR_TEXT_WHITE
			SubIndicator.BorderSizePixel = 0
			SubIndicator.Visible = false
			SubIndicator.Parent = SubBtn
			subObj.Indicator = SubIndicator

			Instance.new("UICorner", SubIndicator).CornerRadius = UDim.new(0, 2)

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

			local subPageKey = data.Name .. "/" .. subData.Name
			MakePage(subPageKey)

			SubBtn.MouseButton1Click:Connect(function()
				if ActiveTabRef    then SetTabActive(ActiveTabRef, false)       end
				if ActiveSubTabRef then SetSubTabActive(ActiveSubTabRef, false) end
				ActiveTabRef    = nil
				ActiveSubTabRef = subObj
				SetSubTabActive(subObj, true)
				UpdateHeader(data.Name .. " / " .. subData.Name, subData.Icon)
				ShowPage(subPageKey)
			end)

			table.insert(tabObj.SubObjects, subObj)
		end
	else
		MakePage(data.Name)
	end

	TabBtn.MouseButton1Click:Connect(function()
		if data.SubTabs then
			tabObj.Expanded = not tabObj.Expanded
			tabObj.SubContainer.Visible = tabObj.Expanded
			tabObj.Chevron.Rotation = tabObj.Expanded and 180 or 0

			if tabObj.Expanded and #tabObj.SubObjects > 0 then
				local isSubActive = false
				for _, sub in ipairs(tabObj.SubObjects) do
					if sub == ActiveSubTabRef then isSubActive = true; break end
				end
				if not isSubActive then
					if ActiveTabRef    then SetTabActive(ActiveTabRef, false)       end
					if ActiveSubTabRef then SetSubTabActive(ActiveSubTabRef, false) end
					ActiveTabRef    = nil
					ActiveSubTabRef = tabObj.SubObjects[1]
					SetSubTabActive(tabObj.SubObjects[1], true)
					local subPageKey = data.Name .. "/" .. tabObj.SubObjects[1].Data.Name
					UpdateHeader(data.Name .. " / " .. tabObj.SubObjects[1].Data.Name, tabObj.SubObjects[1].Data.Icon)
					ShowPage(subPageKey)
				end
			end
		else
			if ActiveTabRef    then SetTabActive(ActiveTabRef, false)       end
			if ActiveSubTabRef then SetSubTabActive(ActiveSubTabRef, false) end
			ActiveSubTabRef = nil
			ActiveTabRef    = tabObj
			SetTabActive(tabObj, true)
			UpdateHeader(data.Name, data.Icon)
			ShowPage(data.Name)
		end
	end)

	table.insert(TabObjects, tabObj)
end

if #TabObjects > 0 then
	local first = TabObjects[1]
	ActiveTabRef = first
	SetTabActive(first, true)
	UpdateHeader(first.Data.Name, first.Data.Icon)
	ShowPage(first.Data.Name)
end

SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
	local q = string.lower(SearchInput.Text)
	for _, tabObj in ipairs(TabObjects) do
		local matchParent = (q == "") or string.find(string.lower(tabObj.Data.Name), q, 1, true)
		tabObj.Btn.Visible = matchParent or false

		if tabObj.SubObjects then
			local anySubMatch = false
			for _, sub in ipairs(tabObj.SubObjects) do
				local matchSub = (q == "") or string.find(string.lower(sub.Data.Name), q, 1, true)
				sub.Btn.Visible = matchSub
				if matchSub then anySubMatch = true end
			end
			if anySubMatch and not matchParent then tabObj.Btn.Visible = true end
			if tabObj.SubContainer then
				tabObj.SubContainer.Visible = (q ~= "") and (matchParent or anySubMatch) or tabObj.Expanded
			end
		end
	end
end)

return {
	Notify = Notify,

	GetPage = function(tabName) return TabPages[tabName] end,

	MakeGroupbox = MakeGroupbox,

	CreateLabel         = CreateLabel,
	CreateCheckbox      = CreateCheckbox,
	CreateSlider        = CreateSlider,
	CreateInput         = CreateInput,
	CreateDropdown      = CreateDropdown,
	CreateMultiDropdown = CreateMultiDropdown,
	CreateColorPicker   = CreateColorPicker,
	CreateButton        = CreateButton,
	CreateKeybind       = CreateKeybind,

	ApplyConfigManager  = ApplyConfigManager,
}
