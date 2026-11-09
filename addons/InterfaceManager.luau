-- Orasense addon | InterfaceManager
-- Reglages de l'interface elle-meme : touche du menu, echelle, dechargement.

return function(Library)
	local InterfaceManager = {}
	InterfaceManager.Library = Library
	InterfaceManager.Folder = "Orasense"
	InterfaceManager.Flags = { "interface_menu_key", "interface_scale", "interface_dpi", "interface_hotkeys", "orasense_particles", "orasense_particle_custom", "orasense_background", "orasense_background_fade", "orasense_liquid", "orasense_glass_blur", "orasense_glass_strength" }

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
		self.Settings = self.Settings or { MenuKey = "RightShift", Scale = 100, Dpi = 96, Hotkeys = false }

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
			Text = "ui scale",
			Flag = "interface_scale",
			Min = 70,
			Max = 130,
			Suffix = "%",
			Default = self.Settings.Scale,
			Callback = function(v)
				self.Settings.Scale = v
				self.Settings.Dpi = math.floor(v * 96 / 100 + 0.5)
				if dpi then dpi:Set(self.Settings.Dpi, true) end
				local win = self:GetWindow()
				if win then win:SetUserScale(v / 100) end
			end,
		})

		dpi = section:SliderButtons({
			Text = "dpi",
			Flag = "interface_dpi",
			Min = 60,
			Max = 140,
			Step = 2,
			Suffix = " dpi",
			Default = self.Settings.Dpi or 96,
			Callback = function(v)
				self.Settings.Dpi = v
				self.Settings.Scale = math.floor(v / 96 * 100 + 0.5)
				if scale then scale:Set(self.Settings.Scale, true) end
				local win = self:GetWindow()
				if win then win:SetUserScale(v / 96) end
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
		hotkeys:Set(self.Settings.Hotkeys == true)

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
