-- Reference API example.
--
-- This script builds a menu using only the other library's call names
-- (CreateWindow, AddTab, AddLeftGroupbox, AddToggle, ...). The adapter layer in
-- Library.lua turns each one into this library's own API, so both styles work.
-- Example.lua builds the same kind of menu with the native names.
--
-- On touch devices the menu starts at 104 dpi, and SetDefaultSize below sets
-- the width and height it opens with.

local BASE = "https://raw.githubusercontent.com/sickletone/hstdhhagshsdgahshsbshxbchbshaiagsgsdtxbbashaghsgvcbcdgvsjgauagvxjhhdhdjcgbbsdujbhdfhsujhahdggfyhdhsb/refs/heads/main/"

local source = game:HttpGet(BASE .. "Library.lua")
assert(#source > 1000 and not string.find(source, "404", 1, true),
	"Library.lua not found at this URL, check the repo and branch")

local chunk, err = loadstring(source)
assert(chunk, "Library.lua does not compile: " .. tostring(err))

local Library = chunk()
assert(type(Library) == "table", "Library.lua returned nothing; the file is incomplete or truncated")

Library.BaseUrl = BASE

-- Icons come from the Molto lucide provider, same as the main example.
Library.IconProvider = "lucide"

-- Default menu size for every window this script creates.
Library:SetDefaultSize(1020, 620)

local Window = Library:CreateWindow({
	Title = "orasense",
	Suffix = ".win",
	Width = 1020,
	Height = 620,
	MinWidth = 520,
	MinHeight = 340,

	TabStyle = "top",     -- "top" or "side"
	TabWidth = 140,
	TitleSize = 15,
	TitleAlign = "left",
	TabAlign = "left",
})

-- AddTab also registers the tab in Window.Tabs, like the other library.
local Main     = Window:AddTab("main")
local Visuals  = Window:AddTab("visuals")
local Settings = Window:AddTab("settings")

-- main: a left box with one of every control, a right box with the rest.
local general = Main:AddLeftGroupbox("general")

general:AddToggle("ref_enable", {
	Text = "enable",
	Default = true,
	Tooltip = "master switch for this box",
	Callback = function(state) print("enable", state) end,
})

general:AddSlider("ref_speed", {
	Text = "speed",
	Min = 0,
	Max = 100,
	Default = 40,
	Suffix = "%",
})

general:AddDropdown("ref_mode", {
	Text = "mode",
	Values = { "safe", "fast", "aggressive" },
	Default = "safe",
	Callback = function(value) print("mode", value) end,
})

general:AddKeyPicker("ref_key", {
	Text = "toggle key",
	Default = "F",
	Mode = "toggle",
})

general:AddColorPicker("ref_color", {
	Text = "highlight",
	Default = Color3.fromRGB(232, 161, 168),
})

general:AddInput("ref_prefix", {
	Text = "prefix",
	Placeholder = "obj_",
})

general:AddButton({
	Text = "say hello",
	Tooltip = "Notify takes a message and a lifetime in this API",
	Func = function() Library:Notify("hello from the reference API", 3) end,
})

general:AddLabel("AddLabel(text, true) keeps the wrap.", true)
general:AddDivider()

-- A dependency box only shows while the flags it names match.
local extra = general:AddDependencyBox()
extra:AddToggle("ref_extra", { Text = "extra option" })
extra:AddSlider("ref_strength", { Text = "strength", Min = 0, Max = 10, Default = 5 })
extra:SetupDependencies({ { Toggle = "ref_enable", Value = true } })

local behaviour = Main:AddRightGroupbox("behaviour")

behaviour:AddMultiDropdown("ref_ignore", {
	Text = "ignore",
	Values = { "friends", "team", "invisible", "dead" },
	Default = { "friends", "dead" },
})

behaviour:AddSlider("ref_delay", {
	Text = "delay",
	Min = 0,
	Max = 500,
	Default = 60,
	Suffix = " ms",
})

-- AddLeftTabbox / AddRightTabbox return a box with AddTab, like theirs.
local tabbox = Main:AddRightTabbox()

local firstTab = tabbox:AddTab("first tab")
firstTab:AddToggle("ref_tab_toggle", { Text = "tab toggle", Default = true })
firstTab:AddSlider("ref_tab_slider", { Text = "tab slider", Min = 0, Max = 10, Default = 3 })

local secondTab = tabbox:AddTab("second tab")
secondTab:AddDropdown("ref_tab_dropdown", {
	Text = "tab dropdown",
	Values = { "a", "b", "c" },
	Default = "a",
})
secondTab:AddButton({
	Text = "notify",
	Func = function() Library:Notify("the second tab works", 2) end,
})

-- visuals: glass and blur, the two looks this library adds on top.
local look = Visuals:AddLeftGroupbox("look")

look:AddToggle("ref_glass", {
	Text = "glass",
	Default = Library.Glass == true,
	Callback = function(state) Library:SetGlass(state) end,
})

look:AddSlider("ref_glass_strength", {
	Text = "glass strength",
	Min = 0,
	Max = 150,
	Default = 100,
	Suffix = "%",
	Callback = function(value) Library:SetGlassStrength(value / 100) end,
})

look:AddToggle("ref_blur", {
	Text = "menu blur",
	Default = Library.MenuBlur == true,
	Callback = function(state) Library:SetMenuBlur(state) end,
})

look:AddSlider("ref_blur_strength", {
	Text = "blur strength",
	Min = 0,
	Max = 30,
	Default = Library.MenuBlurStrength or 12,
	Callback = function(value) Library:SetMenuBlurStrength(value) end,
})

local readout = Visuals:AddRightGroupbox("readout")
readout:AddLabel("every Add* call from the reference API works here.")
readout:AddButton({
	Text = "notify",
	Func = function() Library:Notify("the right box works too", 2) end,
})
readout:AddDivider()
readout:AddLabel("wrapped label, because the flag is true.", true)
readout:AddLabel("single line label.")

-- settings: keybinds, then the watermark controls.
local keys = Settings:AddLeftGroupbox("keys")

keys:AddKeyPicker("ref_always", { Text = "always", Default = "Z", Mode = "always" })
keys:AddKeyPicker("ref_hold", { Text = "hold", Default = "Q", Mode = "hold" })
keys:AddKeyPicker("ref_toggle", { Text = "toggle", Default = "T", Mode = "toggle" })

local session = Settings:AddRightGroupbox("session")

session:AddToggle("ref_watermark", {
	Text = "watermark",
	Default = true,
	Callback = function(state) Library:SetWatermarkVisibility(state) end,
})

session:AddButton({
	Text = "rename watermark",
	Func = function()
		Library:SetWatermark("orasense " .. tostring(math.random(100, 999)) .. ".win")
	end,
})

session:AddButton({
	Text = "print tabs",
	Func = function()
		for name in pairs(Window.Tabs) do
			print("tab:", name)
		end
	end,
})

session:AddLabel("Window:AddTab also fills Window.Tabs.")

-- The watermark and a first notification, both reference calls.
Library:SetWatermark("orasense.win")
Library:Notify("reference example loaded", 4)

Library:Notify({
	Title = "tips",
	Text = "Library:Toggle() hides the menu, Library:Unload() removes it.",
	Duration = 6,
})
