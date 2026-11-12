

return function(Library)
	local HttpService = game:GetService("HttpService")
	local Theme = Library.Theme

	local ThemeManager = {}
	ThemeManager.Library = Library
	ThemeManager.Folder = "Orasense"
	ThemeManager.Flags = { "theme_preset", "theme_accent" }
	ThemeManager.AutoSave = false
	ThemeManager.Current = "orasense"

	ThemeManager.Keys = {
		{ "Accent", "Accent" },
		{ "AccentSoft", "Accent Hover" },
		{ "AccentDim", "Accent Dim" },
		{ "Window", "Window BG" },
		{ "WindowBorder", "Window Border" },
		{ "TopBar", "Topbar BG" },
		{ "Section", "Card BG" },
		{ "SectionBorder", "Card Border" },
		{ "Group", "Group BG" },
		{ "GroupBorder", "Group Border" },
		{ "Field", "Control BG" },
		{ "FieldHover", "Control Hover" },
		{ "Border", "Control Border" },
		{ "BorderSoft", "Divider" },
		{ "PopupBg", "Popup Bg" },
		{ "PopupBorder", "Popup Border" },
		{ "Track", "Slider Track" },
		{ "Text", "Text" },
		{ "TextDim", "Text Dim" },
		{ "TextBright", "Text Bright" },
		{ "TextMarked", "Text Warning" },
		{ "TextCode", "Text Success" },
		{ "Danger", "Text Danger" },
	}

	ThemeManager.Order = {
		"orasense", "darker", "typewriter", "aqua",
		"amethyst", "rose", "contrast", "light",
		"crimson", "dark", "onyx", "emerald",
		"toxic", "noir", "lagoon", "liquid",
	}

	ThemeManager.Presets = {
		orasense   = { Bg = Color3.fromRGB(26, 26, 28),    Accent = Color3.fromRGB(232, 161, 168) },
		darker     = { Bg = Color3.fromRGB(16, 16, 16),    Accent = Color3.fromRGB(72, 138, 182) },
		typewriter = { Bg = Color3.fromRGB(34, 34, 34),    Accent = Color3.fromRGB(109, 180, 120) },
		aqua       = { Bg = Color3.fromRGB(14, 22, 22),    Accent = Color3.fromRGB(60, 165, 165) },
		amethyst   = { Bg = Color3.fromRGB(18, 4, 32),     Accent = Color3.fromRGB(177, 51, 255) },
		rose       = { Bg = Color3.fromRGB(30, 18, 22),    Accent = Color3.fromRGB(200, 120, 170) },
		contrast   = { Bg = Color3.fromRGB(0, 0, 0),       Accent = Color3.fromRGB(86, 156, 214) },
		light      = { Bg = Color3.fromRGB(238, 238, 240), Accent = Color3.fromRGB(0, 103, 192), Light = true },
		crimson    = { Bg = Color3.fromRGB(19, 19, 19),    Accent = Color3.fromRGB(255, 24, 24) },
		dark       = { Bg = Color3.fromRGB(24, 24, 26),    Accent = Color3.fromRGB(96, 205, 255) },
		onyx       = { Bg = Color3.fromRGB(10, 10, 10),    Accent = Color3.fromRGB(235, 235, 235) },
		emerald    = { Bg = Color3.fromRGB(14, 24, 19),    Accent = Color3.fromRGB(52, 211, 153) },
		toxic      = { Bg = Color3.fromRGB(12, 18, 10),    Accent = Color3.fromRGB(166, 255, 0) },
		noir       = { Bg = Color3.fromRGB(10, 8, 9),      Accent = Color3.fromRGB(255, 92, 150) },
		lagoon     = { Bg = Color3.fromRGB(8, 20, 30),     Accent = Color3.fromRGB(34, 230, 222) },
		liquid     = { Bg = Color3.fromRGB(18, 22, 30),    Accent = Color3.fromRGB(125, 211, 252), Liquid = true },
	}

	local function shade(color, amount)
		return Color3.fromRGB(
			math.clamp(color.R * 255 + amount, 0, 255),
			math.clamp(color.G * 255 + amount, 0, 255),
			math.clamp(color.B * 255 + amount, 0, 255))
	end

	local function tint(color, saturation, value)
		local h, s, v = color:ToHSV()
		return Color3.fromHSV(h, math.clamp(s * saturation, 0, 1), math.clamp(v * value, 0, 1))
	end

	local function toHex(color, alpha)
		return string.format("#%02X%02X%02X%02X",
			math.floor(color.R * 255 + 0.5),
			math.floor(color.G * 255 + 0.5),
			math.floor(color.B * 255 + 0.5),
			math.floor(math.clamp(alpha or 1, 0, 1) * 255 + 0.5))
	end

	local function fromHex(text)
		if typeof(text) == "Color3" then return text, 1 end
		if type(text) ~= "string" then return nil end
		local hex = string.gsub(string.gsub(text, "#", ""), "%s", "")
		if #hex < 6 then return nil end
		local r = tonumber(string.sub(hex, 1, 2), 16)
		local g = tonumber(string.sub(hex, 3, 4), 16)
		local b = tonumber(string.sub(hex, 5, 6), 16)
		if not r or not g or not b then return nil end
		local a = 255
		if #hex >= 8 then a = tonumber(string.sub(hex, 7, 8), 16) or 255 end
		return Color3.fromRGB(r, g, b), a / 255
	end

	function ThemeManager:SetLibrary(lib)
		self.Library = lib or Library
	end

	function ThemeManager:BuildFolderTree()
		self.Library:BuildFolders(self.Folder)
		self.Library.FileSystem:MakeFolder(self:ThemeFolder())
	end

	function ThemeManager:SetFolder(folder)
		self.Folder = folder
		self:BuildFolderTree()
	end

	function ThemeManager:Path()
		return self.Folder .. "/settings/theme.json"
	end

	function ThemeManager:Names()
		local names = {}
		for index, name in ipairs(self.Order) do names[index] = name end
		return names
	end

	function ThemeManager:SetAccent(color)
		color = fromHex(color)
		if not color then return false end
		Theme.Accent = color
		Theme.AccentSoft = tint(color, 0.78, 1.08)
		Theme.AccentDim = tint(color, 0.72, 0.64)
		self.Library:Repaint()
		if self.SyncPickers then self.SyncPickers() end
		if self.AutoSave then self:Save() end
		return true
	end

	function ThemeManager:Apply(name)
		local preset = self.Presets[name]
		if not preset then return false end

		local bg = preset.Bg
		local step = preset.Light and -1 or 1

		Theme.Window = bg
		Theme.TopBar = shade(bg, 5 * step)
		Theme.Section = shade(bg, 3 * step)
		Theme.Group = shade(bg, 8 * step)
		Theme.Field = shade(bg, 14 * step)
		Theme.FieldHover = shade(bg, 22 * step)
		Theme.PopupBg = shade(bg, 12 * step)
		Theme.Track = shade(bg, 32 * step)

		Theme.WindowBorder = shade(bg, 26 * step)
		Theme.SectionBorder = shade(bg, 20 * step)
		Theme.GroupBorder = shade(bg, 28 * step)
		Theme.Border = shade(bg, 34 * step)
		Theme.BorderSoft = shade(bg, 19 * step)
		Theme.PopupBorder = shade(bg, 36 * step)

		if preset.Light then
			Theme.Text = Color3.fromRGB(70, 70, 76)
			Theme.TextDim = Color3.fromRGB(122, 122, 130)
			Theme.TextBright = Color3.fromRGB(24, 24, 28)
			Theme.TextMarked = Color3.fromRGB(158, 132, 30)
			Theme.TextCode = Color3.fromRGB(38, 138, 60)
			Theme.Danger = Color3.fromRGB(196, 58, 58)
		else
			Theme.Text = Color3.fromRGB(174, 174, 178)
			Theme.TextDim = Color3.fromRGB(108, 108, 113)
			Theme.TextBright = Color3.fromRGB(228, 228, 232)
			Theme.TextMarked = Color3.fromRGB(198, 198, 122)
			Theme.TextCode = Color3.fromRGB(96, 200, 96)
			Theme.Danger = Color3.fromRGB(226, 102, 102)
		end

		self.Current = name
		if self.Library.SetLiquidGlass then
			self.Library:SetLiquidGlass(preset.Liquid == true)
		end
		self:SetAccent(preset.Accent)
		if self.SyncPickers then self.SyncPickers() end
		return true
	end

	local function applyData(data)
		if type(data) ~= "table" then return false end
		if data.Preset then ThemeManager:Apply(data.Preset) end
		for key, hex in pairs(data.Colors or {}) do
			local color, alpha = fromHex(hex)
			if color and Theme[key] ~= nil then
				ThemeManager.Library:SetColor(key, color, alpha)
			end
		end
		if ThemeManager.Library.SetLiquidGlass and data.LiquidGlass ~= nil then
			ThemeManager.Library:SetLiquidGlass(data.LiquidGlass == true)
		end
		ThemeManager.Library:Repaint()
		if ThemeManager.SyncPickers then ThemeManager.SyncPickers() end
		if ThemeManager.AutoSave then ThemeManager:Save() end
		return true
	end

	function ThemeManager:Save()
		local encoded = self:Encode()
		if not encoded then return false end
		self.Library.FileSystem:Write(self:Path(), encoded)
		return true
	end

	function ThemeManager:Load()
		local autoload = self:GetAutoload()
		local path = autoload and self:ThemePath(autoload) or self:Path()
		local raw = path and self.Library.FileSystem:Read(path)
		if not raw or raw == "" then return false end
		local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
		if not ok or type(data) ~= "table" then return false end


		return applyData(data)
	end

	function ThemeManager:Encode()
		local alphas = self.Library.ThemeAlpha or {}
		local colors = {}
		for _, entry in ipairs(self.Keys) do
			colors[entry[1]] = toHex(Theme[entry[1]], alphas[entry[1]])
		end
		local ok, encoded = pcall(function()
			return HttpService:JSONEncode({
				Preset = self.Current,
				Colors = colors,
				Glass = self.Library.Glass == true,
				GlassStrength = self.Library.GlassStrength or 1,
				LiquidGlass = self.Library.LiquidGlass == true,
			})
		end)
		if not ok then return nil end
		return encoded
	end

	function ThemeManager:Export(name)
		local encoded = self:Encode()
		if not encoded then return false, "encode failed" end
		local file = tostring(name or self.Current or "theme")
		file = string.gsub(file, "[^%w%-%_ ]", "")
		if file == "" then file = "theme" end
		local folder = self.Folder .. "/themes"
		self.Library.FileSystem:MakeFolder(folder)
		local path = folder .. "/" .. file .. ".json"
		if not self.Library.FileSystem:Write(path, encoded) then return false, "write failed" end
		local copied = false
		if typeof(setclipboard) == "function" then
			copied = pcall(setclipboard, encoded)
		end
		return true, path .. (copied and " (copied)" or "")
	end








	function ThemeManager:ThemeFolder()
		return self.Folder .. "/themes"
	end

	function ThemeManager:ThemePath(file)
		if type(file) ~= "string" or file == "" then return nil end
		if not string.match(file, "%.%w+$") then file = file .. ".json" end
		return self:ThemeFolder() .. "/" .. file
	end

	function ThemeManager:List()
		self.Library.FileSystem:MakeFolder(self:ThemeFolder())
		return self.Library.FileSystem:List(self:ThemeFolder())
	end

	function ThemeManager:SaveAs(name)
		if type(name) ~= "string" or string.gsub(name, "%s", "") == "" then
			return false, "empty name"
		end
		local encoded = self:Encode()
		if not encoded then return false, "encode failed" end
		local path = self:ThemePath(name)
		if not path then return false, "bad name" end
		self.Library.FileSystem:MakeFolder(self:ThemeFolder())
		if not self.Library.FileSystem:Write(path, encoded) then return false, "write failed" end
		return true, tostring(string.match(path, "[^/]+$"))
	end
	ThemeManager.Create = ThemeManager.SaveAs
	ThemeManager.Overwrite = ThemeManager.SaveAs

	function ThemeManager:LoadAs(file)
		local path = self:ThemePath(file)
		if not path then return false, "no theme" end
		local raw = self.Library.FileSystem:Read(path)
		if not raw or raw == "" then return false, "not found" end
		local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
		if not ok or type(data) ~= "table" then return false, "corrupted file" end
		if not applyData(data) then return false, "corrupted file" end
		return true, tostring(file)
	end

	function ThemeManager:DeleteTheme(file)
		local path = self:ThemePath(file)
		if not path then return false, "no theme" end
		self.Library.FileSystem:Delete(path)
		if self:GetAutoload() == file then self:ClearAutoload() end
		return true, tostring(file)
	end

	function ThemeManager:AutoloadPath()
		return self.Folder .. "/settings/theme_autoload.txt"
	end

	function ThemeManager:GetAutoload()
		local name = self.Library.FileSystem:Read(self:AutoloadPath())
		if not name or name == "" then return nil end
		return name
	end

	function ThemeManager:SetAutoload(file)
		if type(file) ~= "string" or file == "" then return false end
		self.Library:BuildFolders(self.Folder .. "/settings")
		return self.Library.FileSystem:Write(self:AutoloadPath(), file)
	end

	function ThemeManager:ClearAutoload()
		self.Library.FileSystem:Delete(self:AutoloadPath())
	end

	function ThemeManager:CopyToClipboard()
		local encoded = self:Encode()
		if not encoded then return false, "encode failed" end
		if typeof(setclipboard) ~= "function" then return false, "clipboard unavailable" end
		setclipboard(encoded)
		return true, "copied"
	end

	function ThemeManager:ImportFromClipboard()
		local reader = typeof(getclipboard) == "function" and getclipboard or nil
		if not reader then return false, "clipboard unavailable" end
		local ok, data = pcall(function() return HttpService:JSONDecode(reader()) end)
		if not ok or type(data) ~= "table" then return false, "invalid clipboard" end
		if not applyData(data) then return false, "invalid clipboard" end
		return true, "imported"
	end

	function ThemeManager:BuildThemeConfigSection(tab, column)
		local section = tab:Section("Configs", column or 1)
		local nameBox = section:Input({ Text = "Name", Flag = false, Default = "default", Placeholder = "Theme Name" })
		local savedBox = section:Dropdown({ Text = "Saved", Flag = false, Options = self:List(), Empty = "None", Search = true })
		local autoloadLabel

		local function refreshList(select)
			savedBox:SetOptions(self:List())
			if select then savedBox:Set(select, true) end
		end

		local function selected()
			local file = savedBox:Get()
			if type(file) ~= "string" or file == "" then return nil end
			return file
		end

		local function exists(file)
			for _, name in ipairs(self:List()) do
				if name == file or name == file .. ".json" then return true end
			end
			return false
		end

		local function notify(ok, result, action)
			self.Library:Notify({
				Title = ok and ("theme " .. action) or "theme error",
				Text = tostring(result),
				Duration = 3,
			})
		end

		section:ButtonRow({
			{
				Text = "Create",
				Callback = function()
					local name = nameBox:Get()
					if name == "" then return notify(false, "enter a name", "") end
					local file = name .. (string.match(name, "%.%w+$") and "" or ".json")
					if exists(file) then return notify(false, file .. " already exists, use overwrite", "") end
					local ok, result = self:SaveAs(name)
					if ok then refreshList(result) end
					notify(ok, result, "created")
				end,
			},
			{
				Text = "Overwrite",
				Callback = function()
					local file = selected() or nameBox:Get()
					if not file or file == "" then return notify(false, "no theme", "") end
					local ok, result = self:SaveAs(file)
					if ok then refreshList(result) end
					notify(ok, result, "overwritten")
				end,
			},
		})

		section:ButtonRow({
			{
				Text = "Load",
				Callback = function()
					local ok, result = self:LoadAs(selected())
					notify(ok, result, "loaded")
				end,
			},
			{
				Text = "Refresh List",
				Callback = function()
					refreshList()
					notify(true, "theme list refreshed", "refreshed")
				end,
			},
		})

		section:ButtonRow({
			{
				Text = "Delete",
				Callback = function()
					local file = selected()
					if not file then return notify(false, "no theme", "") end

					local function remove()
						local ok, result = self:DeleteTheme(file)
						if ok then
							refreshList()
							if autoloadLabel then autoloadLabel:Set("autoload: " .. (self:GetAutoload() or "none")) end
						end
						notify(ok, result, "deleted")
					end

					local window = self.Library.Windows[1]
					if not window then return remove() end
					window:Confirm({
						Title = "Delete Theme",
						Text = "Delete " .. file .. " permanently?",
						Confirm = "delete",
						Cancel = "cancel",
						OnConfirm = remove,
					})
				end,
			},
			{
				Text = "Set Autoload",
				Callback = function()
					local file = selected()
					if not file then return notify(false, "no theme", "") end
					self:SetAutoload(file)
					if autoloadLabel then autoloadLabel:Set("autoload: " .. file) end
					notify(true, file, "autoload set")
				end,
			},
		})

		section:ButtonRow({
			{
				Text = "Remove Autoload",
				Callback = function()
					self:ClearAutoload()
					if autoloadLabel then autoloadLabel:Set("autoload: none") end
					notify(true, "autoload cleared", "autoload removed")
				end,
			},
			{
				Text = "Copy to Clipboard",
				Callback = function()
					local ok, result = self:CopyToClipboard()
					notify(ok, result, "copied")
				end,
			},
		})

		section:ButtonRow({
			{
				Text = "Import from Clipboard",
				Callback = function()
					local ok, result = self:ImportFromClipboard()
					notify(ok, result, "imported")
				end,
			},
			{
				Text = "Export File",
				Callback = function()
					local ok, result = self:Export(selected() or nameBox:Get())
					if ok then refreshList(result) end
					notify(ok, result, "exported")
				end,
			},
		})

		autoloadLabel = section:Label("Autoload: " .. (self:GetAutoload() or "none"))

		self.ConfigSection = section
		return section
	end

	function ThemeManager:Mount(window, container)
		window = window or self.Library.Windows[1]
		if not window then return nil end

		local alphas = self.Library.ThemeAlpha or {}
		local defaults = {}
		for _, entry in ipairs(self.Keys) do
			defaults[entry[1]] = Theme[entry[1]]
		end



		local modal
		local content


		local controls, colors
		if container then
			content = container
			controls, colors = content, content
		else


			modal = window:Modal({ Title = "Theme", Width = 300, Height = 0.82, Dim = 0, Blur = 0 })
			content = modal.Content
			controls, colors = content, content
		end
		local pickers = {}
		local presetBox
		local snapshot, snapshotAlphas, snapshotPreset
		local dirty = false

		local function syncPickers()
			for key, picker in pairs(pickers) do
				picker:Set(Theme[key], alphas[key] or 1, true)
			end
		end
		self.SyncPickers = syncPickers

		local function takeSnapshot()
			snapshot, snapshotAlphas = {}, {}
			for _, entry in ipairs(self.Keys) do
				snapshot[entry[1]] = Theme[entry[1]]
				snapshotAlphas[entry[1]] = alphas[entry[1]] or 1
			end
			snapshotPreset = self.Current
			dirty = false
		end

		local function restoreSnapshot()
			if not snapshot then return end
			for key, color in pairs(snapshot) do
				Theme[key] = color
				alphas[key] = snapshotAlphas[key]
			end
			self.Current = snapshotPreset
			self.Library:Repaint()
			syncPickers()
			if presetBox and snapshotPreset then presetBox:Set(snapshotPreset, true) end
			dirty = false
		end

		presetBox = controls:Dropdown({
			Text = "Preset",
			Flag = "theme_preset",
			Options = self:Names(),
			Default = self.Current,
			Search = false,
			Callback = function(name)
				if self:Apply(name) then
					syncPickers()
					dirty = true
				end
			end,
		})

		local strengthSlider, liquidToggle
		if self.Library.SetGlass then
			liquidToggle = controls:Toggle({
				Text = "Liquid Glass",
				Flag = "theme_liquid",
			Default = self.Library.LiquidGlass == true,
				Hint = "True refractive liquid look, not plain blur",
				Callback = function(state)
					self.Library:SetLiquidGlass(state)
					dirty = true
					if self.AutoSave then self:Save() end
				end,
			})
			strengthSlider = controls:Slider({
				Text = "Glass Strength",
				Flag = "theme_strength",
				Min = 0,
				Max = 150,
				Suffix = "%",
				Default = math.floor((self.Library.GlassStrength or 1) * 100 + 0.5),
				Callback = function(value)
					self.Library:SetGlassStrength(value / 100)
					dirty = true
					if self.AutoSave then self:Save() end
				end,
			})
		end
		self.StrengthSlider, self.LiquidToggle = strengthSlider, liquidToggle

		controls:Divider()



		controls:ButtonRow({
			{
				Text = "Reset Colors",
				Callback = function()
					for key, color in pairs(defaults) do
						Theme[key] = color
						alphas[key] = 1
					end
					self.Current = "orasense"
					self.Library:Repaint()
					syncPickers()
					if presetBox then presetBox:Set("orasense", true) end
					dirty = true
				end,
			},
			{
				Text = "Export Theme",
				Callback = function()
					local ok, result = self:Export()
					self.Library:Notify({
						Title = ok and "theme exported" or "theme error",
						Text = tostring(result),
						Duration = 4,
					})
				end,
			},
		})

		controls:Divider()

		for _, entry in ipairs(self.Keys) do
			local key, label = entry[1], entry[2]
			pickers[key] = colors:ColorPicker({
				Text = label,
				Flag = "theme_color_" .. key,
				Default = Theme[key],
				DefaultAlpha = alphas[key] or 1,
				Callback = function(color, alpha)
					self.Library:SetColor(key, color, alpha)
					self.Library:Repaint()
					dirty = true
					if key == "Accent" then
						self:SetAccent(color)
						syncPickers()
					elseif self.AutoSave then
						self:Save()
					end
				end,
			})
		end

		if modal then
			modal.OnClose = function()
				if not dirty or self.AutoSave then
					dirty = false
					return
				end
				window:Confirm({
					Title = "Theme",
					Text = "Save the Colour Changes?",
					Confirm = "save",
					Cancel = "discard",
					OnConfirm = function()
						self:Save()
						dirty = false
					end,
					OnCancel = restoreSnapshot,
				})
			end

			window:IconAction("paintbrush", function()
				if not modal.Open then takeSnapshot() end
				modal:Toggle()
			end)
		else
			takeSnapshot()
		end

		self.Modal = modal
		self.Pickers = pickers
		return modal or content
	end

	return ThemeManager
end
