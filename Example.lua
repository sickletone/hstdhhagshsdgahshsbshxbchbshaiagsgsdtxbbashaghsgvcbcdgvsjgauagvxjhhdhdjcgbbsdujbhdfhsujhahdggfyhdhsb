local BASE = "https://raw.githubusercontent.com/sickletone/hstdhhagshsdgahshsbshxbchbshaiagsgsdtxbbashaghsgvcbcdgvsjgauagvxjhhdhdjcgbbsdujbhdfhsujhahdggfyhdhsb/refs/heads/main/"

local source = game:HttpGet(BASE .. "Library.lua")
assert(#source > 1000 and not string.find(source, "404", 1, true),
        "Library.lua not found at this URL, check the repo and branch")

local chunk, err = loadstring(source)
assert(chunk, "Library.lua does not compile: " .. tostring(err))

local Library = chunk()
assert(type(Library) == "table", "Library.lua returned nothing; the file is incomplete or truncated")

Library.BaseUrl = BASE

-- Tab, sub tab and control icons come from the Molto lucide provider.
Library.IconProvider = "lucide"

-- Glass is opt-in: the only controls for it live in settings > themes.
Library.Glass = false
Library.LiquidGlass = false

-- One square menu size and one dpi for every platform, mobile included.
Library:SetDefaultSize(620, 620)
Library:SetDpi(98)

local Players = game:GetService("Players")

local SaveManager = Library.SaveManager
local InterfaceManager = Library.InterfaceManager
local ThemeManager = Library.ThemeManager

assert(SaveManager and InterfaceManager and ThemeManager,
        "addons not found, check Library.BaseUrl and the addons/ folder")

local Window = Library:Window({
        Title = "orasense",
        Suffix = ".win",
        Width = 620,
        Height = 620,
        MinWidth = 520,
        MinHeight = 340,

        TabStyle = "top",    -- "top" (default) or "side"; CategoryMod = 1 / 2 also works
        TabWidth = 140,

        -- Title: free size and horizontal alignment.
        TitleSize = 16,      -- 9 to 28
        TitleAlign = "left", -- "left", "center" or "right"

        -- Tabs: aligned at the top, or placed at the bottom of the window.
        TabAlign = "left",   -- "left", "center", "right", "bottomleft", "bottom", "bottomright"

        -- Discord: joins the server silently through the local RPC API
        -- Discord = {
        --     Invite        = "xxxxxxx",   -- code without discord.gg/
        --     RememberJoins = true,
        -- },

        -- Key system: blocks until a key is validated
        -- KeySystem = true,
        -- KeySettings = {
        --     Title           = "Orasense",
        --     Subtitle        = "Enter your key to continue",
        --     Note            = "Get your key on our Discord",
        --     FileName        = "OrasenseKey",
        --     SaveKey         = true,
        --     GrabKeyFromSite = false,
        --     Key             = { "ORASENSE-2024", "ORASENSE-BETA" },
        -- },
})

-- Tab order: main, visuals, world, misc, settings.
-- Icons are Molto lucide names and the tab name only shows on hover or while
-- the tab is active, so the strip stays icon-only.
local Main     = Window:Tab({ Title = "Main", Icon = "house" })
local Visuals  = Window:Tab({ Title = "Visuals", Icon = "eye" })
local World    = Window:Tab({ Title = "World", Icon = "globe" })
local Misc     = Window:Tab({ Title = "Misc", Icon = "settings-2" })
local Settings = Window:Tab({ Title = "Settings", Icon = "settings" })

local settingsOptions = Settings:SubTab({ Title = "Options", Icon = "wand-sparkles" })
local settingsThemes = Settings:SubTab({ Title = "Themes", Icon = "palette" })

-- Watermark: built here, before the rest of the menu, so the pill is on screen
-- from the first frame and its box exists even if something later fails.
local watermark = Library:Watermark({
        Title = "orasense",
        Suffix = ".win",
        Width = 268,
        Padding = 8,        -- thickness: lower this for a slimmer pill
        RowHeight = 18,
        StatsHeight = 15,
        -- below the Roblox topbar buttons, which sit at the very top left
        Position = UDim2.fromOffset(18, 96),
})
watermark:SetVisible(true)

-- Floating toolbar: an icon bar pinned to the bottom center of the screen.
-- Each button owns a window; the dot under an icon means that window is open.
local toolbar = Library:FloatingToolbar({
        -- the bar docks six pixels under the menu; these set its thickness
        Height = 44,
        ButtonWidth = 30,
        ButtonHeight = 34,
        IconSize = 18,
        Items = {
                { Title = "Menu", Icon = "layout-dashboard", Window = Window },
                {
                        Title = "Keybind Menu",
                        Icon = "keyboard",
                        OnClick = function()
                                Library:SetKeybindListVisible(not Library.HotkeysEnabled)
                        end,
                        IsActive = function() return Library.HotkeysEnabled ~= false end,
                },
        },
})

local watermarkSection = settingsOptions:Section("Watermark", 1)

local watermarkToggle
watermarkToggle = watermarkSection:Toggle({
        Text = "Hide Watermark",
        Flag = "overlay_watermark",
        Hint = "FPS, ping, players and region",
        Default = true,
        Callback = function(state)
                watermark:SetVisible(state)
                if watermarkToggle then
                        watermarkToggle:SetText(state and "Hide Watermark" or "Show Watermark")
                end
        end,
})


