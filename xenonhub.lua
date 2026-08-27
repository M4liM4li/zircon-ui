repeat
	task.wait()
until game:IsLoaded()

if getgenv().Androssy then
	getgenv().Androssy:Destroy()

	task.wait(0.5)
end

local Androssy = {
	DEBUG = not LPH_OBFUSCATED,
	Running = true,
	Utils = {},
	Connections = {},
	Caches = {
		EntityRestPosition = {},
		["Dungeon PlaceId"] = {
			75159314259063,
			96767841099256,
			99684056491472,
			123955125827131,
			138368689293913,
		},
	},
	Services = setmetatable({}, {
		__index = function(t, k)
			local service = game:GetService(k)
			t[k] = service
			return service
		end,
	}),
	Cooldowns = setmetatable({}, {
		__index = function(t, k)
			t[k] = 0
			return 0
		end,
	}),
}

local DEBUG = Androssy.DEBUG
local Utils = Androssy.Utils
local Connections = Androssy.Connections
local Caches = Androssy.Caches
local Services = Androssy.Services
local Cooldowns = Androssy.Cooldowns

if not DEBUG then
	repeat
		task.wait()
	until Services.GamePassService and Services.GamePassService:GetAttribute("ValidationService")
end

if not DEBUG then
	getgenv().print = function() end
	getgenv().warn = function() end
end

Caches._thread = {
	_threads = {},
	_nextId = 1,
}

local SaveManager = {
	Folder = "Zircon Hub",
	SubFolder = "Sailor Piece",
	Location = nil,
	UI = {},
	Templates = {
		["Auto Farm Level"] = false,
		["Kill Aura"] = false,
		["Auto Best Title"] = false,
		["Auto Buy Gryphon"] = false,
		["Auto Buso Haki"] = false,
		["Auto Observation Haki"] = false,
		["Auto Unlock Artifact"] = false,
		["Auto Ascend"] = false,

		["Auto Skills"] = false,
		["Skill Settings"] = {
			["Z"] = { ["Enabled"] = false, ["Delay"] = 0 },
			["X"] = { ["Enabled"] = false, ["Delay"] = 0 },
			["C"] = { ["Enabled"] = false, ["Delay"] = 0 },
			["V"] = { ["Enabled"] = false, ["Delay"] = 0 },
			["F"] = { ["Enabled"] = false, ["Delay"] = 0 },
		},

		["Selected Weapon"] = "Melee",
		["Attack Distance"] = 30,

		["Auto Farm Entity"] = false,
		["Selected Entities"] = {},
		["Auto Dark Blade"] = false,

		["Auto Open Chests"] = false,
		["Selected Chests"] = {},
		["Chest Amount"] = 1,

		["Auto Race Reroll"] = false,
		["Preferred Races"] = {},

		["Auto Boss"] = false,
		["Boss Settings"] = {},
		["Boss Difficulty"] = "Normal",
		["Auto World Boss"] = false,
		["World Boss Settings"] = {},

		["Auto Stats"] = true,
		["Stat Mode"] = "Smart",
		["Selected Stats"] = { "Sword" },

		["Auto Dungeon"] = false,
		["Auto Replay"] = false,
		["Selected Dungeon"] = "Cid Dungeon",
		["Selected Dungeon Difficulty"] = "Easy",

		["Theme"] = "Dark",
		["Minimize Keybind"] = "RightControl",
		["Searching"] = false,
		["Draggable"] = true,
		["Resizable"] = true,
		["Dropshadow"] = true,
		["UI Blur"] = false,
	},
	_RawData = {},
	_SaveQueued = false,
	App = nil,
	Window = nil,
	Cascade = nil,
	Caches = {
		ConfigRows = {},
		ConfigListForm = nil,
		AutoLoadLabel = nil,
		Chest = {
			"Common Chest",
			"Rare Chest",
			"Epic Chest",
			"Legendary Chest",
			"Mythical Chest",
		},
		Races = {},
	},
}

-- if getgenv().KEY and not DEBUG then
-- 	local Passed, Statement = pcall(function()
-- 		local keyFile = "Xenon Hub/key.txt"

-- 		if not isfolder("Zircon Hub") then
-- 			makefolder("Zircon Hub")
-- 		end

-- 		writefile(keyFile, getgenv().KEY)

-- 		queue_on_teleport(
-- 			'getgenv().KEY=readfile("Xenon Hub/key.txt")loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/ff744638668c00b2f2f8fdce4072716e.lua"))()'
-- 		)
-- 	end)

-- 	if not Passed then
-- 		warn("Failed to set up key for auto-teleport:", Statement)
-- 	else
-- 		print("Key set up for auto-teleport")
-- 	end
-- end

function Androssy:Destroy()
	Androssy.Running = false

	task.wait(1)

	for _, connection in pairs(Connections) do
		if typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
		elseif typeof(connection) == "thread" then
			task.cancel(connection)
		end
	end

	for _, thread in pairs(Caches._thread._threads) do
		task.cancel(thread)
	end

	table.clear(Connections)
	table.clear(Caches._thread._threads)
	Caches._thread._nextId = 1

	if SaveManager.Window and SaveManager.Window.Parent then
		local Passed, Statement = pcall(function()
			SaveManager.Window:Destroy()
		end)

		SaveManager.Window = nil

		if not Passed then
			warn("Failed to destroy window:", Statement)
		end
	end

	if Caches._espModule and Caches._espModule._hasLoaded then
		pcall(Caches._espModule.Unload)
		Caches._espModule = nil
	end

	getgenv().Androssy = nil
end

do
	getgenv().Androssy = Androssy
end

function Utils:Thread(func, ...)
	local args = { ... }
	local threadId = Caches._thread._nextId
	Caches._thread._nextId = Caches._thread._nextId + 1

	local thread = task.spawn(function()
		func(unpack(args))
		Caches._thread._threads[threadId] = nil
	end)

	Caches._thread._threads[threadId] = thread

	return threadId, thread
end

function Utils:Cooldown(Name, Time)
	local Current = tick()

	if Current < Cooldowns[Name] then
		return false
	end

	Cooldowns[Name] = Current + Time

	return true
end

function Utils:Connect(Event, Handler)
	local Connection = Event:Connect(Handler)
	table.insert(Connections, Connection)
	return Connection
end

function Utils:Create(className, properties, children)
	local obj = Instance.new(className)

	if properties then
		for k, v in pairs(properties) do
			obj[k] = v
		end
	end

	if children then
		for _, child in ipairs(children) do
			child.Parent = obj
		end
	end

	return obj
end

local PlaceId = game.PlaceId

local Players = Services.Players
local ReplicatedStorage = Services.ReplicatedStorage
local HttpService = Services.HttpService
local GuiService = Services.GuiService
local VirtualInputManager = Services.VirtualInputManager
local VirtualUser = Services.VirtualUser
local UserInputService = Services.UserInputService
local RunService = Services.RunService
local Debris = Services.Debris

local LocalPlayer = Players.LocalPlayer

