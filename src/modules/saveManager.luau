--// Imports
local services = require("@modules/services")

--// Variables
local SaveManager = {}
SaveManager.__index = SaveManager

SaveManager.Data = {}
SaveManager.Templates = {}
SaveManager.App = nil
SaveManager.Window = nil
SaveManager.Cascade = nil

--// Privates
local controls = {}

local function deepClone(value)
	if typeof(value) == "table" then
		local copy = {}

		for key, item in value do
			copy[key] = deepClone(item)
		end

		return copy
	end

	return value
end

local function ensureKey(key: string, defaultValue: any)
	if SaveManager.Templates[key] == nil then
		SaveManager.Templates[key] = defaultValue
	end

	if SaveManager.Data[key] == nil then
		SaveManager.Data[key] = deepClone(defaultValue)
	end
end

--// Public
function SaveManager:QueueSave()
	-- host script overrides this to persist to file/attributes
end

function SaveManager:UpdateUI()
	for key, control in controls do
		local value = SaveManager.Data[key]

		if value ~= nil and control.Value ~= value then
			control.Value = value
		end
	end
end

function SaveManager:Toast(message: string, kind: string?)
	local title = "_h4ckler"

	if kind == "error" then
		title = "Error"
	elseif kind == "success" then
		title = "Success"
	elseif kind == "loading" then
		title = "Loading"
	end

	if self.App then
		self.App:Notification({ Title = title, Description = message, Duration = 4 })
	end
end

function SaveManager:Toggle(right: any, key: string, properties: { [string]: any }?)
	ensureKey(key, false)

	properties = properties or {}

	local toggle = right:Toggle({
		Value = SaveManager.Data[key],
		ValueChanged = function(_, value: boolean)
			SaveManager.Data[key] = value
			self:QueueSave()

			if properties.ValueChanged then
				properties.ValueChanged(_, value)
			end
		end,
	})

	controls[key] = toggle

	return toggle
end

function SaveManager:Stepper(right: any, key: string, properties: { [string]: any })
	ensureKey(key, properties.Minimum or 0)

	local stepper = right:Stepper({
		Value = SaveManager.Data[key],
		Minimum = properties.Minimum or 0,
		Maximum = properties.Maximum or 100,
		Step = properties.Step or 1,
		Fielded = properties.Fielded or false,
		ValueChanged = function(_, value: number)
			SaveManager.Data[key] = value
			self:QueueSave()

			if properties.ValueChanged then
				properties.ValueChanged(_, value)
			end
		end,
	})

	controls[key] = stepper

	return stepper
end

function SaveManager:PopUpButton(right: any, key: string, properties: { [string]: any })
	local options = properties.Options or {}
	ensureKey(key, properties.Maximum and properties.Maximum > 1 and {} or (options[1] or ""))

	local button = right:PopUpButton({
		Options = options,
		Maximum = properties.Maximum,
		Value = SaveManager.Data[key],
		ValueChanged = function(_, value: any)
			SaveManager.Data[key] = value
			self:QueueSave()

			if properties.ValueChanged then
				properties.ValueChanged(_, value)
			end
		end,
	})

	controls[key] = button

	return button
end

function SaveManager:TextField(right: any, key: string, properties: { [string]: any }?)
	ensureKey(key, "")

	properties = properties or {}

	local field = right:TextField({
		Placeholder = properties.Placeholder or "",
		ValueChanged = function(_, value: string)
			SaveManager.Data[key] = value
			self:QueueSave()

			if properties.ValueChanged then
				properties.ValueChanged(_, value)
			end
		end,
	})

	controls[key] = field

	return field
end

function SaveManager:KeybindField(right: any, key: string, properties: { [string]: any }?)
	ensureKey(key, properties and properties.Value or Enum.KeyCode.Unknown)

	properties = properties or {}

	local field = right:KeybindField({
		Value = SaveManager.Data[key],
		BindPressed = properties.BindPressed,
		ValueChanged = function(_, value: Enum.KeyCode)
			SaveManager.Data[key] = value
			self:QueueSave()

			if properties.ValueChanged then
				properties.ValueChanged(_, value)
			end
		end,
	})

	controls[key] = field

	return field
end