-- The touch toggle only exists on mobile, so this sub tab is mobile-only.
-- Every control carries a Flag, so the whole panel is written to a config file.
if Library.IsMobile then
local mobileTab = Settings:SubTab({ Title = "Mobile", Icon = "smartphone" })
        local mobileButton = mobileTab:Section("Menu Button", 1)
        local cfg = Library.MobileConfig and Library:MobileConfig() or {}
        local function apply(options) Library:SetMobileButtonOptions(options) end

        mobileButton:Slider({
                Text = "Transparency",
                Flag = "mobile_button_transparency",
                Min = 0, Max = 1, Decimals = 2,
                Default = cfg.Transparency or 0,
                Callback = function(v) apply({ Transparency = v }) end,
        })
        mobileButton:Slider({
                Text = "Width",
                Flag = "mobile_button_width",
                Min = 28, Max = 96,
                Default = cfg.Width or 44,
                Callback = function(v) apply({ Width = v }) end,
        })
        mobileButton:Slider({
                Text = "Height",
                Flag = "mobile_button_height",
                Min = 28, Max = 96,
                Default = cfg.Height or 44,
                Callback = function(v) apply({ Height = v }) end,
        })
        mobileButton:Slider({
                Text = "Icon Size",
                Flag = "mobile_button_icon",
                Min = 8, Max = 36,
                Default = cfg.IconSize or 18,
                Callback = function(v) apply({ IconSize = v }) end,
        })

        local holdSlider
        mobileButton:Dropdown({
                Text = "Toggle Mode",
                Flag = "mobile_button_mode",
                Options = { "tap", "tap twice", "hold" },
                Default = cfg.Mode == "tap_twice" and "tap twice" or (cfg.Mode or "tap"),
                Callback = function(choice)
                        local mode = (choice == "tap twice") and "tap_twice" or choice
                        apply({ Mode = mode })
                        if holdSlider then holdSlider.Instance.Visible = (mode == "hold") end
                end,
        })
        holdSlider = mobileButton:Slider({
                Text = "Hold Duration",
                Flag = "mobile_button_hold",
                Min = 0.2, Max = 2, Decimals = 2, Suffix = " s",
                Default = cfg.HoldDuration or 0.6,
                Callback = function(v) apply({ HoldDuration = v }) end,
        })
        if holdSlider then holdSlider.Instance.Visible = (cfg.Mode == "hold") end

        local behaviour = mobileTab:Section("Behaviour", 1)

        behaviour:Toggle({
                Text = "Invisible Button",
                Flag = "mobile_button_invisible",
                Hint = "Hides the button, tapping it still works",
                Default = cfg.Invisible == true,
                Callback = function(state) apply({ Invisible = state }) end,
        })

        local lockToggle
        lockToggle = behaviour:Toggle({
                Text = (cfg.Locked and "Unlock Mobile Toggle" or "Lock Mobile Toggle"),
                Flag = "mobile_button_locked",
                Hint = "Keeps the button in place so it cannot be dragged",
                Default = cfg.Locked == true,
                Callback = function(state)
                        apply({ Locked = state })
                        if lockToggle then
                                lockToggle:SetText(state and "Unlock Mobile Toggle" or "Lock Mobile Toggle")
                        end
                end,
        })

        -- The menu size lives on the library, so these two sliders resize the open
        -- window and every window created after them.
        local menuSize = mobileTab:Section("Menu Size", 2)
        menuSize:Slider({
                Text = "Width",
                Flag = "menu_default_width",
                Min = 520, Max = 1100,   -- the window never goes under its MinWidth
                Default = Library.DefaultWidth or 620,
                Callback = function(v) Library:SetDefaultSize(v, Library.DefaultHeight) end,
        })
        menuSize:Slider({
                Text = "Height",
                Flag = "menu_default_height",
                Min = 340, Max = 1100,   -- same for MinHeight
                Default = Library.DefaultHeight or 620,
                Callback = function(v) Library:SetDefaultSize(Library.DefaultWidth, v) end,
        })
end

local global = Main:Section("Global", 1)

global:Toggle({
        Text = "Enable",
        Flag = "global_enable",
        Callback = function(state) print("enable", state) end,
})
        :Keybind({ Default = "F", Flag = "global_enable_key" })
        :Gear(function(panel)
                panel:Slider({ Text = "Delay", Flag = "global_delay", Min = 0, Max = 500, Suffix = " ms", Default = 60 })
                panel:Dropdown({ Text = "Profile", Flag = "global_profile", Options = { "default", "custom" }, Default = "default" })
        end)

global:Toggle({ Text = "Auto Refresh", Flag = "auto_refresh", Default = true })
        :Gear(function(panel)
                panel:Slider({ Text = "Interval", Flag = "auto_refresh_interval", Min = 1, Max = 60, Suffix = " s", Default = 5 })
        end)

global:Toggle({ Text = "Simulation", Flag = "simulation", Hint = "Runs the local prediction pass" })
global:Toggle({ Text = "Cache Check", Flag = "cache_check" })

global:Toggle({ Text = "Motion Smoothing", Flag = "motion_smoothing", Default = true, Hint = "Interpolates between frames" })
        :Gear(function(panel)
                panel:Slider({ Text = "Strength", Flag = "motion_strength", Min = 0, Max = 1, Decimals = 2, Default = 0.35 })
        end)

global:Toggle({ Text = "No Jitter", Flag = "no_jitter", Default = true })
        :Gear(function(panel)
                panel:Slider({ Text = "Threshold", Flag = "jitter_threshold", Min = 0, Max = 20, Default = 4 })
        end)

global:Toggle({ Text = "No Drift", Flag = "no_drift", Default = true })
        :Gear(function(panel)
                panel:Slider({ Text = "Tolerance", Flag = "drift_tolerance", Min = 0, Max = 10, Decimals = 1, Default = 1.5 })
        end)

global:Toggle({ Text = "Clamp to Bounds", Flag = "clamp_bounds", Hint = "Keeps values inside the viewport" })

