-- Orasense addon | ThemeManager

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
		{ "Accent", "accent" },
		{ "AccentSoft", "accent hover" },
		{ "AccentDim", "accent dim" },
		{ "Window", "window bg" },
		{ "WindowBorder", "window border" },
		{ "TopBar", "topbar bg" },
		{ "Section", "card bg" },
		{ "SectionBorder", "card border" },
		{ "Group", "group bg" },
		{ "GroupBorder", "group border" },
		{ "Field", "control bg" },
		{ "FieldHover", "control hover" },
		{ "Border", "control border" },
		{ "BorderSoft", "divider" },
		{ "PopupBg", "popup bg" },
		{ "PopupBorder", "popup border" },
		{ "Track", "slider track" },
		{ "Text", "text" },
		{ "TextDim", "text dim" },
		{ "TextBright", "text bright" },
		{ "TextMarked", "text warning" },
		{ "TextCode", "text success" },
		{ "Danger", "text danger" },
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

	function ThemeManager:SetFolder(folder)
		self.Folder = folder
		self.Library:BuildFolders(folder)
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
		return true
	end

	function ThemeManager:Save()
		local alphas = self.Library.ThemeAlpha or {}
		local colors = {}
		for _, entry in ipairs(self.Keys) do
			colors[entry[1]] = toHex(Theme[entry[1]], alphas[entry[1]])
		end
		local ok, encoded = pcall(function()
			-- Glass is deliberately not stored: it is a session look, set in
			-- Settings > themes, and must start off on every launch.
			return HttpService:JSONEncode({
				Preset = self.Current,
				Colors = colors,
			})
		end)
		if ok then self.Library.FileSystem:Write(self:Path(), encoded) end
		return ok
	end

	function ThemeManager:Load()
		local raw = self.Library.FileSystem:Read(self:Path())
		if not raw then return false end
		local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
		if not ok or type(data) ~= "table" then return false end

		if data.Preset then self:Apply(data.Preset) end
		-- Old theme files may still carry Glass / GlassBlur / GlassStrength.
		-- They are ignored on purpose so glass cannot come back on at launch.
		for key, hex in pairs(data.Colors or {}) do
			local color, alpha = fromHex(hex)
			if color and Theme[key] ~= nil then
				self.Library:SetColor(key, color, alpha)
			end
		end
		return true
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
				GlassBlur = self.Library.GlassBlur == true,
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

	function ThemeManager:Mount(window, container)
		window = window or self.Library.Windows[1]
		if not window then return nil end

		local alphas = self.Library.ThemeAlpha or {}
		local defaults = {}
		for _, entry in ipairs(self.Keys) do
			defaults[entry[1]] = Theme[entry[1]]
		end

		-- With a container the same editor is built straight into a settings
		-- sub tab; without one it stays a modal opened from the footer.
		local modal
		local content
		if container then
			content = container
		else
			-- no scrim: the interface behind has to stay readable while its
			-- colours are being edited
			modal = window:Modal({ Title = "theme", Width = 300, Height = 0.82, Dim = 0, Blur = 0 })
			content = modal.Content
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

		presetBox = content:Dropdown({
			Text = "preset",
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

		local glassToggle, blurToggle, strengthSlider, liquidToggle
		if self.Library.SetGlass then
			glassToggle = content:Toggle({
				Text = "glass",
				Flag = false,
				Default = self.Library.Glass == true,
				Hint = "see-through panels",
				Callback = function(state)
					self.Library:SetGlass(state)
					dirty = true
					if self.AutoSave then self:Save() end
				end,
			})
			blurToggle = content:Toggle({
				Text = "glass blur",
				Flag = false,
				Default = self.Library.GlassBlur ~= false,
				Hint = "frosts the menu glass instead of blurring the whole screen",
				Callback = function(state)
					self.Library:SetGlassBlur(state)
					dirty = true
					if self.AutoSave then self:Save() end
				end,
			})
			liquidToggle = content:Toggle({
				Text = "liquid glass",
				Flag = false,
			Default = self.Library.LiquidGlass == true,
				Hint = "true refractive liquid look, not plain blur",
				Callback = function(state)
					self.Library:SetLiquidGlass(state)
					dirty = true
					if self.AutoSave then self:Save() end
				end,
			})
			strengthSlider = content:Slider({
				Text = "glass strength",
				Flag = false,
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
		self.GlassToggle, self.BlurToggle, self.StrengthSlider, self.LiquidToggle = glassToggle, blurToggle, strengthSlider, liquidToggle

		content:Divider()

		for _, entry in ipairs(self.Keys) do
			local key, label = entry[1], entry[2]
			pickers[key] = content:ColorPicker({
				Text = label,
				Flag = false,
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

		content:Divider()

		content:Button({
			Text = "reset colors",
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
		})

		content:Button({
			Text = "export theme",
			Callback = function()
				local ok, result = self:Export()
				self.Library:Notify({
					Title = ok and "theme exported" or "theme error",
					Text = tostring(result),
					Duration = 4,
				})
			end,
		})

		if modal then
			modal.OnClose = function()
				if not dirty or self.AutoSave then
					dirty = false
					return
				end
				window:Confirm({
					Title = "theme",
					Text = "Save the colour changes?",
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