function SaveManager:BuildAppearanceTab(Cascade: any, section: any)
	local tab = section:Tab({ Title = "Appearance", Icon = Cascade.Symbols.paintpalette })

	local themeSection = tab:PageSection({
		Title = "Theme",
		Subtitle = "Customize the visual appearance.",
		Icon = Cascade.Symbols.paintpalette,
	})

	local themeRow = themeSection:Form():Row({ SearchIndex = "Color Theme" })
	themeRow:Left():TitleStack({ Title = "Color Theme", Subtitle = "Palette used by the whole hub." })

	self:PopUpButton(themeRow:Right(), "Theme", {
		Options = { "Dark", "Light" },
		ValueChanged = function(_, value: string)
			if self.App and Cascade.Themes[value] then
				self.App.Theme = Cascade.Themes[value]
			end
		end,
	})

	local accents = {}
	for accent in Cascade.Accents do
		table.insert(accents, accent)
	end
	table.sort(accents)

	local accentRow = themeSection:Form():Row({ SearchIndex = "Accent" })
	accentRow:Left():TitleStack({ Title = "Accent", Subtitle = "Accent color used across the hub." })

	self:PopUpButton(accentRow:Right(), "Accent", {
		Options = accents,
		ValueChanged = function(_, value: string)
			if self.App and Cascade.Accents[value] then
				self.App.Accent = Cascade.Accents[value]
			end
		end,
	})

	local windowSection = tab:PageSection({
		Title = "Window",
		Subtitle = "Configure window behavior.",
		Icon = Cascade.Symbols.sidebarLeft,
	})

	local bindRow = windowSection:Form():Row({ SearchIndex = "Minimize Keybind" })
	bindRow:Left():TitleStack({ Title = "Minimize Keybind", Subtitle = "Toggles window visibility." })

	self:KeybindField(bindRow:Right(), "Minimize Keybind", {
		Value = Enum.KeyCode.RightControl,
		BindPressed = function(_, _, complete: boolean, processed: boolean)
			if complete and not processed and self.Window then
				self.Window.Minimized = not self.Window.Minimized
			end
		end,
	})

	for _, entry in {
		{ key = "Searching", label = "Searchable", sub = "Enable search in the titlebar." },
		{ key = "Draggable", label = "Draggable", sub = "Allow window movement." },
		{ key = "Resizable", label = "Resizable", sub = "Allow window resizing." },
		{ key = "Dropshadow", label = "Drop Shadow", sub = "Shadow behind the window." },
		{ key = "UIBlur", label = "Background Blur", sub = "Blur effect behind the window." },
	} do
		local row = windowSection:Form():Row({ SearchIndex = entry.label })
		row:Left():TitleStack({ Title = entry.label, Subtitle = entry.sub })

		ensureKey(entry.key, self.Window and self.Window[entry.key] or true)

		row:Right():Toggle({
			Value = SaveManager.Data[entry.key],
			ValueChanged = function(_, value: boolean)
				SaveManager.Data[entry.key] = value
				self:QueueSave()

				if self.Window then
					self.Window[entry.key] = value
				end
			end,
		})
	end
end

function SaveManager:BuildConfigTab(Cascade: any, section: any)
	local tab = section:Tab({ Title = "Config", Icon = Cascade.Symbols.folder })

	local profileSection = tab:PageSection({
		Title = "Profiles",
		Subtitle = "Manage your configuration profiles.",
		Icon = Cascade.Symbols.folder,
	})

	local profileRow = profileSection:Form():Row({ SearchIndex = "Profile" })
	profileRow:Left():TitleStack({ Title = "Profile", Subtitle = "Loaded when auto load is on." })

	self:PopUpButton(profileRow:Right(), "Profile", {
		Options = { "default", "legit", "rage" },
	})

	local newRow = profileSection:Form():Row({ SearchIndex = "New Profile" })
	newRow:Left():TitleStack({ Title = "New Profile", Subtitle = "Saves every tab under this name." })

	self:TextField(newRow:Right(), "New Profile", { Placeholder = "Profile name..." })

	local actionsRow = profileSection:Form():Row({ SearchIndex = "Actions" })
	actionsRow:Left():TitleStack({ Title = "Actions", Subtitle = "Housekeeping for the selected profile." })

	local actions = actionsRow:Right()

	actions:Button({
		Label = "Save",
		State = "Primary",
		Pushed = function()
			self:Toast(`Saved profile "{SaveManager.Data["Profile"] or "default"}"`, "success")
		end,
	})

	actions:Button({
		Label = "Load",
		State = "Secondary",
		Pushed = function()
			self:Toast(`Loaded profile "{SaveManager.Data["Profile"] or "default"}"`, "success")
		end,
	})

	actions:Button({
		Label = "Delete",
		State = "Destructive",
		Pushed = function()
			self:Toast(`Deleted profile "{SaveManager.Data["Profile"] or "default"}"`, "error")
		end,
	})

	local autoLoadRow = profileSection:Form():Row({ SearchIndex = "Auto Load" })
	autoLoadRow:Left():TitleStack({ Title = "Auto Load", Subtitle = "Applies the profile on launch." })

	self:Toggle(autoLoadRow:Right(), "Auto Load")
end

return SaveManager