global:Toggle({ Text = "Radius Circle", Flag = "radius_circle" })
        :ColorPicker({ Flag = "radius_outline", Default = Color3.fromRGB(232, 161, 168) })
        :ColorPicker({ Flag = "radius_fill", Default = Color3.fromRGB(60, 60, 65), DefaultAlpha = 0.35 })
        :Gear(function(panel)
                panel:Slider({ Text = "Thickness", Flag = "radius_thickness", Min = 1, Max = 6, Default = 2 })
        end)

global:Toggle({ Text = "Object Lock", Flag = "object_lock", Hint = "Keeps the current selection" })
global:Toggle({ Text = "Fast Scan", Flag = "fast_scan" })

global:Toggle({
        Text = "Experimental Hitbox",
        Flag = "exp_hitbox",
        Style = "warning",
        Hint = "Unstable, may break in some places",
})

global:Toggle({
        Text = "Force Respawn",
        Flag = "force_respawn",
        Style = "danger",
        Hint = "Kills the character immediately",
})

global:Slider({
        Text = "Aggressive Rate",
        Flag = "aggressive_rate",
        Style = "warning",
        Min = 1,
        Max = 60,
        Suffix = " /s",
        Default = 8,
})

local transform = Main:Section("Transform", 1)

transform:Toggle({ Text = "Enable", Flag = "transform_enable" })
        :Keybind({ Default = "G", Flag = "transform_enable_key" })

transform:Dropdown({ Text = "Direction", Flag = "transform_direction", Options = { "forward", "backward", "mirrored" }, Default = "forward" })
transform:Dropdown({ Text = "Yaw", Flag = "transform_yaw", Options = { "none", "relative", "absolute" }, Default = "none" })
transform:Dropdown({ Text = "Pitch", Flag = "transform_pitch", Options = { "off", "clamped", "free" }, Default = "off" })

transform:Divider()

transform:Toggle({ Text = "Offset Angle", Flag = "transform_offset" })
        :Gear(function(panel)
                panel:Slider({ Text = "Angle", Flag = "transform_angle", Min = -180, Max = 180, Suffix = "°", Default = 0 })
        end)

local settings = Main:Section("Settings", 2)

settings:Dropdown({ Text = "Visualization", Flag = "visualization", Options = { "visible", "always", "hidden" }, Default = "visible" })
settings:Dropdown({ Text = "Anchor", Flag = "anchor", Options = { "head", "torso", "origin", "bounds" }, Default = "head" })
settings:Dropdown({ Text = "Target Selection", Flag = "target_selection", Options = { "crosshair", "distance", "priority" }, Default = "crosshair" })

settings:Dropdown({
        Text = "Ignore Conditions",
        Flag = "ignore_conditions",
        Options = { "friends", "hidden", "inactive" },
        Multi = true,
        Default = { "friends" },
        Empty = "none",
})

settings:Slider({ Text = "Radius", Flag = "radius", Min = 0, Max = 200, Default = 1 })
settings:Slider({ Text = "Max Distance", Flag = "max_distance", Min = 0, Max = 5000, Default = 0, ZeroText = "0 - unlimited" })

settings:ColorPicker({
        Text = "Highlight",
        Flag = "highlight_color",
        Default = Color3.fromRGB(232, 161, 168),
        DefaultAlpha = 1,
        Callback = function(color, alpha) print("highlight", color, alpha) end,
})

local groups = Main:Section("Group Filter", 2)

groups:Search({
        Placeholder = "",
        Label = "search",
        Live = true,
        Callback = function(text) print("query:", text) end,
})
groups:Label("no groups found.")


local leftNotes = Main:Section("Notes", 1)
leftNotes:Paragraph({
        Title = "Left Column",
        Content = "A paragraph inside a normal card. text wraps on the column width.",
        Icon = "info",
})
leftNotes:Label("plain label, no icon, no style.")

local rightNotes = Main:Section("Warnings", 2)
rightNotes:Paragraph({
        Title = "Right Column",
        Content = "Same thing on the other side.",
        Style = "warning",
        Icon = "alert-triangle",
})
rightNotes:Label("all systems nominal.", { Style = "success", Icon = "check" })

local visual = Main:Section("Preview", 2)

local avatar = visual:Image({ Height = 96, Corner = 8 })
avatar:SetUser(Players.LocalPlayer.UserId)

local board = Main:Section("Nearby", 2)

local roster = board:Table({
        Columns = { "player", "distance", "team" },
        MaxRows = 6,
        EmptyText = "nobody nearby",
})

local function rootOf(player)
        local character = player.Character
        return character and character:FindFirstChild("HumanoidRootPart")
end

task.spawn(function()
        while task.wait(1) do
                local rows = {}
                local myRoot = rootOf(Players.LocalPlayer)

                for _, other in ipairs(Players:GetPlayers()) do
                        if other ~= Players.LocalPlayer and #rows < 6 then
                                local otherRoot = rootOf(other)
                                local distance = "-"
                                if myRoot and otherRoot then
                                        distance = string.format("%dm",
                                                math.floor((myRoot.Position - otherRoot.Position).Magnitude))
                                end

                                table.insert(rows, {
                                        other.DisplayName,
                                        distance,
                                        other.Team and other.Team.Name or "none",
                                })
                        end
                end

                roster:SetRows(rows)
        end
end)

local notes = Main:Section("Reference", "full")

notes:Paragraph({
        Title = "Full Width",
        Content = "This box spans both columns. any element fits inside, stacked or side by side.",
        Icon = "info",
})