Utils:Connect(LocalPlayer.Idled, function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

local base64 = {}
local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

function base64.encode(data)
	return (data:gsub(".", function(x)
		local r, b = "", x:byte()
		for i = 8, 1, -1 do
			r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
		end
		return r
	end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
		if #x < 6 then
			return ""
		end
		local c = 0
		for i = 1, 6 do
			c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
		end
		return chars:sub(c + 1, c + 1)
	end) .. ({ "", "==", "=" })[#data % 3 + 1]
end

function base64.decode(data)
	data = data:gsub("[^" .. chars .. "=]", "")
	return (
		data:gsub(".", function(x)
			if x == "=" then
				return ""
			end
			local r, f = "", chars:find(x) - 1
			for i = 6, 1, -1 do
				r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0")
			end
			return r
		end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
			if #x ~= 8 then
				return ""
			end
			local c = 0
			for i = 1, 8 do
				c = c + (x:sub(i, i) == "1" and 2 ^ (8 - i) or 0)
			end
			return string.char(c)
		end)
	)
end

function SaveManager:GetIndex(tbl, value)
	for index, item in tbl do
		if item == value then
			return index
		end
	end
	return nil
end

local function CreateReactiveData(saveManager)
	return setmetatable({}, {
		__index = function(_, key)
			return saveManager._RawData[key]
		end,
		__newindex = function(_, key, value)
			if saveManager._RawData[key] ~= value then
				saveManager._RawData[key] = value
				saveManager:QueueSave()
			end
		end,
		__pairs = function(_)
			return pairs(saveManager._RawData)
		end,
	})
end

SaveManager.Data = CreateReactiveData(SaveManager)

function SaveManager:QueueSave()
	if self._SaveQueued or not Androssy.Running then
		return
	end

	self._SaveQueued = true
	task.delay(0.5, function()
		self._SaveQueued = false
		self:Save()
	end)
end

function SaveManager:Toast(message, type, func)
	if not self.App then
		return
	end

	if type == "success" then
		return self.App.toast.success(message)
	elseif type == "error" then
		return self.App.toast.error(message)
	elseif type == "loading" then
		return self.App.toast.loading(message)
	elseif type == "promise" then
		return self.App.toast.promise(func, {
			loading = "Loading...",
			success = message,
			error = function(err)
				return "Error: " .. tostring(err)
			end,
		})
	else
		return self.App.toast(message)
	end
end

if not isfolder(SaveManager.Folder) then
	makefolder(SaveManager.Folder)
end
if not isfolder(SaveManager.Folder .. "/" .. SaveManager.SubFolder) then
	makefolder(SaveManager.Folder .. "/" .. SaveManager.SubFolder)
end
SaveManager.Location = SaveManager.Folder .. "/" .. SaveManager.SubFolder

function SaveManager:Save()
	pcall(function()
		local filePath = self.Location .. "/Auto_" .. LocalPlayer.Name .. ".json"
		for key, value in self.Templates do
			if self._RawData[key] == nil or typeof(self._RawData[key]) ~= typeof(value) then
				self._RawData[key] = value
			end
		end
		writefile(filePath, HttpService:JSONEncode({ Data = self._RawData }))
	end)
end

function SaveManager:Load()
	pcall(function()
		local filePath = self.Location .. "/Auto_" .. LocalPlayer.Name .. ".json"
		if not isfile(filePath) then
			writefile(filePath, HttpService:JSONEncode({ Data = {} }))
		end
		local decoded = HttpService:JSONDecode(readfile(filePath))
		for key, value in self.Templates do
			if decoded.Data[key] == nil then
				decoded.Data[key] = value
			end
		end
		for key in decoded.Data do
			if self.Templates[key] == nil and not tostring(key):match("^Auto .+ Questline$") then
				decoded.Data[key] = nil
			end
		end
		self._RawData = decoded.Data
	end)
end

function SaveManager:UpdateUI()
	local keys = {}
	for key in self.UI do
		table.insert(keys, key)
	end
	table.sort(keys)

	for _, key in ipairs(keys) do
		local element = self.UI[key]
		warn("Updating UI for key:", key)
		if self._RawData[key] ~= nil and element.Value ~= nil then
			if key:find("Keybind") then
				element.Value = Enum.KeyCode[self._RawData[key]] or Enum.KeyCode.RightControl
			elseif element["Options"] then
				element.Value = SaveManager:GetIndex(element.Options, self._RawData[key]) or 1
			else
				element.Value = self._RawData[key]
			end
		end
		if element.ValueChanged then
			element:ValueChanged(typeof(element.Value) == "EnumItem" and element.Value.Name or element.Value)
		end
	end
end

function SaveManager:GetConfigs()
	local configs = {}
	for _, filePath in listfiles(self.Location) do
		if filePath:match("%.json$") then
			local name = filePath:match("([^/\\]+)%.json$")
			if name and name ~= "AutoLoadConfig" and not name:match("^Auto_") then
				table.insert(configs, name)
			end
		end
	end
	return configs
end

function SaveManager:GetConfig(configName)
	local filePath = self.Location .. "/" .. configName .. ".json"
	if not isfile(filePath) then
		return nil
	end
	return HttpService:JSONDecode(readfile(filePath))
end

function SaveManager:SaveConfig(configName)
	local filePath = self.Location .. "/" .. configName .. ".json"
	local data = {
		Name = configName,
		Data = self._RawData,
		CreatedAt = os.time(),
	}
	writefile(filePath, HttpService:JSONEncode(data))
end

function SaveManager:LoadConfig(configName)
	local config = self:GetConfig(configName)
	if not config then
		self:Toast("Profile not found: " .. configName, "error")
		return false
	end
	local configData = config.Data or config
	for key, value in configData do
		if self.Templates[key] ~= nil then
			self._RawData[key] = value
		end
	end
	self:Save()
	self:UpdateUI()
	self:Toast("Loaded profile: " .. configName, "success")
	return true
end

function SaveManager:CreateConfig(configName)
	local filePath = self.Location .. "/" .. configName .. ".json"
	if isfile(filePath) then
		self:Toast("Profile already exists: " .. configName, "error")
		return false
	end
	self:SaveConfig(configName)
	self:Toast("Created profile: " .. configName, "success")
	return true
end

function SaveManager:DeleteConfig(configName)
	local filePath = self.Location .. "/" .. configName .. ".json"
	if not isfile(filePath) then
		self:Toast("Profile not found: " .. configName, "error")
		return false
	end
	delfile(filePath)
	if self:GetAutoLoadName() == configName then
		self:ClearAutoLoad()
	end
	self:Toast("Deleted profile: " .. configName, "success")
	return true
end

function SaveManager:OverwriteConfig(configName)
	local filePath = self.Location .. "/" .. configName .. ".json"
	if not isfile(filePath) then
		self:Toast("Profile not found: " .. configName, "error")
		return false
	end
	self:SaveConfig(configName)
	self:Toast("Saved to profile: " .. configName, "success")
	return true
end

function SaveManager:ExportConfig(name)
	local data = {
		Name = name or "Export_" .. os.time(),
		Data = self._RawData,
		CreatedAt = os.time(),
	}
	return base64.encode(HttpService:JSONEncode(data))
end

function SaveManager:ImportConfig(encoded)
	local ok, decoded = pcall(base64.decode, encoded)
	if not ok or not decoded then
		self:Toast("Failed to decode Base64", "error")
		return false, nil
	end
	local ok2, config = pcall(HttpService.JSONDecode, HttpService, decoded)
	if not ok2 or type(config) ~= "table" then
		self:Toast("Invalid config format", "error")
		return false, nil
	end

	local name = config.Name or "Import_" .. os.time()
	local baseName = name
	local counter = 1
	while isfile(self.Location .. "/" .. name .. ".json") do
		name = baseName .. "_" .. counter
		counter = counter + 1
	end

	local data = {
		Name = name,
		Data = config.Data or config,
		CreatedAt = config.CreatedAt or os.time(),
		ImportedAt = os.time(),
	}
	writefile(self.Location .. "/" .. name .. ".json", HttpService:JSONEncode(data))
	self:Toast("Imported profile: " .. name, "success")
	return true, name
end

function SaveManager:GetAutoLoadName()
	local path = self.Location .. "/AutoLoadConfig.json"
	if not isfile(path) then
		return nil
	end
	local ok, config = pcall(function()
		return HttpService:JSONDecode(readfile(path))
	end)
	return ok and config and config.Name or nil
end

function SaveManager:SetAutoLoad(configName)
	local config = self:GetConfig(configName)
	if not config then
		self:Toast("Profile not found: " .. configName, "error")
		return false
	end
	writefile(self.Location .. "/AutoLoadConfig.json", HttpService:JSONEncode(config))
	Utils:UpdateAutoLoadLabel()
	self:Toast("Auto-load set to: " .. configName, "success")
	return true
end

function SaveManager:ClearAutoLoad()
	local path = self.Location .. "/AutoLoadConfig.json"
	if isfile(path) then
		delfile(path)
		self:Toast("Auto-load cleared", "success")
	end
	Utils:UpdateAutoLoadLabel()
end

function SaveManager:Bind(key, element)
	if self.Templates[key] then
		self.UI[key] = element
	end
	return element
end

function SaveManager:Toggle(parent, key, props)
	props = props or {}
	props.Value = self.Data[key]
	local orig = props.ValueChanged
	props.ValueChanged = function(s, v)
		self.Data[key] = v
		if orig then
			orig(s, v)
		end
	end
	return self:Bind(key, parent:Toggle(props))
end

function SaveManager:Stepper(parent, key, props)
	props = props or {}
	props.Value = self.Data[key]
	local orig = props.ValueChanged
	props.ValueChanged = function(s, v)
		self.Data[key] = v
		if orig then
			orig(s, v)
		end
	end
	return self:Bind(key, parent:Stepper(props))
end

function SaveManager:PopUpButton(parent, key, props)
	props = props or {}
	local multi = props.Maximum and props.Maximum > 1

	if multi then
		local value = self.Data[key]
		if type(value) ~= "table" then
			value = {}
		end

		props.Value = {}

		for _, v in ipairs(value) do
			local idx = SaveManager:GetIndex(props.Options, v)
			if idx then
				table.insert(props.Value, idx)
			end
		end
	else
		props.Value = SaveManager:GetIndex(props.Options, self.Data[key]) or 1
	end

	local orig = props.ValueChanged
	props.ValueChanged = function(s, v)
		if multi then
			local selected = {}
			v = typeof(v) == "number" and { v } or v
			for _, idx in ipairs(v or {}) do
				table.insert(selected, s.Options[idx])
			end
			self.Data[key] = selected
		else
			self.Data[key] = s.Options[v]
		end
		if orig then
			orig(s, v)
		end
	end

	return self:Bind(key, parent:PopUpButton(props))
end

function SaveManager:TextField(parent, key, props)
	props = props or {}
	props.Value = tostring(self.Data[key] or "")
	local orig = props.ValueChanged
	props.ValueChanged = function(s, v)
		self.Data[key] = tonumber(v) or v
		if orig then
			orig(s, v)
		end
	end
	return self:Bind(key, parent:TextField(props))
end

function SaveManager:KeybindField(parent, key, props)
	props = props or {}
	props.Value = Enum.KeyCode[self.Data[key]] or Enum.KeyCode.RightControl
	local orig = props.ValueChanged
	props.ValueChanged = function(s, v)
		self.Data[key] = v.Name
		if orig then
			orig(s, v)
		end
	end
	return self:Bind(key, parent:KeybindField(props))
end

-- One-call rows. Same three pieces as before — Row, TitleStack, control — but written once here
-- instead of at every call site, and still routed through Bind so loading a profile refreshes the UI.
function SaveManager:Field(section, key, config, make)
	config = config or {}

	-- One form per section. A form per row leaves every row without the hairline that the
	-- form draws between consecutive entries.
	local form = config.Form

	if not form then
		form = section.__fieldsForm

		if not form then
			form = section:Form()
			section.__fieldsForm = form
		end
	end
	local row = form:Row({ SearchIndex = config.SearchIndex or config.Title or key })

	row:Left():TitleStack({
		Title = config.Title or key,
		Subtitle = config.Description or "",
	})

	if config.Locked then
		row.Locked = config.Locked
	end

	local props = {}

	for prop, value in pairs(config) do
		props[prop] = value
	end

	props.Title = nil
	props.Description = nil
	props.SearchIndex = nil
	props.Locked = nil
	props.Form = nil

	return make(self, row:Right(), key, props), row
end

function SaveManager:AddToggle(section, key, config)
	return self:Field(section, key, config, self.Toggle)
end

function SaveManager:AddStepper(section, key, config)
	return self:Field(section, key, config, self.Stepper)
end

function SaveManager:AddDropdown(section, key, config)
	return self:Field(section, key, config, self.PopUpButton)
end

function SaveManager:AddInput(section, key, config)
	return self:Field(section, key, config, self.TextField)
end

function SaveManager:AddKeybind(section, key, config)
	return self:Field(section, key, config, self.KeybindField)
end

-- Not every row is a saved setting: buttons and labels take the same shape without a flag.
function SaveManager:AddButton(section, config)
	return self:Field(section, config.Title, config, function(_, right, _, props)
		props.Label = props.Label or "Run"
		props.State = props.State or "Primary"

		return right:Button(props)
	end)
end

function SaveManager:AddLabel(section, config)
	return self:Field(section, config.Title, config, function(_, right, _, props)
		props.Text = props.Text or ""

		return right:Label(props)
	end)
end

local autoLoadPath = SaveManager.Location .. "/AutoLoadConfig.json"

if isfile(autoLoadPath) then
	local config = HttpService:JSONDecode(readfile(autoLoadPath))
	for key, value in (config.Data or config) do
		if SaveManager.Templates[key] ~= nil or tostring(key):match("^Auto .+ Questline$") then
			SaveManager._RawData[key] = value
		end
	end
elseif isfile(SaveManager.Location .. "/Auto_" .. LocalPlayer.Name .. ".json") then
	SaveManager:Load()
else
	for key, value in SaveManager.Templates do
		SaveManager._RawData[key] = value
	end
	SaveManager:Save()
end

function Utils:UpdateAutoLoadLabel()
	if SaveManager.Caches.AutoLoadLabel then
		local name = SaveManager:GetAutoLoadName()
		SaveManager.Caches.AutoLoadLabel.Text = name or "None"
	end
end

function Utils:CreateConfigRow(configName)
	if SaveManager.Caches.ConfigRows[configName] then
		return
	end

	local config = SaveManager:GetConfig(configName)
	local subtitle = config and config.CreatedAt and os.date("%Y-%m-%d %H:%M", config.CreatedAt) or "Custom profile"

	local row = SaveManager.Caches.ConfigListForm:Row({ SearchIndex = configName })

	row:Left():TitleStack({
		Title = configName,
		Subtitle = subtitle,
	})

	row:Right():Button({
		Label = "Load",
		State = "Primary",
		Pushed = function()
			SaveManager:LoadConfig(configName)
		end,
	})

	row:Right():Button({
		Label = "Save",
		State = "Secondary",
		Pushed = function()
			SaveManager:OverwriteConfig(configName)
		end,
	})

	row:Right():Button({
		Label = "Export",
		State = "Secondary",
		Pushed = function()
			local encoded = SaveManager:ExportConfig(configName)
			setclipboard(encoded)
			SaveManager:Toast("Copied to clipboard: " .. configName, "success")
		end,
	})

	row:Right():Button({
		Label = "Auto-Load",
		State = "Secondary",
		Pushed = function()
			SaveManager:SetAutoLoad(configName)
		end,
	})

	row:Right():Button({
		Label = "Delete",
		State = "Destructive",
		Pushed = function()
			SaveManager.Window:Confirm({
				Title = `Delete "{configName}"?`,
				Text = "The profile and everything saved in it goes away. This cannot be undone.",
				Confirm = "Delete",
				Cancel = "Keep it",
				Destructive = true,
				Accepted = function()
					SaveManager:DeleteConfig(configName)
					Utils:UpdateConfigs()
				end,
			})
		end,
	})

	SaveManager.Caches.ConfigRows[configName] = row
end

function Utils:UpdateConfigs()
	local configs = SaveManager:GetConfigs()

	for _, name in configs do
		Utils:CreateConfigRow(name)
	end

	for name, row in SaveManager.Caches.ConfigRows do
		if not table.find(configs, name) then
			row:Destroy()
			SaveManager.Caches.ConfigRows[name] = nil
		end
	end

	Utils:UpdateAutoLoadLabel()
end

function SaveManager:BuildAppearanceTab(Cascade, section)
	local tab = section:Tab({
		Title = "Appearance",
		Icon = Cascade.Symbols.paintbrush,
	})

	local themeForm = tab:PageSection({
		Title = "Theme",
		Subtitle = "Customize the visual appearance.",
	}):Form()

	self:AddDropdown(themeForm, "Theme", {
		Title = "Color Theme",
		Description = "Select your preferred color scheme.",
		SearchIndex = "Theme",
		Options = { "Light", "Dark", "Crimson", "Emerald", "Violet", "Amber", "Azure", "Rose", "Sapphire" },
		Searchable = true,
		ValueChanged = function(s, v),
		if self.App then,
		self.App.Theme = Cascade.Themes[s.Options[v]],
		end,
		end,
	})

	local windowForm = tab:PageSection({
		Title = "Window",
		Subtitle = "Configure window behavior.",
	}):Form()

	self:AddKeybind(windowForm, "Minimize Keybind", {
		Title = "Minimize Keybind",
		Description = "Toggle window visibility.",
		BindPressed = function(_, _, complete, processed),
		if complete and not processed and self.Window then,
		self.Window.Minimized = not self.Window.Minimized,
		end,
		end,
	})

	self:AddToggle(windowForm, "Searching", {
		Title = "Searchable", Subtitle = "Enable search in titlebar.",
		SearchIndex = "Searching",
		ValueChanged = function(_, v),
		if self.Window then,
		self.Window.Searching = v,
		end,
		end,
	})

	self:AddToggle(windowForm, "Draggable", {
		Title = "Draggable", Subtitle = "Allow window movement.",
		SearchIndex = "Draggable",
		ValueChanged = function(_, v),
		if self.Window then,
		self.Window.Draggable = v,
		end,
		end,
	})

	self:AddToggle(windowForm, "Resizable", {
		Title = "Resizable", Subtitle = "Allow window resizing.",
		SearchIndex = "Resizable",
		ValueChanged = function(_, v),
		if self.Window then,
		self.Window.Resizable = v,
		end,
		end,
	})

	local effectsForm = tab:PageSection({
		Title = "Effects",
		Subtitle = "Visual effects (may impact performance).",
	}):Form()

	self:AddToggle(effectsForm, "Dropshadow", {
		Title = "Drop Shadow", Subtitle = "Shadow behind window.",
		SearchIndex = "Dropshadow",
		ValueChanged = function(_, v),
		if self.Window then,
		self.Window.Dropshadow = v,
		end,
		end,
	})

	self:AddToggle(effectsForm, "UI Blur", {
		Title = "Background Blur", Subtitle = "Blur effect (detectable).",
		SearchIndex = "UI Blur",
		ValueChanged = function(_, v),
		if self.Window then,
		self.Window.UIBlur = v,
		end,
		end,
	})

	return tab
end

function SaveManager:BuildConfigTab(Cascade, section)
	local tab = section:Tab({
		Title = "Profiles",
		Icon = Cascade.Symbols.folder,
	})

	local listForm = tab:PageSection({
		Title = "Saved Profiles",
		Subtitle = "Manage your configuration profiles.",
	}):Form()

	SaveManager.Caches.ConfigListForm = listForm

	for _, name in self:GetConfigs() do
		Utils:CreateConfigRow(name)
	end

	local createForm = tab:PageSection({
		Title = "Create Profile",
		Subtitle = "Save current settings as a new profile.",
	}):Form()

	local createRow = createForm:Row({ SearchIndex = "Create" })
	createRow:Left():TitleStack({
		Title = "New Profile",
		Subtitle = "Enter a name and create.",
	})

	local newName = ""
	local nameField = createRow:Right():TextField({
		Value = "",
		Placeholder = "Profile name...",
		ValueChanged = function(_, v)
			newName = v
		end,
	})

	createRow:Right():Button({
		Label = "Create",
		State = "Primary",
		Pushed = function()
			if newName == "" or newName == "None" or newName == "AutoLoadConfig" then
				self:Toast("Enter a valid profile name", "error")
				return
			end

			-- The name is taken, so offer the overwrite instead of dead-ending on an error toast.
			if isfile(self.Location .. "/" .. newName .. ".json") then
				local target = newName

				self.Window:Confirm({
					Title = `Overwrite "{target}"?`,
					Text = "That profile already exists. Its saved settings are replaced with the ones you have set right now.",
					Confirm = "Overwrite",
					Cancel = "Cancel",
					Destructive = true,
					Accepted = function()
						if self:OverwriteConfig(target) then
							Utils:UpdateConfigs()
							nameField.Value = ""
						end
					end,
				})

				return
			end

			if self:CreateConfig(newName) then
				Utils:UpdateConfigs()
				nameField.Value = ""
			end
		end,
	})

	local ioForm = tab:PageSection({
		Title = "Import / Export",
		Subtitle = "Share profiles via Base64.",
	}):Form()

	local exportRow = ioForm:Row({ SearchIndex = "Export" })
	exportRow:Left():TitleStack({
		Title = "Export Current",
		Subtitle = "Copy settings to clipboard.",
	})

	local exportName = ""
	exportRow:Right():TextField({
		Value = "",
		Placeholder = "Export name...",
		ValueChanged = function(_, v)
			exportName = v
		end,
	})

	exportRow:Right():Button({
		Label = "Export",
		State = "Primary",
		Pushed = function()
			local name = exportName ~= "" and exportName or "Export_" .. os.time()
			setclipboard(self:ExportConfig(name))
			self:Toast("Exported as: " .. name, "success")
		end,
	})

	local importRow = ioForm:Row({ SearchIndex = "Import" })
	importRow:Left():TitleStack({
		Title = "Import Profile",
		Subtitle = "Paste Base64 to import.",
	})

	local importData = ""
	local importField = importRow:Right():TextField({
		Value = "",
		Placeholder = "Paste Base64...",
		ValueChanged = function(_, v)
			importData = v
		end,
	})

	importRow:Right():Button({
		Label = "Import",
		State = "Primary",
		Pushed = function()
			if importData ~= "" then
				local ok, _name = self:ImportConfig(importData)
				if ok then
					Utils:UpdateConfigs()
					importField.Value = ""
				end
			else
				self:Toast("Paste a Base64 string first", "error")
			end
		end,
	})

	local autoForm = tab:PageSection({
		Title = "Auto-Load",
		Subtitle = "Profile that loads on startup.",
	}):Form()

	local autoRow = autoForm:Row({ SearchIndex = "Auto-Load" })
	autoRow:Left():TitleStack({
		Title = "Current Auto-Load",
		Subtitle = "Set via profile buttons above.",
	})

	SaveManager.Caches.AutoLoadLabel = autoRow:Right():Label({
		Text = self:GetAutoLoadName() or "None",
	})

	autoRow:Right():Button({
		Label = "Clear",
		State = "Destructive",
		Pushed = function()
			self:ClearAutoLoad()
		end,
	})

	return tab
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local PressFrame = PlayerGui:FindFirstChild("PressFrame")
	or Utils:Create("Frame", {
		Name = "PressFrame",
		Size = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
		Parent = PlayerGui,
	})

PlayerGui.SelectionImageObject = PressFrame

function Utils:PressButton(Button)
	if not Button or not Button.Parent then
		return
	end
	GuiService.SelectedCoreObject = Button
	VirtualInputManager:SendKeyEvent(true, "Return", false, game)
	task.wait(0.1)
	VirtualInputManager:SendKeyEvent(false, "Return", false, game)
	task.wait(0.1)
	GuiService.SelectedCoreObject = nil
end

function Utils:SafeRequire(module)
	local Passed, Statement = pcall(require, module)

	if not Passed then
		warn("Failed to require module:", module, "Error:", Statement)
		return nil
	end

	return Statement
end

function Utils:GetCharacter()
	return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end
function Utils:GetHumanoid()
	local Character = Utils:GetCharacter()
	return Character:WaitForChild("Humanoid", 1)
end
function Utils:GetHumanoidRootPart()
	local Character = Utils:GetCharacter()
	return Character:WaitForChild("HumanoidRootPart", 1)
end

function Utils:StartsWith(str, prefix)
	return string.sub(str, 1, #prefix) == prefix
end
function Utils:Comma(amount)
	local formatted = amount
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
		if k == 0 then
			break
		end
	end
	return formatted
end
function Utils:IsAlive()
	local Character = LocalPlayer.Character
	if not Character then
		return false
	end
	local Humanoid = Character:FindFirstChild("Humanoid")
	return Humanoid and Humanoid.Health > 0
end

function Utils:WaitForRespawn()
	if Utils:IsAlive() then
		return
	end

	warn("[QuestHandler] Waiting for respawn...")
	LocalPlayer.CharacterAdded:Wait()
	task.wait(1)
end

function Utils:ToTarget(cframe)
	cframe = typeof(cframe) == "CFrame" and cframe or typeof(cframe) == "Vector3" and CFrame.new(cframe) or nil

	if not cframe then
		warn("Invalid CFrame or Vector3 provided to ToTarget")
		return
	end

	local rootPart = Utils:GetHumanoidRootPart()

	if not rootPart then
		warn("HumanoidRootPart not found")
		return
	end

	LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
	LocalPlayer.Character.HumanoidRootPart.CFrame = cframe
end

function Utils:Float(State)
	if not Utils:IsAlive() then
		return
	end

	local RootPart = Utils:GetHumanoidRootPart()

	if not RootPart then
		return
	end

	if not State and RootPart:FindFirstChild("FloatBV") then
		Debris:AddItem(RootPart.FloatBV, 0.1)
		return
	end

	local BV = RootPart:FindFirstChild("FloatBV")
		or Utils:Create("BodyVelocity", {
			Name = "FloatBV",
			Parent = RootPart,
			MaxForce = Vector3.new(100000, 100000, 100000),
			Velocity = Vector3.new(0, 0, 0),
		})

	BV.MaxForce = Vector3.new(100000, 100000, 100000)
	BV.Velocity = Vector3.new(0, 0, 0)
end

local NPCs = workspace:WaitForChild("NPCs")
local ServiceNPCs = workspace:WaitForChild("ServiceNPCs")

function Utils:FindMob(mobName)
	local nearestMob, nearestDistance = nil, math.huge

	for _, mob in next, NPCs:GetChildren() do
		if mob.Name:lower():find(mobName:lower()) then
			local humanoid = mob:FindFirstChildOfClass("Humanoid")

			if not humanoid or humanoid.Health <= 0 then
				continue
			end

			local rootPart = mob.PrimaryPart
			local rootPos = rootPart and rootPart.Position or mob:GetPivot().Position

			local distance = (Utils:GetHumanoidRootPart().Position - rootPos).Magnitude
			if distance < nearestDistance then
				nearestMob, nearestDistance = mob, distance
			end
		end
	end

	return nearestMob
end

function Utils:FindNearbyMob(radius, multiple, maxCount)
	if not multiple then
		local nearestMob, nearestDistance = nil, math.huge

		for _, mob in next, NPCs:GetChildren() do
			local humanoid = mob:FindFirstChildOfClass("Humanoid")

			if not humanoid or humanoid.Health <= 0 then
				continue
			end

			local rootPart = mob.PrimaryPart
			local rootPos = rootPart and rootPart.Position or mob:GetPivot().Position

			local distance = (Utils:GetHumanoidRootPart().Position - rootPos).Magnitude
			if distance < nearestDistance and distance <= radius then
				nearestMob, nearestDistance = mob, distance
			end
		end

		return nearestMob
	else
		local candidates = {}
		local rootPart = Utils:GetHumanoidRootPart()

		for _, mob in next, NPCs:GetChildren() do
			local humanoid = mob:FindFirstChildOfClass("Humanoid")

			if not humanoid or humanoid.Health <= 0 then
				continue
			end

			local mobRoot = mob.PrimaryPart
			local mobPos = mobRoot and mobRoot.Position or mob:GetPivot().Position

			local distance = (rootPart.Position - mobPos).Magnitude
			if distance <= radius then
				table.insert(candidates, { Mob = mob, Distance = distance })
			end
		end

		table.sort(candidates, function(a, b)
			return a.Distance < b.Distance
		end)

		local result = {}

		for i = 1, math.min(maxCount or #candidates, #candidates) do
			table.insert(result, candidates[i].Mob)
		end

		return result
	end
end

function Utils:FindNPC(npcName)
	if not ServiceNPCs then
		return nil
	end

	for _, npc in next, ServiceNPCs:GetChildren() do
		if npc.Name:lower():find(npcName:lower()) then
			return npc
		end
	end

	return nil
end

local CombatSystem = ReplicatedStorage:FindFirstChild("CombatSystem")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local CombatRemotes = CombatSystem and CombatSystem:FindFirstChild("Remotes")
local EquipWeapon = Remotes:WaitForChild("EquipWeapon")
local UpdateInventory = Remotes:WaitForChild("UpdateInventory")
local RequestInventory = Remotes:WaitForChild("RequestInventory")
local UseItem = Remotes:WaitForChild("UseItem")
local RequestSummonBoss = Remotes:WaitForChild("RequestSummonBoss")
local RequestDungeonPortal = Remotes:WaitForChild("RequestDungeonPortal")
local DungeonWaveReplayVote = Remotes:WaitForChild("DungeonWaveReplayVote")
local DungeonWaveVote = Remotes:WaitForChild("DungeonWaveVote")

local AbilitySystem = ReplicatedStorage:WaitForChild("AbilitySystem")
local AbilityRemotes = AbilitySystem:WaitForChild("Remotes")
local RequestAbility = AbilityRemotes:WaitForChild("RequestAbility")

local RemoteEvents = ReplicatedStorage:FindFirstChild("RemoteEvents")

local GetPlayerStats = RemoteEvents:WaitForChild("GetPlayerStats")
local AllocateStat = RemoteEvents:WaitForChild("AllocateStat")
local QuestAccept = RemoteEvents:WaitForChild("QuestAccept")
local QuestAbandon = RemoteEvents:WaitForChild("QuestAbandon")
local TitleEquip = RemoteEvents:WaitForChild("TitleEquip")
local HakiRemote = RemoteEvents:WaitForChild("HakiRemote")
local ObservationHakiRemote = RemoteEvents:WaitForChild("ObservationHakiRemote")
local ArtifactUnlockSystem = RemoteEvents:WaitForChild("ArtifactUnlockSystem")
local GetAscendData = RemoteEvents:WaitForChild("GetAscendData")
local RequestAscend = RemoteEvents:WaitForChild("RequestAscend")

local RemoteFunctions = ReplicatedStorage:FindFirstChild("RemoteFunctions")
local GetTitlesData = Remotes:WaitForChild("GetTitlesData")
local TitleConfig = require(Modules.TitlesConfig)
local DungeonConfig = require(Modules.DungeonConfig)
local PortalConfig = require(ReplicatedStorage.PortalConfig)

Caches.BusoHakiOwned = false
Caches.BusoHakiQuestlineCompleted = false
Caches.ObservationHakiOwned = false

Utils:Connect(HakiRemote.OnClientEvent, function(eventType, payload)
	if eventType == "Status" then
		Caches.BusoHakiQuestlineCompleted = payload.questlineComplete or false
		Caches.BusoHakiOwned = payload.hasHaki or false
		if Caches.BusoHakiOwned and not payload.isActive then
			HakiRemote:FireServer("Toggle")
		end
	end
end)

Utils:Connect(ObservationHakiRemote.OnClientEvent, function(eventType, payload)
	if eventType == "Status" then
		Caches.ObservationHakiOwned = payload.hasObsHaki or false
		if Caches.ObservationHakiOwned and not payload.isActive then
			ObservationHakiRemote:FireServer("Toggle")
		end
	end
end)

local RaceConfig = require(Modules.RaceConfig)
local BossConfig = require(Modules.BossConfig)
local WeaponClassification = require(Modules.WeaponClassification)
local SummonableBossConfig = require(Modules.SummonableBossConfig)

function Utils:KillAura(multiple)
	if not Utils:IsAlive() or not Utils:Cooldown("KillAura", 0.1) then
		return
	end

	local mob = Utils:FindNearbyMob(200, multiple, 5)

	if mob then
		if multiple then
			for _, m in next, mob do
				local position = m.PrimaryPart and m.PrimaryPart.Position or m:GetPivot().Position
				CombatRemotes.RequestHit:FireServer(position)
			end
		else
			local position = mob.PrimaryPart and mob.PrimaryPart.Position or mob:GetPivot().Position

			CombatRemotes.RequestHit:FireServer(position)
		end
	end
end

function Utils:GetRaceList()
	local Races = {}

	for race, data in next, RaceConfig.Races do
		local rarity = data.rarity or "Common"
		table.insert(Races, {
			name = race,
			rarity = rarity,
			order = RaceConfig.Rarities[rarity] and RaceConfig.Rarities[rarity].order or 0,
		})
	end

	table.sort(Races, function(a, b)
		if a.order ~= b.order then
			return a.order > b.order
		end
		return a.name < b.name
	end)

	local result = {}
	for _, entry in next, Races do
		table.insert(result, string.format("[%s] %s", entry.rarity, entry.name))
	end

	return result
end

function Utils:ParseRaceName(displayName)
	return displayName:match("%[.-%] (.+)")
end

function Utils:GetCurrentRace()
	if Utils:Cooldown("GetPlayerStats_Race", 0.15) then
		local PlayerStats = GetPlayerStats:InvokeServer()
		if PlayerStats then
			Caches.CurrentRace = PlayerStats.Inventory.Equipped.Race
		end
	end

	return Caches.CurrentRace
end

function Utils:HasTargetRace(targetRaces)
	local currentRace = Utils:GetCurrentRace()
	for _, displayName in next, targetRaces do
		local raceName = Utils:ParseRaceName(displayName) or displayName
		if raceName == currentRace then
			return true
		end
	end
	return false
end

function Utils:GetRaceRarity(raceName)
	local raceData = RaceConfig.Races[raceName]
	return raceData and raceData.rarity or "Unknown"
end

function Utils:UpdateRaceLabels()
	local currentRace = Utils:GetCurrentRace()
	if Caches.RaceLabel then
		local rarity = Utils:GetRaceRarity(currentRace)
		Caches.RaceLabel.Text = currentRace and string.format("%s (%s)", currentRace, rarity) or "Unknown"
	end

	local item = Utils:GetItem("Items", "Race Reroll")
	if Caches.RaceRerollCountLabel then
		Caches.RaceRerollCountLabel.Text = tostring(item and item.quantity or 0)
	end
end

function Utils:HandleRaceReroll()
	local statusLabel = Caches.RaceStatusLabel

	Utils:UpdateRaceLabels()

	local TargetRaces = SaveManager.Data["Preferred Races"]
	if not TargetRaces or #TargetRaces == 0 then
		if statusLabel then
			statusLabel.Text = "No target races selected"
		end
		return
	end

	local currentRace = Utils:GetCurrentRace()

	if Utils:HasTargetRace(TargetRaces) then
		local rarity = Utils:GetRaceRarity(currentRace)
		if statusLabel then
			statusLabel.Text = string.format("Got: %s (%s)", currentRace or "Unknown", rarity)
		end
		SaveManager.Data["Auto Race Reroll"] = false
		SaveManager:QueueSave()
		return
	end

	local item = Utils:GetItem("Items", "Race Reroll")
	if not item or item.quantity <= 0 then
		if statusLabel then
			statusLabel.Text = "No Race Rerolls left"
		end
		return
	end

	Caches.RaceRerollCount = (Caches.RaceRerollCount or 0) + 1

	if statusLabel then
		local rarity = Utils:GetRaceRarity(currentRace)
		statusLabel.Text =
			string.format("#%d: %s (%s) - Rerolling...", Caches.RaceRerollCount, currentRace or "Unknown", rarity)
	end

	UseItem:FireServer("Use", "Race Reroll", 1, false)
	task.wait(0.5)

	Utils:UpdateRaceLabels()
end

function Utils:Attack(target)
	if not Utils:IsAlive() or not Utils:Cooldown("Attack", 0.1) then
		return
	end

	if target and target.PrimaryPart then
		Utils:Thread(function(...)
			CombatRemotes.RequestHit:FireServer(target.PrimaryPart.Position)
		end)
	end
end

function Utils:Dash()
	if not Utils:IsAlive() then
		return
	end

	RemoteEvents.DashRemote:FireServer(Vector3.new(-0.94969344139099, 0, 0.3131810426712), 33, false)
end

local LocalData = LocalPlayer:WaitForChild("Data")

function Utils:GetCurrentLevel()
	return LocalData.Level.Value
end

local QuestConfig = require(Modules.QuestConfig)

for provider in next, QuestConfig.Questlines do
	if provider == "Haki" then
		continue
	end
	local displayName = provider:gsub("(%l)(%u)", "%1 %2")
	local toggleKey = `Auto {displayName} Questline`
	if SaveManager.Templates[toggleKey] == nil then
		SaveManager.Templates[toggleKey] = false
	end
end

-- function Utils:GetQuestData()
-- 	local Level = Utils:GetCurrentLevel()
-- 	local QuestLevelData = {}
-- 	local QuestData = {}

-- 	for QuestID, Data in pairs(QuestConfig.RepeatableQuests) do
-- 		local LevelRequire = Data.recommendedLevel
-- 		if Level >= LevelRequire then
-- 			local TargetEntities = Data.requirements[1]["npcType"]

-- 			table.insert(QuestLevelData, LevelRequire)
-- 			QuestData[LevelRequire] = Data
-- 			QuestData[LevelRequire].QuestID = QuestID
-- 			QuestData[LevelRequire].Target = TargetEntities
-- 		end
-- 	end

-- 	-- print("#QuestLevelData:", #QuestLevelData)

-- 	local CurrentQuestLevel = math.max(unpack(QuestLevelData))
-- 	local CurrentQuest = QuestData[CurrentQuestLevel]
-- 	local PreviousQuestLevel = nil

-- 	for level in pairs(QuestLevelData) do
-- 		if level ~= CurrentQuestLevel then
-- 			PreviousQuestLevel = math.max(PreviousQuestLevel or 0, level)
-- 		end
-- 	end

-- 	local PreviousQuest = PreviousQuestLevel and QuestData[PreviousQuestLevel] or nil

-- 	return CurrentQuest, PreviousQuest
-- end

function Utils:GetQuestData()
	local Level = Utils:GetCurrentLevel()
	local QuestLevelData = {}
	local QuestData = {}

	for QuestID, Data in pairs(QuestConfig.RepeatableQuests) do
		local LevelRequire = Data.recommendedLevel
		if Level >= LevelRequire then
			local TargetEntities = Data.requirements[1]["npcType"]

			table.insert(QuestLevelData, LevelRequire)
			QuestData[tostring(LevelRequire)] = Data
			QuestData[tostring(LevelRequire)].QuestID = QuestID
			QuestData[tostring(LevelRequire)].Target = TargetEntities

			-- print(QuestID,LevelRequire, TargetEntities)
		end
	end

	local CurrentQuestLevel = math.max(unpack(QuestLevelData))
	local CurrentQuest = QuestData[tostring(CurrentQuestLevel)]

	local QuestLevelData = {}
	local QuestData = {}

	for QuestID, Data in pairs(QuestConfig.RepeatableQuests) do
		local LevelRequire = Data.recommendedLevel
		if Level >= LevelRequire and LevelRequire ~= CurrentQuestLevel then
			local TargetEntities = Data.requirements[1]["npcType"]

			table.insert(QuestLevelData, LevelRequire)
			QuestData[tostring(LevelRequire)] = Data
			QuestData[tostring(LevelRequire)].QuestID = QuestID
			QuestData[tostring(LevelRequire)].Target = TargetEntities

			-- print(QuestID,LevelRequire, TargetEntities)
		end
	end

	local PreviousQuest
	if #QuestLevelData > 0 then
		local PreviousQuestLevel = tostring(math.max(unpack(QuestLevelData)))
		PreviousQuest = QuestData[PreviousQuestLevel]
	end

	return CurrentQuest, PreviousQuest
end

function Utils:AcceptQuest(questId)
	QuestAccept:FireServer(questId)
end

function Utils:IsQuest()
	local questUI = LocalPlayer.PlayerGui:FindFirstChild("QuestUI")

	if not questUI then
		return false
	end

	local questTitle = questUI.Quest.Quest.Holder.Content.QuestInfo.QuestTitle.QuestTitle

	return questUI.Quest.Visible, questTitle.Text
end

function Utils:GetQuestline(title)
	for questline, data in next, QuestConfig.Questlines do
		for _, stage in next, data.stages do
			if stage.title == title then
				return questline
			end
		end
	end

	return nil
end

function Utils:AbandonQuest()
	local questActive, questTitle = Utils:IsQuest()

	if questActive and questTitle then
		local questline = Utils:GetQuestline(questTitle)

		if questline then
			QuestAbandon:FireServer(questline)
		else
			QuestAbandon:FireServer("repeatable")
		end
	end
end

function Utils:GetSelfDistance(position)
	local rootPart = Utils:GetHumanoidRootPart()
	if not rootPart then
		return math.huge
	end
	return (rootPart.Position - position).Magnitude
end

function Utils:GetSpawnPoint()
	local Spawnpoint = workspace:FindFirstChild(("%s_Spawn"):format(LocalPlayer.Name))
	return Spawnpoint
end

function Utils:GetClosestCrystal(position)
	local nearestSpawnpoint, nearestDistance = nil, math.huge
	local playerPos = position or Utils:GetHumanoidRootPart().Position

	for _, island in next, workspace:GetChildren() do
		if island:IsA("Folder") then
			for _, object in next, island:GetChildren() do
				if object:IsA("Model") and object.Name:find("SpawnPointCrystal") then
					local distance = (playerPos - object:GetModelCFrame().Position).Magnitude
					if distance < nearestDistance then
						nearestSpawnpoint = object
						nearestDistance = distance
					end
				end
			end
		end
	end

	return nearestSpawnpoint
end

function Utils:GetEntities(Entities, Configuration)
	Configuration = Configuration or {}

	local EntitiesData = {}
	local MaxHealthEntity
	local DistanceData = {}
	local HealthData = {}

	for _, Entity in next, NPCs:GetChildren() do
		local Humanoid = Entity:FindFirstChildOfClass("Humanoid")
		if Humanoid and Humanoid.Health > 0 then
			for _, EntityToFind in next, Entities do
				local SearchName = EntityToFind == "SlimeWarrior" and "Slime" or EntityToFind
				local IsBoss = Entity.Name:find("Boss")

				if
					Utils:StartsWith(Entity.Name, SearchName)
					and ((not IsBoss) or (IsBoss and SearchName:find("Boss")))
				then
					local Health = Humanoid.Health
					local Distance = math.floor(Utils:GetSelfDistance(Entity:GetModelCFrame().Position))

					table.insert(HealthData, { Health = Health, Entity = Entity })
					table.insert(EntitiesData, Entity)
					table.insert(DistanceData, { Distance = Distance, Entity = Entity })

					if Configuration.GetMaxHealthEntity and Health >= Humanoid.MaxHealth then
						MaxHealthEntity = Entity
					end
				end
			end
		end
	end

	if #DistanceData == 0 then
		return
	end

	if MaxHealthEntity and Configuration.GetMaxHealthEntity then
		return MaxHealthEntity
	end

	if Configuration.LowestHealth then
		table.sort(HealthData, function(a, b)
			return a.Health < b.Health
		end)
		return HealthData[1].Entity, EntitiesData
	end

	table.sort(DistanceData, function(a, b)
		return a.Distance < b.Distance
	end)

	return DistanceData[1].Entity, EntitiesData
end

function Utils:GetTool(toolName)
	return LocalPlayer.Backpack:FindFirstChild(toolName) or LocalPlayer.Character:FindFirstChild(toolName)
end

function Utils:GetToolByType(Type)
	local holding = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")

	if holding and WeaponClassification["Tools"][holding.Name] == Type then
		return holding
	end

	for _, tool in next, LocalPlayer.Backpack:GetChildren() do
		if WeaponClassification["Tools"][tool.Name] == Type then
			return tool
		end
	end

	return nil
end

function Utils:EquipTool(RequestTool)
	if not Utils:Cooldown("EquipTool", 1) then
		return
	end

	local toolName = tostring(RequestTool)

	local tool = Utils:GetTool(toolName)

	if tool then
		if tool.Parent == LocalPlayer.Backpack then
			local Humanoid = Utils:GetHumanoid()

			if Humanoid then
				Humanoid:EquipTool(tool)
			end
		end

		return
	end

	EquipWeapon:FireServer("Equip", toolName)
end

function Utils:IsSkillCooldown(Weapon, SkillIndex)
	return LocalPlayer.PlayerGui.CooldownUI.MainFrame:FindFirstChild(
		("Cooldown_%s_Skill %s"):format(Weapon, SkillIndex)
	)
end

function Utils:AutoSkill(skills)
	local SkillIndex = {
		["Z"] = 1,
		["X"] = 2,
		["C"] = 3,
		["V"] = 4,
		["F"] = 5,
	}

	local holding = LocalPlayer.Character:FindFirstChildOfClass("Tool")
	if not holding then
		return
	end

	local SkillSettings = typeof(skills) == "table" and skills or SaveManager.Data["Skill Settings"]

	for key, config in next, SkillSettings do
		if not config["Enabled"] then
			continue
		end

		local skillIndex = SkillIndex[key]
		local delay = config["Delay"] or 0
		local cooldownTime = math.max(delay, 0.1)

		if not Utils:Cooldown("Skill_" .. key, cooldownTime) then
			continue
		end

		if Utils:IsSkillCooldown(holding.Name, skillIndex) then
			continue
		end

		RequestAbility:FireServer(skillIndex)
	end
end

function Utils:SplitCamelCase(str)
	return str:gsub("(%l)(%u)", "%1 %2")
end

function Utils:GetEntitiesList()
	local Entities = {}
	for _, data in next, QuestConfig.RepeatableQuests do
		local Entity = Utils:SplitCamelCase(data.requirements[1].npcType)

		table.insert(Entities, Entity)
	end

	table.sort(Entities)

	return Entities
end

function Utils:PrintTable(tbl, indent)
	indent = indent or 0
	local padding = string.rep("    ", indent)
	local lines = {}

	if typeof(tbl) ~= "table" then
		return tostring(tbl)
	end

	table.insert(lines, "{")
	for k, v in next, tbl do
		local key = typeof(k) == "string" and ('["' .. k .. '"]') or ("[" .. tostring(k) .. "]")
		if typeof(v) == "table" then
			table.insert(lines, padding .. "    " .. key .. " = " .. Utils:PrintTable(v, indent + 1) .. ",")
		elseif typeof(v) == "string" then
			table.insert(lines, padding .. "    " .. key .. ' = "' .. v .. '",')
		else
			table.insert(lines, padding .. "    " .. key .. " = " .. tostring(v) .. ",")
		end
	end
	table.insert(lines, padding .. "}")

	return table.concat(lines, "\n")
end

function Utils:FormatNumber(n)
	if n >= 1000000000 then
		return string.format("%.1fB", n / 1000000000)
	elseif n >= 1000000 then
		return string.format("%.1fM", n / 1000000)
	elseif n >= 1000 then
		return string.format("%.1fK", n / 1000)
	end
	return tostring(math.floor(n))
end

function Utils:GetWorldBossNames()
	local summonNames = {}
	for _, data in next, SummonableBossConfig.Bosses do
		summonNames[data.displayName] = true
	end

	local names = {}
	for bossId, data in next, BossConfig.Bosses do
		if not summonNames[data.displayName] then
			table.insert(names, data.displayName)
		end
	end
	table.sort(names)
	return names
end

function Utils:GetWorldBossIdByName(displayName)
	for bossId, data in next, BossConfig.Bosses do
		if data.displayName == displayName then
			return bossId
		end
	end
	return nil
end

function Utils:FindWorldBossEntity(bossId)
	for _, entity in next, NPCs:GetChildren() do
		local Humanoid = entity:FindFirstChildOfClass("Humanoid")
		if Humanoid and Humanoid.Health > 0 and entity.Name:find(bossId) then
			return entity
		end
	end
	return nil
end

function Utils:HandleWorldBossFarm()
	local WorldBossSettings = SaveManager.Data["World Boss Settings"]
	if not WorldBossSettings or #WorldBossSettings == 0 then
		if Caches.WorldBossStatusLabel then
			Caches.WorldBossStatusLabel.Text = "No bosses selected"
		end
		return
	end

	if not Utils:IsAlive() then
		Utils:WaitForRespawn()
	end

	for _, bossDisplayName in next, WorldBossSettings do
		local bossId = Utils:GetWorldBossIdByName(bossDisplayName)
		if not bossId then
			continue
		end

		local bossEntity = Utils:FindWorldBossEntity(bossId)

		if bossEntity then
			if Caches.WorldBossStatusLabel then
				Caches.WorldBossStatusLabel.Text = "Fighting: " .. bossDisplayName
			end

			Utils:KillEntity(bossEntity, function()
				return not SaveManager.Data["Auto World Boss"]
			end)

			return
		end
	end

	if Caches.WorldBossStatusLabel then
		Caches.WorldBossStatusLabel.Text = "Waiting for spawn..."
	end
end

function Utils:UpdateWorldBossLabels()
	if not Caches.WorldBossSpawnedLabel then
		return
	end

	local WorldBossSettings = SaveManager.Data["World Boss Settings"]
	if not WorldBossSettings or #WorldBossSettings == 0 then
		Caches.WorldBossSpawnedLabel.Text = "No bosses selected"
		return
	end

	local alive = {}
	for _, bossDisplayName in next, WorldBossSettings do
		local bossId = Utils:GetWorldBossIdByName(bossDisplayName)
		if bossId then
			local entity = Utils:FindWorldBossEntity(bossId)
			if entity then
				local hp = entity:FindFirstChildOfClass("Humanoid")
				table.insert(
					alive,
					string.format(
						"%s (%s/%s)",
						bossDisplayName,
						hp and Utils:FormatNumber(hp.Health) or "?",
						hp and Utils:FormatNumber(hp.MaxHealth) or "?"
					)
				)
			end
		end
	end

	Caches.WorldBossSpawnedLabel.Text = #alive > 0 and table.concat(alive, ", ") or "None spawned"
end

function Utils:GetBossList()
	local Bosses = {}
	for bossId, data in next, SummonableBossConfig.Bosses do
		table.insert(Bosses, {
			id = bossId,
			name = data.displayName,
			hasDifficulty = data.hasDifficulty or false,
		})
	end
	table.sort(Bosses, function(a, b)
		return a.name < b.name
	end)
	return Bosses
end
function Utils:GetBossesData()
	local WorldBosses = {
		List = {},
		Data = {},
	}
	local SummonBosses = {
		List = {},
		Data = {},
	}

	for _, bossData in pairs(SummonableBossConfig.Bosses) do
		table.insert(SummonBosses.List, bossData.displayName)
		SummonBosses.Data[bossData.displayName] = bossData
	end

	for _, bossData in pairs(BossConfig.Bosses) do
		if not table.find(SummonBosses.List, bossData.displayName) then
			table.insert(WorldBosses.List, bossData.displayName)
			WorldBosses.Data[bossData.displayName] = bossData
		end
	end

	return WorldBosses, SummonBosses
end
function Utils:GetBossDisplayNames()
	local names = {}
	for _, boss in next, Utils:GetBossList() do
		table.insert(names, boss.name)
	end
	return names
end

function Utils:GetBossDataByName(displayName)
	for bossId, data in next, SummonableBossConfig.Bosses do
		if data.displayName == displayName then
			return bossId, data
		end
	end
	return nil, nil
end

function Utils:CanAffordBoss(bossId, difficulty)
	local bossData = SummonableBossConfig.Bosses[bossId]
	if not bossData then
		return false, "Boss not found"
	end

	local costs
	if bossData.hasDifficulty and difficulty then
		costs = bossData.costs[difficulty]
	else
		costs = bossData.costs
	end

	if not costs then
		return false, "No cost data"
	end

	if costs.items then
		for _, itemData in next, costs.items do
			local item = Utils:GetItem(itemData.category, itemData.itemId)
			if not item or item.quantity < itemData.quantity then
				return false, string.format("Need %dx %s", itemData.quantity, itemData.itemId)
			end
		end
	end

	if costs.currencies then
		for _, currencyData in next, costs.currencies do
			if currencyData.type == "Money" then
				if Utils:GetMoney() < currencyData.amount then
					return false, string.format("Need %d Money", currencyData.amount)
				end
			elseif currencyData.type == "Gems" then
				if Utils:GetGems() < currencyData.amount then
					return false, string.format("Need %d Gems", currencyData.amount)
				end
			end
		end
	end

	return true, "Affordable"
end
function Utils:GetIslandList()
    local Island = {
        List = {},
        Data = {}
    }
    for provider, data in next, PortalConfig.Portals do
        table.insert(Island["List"], data.DisplayName)
        Island["Data"][data.DisplayName] = data
        Island["Data"][data.DisplayName]["Provider"] = provider
    end

    table.sort(Island["List"])

    return Island
end
function Utils:TeleportIsland(islandName)
    local islandData = Utils:GetIslandList().Data[islandName]
    local islandFolder = islandData["IslandFolder"] and workspace:FindFirstChild(islandData["IslandFolder"])

    if not islandFolder then
        return
    end

    for _, Model in next, islandFolder:GetChildren() do
        if Model:IsA("Model") and Model.Name:find("SpawnPointCrystal") then
            Utils:ToTarget(Model:GetModelCFrame())
            break
        end
    end
end
function Utils:GetNPCList()
    local NPC = {
        List = {},
        Data = {}
    }
    for _, Model in next, ServiceNPCs:GetChildren() do
        if Model:IsA("Model") and not Model.Name:find("Quest") then
            local formattedName = Utils:SplitCamelCase(Model.Name)
            local DisplayName = formattedName:gsub("NPC", "")
            print(DisplayName)

            table.insert(NPC["List"], DisplayName)
            NPC["Data"][DisplayName] = {
                Parent = Model,
                CFrame = Model:GetModelCFrame()
            }
        end
    end

    table.sort(NPC["List"])

    return NPC
end
function Utils:TeleportNPC(NPC)
    local NPCData = Utils:GetNPCList().Data
    if NPCData[NPC] then
        Utils:ToTarget(NPCData[NPC].CFrame)
    end
end
function Utils:FindBossEntity(bossId)
	for _, entity in next, NPCs:GetChildren() do
		local Humanoid = entity:FindFirstChildOfClass("Humanoid")
		if Humanoid and Humanoid.Health > 0 and entity.Name:find(bossId) then
			return entity
		end
	end
	return nil
end

function Utils:UpdateBossLabels()
	if Caches.BossBalanceLabel then
		Caches.BossBalanceLabel.Text = string.format(
			"%s Money / %s Gems",
			Utils:FormatNumber(Utils:GetMoney()),
			Utils:FormatNumber(Utils:GetGems())
		)
	end

	if not Caches.BossCostLabel then
		return
	end

	local BossSettings = SaveManager.Data["Boss Settings"]
	if not BossSettings or #BossSettings == 0 then
		Caches.BossCostLabel.Text = "No bosses selected"
		return
	end

	local difficulty = SaveManager.Data["Boss Difficulty"] or "Normal"
	local parts = {}

	Utils:GetInventory()

	for _, bossDisplayName in next, BossSettings do
		local bossId, bossData = Utils:GetBossDataByName(bossDisplayName)
		if not bossId then
			continue
		end

		local useDifficulty = bossData.hasDifficulty and difficulty or nil
		local costs
		if useDifficulty then
			costs = bossData.costs[useDifficulty]
		else
			costs = bossData.costs
		end

		if not costs then
			continue
		end

		local costParts = {}

		if costs.items then
			for _, itemData in next, costs.items do
				local item = Utils:GetItem(itemData.category, itemData.itemId)
				local have = item and item.quantity or 0
				local need = itemData.quantity
				local ok = have >= need and "✓" or "✗"
				table.insert(
					costParts,
					string.format(
						"%s %s/%s %s",
						ok,
						Utils:FormatNumber(have),
						Utils:FormatNumber(need),
						itemData.itemId
					)
				)
			end
		end

		if costs.currencies then
			for _, currencyData in next, costs.currencies do
				local have = 0
				if currencyData.type == "Money" then
					have = Utils:GetMoney()
				elseif currencyData.type == "Gems" then
					have = Utils:GetGems()
				end
				local need = currencyData.amount
				local ok = have >= need and "✓" or "✗"
				table.insert(
					costParts,
					string.format(
						"%s %s/%s %s",
						ok,
						Utils:FormatNumber(have),
						Utils:FormatNumber(need),
						currencyData.type
					)
				)
			end
		end

		table.insert(parts, string.format("%s: %s", bossDisplayName, table.concat(costParts, ", ")))
	end

	Caches.BossCostLabel.Text = #parts > 0 and table.concat(parts, " | ") or "..."
end

function Utils:HandleBossFarm()
	local BossSettings = SaveManager.Data["Boss Settings"]
	if not BossSettings or #BossSettings == 0 then
		if Caches.BossStatusLabel then
			Caches.BossStatusLabel.Text = "No bosses selected"
		end
		return
	end

	if not Utils:IsAlive() then
		Utils:WaitForRespawn()
	end

	local difficulty = SaveManager.Data["Boss Difficulty"] or "Normal"

	Utils:GetInventory()

	for _, bossDisplayName in next, BossSettings do
		local bossId, bossData = Utils:GetBossDataByName(bossDisplayName)
		if not bossId then
			continue
		end

		local useDifficulty = bossData.hasDifficulty and difficulty or nil

		local bossEntity = Utils:FindBossEntity(bossId)

		if bossEntity then
			if Caches.BossStatusLabel then
				Caches.BossStatusLabel.Text = "Fighting: " .. bossDisplayName
			end

			Utils:KillEntity(bossEntity, function()
				return not SaveManager.Data["Auto Boss"]
			end)

			return
		end

		local canAfford, reason = Utils:CanAffordBoss(bossId, useDifficulty)

		if canAfford then
			if Caches.BossStatusLabel then
				Caches.BossStatusLabel.Text = string.format(
					"Spawning: %s%s",
					bossDisplayName,
					useDifficulty and (" [" .. useDifficulty .. "]") or ""
				)
			end

			local SummonNPC = Utils:FindNPC(bossData.spawnNPC)
			if SummonNPC then
				Utils:ToTarget(SummonNPC:GetModelCFrame())

				if Utils:GetSelfDistance(SummonNPC:GetModelCFrame().Position) < 20 then
					if useDifficulty then
						RequestSummonBoss:FireServer(bossId, useDifficulty)
					else
						RequestSummonBoss:FireServer(bossId)
					end
					task.wait(2)
				end
			end

			return
		else
			if Caches.BossStatusLabel then
				Caches.BossStatusLabel.Text = string.format("%s: %s", bossDisplayName, reason)
			end
		end
	end
end
function Utils:GetQuestlineStage(title)
	for questline, data in next, QuestConfig.Questlines do
		for _, stage in next, data.stages do
			if stage.title == title then
				return stage
			end
		end
	end

	return nil
end

function Utils:SpawnAndKillBoss(bossId)
	local bossEntity = Utils:FindBossEntity(bossId)
	if bossEntity then
		Utils:KillEntity(bossEntity, function()
			return false
		end)
		return
	end

	local bossData = SummonableBossConfig.Bosses[bossId]
	if not bossData then
		return
	end

	if not Utils:CanAffordBoss(bossId) then
		return
	end

	local SummonNPC = Utils:FindNPC(bossData.spawnNPC)
	if SummonNPC then
		Utils:ToTarget(SummonNPC:GetModelCFrame())
		if Utils:GetSelfDistance(SummonNPC:GetModelCFrame().Position) < 20 then
			RequestSummonBoss:FireServer(bossId)
			task.wait(2)
		end
	end
end

function Utils:AttackNearestNPC(entities, useCombat)
	local TargetEntity = Utils:GetEntities(entities or { "Thief", "Monkey" }, { LowestHealth = true })
	if not TargetEntity then
		return
	end

	Utils:ToTarget(
		TargetEntity:GetModelCFrame()
			* CFrame.new(0, SaveManager.Data["Attack Distance"], 0)
			* CFrame.Angles(math.rad(270), 0, 0)
	)

	if useCombat then
		Utils:EquipTool("Combat")
	else
		Utils:EquipBestWeapon()
	end

	if Utils:GetSelfDistance(TargetEntity:GetModelCFrame().Position) < SaveManager.Data["Attack Distance"] + 10 then
		Utils:AutoSkill()
	end

	Utils:Attack(TargetEntity)
end

function Utils:CollectPuzzlePieces(pieceData, pieceName)
	for _, islandName in ipairs(pieceData.Index) do
		local position = pieceData.Position[islandName]

		Utils:Thread(function()
			LocalPlayer:RequestStreamAroundAsync(position, 3)
		end)

		local startTime = tick() + 1.5
		repeat
			Utils:ToTarget(CFrame.new(position))
			task.wait()
		until Utils:GetSelfDistance(position) < 15 or tick() >= startTime

		local island = workspace:FindFirstChild(islandName)
		if island then
			local piece = island:FindFirstChild(pieceName)
			if piece then
				local prompt = piece:FindFirstChildOfClass("ProximityPrompt")
				if prompt then
					fireproximityprompt(prompt)
					task.wait(0.3)
				end
			end
		end
	end
end

function Utils:HandleQuestTrackingType(trackingType)
	local TrackingHandlers = {
		["DungeonPuzzlePieces"] = function()
			Utils:CollectPuzzlePieces({
				Position = {
					StarterIsland = Vector3.new(87, 10, -138),
					JungleIsland = Vector3.new(-396, 1, 509),
					DesertIsland = Vector3.new(-1057, 6, -304),
					SnowIsland = Vector3.new(-311, 0, -1188),
					ShibuyaStation = Vector3.new(1711, 140, -29),
					HollowIsland = Vector3.new(-689, 100, 1332),
				},
				Index = {
					"StarterIsland",
					"JungleIsland",
					"DesertIsland",
					"SnowIsland",
					"ShibuyaStation",
					"HollowIsland",
				},
			}, "DungeonPuzzlePiece")
		end,

		["SlimePuzzlePieces"] = function()
			Utils:CollectPuzzlePieces({
				Position = {
					DesertIsland = Vector3.new(-854, 1, -320),
					SnowIsland = Vector3.new(-437, 23, -1183),
					StarterIsland = Vector3.new(62, 36, -144),
					JungleIsland = Vector3.new(-584, 59, 317),
					ShibuyaStation = Vector3.new(1745, 9, 493),
					HollowIsland = Vector3.new(-437, 24, 1397),
					ShinjukuIsland = Vector3.new(788, 68, -2309),
				},
				Index = {
					"DesertIsland",
					"SnowIsland",
					"StarterIsland",
					"JungleIsland",
					"ShibuyaStation",
					"HollowIsland",
					"ShinjukuIsland",
				},
			}, "SlimePuzzlePiece")
		end,

		["HogyokuPieces"] = function()
			print("called HogyokuPieces function")
			local pieceData = {
				Position = {
					SnowIsland = Vector3.new(-426, 59, -1237),
					ShibuyaStation = Vector3.new(1638, 88, 247),
					HollowIsland = Vector3.new(-636, 25, 1204),
					ShinjukuIsland = Vector3.new(650, 137, -2071),
					SlimeIsland = Vector3.new(-1206, 33, 465),
					JudgementIsland = Vector3.new(-906, 15, -1260),
				},
				Index = {
					"SnowIsland",
					"ShibuyaStation",
					"HollowIsland",
					"ShinjukuIsland",
					"SlimeIsland",
					"JudgementIsland",
				},
			}

			for index, islandName in ipairs(pieceData.Index) do
				local position = pieceData.Position[islandName]
				Utils:Thread(function()
					LocalPlayer:RequestStreamAroundAsync(position, 3)
				end)

				local startTime = tick() + 3
				repeat
					warn("stuck ?")
					Utils:ToTarget(CFrame.new(position))
					task.wait(0.1)
				until Utils:GetSelfDistance(position) < 15 or tick() >= startTime

				task.wait(2)

				for _, fragment in next, workspace:GetChildren() do
					if fragment.Name == `HogyokuFragment{index}` then
						local prompt = fragment:FindFirstChildOfClass("ProximityPrompt")
						if prompt then
							task.wait(0.1)
							fireproximityprompt(prompt)
							task.wait(0.1)
							break
						end
					end
				end
			end
		end,

		["GroundSmashUses"] = function()
			Utils:ToTarget(CFrame.new(-65, -3, -163))
			Utils:EquipTool("Combat")

			local cd = PlayerGui.CooldownUI.MainFrame:FindFirstChild("Cooldown_Combat_GroundSmash")
			if not cd or cd.Txt.AutoSizeHolder.WeaponNameAndCooldown.Text:find("Ready") then
				RequestAbility:FireServer(1)
			end
		end,

		["HasShinigamiRace"] = function()
			if Utils:HasTargetRace({"Shinigami"}) then
				return
			end

			local item = Utils:GetItem("Items", "Race Reroll")
			if not item or item.quantity <= 0 then
				warn("No Race Rerolls left")
				SaveManager:Toast("No Race Rerolls left !", "error")

                task.wait(5)

				return
			end

			UseItem:FireServer("Use", "Race Reroll", 1, false)
			task.wait(0.5)
		end,

		["DeemedWorthy"] = function()
			local item = Utils:GetItem("Items", "Worthiness Fragment")

			if not item or item.quantity <= 0 then
				warn("No Worthiness Fragments left")
				SaveManager:Toast("No Worthiness Fragments left !", "error")

                task.wait(5)

				return
			end

			UseItem:FireServer("Use", "Worthiness Fragment", 1, false)
		end,
		["CombatNPCKills"] = function()
			Utils:AttackNearestNPC({ "Thief", "Monkey" }, true)
		end,

		["CombatPunches"] = function()
			Utils:AttackNearestNPC({ "Thief", "Monkey" }, true)
		end,

		["AnyNPCKills"] = function()
			Utils:AttackNearestNPC({ "Thief", "Monkey" })
		end,

		["HakiNPCKills"] = function()
			Utils:AttackNearestNPC({ "Thief", "Monkey" })
		end,

		["AnyAbilityUses"] = function()
			Utils:EquipBestWeapon()
			Utils:AutoSkill()
		end,

		["DamageDealt"] = function()
			Utils:AttackNearestNPC({ "TrainingDummy" })
		end,

		["DamageTaken"] = function()
			Utils:AttackNearestNPC({ "Thief", "Monkey" })
		end,

		["AnyBossKills"] = function()
			Utils:SpawnAndKillBoss("SaberBoss")
		end,

		["GojoBossKills"] = function()
			Utils:SpawnAndKillBoss("GojoBoss")
		end,

		["AizenBossKills"] = function()
			Utils:SpawnAndKillBoss("AizenBoss")
		end,

		["HardAizenBossKills"] = function()
			Utils:SpawnAndKillBoss("TrueAizenBoss")
		end,

		["SukunaBossKills"] = function()
			Utils:SpawnAndKillBoss("SukunaBoss")
		end,

		["JinwooBossKills"] = function()
			Utils:SpawnAndKillBoss("JinwooBoss")
		end,

		["HardRimuruBossKills"] = function()
			Utils:SpawnAndKillBoss("RimuruBoss")
		end,

		["HollowKills"] = function()
			Utils:AttackNearestNPC({ "Hollow" })
		end,

		["ShadowSoldierKills"] = function()
			Utils:AttackNearestNPC({ "ShadowSoldier" })
		end,

		["PlayTime"] = function() end,
		["ObsHakiDodges"] = function() end,
		["DemonitePieces"] = function()
			for _, coreName in ipairs({ "DemoniteCore1", "DemoniteCore2" }) do
				local core = workspace:FindFirstChild(coreName)
				if core then
					local prompt = core:FindFirstChild("DemoniteCollectPrompt")
					if prompt then
						local startTime = tick() + 2
						repeat
							Utils:ToTarget(core.CFrame)
							task.wait()
						until Utils:GetSelfDistance(core.CFrame.Position) < 15 or tick() >= startTime

						task.wait(2)
						fireproximityprompt(prompt)
						task.wait(0.5)
					end
				end
			end
		end,
	}

	local handler = TrackingHandlers[trackingType]
	print("handler:", handler, trackingType)
	if handler then
		handler()
	end
end

function Utils:HandleQuestline(questLineTask)
	print("Handling questline task:", questLineTask)
	local currentQuestline = Caches["QuestLine"][questLineTask]
	local questlineProvider = currentQuestline.QuestlineProvider

	if questlineProvider == "Haki" and Caches.BusoHakiQuestlineCompleted then
		return
	end

	Caches.CompletedQuestlines = Caches.CompletedQuestlines or {}
	if Caches.CompletedQuestlines[questlineProvider] then
		warn("Questline already completed:", questlineProvider)
		return
	end

	local questActive, questTitle = Utils:IsQuest()
	local questLineStageData = Utils:GetQuestlineStage(questTitle)
	local questlineData = QuestConfig.Questlines[questlineProvider]

	print("questActive:", questActive)
	print("questLineStageData:", questLineStageData)

	if questActive and questLineStageData then
		Utils:HandleQuestTrackingType(questLineStageData.trackingType)
	elseif questActive then
		Utils:AbandonQuest()
	else
		Utils:AcceptQuest(questlineData.npcName)
		task.wait(2)

		local questAppeared = Utils:IsQuest()
		if not questAppeared then
			local canAffordCost = true

			if questlineData.cost then
				if questlineData.cost.Money and Utils:GetMoney() < questlineData.cost.Money then
					canAffordCost = false
				end
				if questlineData.cost.Gems and Utils:GetGems() < questlineData.cost.Gems then
					canAffordCost = false
				end
				if questlineData.cost.Items then
					for _, itemReq in next, questlineData.cost.Items do
						local item = Utils:GetItem("Items", itemReq.name)
						if not item or item.quantity < (itemReq.quantity or 1) then
							canAffordCost = false
							break
						end
					end
				end
			end

			if canAffordCost then
				Caches.CompletedQuestlines[questlineProvider] = true
			end
		end
	end
end

function Utils:GetBestTitle()
	if not Utils:Cooldown("GetTitlesData", 2) then
		return Caches.BestTitle, Caches.TitlesData
	end

	local TitlesData = GetTitlesData:InvokeServer()
	Caches.TitlesData = TitlesData

	local TitleLevel = {}
	local TitleData = {}

	for Title, Data in next, TitleConfig.Titles do
		local Success, LevelRequirement = pcall(function()
			return tonumber(Data["unlockRequirement"])
		end)
		if Success and table.find(TitlesData.unlocked, Title) then
			table.insert(TitleLevel, LevelRequirement)
			TitleData[tostring(LevelRequirement)] = Title
		end
	end

	if #TitleLevel <= 0 then
		Caches.BestTitle = "Novice"
	else
		Caches.BestTitle = TitleData[tostring(math.max(unpack(TitleLevel)))]
	end

	return Caches.BestTitle, TitlesData
end

function Utils:HandleAutoTitle()
	local BestTitle, TitlesData = Utils:GetBestTitle()
	if BestTitle and TitlesData and TitlesData.equipped ~= BestTitle then
		Utils:SetFarmStatus("Equipping title: " .. BestTitle)
		TitleEquip:FireServer(BestTitle)
	end
end

function Utils:GetHakiStatus()
	if Utils:Cooldown("HakiStatus", 1) then
		HakiRemote:FireServer("GetStatus")
		ObservationHakiRemote:FireServer("GetStatus")

		local Parts = { LocalPlayer.Character["Left Arm"], LocalPlayer.Character["Right Arm"] }
		for _, Part in next, Parts do
			for _, v in next, Part:GetChildren() do
				if v:IsA("ParticleEmitter") then
					v:Destroy()
				end
			end
		end
	end
end

function Utils:HandleAutoBuyObservationHaki()
	if Caches.ObservationHakiOwned then
		return
	end

	if not Caches.BusoHakiOwned then
		return
	end

	if Utils:GetGems() < 300 or Utils:GetMoney() < 250000 then
		return
	end

	Utils:SetFarmStatus("Buying Observation Haki")
	Utils:ToTarget(CFrame.new(-714, 12, -525))

	if Utils:GetSelfDistance(Vector3.new(-714, 12, -525)) < 8 then
		local ObsNPC = ServiceNPCs:FindFirstChild("ObservationBuyer")
		if ObsNPC and ObsNPC:FindFirstChild("HumanoidRootPart") then
			fireproximityprompt(ObsNPC.HumanoidRootPart:FindFirstChildOfClass("ProximityPrompt"))
		end
	end
end

function Utils:HandleAutoBuyGryphon()
	local owned = Utils:GetItem("Sword", "Gryphon")
	if owned then
		return
	end

	if Utils:GetMoney() < 650000 or Utils:GetGems() < 650 then
		return
	end

	Utils:SetFarmStatus("Buying Gryphon")
	Utils:ToTarget(CFrame.new(1433, 9, 275))

	if Utils:GetSelfDistance(Vector3.new(1433, 9, 275)) < 8 then
		local GryphonNPC = ServiceNPCs:FindFirstChild("GryphonBuyerNPC")
		if GryphonNPC and GryphonNPC:FindFirstChild("HumanoidRootPart") then
			fireproximityprompt(GryphonNPC.HumanoidRootPart:FindFirstChildOfClass("ProximityPrompt"))
		end
	end
end

function Utils:IsArtifactUnlocked()
	if Utils:Cooldown("GetArtifactData", 1) and RemoteFunctions then
		local GetArtifactData = RemoteFunctions:FindFirstChild("GetArtifactData")
		if GetArtifactData then
			local success, result = pcall(function()
				return GetArtifactData:InvokeServer()
			end)
			if success and result then
				Caches.ArtifactUnlocked = result.Unlocked == true
			end
		end
	end
	return Caches.ArtifactUnlocked == true
end

function Utils:HandleAutoUnlockArtifact()
	if Utils:IsArtifactUnlocked() then
		return
	end

	if Utils:GetCurrentLevel() < 2500 then
		return
	end

	if Utils:GetGems() < 500 or Utils:GetMoney() < 500000 then
		return
	end

	Utils:SetFarmStatus("Unlocking Artifact")
	Utils:ToTarget(CFrame.new(-439, 2, -1092))

	if Utils:GetSelfDistance(Vector3.new(-439, 2, -1092)) < 8 then
		local ArtifactNPC = ServiceNPCs:FindFirstChild("ArtifactMilestoneNPC")
		if ArtifactNPC and ArtifactNPC:FindFirstChild("HumanoidRootPart") then
			fireproximityprompt(ArtifactNPC.HumanoidRootPart:FindFirstChildOfClass("ProximityPrompt"))
			ArtifactUnlockSystem:FireServer()
		end
	end
end

function Utils:HandleAutoAscend()
	if not Utils:Cooldown("GetAscendData", 5) then
		return
	end

	local success, ascendData = pcall(function()
		return GetAscendData:InvokeServer()
	end)

	if not success or not ascendData then
		return
	end

	if ascendData.isMaxed then
		return
	end

	if ascendData.allMet then
		RequestAscend:FireServer()
	end
end

function Utils:HandleAutoPurchases()
	if not Utils:IsAlive() then
		return
	end

	Utils:GetInventory()

	if SaveManager.Data["Auto Ascend"] then
		Utils:HandleAutoAscend()
	end

	if SaveManager.Data["Auto Best Title"] then
		Utils:HandleAutoTitle()
	end

	if SaveManager.Data["Auto Buy Gryphon"] then
		if not Utils:GetItem("Sword", "Gryphon") then
			Utils:HandleAutoBuyGryphon()
			return
		end
	end

	if SaveManager.Data["Auto Buso Haki"] then
		if not Caches.BusoHakiOwned and Caches.BusoHakiQuestlineCompleted then
			if Utils:GetGems() >= 300 and Utils:GetMoney() >= 250000 then
				Utils:SetFarmStatus("Buying Buso Haki")
				Utils:ToTarget(CFrame.new(-500, 24, -1250))

				if Utils:GetSelfDistance(Vector3.new(-500, 24, -1250)) < 8 then
					local HakiNPC = ServiceNPCs:FindFirstChild("HakiQuestNPC")
					if HakiNPC and HakiNPC:FindFirstChild("HumanoidRootPart") then
						fireproximityprompt(HakiNPC.HumanoidRootPart:FindFirstChildOfClass("ProximityPrompt"))
					end
				end

				return
			end
		end
	end

	if SaveManager.Data["Auto Observation Haki"] then
		if not Caches.ObservationHakiOwned then
			Utils:HandleAutoBuyObservationHaki()
			return
		end
	end

	if SaveManager.Data["Auto Unlock Artifact"] then
		if not Utils:IsArtifactUnlocked() then
			Utils:HandleAutoUnlockArtifact()
			return
		end
	end
end

function Utils:HandleOpenChests()
	local SelectedChests = SaveManager.Data["Selected Chests"]

	if not SelectedChests or #SelectedChests == 0 then
		return
	end

	local amount = SaveManager.Data["Chest Amount"] or 1

	Utils:GetInventory()

	for _, chestName in next, SelectedChests do
		local item = Utils:GetItem("Items", chestName)
		if item and item.quantity > 0 then
			local useAmount = math.min(amount, item.quantity)
			UseItem:FireServer("Use", chestName, useAmount, false)
		end
	end
end

function Utils:HandleEntityFarm()
	if not Utils:IsAlive() then
		Utils:WaitForRespawn()
	end

	local SelectedEntities = SaveManager.Data["Selected Entities"]
	if not SelectedEntities or #SelectedEntities == 0 then
		return
	end

	local RawNames = {}
	for _, displayName in next, SelectedEntities do
		table.insert(RawNames, (displayName:gsub(" ", "")))
	end

	local Entity = Utils:GetEntities(RawNames, { LowestHealth = true })

	if not Entity then
		return
	end

	Utils:KillEntity(Entity, function()
		return not SaveManager.Data["Auto Farm Entity"]
	end)
end

function Utils:UpdateStatLabels()
	if Utils:Cooldown("GetPlayerStats_Labels", 0.15) then
		local PlayerStats = GetPlayerStats:InvokeServer()
		if PlayerStats then
			Caches.StatPoints = PlayerStats.StatPoints
			Caches.Stats = PlayerStats.Stats
		end
	end

	local Stats = Caches.Stats
	local StatPoints = Caches.StatPoints or 0

	if Caches.StatPointsLabel then
		Caches.StatPointsLabel.Text = tostring(StatPoints)
	end

	if Caches.StatBreakdownLabel and Stats then
		Caches.StatBreakdownLabel.Text = string.format(
			"M:%d S:%d D:%d P:%d",
			Stats["Melee"] or 0,
			Stats["Sword"] or 0,
			Stats["Defense"] or 0,
			Stats["Power"] or 0
		)
	end

	if Caches.StatFocusLabel then
		if SaveManager.Data["Stat Mode"] == "Smart" then
			local holding = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
			local weaponType = holding and WeaponClassification["Tools"][holding.Name]
			if weaponType then
				local current = (Stats and Stats[weaponType]) or 0
				if current >= 13000 then
					Caches.StatFocusLabel.Text = string.format("%s (maxed) -> Defense", weaponType)
				else
					Caches.StatFocusLabel.Text = string.format("%s (%d/13000)", weaponType, current)
				end
			else
				Caches.StatFocusLabel.Text = "No weapon equipped"
			end
		else
			local selected = SaveManager.Data["Selected Stats"]
			if selected and #selected > 0 then
				Caches.StatFocusLabel.Text = table.concat(selected, ", ")
			else
				Caches.StatFocusLabel.Text = "No stats selected"
			end
		end
	end
end

function Utils:HandleUpgradeStats()
	Utils:UpdateStatLabels()

	if SaveManager.Data["Stat Mode"] == "Smart" then
		local holding = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
		local weaponType = holding and WeaponClassification["Tools"][holding.Name]

		if not weaponType then
			return
		end

		if Caches.LastSmartStatType ~= weaponType then
			Services.ReplicatedStorage.RemoteEvents.ResetStats:FireServer()
			Caches.LastSmartStatType = weaponType
		end

		local PlayerStats = GetPlayerStats:InvokeServer()
		Caches.StatPoints = PlayerStats.StatPoints
		Caches.Stats = PlayerStats.Stats

		local StatPoints = Caches.StatPoints or 0
		if StatPoints > 0 then
			local currentInStat = (Caches.Stats and Caches.Stats[weaponType]) or 0
			local canAllocate = math.min(StatPoints, 13000 - currentInStat)

			if canAllocate > 0 then
				AllocateStat:FireServer(weaponType, canAllocate)
			end

			local remaining = StatPoints - math.max(canAllocate, 0)
			if remaining > 0 and weaponType ~= "Defense" then
				local currentDefense = (Caches.Stats and Caches.Stats["Defense"]) or 0
				local canDefense = math.min(remaining, 13000 - currentDefense)
				if canDefense > 0 then
					AllocateStat:FireServer("Defense", canDefense)
				end
			end
		end
	else
		local StatPoints = Caches.StatPoints or 0
		if StatPoints > 0 then
			for _, Stats in next, SaveManager.Data["Selected Stats"] do
				AllocateStat:FireServer(Stats, StatPoints / #SaveManager.Data["Selected Stats"])
			end
		end
	end
end

function Utils:KillEntity(TargetEntity, ShouldStop)
	local Humanoid = TargetEntity:FindFirstChildOfClass("Humanoid")

	if not Humanoid or Humanoid.Health <= 0 then
		return
	end

	Utils:EquipBestWeapon()
	Utils:Float(true)

	repeat
		Utils:ToTarget(
			TargetEntity:GetModelCFrame()
				* CFrame.new(0, SaveManager.Data["Attack Distance"], 0)
				* CFrame.Angles(math.rad(270), 0, 0)
		)

		if Utils:GetSelfDistance(TargetEntity:GetModelCFrame().Position) < SaveManager.Data["Attack Distance"] + 10 then
			Utils:AutoSkill()
		end

		Utils:Attack(TargetEntity)

		task.wait()
	until not not TargetEntity
		or not TargetEntity.PrimaryPart
		or not Humanoid
		or Humanoid.Health <= 0
		or (ShouldStop and ShouldStop())

	Utils:Float(false)
end

Caches.Inventory = {
	Data = {},
	Updated = false,
	UpdatedAt = 0,
}

local InventoryBindable = LocalPlayer:FindFirstChild("InventoryBindable")
	or Utils:Create("BindableEvent", {
		Name = "InventoryBindable",
		Parent = LocalPlayer,
	})

function Utils:GetInventory()
	if Utils:Cooldown("RequestInventory", 1) then
		RequestInventory:FireServer()

		if not Caches.Inventory.Updated then
			InventoryBindable.Event:Wait()
		end
	end

	return Caches.Inventory.Data
end

function Utils:GetItem(itemType, itemName)
	Utils:GetInventory()

	local items = Caches.Inventory.Data[itemType]

	if items then
		for _, item in next, items do
			if item.name == itemName then
				return item
			end
		end
	end

	return nil
end

Utils:Connect(UpdateInventory.OnClientEvent, function(eventType, payload)
	Caches.Inventory.Data[eventType] = payload

	Caches.Inventory.Updated = true
	Caches.Inventory.UpdatedAt = tick()

	InventoryBindable:Fire()

	-- warn("[Utils] Inventory updated:", Type, "Data:", Data)
end)

function Utils:GetMoney()
	return LocalPlayer.Data.Money.Value
end

function Utils:GetGems()
	return LocalPlayer.Data.Gems.Value
end

function Utils:ShouldYieldForBoss()
	if SaveManager.Data["Auto Boss"] then
		local BossSettings = SaveManager.Data["Boss Settings"]
		if BossSettings and #BossSettings > 0 then
			local difficulty = SaveManager.Data["Boss Difficulty"] or "Normal"

			for _, bossDisplayName in next, BossSettings do
				local bossId, bossData = Utils:GetBossDataByName(bossDisplayName)
				if not bossId then
					continue
				end

				if Utils:FindBossEntity(bossId) then
					return true
				end

				local useDifficulty = bossData.hasDifficulty and difficulty or nil
				if Utils:CanAffordBoss(bossId, useDifficulty) then
					return true
				end
			end
		end
	end

	if SaveManager.Data["Auto World Boss"] then
		local WorldBossSettings = SaveManager.Data["World Boss Settings"]
		if WorldBossSettings and #WorldBossSettings > 0 then
			for _, bossDisplayName in next, WorldBossSettings do
				local bossId = Utils:GetWorldBossIdByName(bossDisplayName)
				if bossId and Utils:FindWorldBossEntity(bossId) then
					return true
				end
			end
		end
	end

	return false
end

function Utils:EquipBestWeapon()
	if SaveManager.Data["Auto Buy Gryphon"] and Utils:GetTool("Gryphon") then
		Utils:EquipTool("Gryphon")
	elseif SaveManager.Data["Auto Dark Blade"] and Utils:GetTool("Dark Blade") then
		Utils:EquipTool("Dark Blade")
	else
		Utils:EquipTool(Utils:GetToolByType(SaveManager.Data["Selected Weapon"]))
	end
end

function Utils:SetFarmStatus(text)
	if Caches.FarmStatusLabel then
		Caches.FarmStatusLabel.Text = text
	end

	local running = text ~= nil and text ~= "" and text ~= "Idle"

	if Caches.FarmProgress then
		Caches.FarmProgress.Indeterminate = running
		Caches.FarmProgress.Text = text or "Idle"
	end

	if Caches.FarmSection then
		Caches.FarmSection.Badge = running and "Running" or "Idle"
		Caches.FarmSection.BadgeActive = running
	end

	if Caches.StatFarm then
		Caches.StatFarm.Value = running and text or "Idle"
		Caches.StatFarm.Muted = not running
	end

	if Caches.SessionSection then
		Caches.SessionSection.Badge = running and "Running" or "Idle"
		Caches.SessionSection.BadgeActive = running
	end
end

function Utils:IsInDungeon()
	return table.find(Caches["Dungeon PlaceId"], PlaceId) ~= nil
end
function Utils:GetActiveDungeonPortal()
	if Utils:Cooldown("ActiveDungeonPortal", 3) then
		Utils:Thread(function()
			LocalPlayer:RequestStreamAroundAsync(Vector3.new(1420, 2, -926), 3)
		end)
		Utils:Thread(function()
			LocalPlayer:RequestStreamAroundAsync(Vector3.new(90, 6, 839), 3)
		end)
		Utils:Thread(function()
			LocalPlayer:RequestStreamAroundAsync(Vector3.new(1343, 1, -1468), 3)
		end)
	end

	local ActiveDungeonPortal = workspace:FindFirstChild("ActiveDungeonPortal")

	if not ActiveDungeonPortal then
		return
	end

	return ActiveDungeonPortal, ActiveDungeonPortal.JoinPrompt.ObjectText, ActiveDungeonPortal.JoinPrompt
end

function Utils:HandleDungeon()
	if not Utils:IsAlive() then
		Utils:SetFarmStatus("Waiting to respawn")
		Utils:WaitForRespawn()
	end

	if Utils:IsInDungeon() then
		local entity = Utils:FindNearbyMob(200)
		if entity then
			Utils:KillEntity(entity, function()
				return not Utils:IsInDungeon()
			end)
		else
			if
				SaveManager.Data["Auto Replay"]
				and PlayerGui.DungeonUI.ReplayDungeonFrameVisibleOnlyWhenClearingDungeon.Visible
			then
				DungeonWaveReplayVote:FireServer("sponsor")
			end
			pcall(function()
				if PlayerGui.DungeonUI.ContentFrame.Actions.EasyDifficultyFrame.Visible then
					DungeonWaveVote:FireServer(SaveManager.Data["Selected Dungeon Difficulty"])
				end
			end)
			pcall(function()
				if PlayerGui.DungeonUI.ContentFrame.PeopleVoted.ButtonFrame.StartButton.Visible then
					DungeonWaveVote:FireServer("start")
				end
			end)
		end
	else
		local ActiveDungeonPortal, Dungeon, JoinPrompt = Utils:GetActiveDungeonPortal()
		if ActiveDungeonPortal then
			if Dungeon == SaveManager.Data["Selected Dungeon"] then
				Utils:ToTarget(ActiveDungeonPortal.CFrame)
				fireproximityprompt(JoinPrompt)
			end
		else
			RequestDungeonPortal:FireServer(Caches["Dungeon"].Data[SaveManager.Data["Selected Dungeon"]].Flag)
		end
	end
end

function Utils:HandleFarm()
	if Utils:GetQueslineTask() then
		Utils:SetFarmStatus("Yielding for questline")
		return
	end

	if Utils:ShouldYieldForBoss() then
		Utils:SetFarmStatus("Yielding for boss")
		return
	end

	if not Utils:IsAlive() then
		Utils:SetFarmStatus("Waiting to respawn")
		Utils:WaitForRespawn()
	end

	local QuestData, PreviousQuestData = Utils:GetQuestData()

	if not QuestData then
		Utils:SetFarmStatus("No quest available")
		return
	end

	Utils:GetInventory()

	if SaveManager.Data["Auto Buy Gryphon"] and not Utils:GetItem("Sword", "Gryphon") then
		if Utils:GetMoney() >= 650000 and Utils:GetGems() >= 650 then
			Utils:SetFarmStatus("Buying Gryphon")
			Utils:ToTarget(CFrame.new(1433, 9, 275))

			if Utils:GetSelfDistance(Vector3.new(1433, 9, 275)) < 8 then
				local GryphonNPC = ServiceNPCs:FindFirstChild("GryphonBuyerNPC")
				if GryphonNPC and GryphonNPC:FindFirstChild("HumanoidRootPart") then
					fireproximityprompt(GryphonNPC.HumanoidRootPart:FindFirstChildOfClass("ProximityPrompt"))
				end
			end

			return
		end
	end

	if SaveManager.Data["Auto Dark Blade"] and not Utils:GetItem("Sword", "Dark Blade") then
		if Utils:GetMoney() >= 250000 and Utils:GetGems() >= 200 then
			Utils:SetFarmStatus("Buying Dark Blade")
			Utils:ToTarget(CFrame.new(-134, 13, -1094))

			if Utils:GetSelfDistance(Vector3.new(-134, 13, -1094)) < 8 then
				local DarkBladeNPC = Utils:FindNPC("DarkBladeNPC")
				if DarkBladeNPC and DarkBladeNPC.PrimaryPart then
					fireproximityprompt(DarkBladeNPC.PrimaryPart:FindFirstChildOfClass("ProximityPrompt"))
				end
			end

			return
		end
	end

	local IsBossQuest = QuestData.Target:find("Boss") ~= nil
	local Spawnpoint = Utils:GetSpawnPoint()
	local IsQuest, QuestTitle = Utils:IsQuest()
	local NPCQuest = Utils:FindNPC(QuestData.QuestID)

	-- Boss quest: skip it entirely and farm previous quest instead
	if IsBossQuest and PreviousQuestData then
		if IsQuest and QuestTitle ~= PreviousQuestData.title then
			Utils:SetFarmStatus("Abandoning boss quest")
			Utils:AbandonQuest()
			return
		end

		if not IsQuest then
			Utils:SetFarmStatus("Accepting: " .. PreviousQuestData.QuestID)
			Utils:AcceptQuest(PreviousQuestData.QuestID)
			return
		end

		local PreviousEntity = Utils:GetEntities(
			{ PreviousQuestData.Target },
			{ GetMaxHealthEntity = true, LowestHealth = true }
		)

		if not PreviousEntity then
			Utils:SetFarmStatus("Searching: " .. PreviousQuestData.Target)
			local PreviousNPC = Utils:FindNPC(PreviousQuestData.QuestID)

			if Caches.EntityRestPosition[PreviousQuestData.Target] then
				Utils:ToTarget(Caches.EntityRestPosition[PreviousQuestData.Target] * CFrame.new(0, 100, 0))
			elseif PreviousNPC then
				Utils:ToTarget(PreviousNPC:GetModelCFrame() * CFrame.new(0, 100, 0))
			end

			return
		end

		Caches.EntityRestPosition[PreviousQuestData.Target] = Caches.EntityRestPosition[PreviousQuestData.Target]
			or PreviousEntity:GetModelCFrame()

		Utils:SetFarmStatus("Killing: " .. PreviousQuestData.Target)
		Utils:KillEntity(PreviousEntity, function()
			return not SaveManager.Data["Auto Farm Level"]
		end)

		return
	end

	local Entity, _Entities = Utils:GetEntities(
		{ QuestData.Target },
		{ GetMaxHealthEntity = true, LowestHealth = true }
	)

	-- Main quest entity not found, wait near quest area
	if not Entity then
		Utils:SetFarmStatus("Searching: " .. QuestData.Target)
		if Caches.EntityRestPosition[QuestData.Target] then
			Utils:ToTarget(Caches.EntityRestPosition[QuestData.Target] * CFrame.new(0, 100, 0))
		elseif NPCQuest then
			Utils:ToTarget(NPCQuest:GetModelCFrame() * CFrame.new(0, 100, 0))
		end

		return
	end

	-- Main quest entity exists, make sure we have the right quest
	if not IsQuest then
		Utils:SetFarmStatus("Accepting: " .. QuestData.QuestID)
		Utils:AcceptQuest(QuestData.QuestID)
		return
	end

	if QuestData.title ~= QuestTitle then
		Utils:SetFarmStatus("Switching quest")
		Utils:AbandonQuest()
		return
	end

	-- Spawn crystal checkpoint
	if not Spawnpoint or (Spawnpoint.Position - Entity:GetModelCFrame().Position).Magnitude > 500 then
		Utils:SetFarmStatus("Setting checkpoint")
		local SpawnCrystal = Utils:GetClosestCrystal(Entity:GetModelCFrame().Position)

		Utils:ToTarget(SpawnCrystal:GetModelCFrame())

		if Utils:GetSelfDistance(SpawnCrystal:GetModelCFrame().Position) < 10 then
			for _, CheckpointPrompt in next, SpawnCrystal:GetChildren() do
				local ProximityPrompt = CheckpointPrompt:FindFirstChildOfClass("ProximityPrompt")

				if ProximityPrompt then
					fireproximityprompt(ProximityPrompt)
				end
			end
		end

		return
	end

	if not Caches.EntityRestPosition[QuestData.Target] then
		Caches.EntityRestPosition[QuestData.Target] = Entity:GetModelCFrame()
	end

	Utils:SetFarmStatus("Killing: " .. QuestData.Target)
	Utils:KillEntity(Entity)
end

function Utils:SafeHttpGet(url)
	local Passed, Statement = pcall(function()
		return game:HttpGet(url)
	end)

	if Passed then
		return Statement
	else
		warn("[Utils] HttpGet failed for", url, "Error:", Statement)
		return nil
	end
end

do
	local Cascade

	repeat
		local ok, result = pcall(function()
			local cascadeSource = Utils:SafeHttpGet("https://raw.githubusercontent.com/M4liM4li/zircon-ui/main/Library.luau?cb=" .. tick())
			local cascadeFunc = loadstring(cascadeSource)
			return cascadeFunc()
		end)
		if ok and result then
			Cascade = result
		else
			warn("[Cascade] Failed to load, retrying in 3s...", result)
			task.wait(3)
		end
	until Cascade

	local app = Cascade.New({
		WindowPill = true,
		Theme = Cascade.Themes[SaveManager.Data["Theme"]] or Cascade.Themes.Dark,
		ToastOptions = {
			Position = "top-center",
			Duration = 3000,
			Gutter = 8,
		},
	})

	Caches.FLAG_MOBILE = UserInputService.TouchEnabled or UserInputService.GamepadEnabled

	local window = app:Window({
		Title = "Zircon Hub",
		Subtitle = "Sailor Piece",
		Size = Caches.FLAG_MOBILE and UDim2.fromOffset(550, 325) or UDim2.fromOffset(900, 530),
	})

	SaveManager.App = app
	SaveManager.Window = window
	SaveManager.Cascade = Cascade

	window.Searching = SaveManager.Data["Searching"]
	window.Draggable = SaveManager.Data["Draggable"]
	window.Resizable = SaveManager.Data["Resizable"]
	window.Dropshadow = SaveManager.Data["Dropshadow"]
	window.UIBlur = SaveManager.Data["UI Blur"]

	Utils:Connect(SaveManager.Window.Destroying, function()
		if Androssy then
			Androssy:Destroy()
		end
	end)

	-- Features
	local mainSection = window:Section({ Disclosure = false, Title = "Main" })

	-- general Tab

	local generalTab = mainSection:Tab({ Title = "General", Icon = Cascade.Symbols.square3Layers3d, Selected = true })

	-- Session bento: the three things worth knowing after you tab back in an hour later.
	-- Every tile reads a value the script already tracks; nothing here is decorative.
	do
		local sessionSection = generalTab:PageSection({
			Title = "Session",
			Subtitle = "What the hub is doing right now.",
			Icon = Cascade.Symbols.chartBar,
			IconColor = Color3.fromRGB(255, 163, 26),
		})

		local grid = sessionSection:StatGrid({ Minimum = 150 })

		Caches.StatFarm = grid:StatTile({
			Label = "Farm",
			Value = "Idle",
			Icon = Cascade.Symbols.flame,
			Wide = true,
			Muted = true,
		})

		Caches.StatLevel = grid:StatTile({
			Label = "Level",
			Value = tostring(Utils:GetCurrentLevel()),
			Icon = Cascade.Symbols.chartBar,
		})

		Caches.StatUptime = grid:StatTile({
			Label = "Uptime",
			Value = "0:00",
			Icon = Cascade.Symbols.clock,
		})

		Caches.SessionSection = sessionSection

		local startedAt = os.clock()
		local startLevel = Utils:GetCurrentLevel()

		Utils:Connect(LocalData.Level.Changed, function(level)
			Caches.StatLevel.Value = tostring(level)

			local gained = level - startLevel
			Caches.StatLevel.Delta = gained > 0 and ("+" .. gained) or ""
		end)

		Utils:Thread(function()
			while Androssy.Running do
				local elapsed = math.floor(os.clock() - startedAt)
				local hours = math.floor(elapsed / 3600)
				local minutes = math.floor(elapsed % 3600 / 60)

				Caches.StatUptime.Value = hours > 0
						and string.format("%d:%02d:%02d", hours, minutes, elapsed % 60)
					or string.format("%d:%02d", minutes, elapsed % 60)

				task.wait(1)
			end
		end)
	end

	-- Farming Page
	do
		local autoFarmLevelSection = generalTab:PageSection({
			Title = "🔥    Auto Farm Level",
			Subtitle = "Automatically farming levels by accepting quests and defeating mobs.",
			Disclosure = true,
		})

		autoFarmLevelSection:Callout({
			Kind = "info",
			Text = "Auto farm takes the quest from the nearest NPC and clears its mobs on a loop. Turn on Kill Aura to hit everything in range while it runs.",
		})

		do
			local farmInfoForm = autoFarmLevelSection:Form()

			local farmStatusRow = farmInfoForm:Row({ SearchIndex = "Farm Status" })
			farmStatusRow:Left():TitleStack({
				Title = "Status",
				Subtitle = "Current auto-farm activity.",
			})
			local farmStatusLabel = farmStatusRow:Right():Label({ Text = "Idle" })
			Caches.FarmStatusLabel = farmStatusLabel

			Caches.FarmProgress = farmInfoForm:ProgressBar({
				Title = "Farm loop",
				Text = "Idle",
			})

			Caches.FarmSection = autoFarmLevelSection
		end

		do
			SaveManager:AddToggle(autoFarmLevelSection, "Auto Farm Level", {
				Title = "Enabled",
				Description = "Automatically accept quest and farm mobs to level up.",
				SearchIndex = "Auto Farm Level",
			})

			SaveManager:AddToggle(autoFarmLevelSection, "Kill Aura", {
				Title = "Kill Aura",
				Description = "Automatically attack nearby mobs while auto-farming.",
			})

			SaveManager:AddToggle(autoFarmLevelSection, "Auto Dark Blade", {
				Title = "Auto Dark Blade",
				Description = "Automatically buy and equip Dark Blade when affordable.",
				SearchIndex = "Auto Buy Dark Blade",
			})

			SaveManager:AddToggle(autoFarmLevelSection, "Auto Buy Gryphon", {
				Title = "Auto Buy Gryphon",
				Description = "Buy Gryphon sword when affordable (650K Money, 650 Gems).",
			})

			SaveManager:AddToggle(autoFarmLevelSection, "Auto Buso Haki", {
				Title = "Auto Buso Haki",
				Description = "Complete Haki questline and buy Busoshoku Haki.",
			})
		end

		-- # Auto Skills Tabs
		local autoSkillSection = generalTab:PageSection({
			Title = "⚡    Auto Skills",
			Subtitle = "Automatically use skills in combat.",
			Disclosure = true,
		})
		do
			SaveManager:AddToggle(autoSkillSection, "Auto Skills", {
				Title = "Enabled",
				Description = "Automatically use skills while auto-farming.",
				SearchIndex = "Auto Skills",
			})
		end

		for _, skillKey in ipairs({ "Z", "X", "C", "V", "F" }) do
			local skillData = SaveManager.Data["Skill Settings"][skillKey]
			local function saveSkill()
				SaveManager:QueueSave()
			end
			local row = autoSkillSection:Form():Row({ SearchIndex = "Skill " .. skillKey })

			row:Left():TitleStack({
				Title = "Skill " .. skillKey,
				Subtitle = "Configure the " .. skillKey .. " skill.",
			})

			local right = row:Right()

			right:Stepper({
				Value = skillData["Delay"],
				Minimum = 0,
				Maximum = 10,
				Step = 0.25,
				Fielded = true,
				ValueChanged = function(_, v)
					SaveManager.Data["Skill Settings"][skillKey]["Delay"] = v
					saveSkill()
				end,
			})

			right:Toggle({
				Value = skillData["Enabled"],
				ValueChanged = function(_, v)
					SaveManager.Data["Skill Settings"][skillKey]["Enabled"] = v
					saveSkill()
				end,
			})
		end

		-- # Auto Purchases
		local autoPurchaseSection = generalTab:PageSection({
			Title = "🛒    Auto Purchases",
			Subtitle = "Automatically buy items and unlock features.",
			Disclosure = true,
		})
		do
			SaveManager:AddToggle(autoPurchaseSection, "Auto Best Title", {
				Title = "Auto Best Title",
				Description = "Equip your highest unlocked title.",
			})

			SaveManager:AddToggle(autoPurchaseSection, "Auto Observation Haki", {
				Title = "Auto Observation Haki",
				Description = "Buy Observation Haki after Buso (250K Money, 300 Gems).",
			})

			local _, artifactRow = SaveManager:AddToggle(autoPurchaseSection, "Auto Unlock Artifact", {
				Title = "Auto Unlock Artifact",
				Description = "Unlock Artifact system at Lv.2500 (500K Money, 500 Gems).",
			})

			-- The artifact system opens at 2,500. Below that the switch does nothing at all,
			-- so it says how far off you are instead of pretending it works.
			local ARTIFACT_LEVEL = 2500

			local function gateArtifact()
				local level = Utils:GetCurrentLevel()

				artifactRow.Locked = level < ARTIFACT_LEVEL
						and `Needs level {ARTIFACT_LEVEL} · you are {level}`
					or nil
			end

			Utils:Connect(LocalData.Level.Changed, gateArtifact)
			gateArtifact()

			SaveManager:AddToggle(autoPurchaseSection, "Auto Ascend", {
				Title = "Auto Ascend",
				Description = "Automatically ascend when all requirements are met.",
			})
		end

		-- # Configurations
		local confirgurationSection = generalTab:PageSection({
			Title = "🔩    Configurations",
			Subtitle = "Configure auto-farming behavior and settings.",
			Disclosure = true,
		})

		do
			SaveManager:AddDropdown(confirgurationSection, "Selected Weapon", {
				Title = "Selected Weapon",
				Description = "Preferred weapon to use while auto-farming. Will equip if available.",
				Options = { "Melee", "Sword", "Devil Fruit" },
				Maximum = 1,
				Searchable = true,
			})
		end
		-- do
		-- 	local selectAttackMethodRow = confirgurationSection:Form():Row({ SearchIndex = "Selected Attack Method" })

		-- 	selectAttackMethodRow:Left():TitleStack({
		-- 		Title = "Selected Attack Method",
		-- 		Subtitle = "Preferred attack position while auto-farming. Will attempt to move to position if enabled.",
		-- 	})

		-- 	SaveManager:PopUpButton(selectAttackMethodRow:Right(), "Selected Attack Method", {
		-- 		Options = { "Above", "Behind", "Under" },
		-- 		Maximum = 1,
		-- 		Searchable = true,
		-- 	})
		-- end
		do
			SaveManager:AddStepper(confirgurationSection, "Attack Distance", {
				Title = "Attack Distance",
				Description = "Preferred distance from mob while auto-farming. (Default: 30)",
				Minimum = 1,
				Maximum = 100,
				Step = 1,
				Fielded = true,
			})
		end
	end

	-- quest Line Tab
	local questLineTab = mainSection:Tab({ Title = "Questlines", Icon = Cascade.Symbols.scroll })
	-- Quest Line Page
	do
		Caches["QuestLine"] = {}

		local questLineNames = {}
		for provider, data in next, QuestConfig.Questlines do
			if provider == "Haki" then
				continue
			end
			local displayName = provider:gsub("(%l)(%u)", "%1 %2")
			-- warn("Adding quest line:", displayName)
			-- warn("Provider:", data.npcName)
			Caches["QuestLine"][displayName] = {
				QuestlineProvider = provider,
			}
			local toggleKey = `Auto {displayName} Questline`
			if SaveManager.Templates[toggleKey] == nil then
				SaveManager.Templates[toggleKey] = false
			end
			if SaveManager.Data[toggleKey] == nil then
				SaveManager.Data[toggleKey] = false
			end
			table.insert(questLineNames, displayName)
		end
		table.sort(questLineNames)

		local autoFarmQuestLineSection = questLineTab:PageSection({
			Title = "📜    Auto Farm Questlines",
			Subtitle = "Automatically progress through quest lines by accepting quests and finishing them.",
			Disclosure = true,
		})

		for _, questLine in ipairs(questLineNames) do
			SaveManager:AddToggle(autoFarmQuestLineSection, `Auto {questLine} Questline`, {
				Title = `{questLine}`,
				Description = `Automatically progress through the {questLine} quest line.`,
				SearchIndex = `Auto {questLine} Questline`,
			})
		end

		-- setclipboard(Utils:PrintTable(questLineNames, 4))
	end

	-- Auto Farm Entity Tab
	local entityTab = mainSection:Tab({ Title = "Entity", Icon = Cascade.Symbols.bookmark })
	-- Farming Page
	do
		local autoFarmEntitySection = entityTab:PageSection({
			Title = "💀    Auto Farm Entity",
			Subtitle = "Automatically farming selected entities.",
			Disclosure = true,
		})

		do
			SaveManager:AddToggle(autoFarmEntitySection, "Auto Farm Entity", {
				Title = "Enabled",
				Description = "Automatically defeat selected entities.",
				SearchIndex = "Auto Farm Entity",
			})
		end
		do
			SaveManager:AddDropdown(autoFarmEntitySection, "Selected Entities", {
				Title = "Selected Entities",
				Description = "Preferred entities to farm. Will attempt to farm all selected.",
				Options = Utils:GetEntitiesList(),
				Maximum = 5,
				Searchable = true,
			})
		end
	end

	-- Bosses Tab
	local bossesTab = mainSection:Tab({ Title = "Bosses", Icon = Cascade.Symbols.burst })

	-- Summonable boss section
	do
		local bossSection = bossesTab:PageSection({
			Title = "⚔️    Auto Boss",
			Subtitle = "Automatically spawn and defeat bosses.",
			Disclosure = true,
		})

		local bossInfoForm = bossSection:Form()

		local statusRow = bossInfoForm:Row({ SearchIndex = "Boss Status" })
		statusRow:Left():TitleStack({
			Title = "Status",
			Subtitle = "Current boss farming status.",
		})
		local bossStatusLabel = statusRow:Right():Label({ Text = "Idle" })
		Caches.BossStatusLabel = bossStatusLabel

		local costRow = bossInfoForm:Row({ SearchIndex = "Boss Cost" })
		costRow:Left():TitleStack({
			Title = "Cost",
			Subtitle = "",
		})
		local bossCostLabel = costRow:Right():Label({ Text = "..." })
		Caches.BossCostLabel = bossCostLabel

		local balanceRow = bossInfoForm:Row({ SearchIndex = "Boss Balance" })
		balanceRow:Left():TitleStack({
			Title = "Balance",
			Subtitle = "Your current Money / Gems.",
		})
		local bossBalanceLabel = balanceRow:Right():Label({ Text = "..." })
		Caches.BossBalanceLabel = bossBalanceLabel

		do
			local _, enabledRow = SaveManager:AddToggle(bossSection, "Auto Boss", {
				Title = "Enabled",
				Description = "Automatically spawn and kill bosses when affordable.",
				SearchIndex = "Auto Boss",
			})
		end

		do
			SaveManager:AddDropdown(bossSection, "Boss Difficulty", {
				Title = "Difficulty",
				Description = "Difficulty for bosses that support it.",
				SearchIndex = "Boss Difficulty",
				Options = { "Normal", "Medium", "Hard", "Extreme" },
			})
		end

		do
			local _, selectBossRow = SaveManager:AddDropdown(bossSection, "Boss Settings", {
				Title = "Selected Bosses",
				Description = "Bosses to automatically farm. Checked in order.",
				SearchIndex = "Boss Settings",
				Options = Utils:GetBossDisplayNames(),
				Maximum = #Utils:GetBossDisplayNames(),
				Searchable = true,
			})
		end
	end

	-- World boss section
	do
		local worldBossSection = bossesTab:PageSection({
			Title = "🌎    Auto World Boss",
			Subtitle = "Automatically defeat world bosses when they spawn.",
			Disclosure = true,
		})

		local worldBossInfoForm = worldBossSection:Form()

		local wbStatusRow = worldBossInfoForm:Row({ SearchIndex = "World Boss Status" })
		wbStatusRow:Left():TitleStack({
			Title = "Status",
			Subtitle = "Current world boss farming status.",
		})
		local worldBossStatusLabel = wbStatusRow:Right():Label({ Text = "Idle" })
		Caches.WorldBossStatusLabel = worldBossStatusLabel

		local wbSpawnedRow = worldBossInfoForm:Row({ SearchIndex = "World Boss Spawned" })
		wbSpawnedRow:Left():TitleStack({
			Title = "",
			-- Subtitle = "Currently alive world bosses from your selection.",
		})
		local worldBossSpawnedLabel = wbSpawnedRow:Right():Label({ Text = "..." })
		Caches.WorldBossSpawnedLabel = worldBossSpawnedLabel

		do
			local _, enabledRow = SaveManager:AddToggle(worldBossSection, "Auto World Boss", {
				Title = "Enabled",
				Description = "Automatically kill world bosses when they spawn.",
				SearchIndex = "Auto World Boss",
			})
		end

		do
			local _, selectBossRow = SaveManager:AddDropdown(worldBossSection, "World Boss Settings", {
				Title = "Selected World Bosses",
				Description = "World bosses to automatically farm when spawned.",
				SearchIndex = "World Boss Settings",
				Options = Utils:GetWorldBossNames(),
				Maximum = #Utils:GetWorldBossNames(),
				Searchable = true,
			})
		end
	end

	-- Chests Tab
	local chestsTab = mainSection:Tab({ Title = "Chests", Icon = Cascade.Symbols.bagBadgePlus })

	do
		local chestSection = chestsTab:PageSection({
			Title = "📦    Auto Open Chests",
			Subtitle = "Automatically open selected chests from inventory.",
			Disclosure = true,
		})

		do
			SaveManager:AddToggle(chestSection, "Auto Open Chests", {
				Title = "Enabled",
				Description = "Automatically open chests when available.",
				SearchIndex = "Auto Open Chests",
			})
		end

		do
			SaveManager:AddDropdown(chestSection, "Selected Chests", {
				Title = "Selected Chests",
				Description = "Chests to automatically open.",
				Options = { "Common Chest", "Rare Chest", "Epic Chest", "Legendary Chest", "Mythical Chest" },
				Maximum = 5,
				Searchable = true,
			})
		end

		do
			SaveManager:AddStepper(chestSection, "Chest Amount", {
				Title = "Amount Per Use",
				Description = "How many chests to open at once. Clamped to available quantity.",
				SearchIndex = "Chest Amount",
				Minimum = 1,
				Maximum = 10000,
				Step = 100,
				Fielded = true,
			})
		end
	end

	-- Dungeons Tab
	local dungeonTab = mainSection:Tab({ Title = "Dungeons", Icon = Cascade.Symbols.dog })

	do
		local dungeonSection = dungeonTab:PageSection({
			Title = "🐲    Auto Dungeons",
			Subtitle = "Automatically entrance and defeat dungeon.",
			Disclosure = true,
		})
		do
			SaveManager:AddToggle(dungeonSection, "Auto Dungeon", {
				Title = "Enabled",
				Description = "Automatically open dungeon gate and defeat the dungeon.",
				SearchIndex = "Auto Dungeon",
			})
		end

		local dungeonConfigurationSection = dungeonTab:PageSection({
			Title = "🔩    Configurations",
			Subtitle = "Configure auto-dungeon behavior and settings.",
			Disclosure = true,
		})

		do
			SaveManager:AddToggle(dungeonConfigurationSection, "Auto Replay", {
				Title = "Auto Replay",
				Description = "Automatically replay the dungeon after completion.",
			})
		end

		do
			Caches["Dungeon"] = {
				List = {},
				Data = {},
			}
			for Dungeon, Data in next, DungeonConfig.Dungeons do
				Caches["Dungeon"].Data[Data["DisplayName"]] = Data
				Caches["Dungeon"].Data[Data["DisplayName"]]["Flag"] = Dungeon

				table.insert(Caches["Dungeon"].List, Data["DisplayName"])
			end

			SaveManager:AddDropdown(dungeonConfigurationSection, "Selected Dungeon", {
				Title = "Selected Dungeon",
				Description = "Preferred dungeon to farm. Will attempt to farm this dungeon when Auto Dungeon is enabled.",
				Options = Caches["Dungeon"].List,
				Maximum = 1,
				Searchable = true,
			})
		end
		do
			SaveManager:AddDropdown(dungeonConfigurationSection, "Selected Dungeon Difficulty", {
				Title = "Selected Difficulty",
				Description = "Preferred difficulty for selected dungeon. Will attempt to farm this difficulty when Auto Dungeon is enabled.",
				Options = { "Easy", "Medium", "Hard", "Extreme" },
				Maximum = 1,
				Searchable = true,
			})
		end
	end

	-- Race Tab
	local raceTab = mainSection:Tab({ Title = "Race", Icon = Cascade.Symbols.sparkles })

	do
		local raceSection = raceTab:PageSection({
			Title = "🎲    Auto Race Reroll",
			Subtitle = "Automatically reroll race until a target race is obtained.",
			Disclosure = true,
		})

		local raceInfoForm = raceSection:Form()

		local currentRaceRow = raceInfoForm:Row({ SearchIndex = "Current Race" })
		currentRaceRow:Left():TitleStack({
			Title = "Current Race",
			Subtitle = "Your currently equipped race.",
		})
		local currentRaceLabel = currentRaceRow:Right():Label({ Text = "Loading..." })
		Caches.RaceLabel = currentRaceLabel

		local rerollCountRow = raceInfoForm:Row({ SearchIndex = "Race Rerolls" })
		rerollCountRow:Left():TitleStack({
			Title = "Rerolls Left",
			Subtitle = "Race Reroll items remaining.",
		})
		local rerollCountLabel = rerollCountRow:Right():Label({ Text = "..." })
		Caches.RaceRerollCountLabel = rerollCountLabel

		local statusRow = raceInfoForm:Row({ SearchIndex = "Race Roll Status" })
		statusRow:Left():TitleStack({
			Title = "Status",
			Subtitle = "Current auto-reroll status.",
		})
		local raceStatusLabel = statusRow:Right():Label({ Text = "Idle" })
		Caches.RaceStatusLabel = raceStatusLabel

		do
			SaveManager:AddToggle(raceSection, "Auto Race Reroll", {
				Title = "Enabled",
				Description = "Automatically use Race Reroll items.",
				SearchIndex = "Auto Race Reroll",
			})
		end

		do
			SaveManager:AddDropdown(raceSection, "Preferred Races", {
				Title = "Preferred Races",
				Description = "Stops rerolling when one of these races is obtained.",
				Options = Utils:GetRaceList(),
				Maximum = #Utils:GetRaceList(),
				Searchable = true,
			})
		end
	end

	
	
	local statsTab = mainSection:Tab({ Title = "Stats", Icon = Cascade.Symbols.chartBar })

	-- local miscTab = mainSection:Tab({ Title = "Misc", Icon = Cascade.Symbols.ellipsis })

	do -- Stats Tab
		local autoStatsSection = statsTab:PageSection({
			Title = "📊    Auto Stats",
			Subtitle = "Automatically allocate stat points.",
			Disclosure = true,
		})

		local statsInfoForm = autoStatsSection:Form()

		local focusRow = statsInfoForm:Row({ SearchIndex = "Stat Focus" })
		focusRow:Left():TitleStack({
			Title = "Focusing",
			Subtitle = "Which stat is currently being allocated to.",
		})
		local statFocusLabel = focusRow:Right():Label({ Text = "Idle" })
		Caches.StatFocusLabel = statFocusLabel

		local pointsRow = statsInfoForm:Row({ SearchIndex = "Stat Points" })
		pointsRow:Left():TitleStack({
			Title = "Points Left",
			Subtitle = "Unallocated stat points remaining.",
		})
		local statPointsLabel = pointsRow:Right():Label({ Text = "..." })
		Caches.StatPointsLabel = statPointsLabel

		local breakdownRow = statsInfoForm:Row({ SearchIndex = "Stat Breakdown" })
		breakdownRow:Left():TitleStack({
			Title = "Breakdown",
			Subtitle = "Current stat allocation.",
		})
		local statBreakdownLabel = breakdownRow:Right():Label({ Text = "..." })
		Caches.StatBreakdownLabel = statBreakdownLabel

		do
			SaveManager:AddToggle(autoStatsSection, "Auto Stats", {
				Title = "Auto Stats",
				Description = "Automatically spend stat points on selected stats.",
			})
		end

		do
			SaveManager:AddDropdown(autoStatsSection, "Stat Mode", {
				Title = "Stat Mode",
				Description = "Normal: split across selected. Smart: reset & allocate to equipped weapon type.",
				Options = { "Normal", "Smart" },
			})
		end

		do
			SaveManager:AddDropdown(autoStatsSection, "Selected Stats", {
				Title = "Selected Stats",
				Description = "Stats to automatically allocate points to. (Normal mode only)",
				Options = { "Melee", "Defense", "Sword", "Power" },
				Maximum = 4,
				Searchable = true,
			})
		end
	end

	-- Teleport Tab
	local teleportTab = mainSection:Tab({ Title = "Teleport", Icon = Cascade.Symbols.figureWave })
	
	do -- # Teleport Island Section
		local teleportIslandSection = statsTab:PageSection({
			Title = "🏝    Teleport Island",
			Subtitle = "Teleport your character to different islands across the map.",
			Disclosure = true,
		})

		do
			SaveManager:AddButton(teleportIslandSection, {
				Title = "Teleport",
				Description = "Instantly teleport to the selected island.",
				SearchIndex = "Teleport Island",
				Label = "Click 👇",
				State = "Primary",
				Pushed = function()
					Utils:TeleportIsland(SaveManager.Data["Selected Island"])
				end,
			})

			SaveManager:AddDropdown(teleportIslandSection, "Selected Island", {
				Title = "Selected Island",
				Description = "Preferred island to teleport to. Will attempt to teleport to this island when button is pressed.",
				Options = Utils:GetIslandList().List,
				Maximum = 1,
				Searchable = true,
			})
		end
	end

	do -- # Teleport NPC Section
		local teleportNPCSection = statsTab:PageSection({
			Title = "👨‍🌾    Teleport NPC",
			Subtitle = "Teleport your character to various NPCs across the map.",
			Disclosure = true,
		})

		do
			SaveManager:AddButton(teleportNPCSection, {
				Title = "Teleport",
				Description = "Instantly teleport to the selected NPC.",
				SearchIndex = "Teleport NPC",
				Label = "Click 👇",
				State = "Primary",
				Pushed = function()
					Utils:TeleportNPC(SaveManager.Data["Selected NPC"])
				end,
			})

			SaveManager:AddDropdown(teleportNPCSection, "Selected NPC", {
				Title = "Selected NPC",
				Description = "Preferred NPC to teleport to. Will attempt to teleport to this NPC when button is pressed.",
				Options = Utils:GetNPCList().List,
				Maximum = 1,
				Searchable = true,
			})
		end
	end

	-- Settings
    do
        local settingsSection = window:Section({ Disclosure = false, Title = "Settings" })

        do
            SaveManager:BuildAppearanceTab(Cascade, settingsSection)
            SaveManager:BuildConfigTab(Cascade, settingsSection)
        end
    end
	SaveManager:Toast("Script loaded successfully!", "success")
end

Utils:Connect(RunService.Heartbeat, function()
	Utils:Thread(function()
		sethiddenproperty(LocalPlayer, "MaximumSimulationRadius", math.huge)
		sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
	end)
end)

Utils:Connect(RunService.Heartbeat, function()
	if Utils:Cooldown("Dash", 0.05) then
		Utils:Dash()
	end
end)

Utils:Thread(function()
	while Androssy.Running do
		if SaveManager.Data["Kill Aura"] then
			local Passed, Statement = pcall(function()
				Utils:KillAura(false)
			end)

			if not Passed then
				warn("[Kill Aura] Error:", Statement)
			end
		end

		task.wait()
	end
end)
Utils:Thread(function()
	while Androssy.Running do
		local Passed, Statement = pcall(function()
			Utils:GetHakiStatus()
			Utils:HandleAutoPurchases()

			if SaveManager.Data["Auto Farm Level"] then
				Utils:HandleFarm()
			end
		end)

		if not Passed then
			warn("[Auto Farm Level] Error:", Statement)
		end

		task.wait()
	end
end)
Utils:Thread(function()
	while Androssy.Running do
		if SaveManager.Data["Auto Farm Entity"] then
			local Passed, Statement = pcall(function()
				Utils:HandleEntityFarm()
			end)

			if not Passed then
				warn("[Auto Farm Entity] Error:", Statement)
			end
		end

		task.wait()
	end
end)
Utils:Thread(function()
	while Androssy.Running do
		local Passed, Statement = pcall(function()
			Utils:UpdateBossLabels()

			if SaveManager.Data["Auto Boss"] then
				Utils:HandleBossFarm()
			end
		end)

		if not Passed then
			warn("[Auto Boss] Error:", Statement)
		end

		task.wait()
	end
end)
Utils:Thread(function()
	while Androssy.Running do
		local Passed, Statement = pcall(function()
			Utils:UpdateWorldBossLabels()

			if SaveManager.Data["Auto World Boss"] then
				Utils:HandleWorldBossFarm()
			end
		end)

		if not Passed then
			warn("[Auto World Boss] Error:", Statement)
		end

		task.wait()
	end
end)
Utils:Thread(function()
	while Androssy.Running do
		local Passed, Statement = pcall(function()
			Utils:UpdateStatLabels()

			if SaveManager.Data["Auto Stats"] then
				Utils:HandleUpgradeStats()
			end
		end)

		if not Passed then
			warn("[Auto Stats] Error:", Statement)
		end

		task.wait(0.1)
	end
end)
Utils:Thread(function()
	while Androssy.Running do
		if SaveManager.Data["Auto Open Chests"] then
			local Passed, Statement = pcall(function()
				Utils:HandleOpenChests()
			end)

			if not Passed then
				warn("[Auto Open Chests] Error:", Statement)
			end
		end

		task.wait(0.1)
	end
end)
Utils:Thread(function()
	while Androssy.Running do
		local Passed, Statement = pcall(function()
			Utils:UpdateRaceLabels()

			if SaveManager.Data["Auto Race Reroll"] then
				Utils:HandleRaceReroll()
			end
		end)

		if not Passed then
			warn("[Auto Race Reroll] Error:", Statement)
		end

		task.wait(0.3)
	end
end)

function Utils:CanStartQuestline(providerName)
	local questlineData = QuestConfig.Questlines[providerName]
	if not questlineData then
		return false
	end

	local questActive = Utils:IsQuest()
	if questActive then
		return true
	end

	if questlineData.requiresItem then
		local item = Utils:GetItem("Sword", questlineData.requiresItem)
			or Utils:GetItem("Items", questlineData.requiresItem)
		if not item then
			return false
		end
	end

	return true
end

function Utils:GetQueslineTask()
	if SaveManager.Data["Auto Buso Haki"] and not Caches.BusoHakiOwned and not Caches.BusoHakiQuestlineCompleted then
		if Utils:CanStartQuestline("Haki") then
			Caches["QuestLine"]["Haki"] = Caches["QuestLine"]["Haki"] or { QuestlineProvider = "Haki" }
			return "Haki"
		end
	end

	Caches.CompletedQuestlines = Caches.CompletedQuestlines or {}

	for questLine, data in next, Caches["QuestLine"] do
		if SaveManager.Data[`Auto {questLine} Questline`] then
			local providerName = data.QuestlineProvider
			if
				providerName
				and not Caches.CompletedQuestlines[providerName]
				and Utils:CanStartQuestline(providerName)
			then
				return questLine
			end
		end
	end

	return nil
end

Utils:Thread(function()
	while Androssy.Running do
		local Passed, Statement = pcall(function()
			local questLineTask = Utils:GetQueslineTask()
			if questLineTask then
				warn("questLineTask:", questLineTask)
				Utils:HandleQuestline(questLineTask)
			end
		end)

		if not Passed then
			warn("[Auto Questline] Error:", Statement)
		end

		task.wait()
	end
end)
Utils:Thread(function()
	while Androssy.Running do
		local Passed, Statement = pcall(function()
			if SaveManager.Data["Auto Dungeon"] then
				Utils:HandleDungeon()
			end
		end)

		if not Passed then
			warn("[Auto Dungeon] Error:", Statement)
		end

		task.wait()
	end
end)
