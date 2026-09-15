local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Ali-lov3/AstraUiLib/refs/heads/main/Source.lua"))()

local Window = Library.CreateWindow({
	Title = "Astra",
	Logo = 0,
	Anonymous = false,
	ConfigFolder = "AstraConfigs"
})

local ExampleTab = Window:CreateTab({
	Name = "Example",
	Icon = "layout"
})

local LeftSection = ExampleTab:CreateSection({
	Name = "Example Left",
	Side = "Left"
})

local RightSection = ExampleTab:CreateSection({
	Name = "Example Right",
	Side = "Right"
})

LeftSection:AddLabel("Example Label")

LeftSection:AddToggle({
	Name = "Example Toggle",
	Default = false,
	ConfigKey = "example_toggle",
	Callback = function(state) end
})

LeftSection:AddSlider({
	Name = "Example Slider",
	Min = 0,
	Max = 100,
	Default = 50,
	ConfigKey = "example_slider",
	Callback = function(val) end
})

LeftSection:AddInput({
	Name = "Example Input",
	Placeholder = "type here...",
	Default = "",
	ConfigKey = "example_input",
	Callback = function(text, entered) end
})

LeftSection:AddDropdown({
	Name = "Example Dropdown",
	Options = { "Option 1", "Option 2", "Option 3" },
	Default = "Option 1",
	ConfigKey = "example_dropdown",
	Callback = function(selected) end
})

RightSection:AddMultiDropdown({
	Name = "Example Multi Dropdown",
	Options = { "Choice A", "Choice B", "Choice C", "Choice D" },
	Default = { "Choice A" },
	ConfigKey = "example_multidrop",
	Callback = function(selected) end
})

RightSection:AddColorPicker({
	Name = "Example Color",
	Default = Color3.fromRGB(0, 230, 150),
	ConfigKey = "example_color",
	Callback = function(color) end
})

RightSection:AddKeybind({
	Name = "Example Keybind",
	Default = Enum.KeyCode.E,
	ConfigKey = "example_keybind",
	Callback = function(key) end
})

RightSection:AddButton({
	Name = "Example Button",
	Callback = function()
		Library.Notify({
			Title = "Astra",
			Text = "Example button pressed.",
			Icon = "check",
			Duration = 3
		})
	end
})

local ConfigTab = Window:CreateTab({
	Name = "Config",
	Icon = "settings"
})

local ConfigLeft = ConfigTab:CreateSection({
	Name = "Config Manager",
	Side = "Left"
})

ConfigLeft:ApplyConfigManager({})