notes:Split({
        function(left)
                left:Paragraph({
                        Title = "Gears",
                        Content = "Options marked with a gear expose extra settings.",
                        Style = "warning",
                        Icon = "alert-triangle",
                })
        end,
        function(right)
                right:Paragraph({
                        Title = "Configs",
                        Content = "Only flagged elements are written to a config file.",
                        Style = "success",
                        Icon = "check",
                })
        end,
})

notes:Label("a full width box can hold as many paragraphs as you need.")

-- Orasense extras demo: dependency toggle, sub toggles, tab boxes.
local demoTab = Main
local leftBox = demoTab:LeftGroupbox("left box")
leftBox:Toggle({ Text = "Master Switch", Flag = "demo_master", Default = true }):Dependency(function(dep)
        dep:Toggle({ Text = "Hidden Option a", Flag = "demo_a", Default = true })
        dep:Slider({ Text = "Hidden Strength", Flag = "demo_strength", Min = 0, Max = 100, Default = 40 })
end)
local midBox = demoTab:MiddleGroupbox("middle box")
midBox:Toggle({ Text = "Parent", Flag = "demo_parent" })
midBox:SubToggle({ Text = "Sub Toggle", Flag = "demo_sub", Hint = "Indented child toggle" })
midBox:Dropdown({ Text = "Searchable", Flag = "demo_search", Options = { "alpha", "beta", "gamma", "delta", "epsilon", "zeta", "eta", "theta", "iota" }, Default = "alpha", Search = true })
local rightBox = demoTab:RightGroupbox("right box")
rightBox:Dropdown({ Text = "Multi Select", Flag = "demo_multi", Options = { "a", "b", "c", "d" }, Multi = true, Default = { "a" } })

local aim = World:Section("Aim", 1)

aim:Toggle({ Text = "Enabled", Flag = "aim_enabled", Default = true })
        :Keybind({ Default = "Q", Flag = "aim_key" })
aim:Slider({ Text = "Field of View", Flag = "aim_fov", Min = 1, Max = 180, Suffix = "°", Default = 80 })
aim:Slider({ Text = "Smoothness", Flag = "aim_smooth", Min = 0, Max = 100, Default = 20 })
aim:Segmented({ Text = "Mode", Flag = "aim_mode", Options = { "hold", "toggle" }, Default = "hold" })

local targeting = World:Section("Targeting", 2)

targeting:Dropdown({ Text = "Hitbox", Flag = "aim_hitbox", Options = { "head", "torso", "nearest" }, Default = "head" })
targeting:MultiDropdown({
        Text = "Ignore",
        Flag = "aim_ignore",
        Options = { "friends", "team", "invisible", "dead" },
        Default = { "friends", "dead" },
})
targeting:ToggleSwitch({ Text = "Wall Check", Flag = "aim_wall", Default = true })
targeting:SliderButtons({ Text = "Delay", Flag = "aim_delay", Min = 0, Max = 500, Step = 10, Suffix = " ms", Default = 60 })
targeting:ProgressBar({ Text = "Confidence", Default = 72, Style = "accent" })

local render = Visuals:Section("Render", 1)
render:Slider({ Text = "Quality", Flag = "render_quality", Min = 1, Max = 10, Default = 8 })
render:Slider({ Text = "Field of View", Flag = "render_fov", Min = 40, Max = 120, Suffix = "°", Default = 70 })
render:Toggle({ Text = "Fullbright", Flag = "render_fullbright" })
        :ColorPicker({ Flag = "render_ambient", Default = Color3.fromRGB(180, 180, 190) })

local effects = Visuals:Section("Effects", 2)
effects:Toggle({ Text = "Bloom", Flag = "fx_bloom", Default = true })
effects:Toggle({ Text = "Blur", Flag = "fx_blur" })
        :Gear(function(panel)
                panel:Slider({ Text = "Size", Flag = "fx_blur_size", Min = 0, Max = 24, Default = 8 })
        end)
effects:Slider({ Text = "Saturation", Flag = "fx_saturation", Min = -1, Max = 1, Decimals = 2, Default = 0 })

-- Look controls: glass, liquid glass and the menu blur. The same settings
-- also live in settings > themes and settings > options.
local look = Visuals:Section("Look", 2)

look:Toggle({
        Text = "Glass",
        Default = Library.Glass == true,
        Hint = "see-through Window fill",
        Callback = function(state) Library:SetGlass(state) end,
})

look:Slider({
        Text = "Glass Strength",
        Flag = false,
        Min = 0,
        Max = 150,
        Suffix = "%",
        Default = 100,
        Callback = function(value) Library:SetGlassStrength(value / 100) end,
})

look:Toggle({
        Text = "Liquid Glass",
        Default = Library.LiquidGlass == true,
        Hint = "Sheen travelling over the glass",
        Callback = function(state) Library:SetLiquidGlass(state) end,
})

look:Toggle({
        Text = "Menu Blur",
        Default = Library.MenuBlur == true,
        Hint = "Blurs the game behind the menu",
        Callback = function(state) Library:SetMenuBlur(state) end,
})

look:Slider({
        Text = "Blur Strength",
        Flag = false,
        Min = 0,
        Max = 30,
        Default = Library.MenuBlurStrength or 12,
        Callback = function(value) Library:SetMenuBlurStrength(value) end,
})

-- Min / Max / Default / Rounding on one slider. Click the value to type a
-- number: it is clamped to Min..Max and rounded to Rounding decimal places.
look:Slider({
        Text = "Rounding Demo",
        Flag = "look_rounding",
        Min = -50,
        Max = 50,
        Default = 10,
        Rounding = 2,
        Suffix = " u",
})

local objects = Misc:Section("Filters", 1)

objects:Toggle({ Text = "Static Objects", Flag = "static_objects" })

