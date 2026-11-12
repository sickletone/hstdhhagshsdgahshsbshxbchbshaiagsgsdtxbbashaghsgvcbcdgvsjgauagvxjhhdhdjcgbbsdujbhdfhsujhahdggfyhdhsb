


local function Build(Library)
	local InterfaceManager = {}
	InterfaceManager.Library = Library
	InterfaceManager.Folder = "Orasense"
	InterfaceManager.Flags = { "interface_menu_key", "interface_scale", "interface_dpi", "interface_transparency", "interface_hotkeys", "interface_cursor", "orasense_particles", "orasense_particle_custom", "orasense_particle_rate", "orasense_particle_size", "orasense_particle_speed", "orasense_particle_start_speed", "orasense_particle_end_speed", "orasense_particle_spread", "orasense_background", "orasense_background_fade", "orasense_liquid", "orasense_menu_blur", "orasense_menu_blur_strength" }

	function InterfaceManager:SetLibrary(lib)
		self.Library = lib or Library
	end

	function InterfaceManager:SetWindow(window)
		self.Window = window
	end

	function InterfaceManager:SetFolder(folder)
		self.Folder = folder
		self.Library:BuildFolders(folder)
	end

	function InterfaceManager:GetWindow()
		return self.Window or self.Library.Windows[1]
	end

	function InterfaceManager:BuildInterfaceSection(tab, column)
		self.Settings = self.Settings or { MenuKey = "RightShift", Scale = 100, Dpi = 98, Hotkeys = false, Transparency = 0 }

		local section = tab:Section("interface", column or 1)
		local menuKey = section:Keybind({
			Text = "menu key",
			Flag = "interface_menu_key",
			Default = self.Settings.MenuKey,
			OnChanged = function(key)
				self.Settings.MenuKey = key or ""
				self.Library:SetToggleKey(key)
			end,
		})

		local scale, dpi
		scale = section:Slider({
			Text = "menu scale",
			Flag = "interface_scale",
			Min = 70,
			Max = 130,
			Suffix = "%",
			Default = self.Settings.Scale,
			Callback = function(v)
				self.Settings.Scale = v
				local win = self:GetWindow()
				if win then win:SetUserScale(v / 100) end
			end,
		})



		dpi = section:SliderButtons({
			Text = "dpi",
			Flag = "interface_dpi",
			Min = 60,
			Max = 160,
			Step = 2,
			Suffix = " dpi",
			Default = self.Settings.Dpi or 96,
			Callback = function(v)
				self.Settings.Dpi = v
				self.Library:SetDpi(v)
			end,
		})

		local transparency = section:Slider({
			Text = "menu transparency",
			Flag = "interface_transparency",
			Min = 0,
			Max = 90,
			Suffix = "%",
			Default = self.Settings.Transparency or 0,
			Callback = function(v)
				self.Settings.Transparency = v
				self.Library:SetMenuTransparency(v / 100)
			end,
		})

		local menuBlur = section:Toggle({
			Text = "menu blur",
			Flag = "orasense_menu_blur",
			Hint = "blurs the game behind the menu",
			Default = self.Library.MenuBlur == true,
			Callback = function(state)
				self.Library:SetMenuBlur(state)
			end,
		})

		local menuBlurStrength = section:Slider({
			Text = "blur strength",
			Flag = "orasense_menu_blur_strength",
			Min = 0,
			Max = 30,
			Default = self.Library.MenuBlurStrength or 12,
			Callback = function(value)
				self.Library:SetMenuBlurStrength(value)
			end,
		})

local hotkeys = section:Toggle({
			Text = "hotkeys panel",
			Flag = "interface_hotkeys",
			Hint = "shows active keybinds on screen",
			Default = self.Settings.Hotkeys == true,
			Callback = function(state)
				self.Settings.Hotkeys = state
				self.Library:SetHotkeysVisible(state)
			end,
		})

		local cursor = section:Toggle({
			Text = "custom cursor",
			Flag = "interface_cursor",
			Hint = "theme coloured cursor while the menu is open",
			Default = self.Library.ShowCustomCursor ~= false,
			Callback = function(state)
				self.Library:SetShowCustomCursor(state)
			end,
		})

		section:Button({
			Text = "unload",
			Callback = function()
				local window = self:GetWindow()
				if not window then return self.Library:Destroy() end
				window:Confirm({
					Title = "unload",
					Text = "Unload the interface? Unsaved changes will be lost.",
					Confirm = "unload",
					Cancel = "cancel",
					OnConfirm = function() self.Library:Destroy() end,
				})
			end,
		})

		menuKey:Set(self.Settings.MenuKey)
		scale:Set(self.Settings.Scale)
		dpi:Set(self.Settings.Dpi or 96, true)
		transparency:Set(self.Settings.Transparency or 0, true)
		hotkeys:Set(self.Settings.Hotkeys == true)
		cursor:Set(self.Library.ShowCustomCursor ~= false)
		menuBlur:Set(self.Library.MenuBlur == true)
		menuBlurStrength:Set(self.Library.MenuBlurStrength or 12, true)
		do
			local win = self:GetWindow()
			if win and win.SetDpi then win:SetDpi(self.Settings.Dpi or 96) end
			self.Library:SetMenuTransparency((self.Settings.Transparency or 0) / 100)
		end

		self.Section = section
		return section
	end

	function InterfaceManager:BuildEffectsSection(tab, column)
		if self.Library.BuildEffectsSection then
			return self.Library:BuildEffectsSection(tab, column)
		end
		return nil
	end

	function Library:Warn(title, text, duration)
		return self:Notify({ Title = title, Text = text, Duration = duration, Style = "warning" })
	end

	function Library:Error(title, text, duration)
		return self:Notify({ Title = title, Text = text, Duration = duration, Style = "danger" })
	end

	function Library:Success(title, text, duration)
		return self:Notify({ Title = title, Text = text, Duration = duration, Style = "success" })
	end

	return InterfaceManager
end

local InterfaceManager = {}

function InterfaceManager:SetLibrary(lib)
	lib = lib or self.Library
	if not lib then return self end
	if self._built then
		self.Library = lib
		return self
	end
	local api = Build(lib)
	for key, value in pairs(api) do
		if key ~= "SetLibrary" then
			self[key] = value
		end
	end
	self._built = true
	self.Library = lib
	lib.InterfaceManager = self
	lib.Addons = lib.Addons or {}
	lib.Addons.InterfaceManager = self
	return self
end

setmetatable(InterfaceManager, {
	__call = function(self, lib) return self:SetLibrary(lib) end,
})

return InterfaceManager