objects:Dropdown({
        Text = "Material",
        Flag = "objects_material",
        Options = { "plastic", "wood", "metal", "glass", "neon", "concrete", "brick", "sand", "grass", "ice", "marble", "fabric" },
        Default = "plastic",
})

objects:Keybind({
        Text = "Hold to Inspect",
        Flag = "objects_inspect",
        Default = "E",
        Mode = "hold",
        Callback = function(down) print("inspect", down) end,
})

objects:Keybind({
        Text = "Auto Collect",
        Flag = "objects_collect",
        Default = "H",
        Mode = "toggle",
        Callback = function(active) print("collect", active) end,
})

local naming = Misc:Section("Naming", 2)
naming:Input({
        Text = "Prefix",
        Flag = "objects_prefix",
        Default = "",
        Placeholder = "obj_",
        Callback = function(text) print("prefix", text) end,
})
naming:Button({ Text = "Apply to Selection", Callback = function() Library:Success("done", "prefix applied.", 3) end })

local status = Misc:Section("Status", 1)
status:Label("idle.", { Style = "dim" })
status:Slider({ Text = "Timeout", Flag = "net_timeout", Min = 1, Max = 30, Suffix = " s", Default = 10 })

Misc:Section("Mixer", 1):Slider({ Text = "Volume", Flag = "audio_volume", Min = 0, Max = 100, Suffix = "%", Default = 70 })

local editor = Misc:Section("Editor", 1)
editor:Button({ Text = "Reload Scripts", Callback = function() Library:Notify("orasense", "scripts reloaded.", 3) end })
editor:ButtonRow({
        { Text = "Run", Callback = function() print("run") end },
        { Text = "Stop", Callback = function() print("stop") end },
})

local console = Misc:Section("Output", 1)
console:Label("empty.")

local reference = Misc:Section("Reference", "full")
reference:Split({
        function(left)
                left:Paragraph({ Title = "Flags", Content = "Every stateful element takes a flag, used for saving.", Icon = "info" })
        end,
        function(middle)
                middle:Paragraph({ Title = "Styles", Content = "Warning, danger, success, accent.", Style = "warning", Icon = "alert-triangle" })
        end,
        function(right)
                right:Paragraph({ Title = "No Filesystem", Content = "Configs stay in memory for the session.", Style = "danger", Icon = "x-circle" })
        end,
})


Window:IconAction("info", function()
        Library:Notify("footer", "icon action from the footer.", 3)
end, 1)
Window:IconAction("check", function()
        Library:Success("footer", "second icon action.", 3)
end, 2)
Window:Action("Connect", function()
        Library:Notify({ Title = "Connected", Text = "Session Started.", Duration = 3 })
end)

SaveManager:SetLibrary(Library)
InterfaceManager:SetLibrary(Library)
InterfaceManager:SetWindow(Window)
ThemeManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("Orasense")
ThemeManager:SetFolder("Orasense")
SaveManager:SetFolder("Orasense/game")

InterfaceManager:BuildInterfaceSection(settingsOptions, 1)
SaveManager:BuildConfigSection(settingsOptions, 2)
if Library.BuildEffectsSection and settingsOptions then
        -- effects section (particles / background) lives in settings tab;
        -- the glass controls are in settings > themes, not here
        pcall(function() Library:BuildEffectsSection(settingsOptions, 1) end)
end
-- Themes tab mirrors settings > options: configs in the first column, the
-- editor in the second.
ThemeManager:BuildThemeConfigSection(settingsThemes, 1)
ThemeManager:Mount(Window, settingsThemes:Section("Theme", 2))

Window:SetTab(Main)

Library:Notify({
        Title = "Orasense",
        Text = "Script Loaded.",
        Duration = 5,
})

SaveManager:LoadAutoloadConfig()
ThemeManager:Load()

-- The theme and the config load after the window is built, so the glass
-- has to be applied once more or the window stays flat until a hide/show.
if Window.ApplyGlass then Window:ApplyGlass() end

local RunService = game:GetService("RunService")

-- Floating player panel: hidden until its settings toggle turns it on.
local hud = Library:Panel({
        Title = "Player",
        Icon = "user",
        Width = 190,
        Position = UDim2.fromOffset(18, 320),
        Visible = false,
})

hud.Content:Label("name", { Style = "dim" })
hud.Content:Label(Players.LocalPlayer.Name, { Style = "bright" })

hud.Content:Divider()

hud.Content:Label("health", { Style = "dim" })
local healthLabel = hud.Content:Label("-", { Style = "success" })

hud.Content:Label("players", { Style = "dim" })
local playersLabel = hud.Content:Label(tostring(#Players:GetPlayers()), { Style = "bright" })

hud:SetVisible(false)

task.spawn(function()
        while task.wait(0.5) do
                local character = Players.LocalPlayer.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                healthLabel:Set(humanoid and string.format("%d / %d", humanoid.Health, humanoid.MaxHealth) or "-")
                playersLabel:Set(tostring(#Players:GetPlayers()))
        end
end)

-- Server browser
-- Without options: lists the servers of the current place and joins them
-- with TeleportService, which fits most games.
--
-- PlaceId: targets another place, useful when the game has a separate lobby.
--
-- OnJoin: some games route their teleports through their own server and
--         reject a direct client call (error 773). In that case, pass a
--         function that goes through their module:
--
-- local servers = Library:ServerBrowser({
--     PlaceId = 123456789,
--     OnJoin = function(jobId, placeId, server)
--         local Teleporter = require(game.ReplicatedStorage.Path.To.Teleporter)
--         Teleporter.Request({ placeId = placeId, jobId = jobId })
--     end,
-- })

local servers = Library:ServerBrowser()

-- the server browser joins the toolbar once it exists
toolbar:AddItem({
        Title = "Server Browser",
        Icon = "server",
        Window = servers,
        IsActive = function() return servers.Visible == true end,
})

-- The keybind menu is on from the start: it fills itself as soon as keybinds
-- exist, and the overlay toggle below turns it off.
pcall(function() Library:SetKeybindListVisible(true) end)

local overlay = settingsOptions:Section("Overlay", 1)


overlay:Toggle({
        Text = "Server Browser",
        Flag = "overlay_servers",
        Hint = "Lists the public servers of this game",
        Default = false,
        Callback = function(state)
                servers:SetVisible(state)
        end,
})

overlay:Toggle({
        Text = "Player Panel",
        Hint = "Shows the floating player panel, off on every launch",
        Default = false,
        Callback = function(state)
                hud:SetVisible(state)
        end,
})

overlay:Toggle({
        Text = "Keybind Menu",
        Flag = "overlay_keybinds",
        Hint = "Floating list of every keybind in the menu, dragged like a panel",
        Default = true,
        Callback = function(state)
                Library:SetKeybindListVisible(state)
        end,
})

overlay:Dropdown({
        Text = "Keybind Menu Mode",
        Flag = "overlay_keybind_mode",
        Options = { "all", "active" },
        Default = "all",
        Callback = function(value)
                Library:SetKeybindListMode(value)
        end,
})

local toolbarToggle
toolbarToggle = overlay:Toggle({
        Text = "Hide Floating Toolbar",
        Flag = "overlay_toolbar",
        Hint = "The icon bar that docks under the menu",
        Default = true,
        Callback = function(state)
                toolbar:SetVisible(state)
                if toolbarToggle then
                        toolbarToggle:SetText(state and "Hide Floating Toolbar" or "Show Floating Toolbar")
                end
        end,
})

overlay:Toggle({
        Text = "Close Floating Toolbar with Menu",
        Flag = "overlay_toolbar_menu",
        Hint = "The bar hides whenever the menu is closed",
        Default = true,
        Callback = function(state)
                toolbar:SetFollowMenu(state)
        end,
})


-- Mini window: a second, smaller window that floats outside the menu. It
-- keeps its own title bar, drag and corner grip, and its Content accepts every
-- component. A toggle, a dropdown and a button all drive the same window.
local float = Library:MiniWindow({
        Title = "Mini Window",
        Width = 230,
        Height = 250,
        Position = UDim2.fromOffset(24, 120),
})
float.Content:Label("lives outside the menu, drag it anywhere.", { Style = "dim" })
float.Content:Dropdown({
        Text = "Popup",
        Flag = false,
        Options = { "glass", "solid", "liquid" },
        Default = "glass",
})
float.Content:Slider({
        Text = "Value",
        Flag = false,
        Min = 0,
        Max = 100,
        Suffix = "%",
        Default = 40,
})
float.Content:Button({
        Text = "Notify",
        Callback = function()
                Library:Notify({ Title = "orasense", Text = "Mini Window Works.", Style = "success", Duration = 2 })
        end,
})
float.Content:Toggle({ Text = "Stay Open", Default = true })
float:SetVisible(false)

local demoToggles = settingsOptions:Section("Windows", 1)

local floatToggle
local floatDropdown

local function setFloat(open)
        open = open ~= false
        if float.Visible == open then return end
        float:SetVisible(open)
        if floatToggle then pcall(function() floatToggle:Set(open, true) end) end
        if floatDropdown then pcall(function() floatDropdown:Set(open and "open" or "closed", true) end) end
end

floatToggle = demoToggles:Toggle({
        Text = "Mini Window",
        Default = false,
        Hint = "The dropdown and the button below drive the same window",
        Callback = function(state) setFloat(state) end,
})

floatDropdown = demoToggles:Dropdown({
        Text = "Mini Window State",
        Options = { "closed", "open" },
        Default = "closed",
        Callback = function(value) setFloat(value == "open") end,
})

demoToggles:Button({ Text = "Toggle Mini Window", Callback = function() setFloat(not float.Visible) end })

-- Embedded sub window: it stays inside the main window instead.
local sub = Window:SubWindow({ Title = "Sub Window", Width = 250, Height = 170 })
sub.Content:Label("a window inside the window.", { Style = "dim" })
sub.Content:Button({ Text = "Ping", Callback = function() Library:Notify({ Title = "orasense", Text = "Pong", Duration = 2 }) end })
sub:SetVisible(false)
demoToggles:Toggle({ Text = "Sub Window", Flag = "demo_subwindow", Callback = function(state) sub:SetVisible(state) end })


-- Every component, grouped in sub tabs.
local Components = Window:Tab("components")
local cInputs = Components:SubTab("inputs")
local cGroups = Components:SubTab("groups")
local cWindows = Components:SubTab("windows")

local inputsLeft = cInputs:Section("Controls", 1)
inputsLeft:Label("every control, with its default look.")
inputsLeft:Toggle({ Text = "Parent Toggle", Flag = "cmp_parent", Default = true })
        :Dependency(function(dep)
                dep:Toggle({ Text = "Child Toggle", Flag = "cmp_child", Default = true })
                dep:Slider({ Text = "Child Slider", Flag = "cmp_child_slider", Min = 0, Max = 100, Default = 25 })
        end)
inputsLeft:SubToggle({ Text = "Sub Toggle", Flag = "cmp_sub", Hint = "Indented child toggle" })
inputsLeft:DependencyToggle({ Text = "Dependency Toggle", Flag = "cmp_dep", Default = false }, function(dep)
        dep:Input({ Text = "Dep Input", Flag = "cmp_dep_input", Placeholder = "only visible when on" })
end)
inputsLeft:MultiDropdown({
        Text = "Multi Dropdown",
        Flag = "cmp_multi",
        Options = { "alpha", "beta", "gamma", "delta" },
        Default = { "alpha", "beta" },
})
inputsLeft:Dropdown({
        Text = "Searchable Dropdown",
        Flag = "cmp_search_dropdown",
        Options = { "one", "two", "three", "four", "five", "six", "seven", "eight" },
        Default = "one",
        Search = true,
})

local inputsRight = cInputs:Section("More Inputs", 2)
inputsRight:Slider({ Text = "Slider", Flag = "cmp_slider", Min = 0, Max = 100, Suffix = "%", Default = 40 })
local alwaysBind = inputsRight:Keybind({ Text = "Always Keybind", Flag = "cmp_always", Default = "Z", Mode = "always" })
local holdBind = inputsRight:Keybind({ Text = "Hold Keybind", Flag = "cmp_hold", Default = "Q", Mode = "hold" })
local toggleBind = inputsRight:Keybind({ Text = "Toggle Keybind", Flag = "cmp_toggle_key", Default = "T", Mode = "toggle" })
-- In game: one right click on a key pill removes its key, a double right click
-- opens the always / hold / toggle picker. The same editing works from code:
inputsRight:ButtonRow({
        { Text = "Edit Modes", Callback = function()
                toggleBind:SetMode("hold")
                holdBind:SetMode("toggle")
                Library:Notify("keybinds", "modes swapped.", 2)
        end },
        { Text = "Remove Keys", Callback = function()
                alwaysBind:Clear()
                Library:Notify("keybinds", "always key cleared.", 2)
        end },
})
inputsRight:Input({ Text = "Input", Flag = "cmp_input", Placeholder = "type something" })
inputsRight:Search({ Label = "search", Placeholder = "filter...", Live = true })
inputsRight:ColorPicker({ Text = "Color Picker", Flag = "cmp_color", Default = Color3.fromRGB(120, 180, 255) })
inputsRight:Divider()
inputsRight:Button({ Text = "Button", Callback = function() Library:Notify("button", "clicked.", 2) end })
inputsRight:ButtonRow({
        { Text = "Left", Callback = function() Library:Notify("row", "left pressed.", 2) end },
        { Text = "Right", Callback = function() Library:Notify("row", "right pressed.", 2) end },
})
inputsRight:Button({
        Text = "Button with Tooltip",
        Tooltip = "tooltips float above the menu, in their own layer",
        Callback = function() Library:Notify("tooltip", "hover me to see the tooltip.", 2) end,
})
inputsRight:Label("labels carry tooltips too.", { Tooltip = "this is a label tooltip" })
inputsRight:Button({
        Text = "Main Action",
        Tooltip = "sub buttons open while you hover the button",
        SubButtons = {
                { Text = "Sub One", Callback = function() Library:Notify("sub", "sub one pressed.", 2) end },
                { Text = "Sub Two", Callback = function() Library:Notify("sub", "sub two pressed.", 2) end },
        },
        Callback = function() Library:Notify("main", "main action pressed.", 2) end,
})
inputsRight:Paragraph({
        Title = "Paragraph",
        Content = "Labels, paragraphs, sliders, keybinds, inputs, search and dividers are all element types.",
        Style = "success",
        Icon = "check",
})

local groupsLeft = cGroups:LeftTabBox({ Title = "Left Box", Icon = "sliders-horizontal" })
groupsLeft:Toggle({ Text = "Left Toggle", Flag = "cmp_left_toggle", Default = true })
groupsLeft:Slider({ Text = "Left Slider", Flag = "cmp_left_slider", Min = 0, Max = 10, Default = 3 })

local groupsMiddle = cGroups:CenterTabBox({ Title = "Center Box", Icon = "settings" })
groupsMiddle:Label("middle column label.", { Style = "dim" })
groupsMiddle:Dropdown({ Text = "Middle Dropdown", Flag = "cmp_mid_dd", Options = { "a", "b", "c" }, Default = "a" })

local groupsRight = cGroups:RightTabBox({ Title = "Right Box", Icon = "wrench" })
groupsRight:Button({ Text = "Right Button", Callback = function() Library:Success("right", "works.", 2) end })
local cmpTable = groupsRight:Table({ Columns = { "name", "value" }, MaxRows = 3, EmptyText = "no rows" })
cmpTable:SetRows({ { "one", "1" }, { "two", "2" } })

local windowsDialogs = cWindows:Section("Dialogs", 1)
windowsDialogs:ButtonRow({
        { Text = "Modal", Callback = function()
                local modal = Window:Modal({ Title = "Modal", Width = 320, Height = 220 })
                modal.Content:Label("a modal with its own components.", { Style = "dim" })
                modal.Content:Toggle({ Text = "Modal Toggle", Flag = "cmp_modal_toggle", Default = true })
                modal.Content:Slider({ Text = "Modal Slider", Flag = "cmp_modal_slider", Min = 0, Max = 100, Default = 30 })
                modal.Content:Button({ Text = "Close", Callback = function() modal:SetOpen(false) end })
                modal:SetOpen(true)
        end },
        { Text = "Confirm", Callback = function()
                Window:Confirm({
                        Title = "Confirm",
                        Text = "This Is the Built in Confirm Dialog.",
                        Confirm = "accept",
                        Cancel = "dismiss",
                        OnConfirm = function() Library:Success("accepted", "you pressed accept.", 3) end,
                        OnCancel = function() Library:Notify("dismissed", "you pressed dismiss.", 3) end,
                })
        end },
})

local windowsOverlays = cWindows:Section("Overlays", 2)
windowsOverlays:Button({ Text = "Sub Window", Callback = function() sub:SetVisible(true) end })
windowsOverlays:Button({ Text = "Mini Window", Callback = function() float:SetVisible(true) end })
windowsOverlays:Button({ Text = "Server Browser", Callback = function() servers:SetVisible(true) end })
windowsOverlays:Button({ Text = "Player Panel", Callback = function()
        hud:SetVisible(true)
end })
-- Glass is configured only in settings > themes.


-- extra components: switches, sliders, display, cards
local cSwitches = Components:SubTab("switches")
local cSliders = Components:SubTab("sliders")
local cDisplay = Components:SubTab("display")
local cLayout = Components:SubTab("layout")

local switchLeft = cSwitches:Section("Toggles", 1)
switchLeft:ToggleSwitch({ Text = "Toggle Switch", Flag = "cmp_switch", Default = true })
switchLeft:BoxToggle({ Text = "Box Toggle", Hint = "Card style toggle", Flag = "cmp_boxtoggle", Default = true })
switchLeft:Checkbox({ Text = "Checkbox", Flag = "cmp_checkbox", Default = false })
switchLeft:RadioGroup({ Text = "Radio Group", Flag = "cmp_radio", Options = { "low", "medium", "high" }, Default = "medium" })

local switchRight = cSwitches:Section("More Toggles", 2)
switchRight:ToggleSwitch({ Text = "Second Switch", Flag = "cmp_switch2", Default = false })
switchRight:Segmented({ Text = "Quality", Flag = "cmp_segmented", Options = { "low", "mid", "high" }, Default = "mid" })
switchRight:Segmented({ Flag = "cmp_segmented2", Options = { "one", "two" }, Default = "one" })
switchRight:RadioGroup({ Text = "Mode", Flag = "cmp_radio2", Options = { "safe", "fast" }, Default = "safe" })

local sliderLeft = cSliders:Section("Sliders", 1)
sliderLeft:SliderButtons({ Text = "Slider + Buttons", Flag = "cmp_sliderbuttons", Min = 0, Max = 100, Step = 5, Default = 50, Suffix = "%" })
sliderLeft:SliderButtons({ Text = "Volume", Flag = "cmp_volume", Min = 0, Max = 10, Step = 1, Default = 7 })
sliderLeft:Stepper({ Text = "Stepper", Flag = "cmp_stepper", Min = 1, Max = 25, Step = 1, Default = 5 })
sliderLeft:Slider({
        Text = "Min / Max / Default",
        Flag = "cmp_slider_range",
        Min = 5,
        Max = 25,
        Default = 12,
        Suffix = " s",
})
sliderLeft:Slider({
        Text = "Rounding 1",
        Flag = "cmp_slider_rounding",
        Min = 0,
        Max = 10,
        Default = 5,
        Rounding = 1,
        Suffix = " x",
})

local sliderRight = cSliders:Section("Bars", 2)
local progress = sliderRight:ProgressBar({ Text = "Progress", Flag = "cmp_progress", Min = 0, Max = 100, Default = 42, Suffix = "%" })
sliderRight:SliderButtons({ Text = "Drives the Bar", Min = 0, Max = 100, Default = 42, Callback = function(v) progress:Set(v) end })
sliderRight:ProgressBar({ Text = "Static Bar", Default = 75, Style = "success" })

local displayLeft = cVisuals:Section("Stats", 1)
displayLeft:Stat({ Title = "Players", Value = "12", Sub = "+3 today", Style = "accent" })
displayLeft:KeyValueGrid({ Rows = { { "region", "eu" }, { "ping", "42 ms" }, { "uptime", "3h" }, { "build", "orasense.win" } } })
displayLeft:BulletList({ Title = "Features", Items = { "sub tabs", "full screen particles", "configs" } })
displayLeft:Badge({ Text = "Stable", Style = "success" })
displayLeft:Badge({ Text = "Beta", Style = "warning" })
displayLeft:ColorSwatches({ Text = "Swatches", Default = 2, Callback = function(c) Library:Notify("swatch", tostring(c), 2) end })

local displayRight = cVisuals:Section("Info", 2)
displayRight:Banner({ Title = "Info Banner", Content = "Banners support an icon, a title and a body.", Icon = "info", Style = "accent" })
displayRight:Banner({ Title = "Warning", Content = "This one can be dismissed.", Icon = "alert-triangle", Style = "warning" })
displayRight:Avatar({ Name = "player", Sub = "level 12" })
displayRight:Spinner({ Text = "Loading Something" })
displayRight:Link({ Text = "Link Component", Callback = function() Library:Notify("link", "link clicked.", 2) end })
displayRight:CopyField({ Value = "orasense.win", ButtonText = "copy" })
displayRight:TextArea({ Text = "Text Area", Placeholder = "multi line input", Default = "line one\nline two", Flag = "cmp_textarea" })
displayRight:LabelDivider("layout below")

local card = cLayout:Card({ Title = "Card Container" })
card:Label("cards group elements and keep long menus organized.", { Style = "dim" })
card:Toggle({ Text = "Card Toggle", Flag = "cmp_card_toggle", Default = true })
card:SliderButtons({ Text = "Card Slider", Flag = "cmp_card_slider", Min = 0, Max = 100, Default = 30 })
card:Divider()
card:Button({ Text = "Card Button", Callback = function() Library:Notify("card", "button inside a card.", 2) end })

local card2 = cLayout:Card("second card")
card2:Avatar({ Name = "row one", Sub = "inside a card" })
card2:Stat({ Title = "Value", Value = "42", Sub = "stat inside a card", Style = "success" })
card2:Badge({ Text = "Inside", Style = "accent" })