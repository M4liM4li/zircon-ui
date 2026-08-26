--// Hackler Hub — xenonhub-style scaffold on the Cascade UI library.
--// One table owns everything; one loop drives automation; one control list covers the basics.
--// Read top to bottom: each --// block is one xenonhub pattern, done the h4cler way.

repeat task.wait() until game:IsLoaded()

if getgenv().Hackler then
	getgenv().Hackler:Destroy()
	task.wait(0.5)
end

--// 1. Load Cascade. Same shape example.lua uses: pull the bundled library off main.
local Cascade = loadstring(game:HttpGet("https://raw.githubusercontent.com/M4liM4li/zircon-ui/main/Library.luau?cb=" .. tick()))()

--// 2. Singleton. Owns the Running flag, the thread list, and the connection list, so
--//    Destroy can tear everything down in one pass. xenonhub calls this Androssy.
local Hackler = {
	Running = true,
	Connections = {},
	Threads = {},
}

local Destroyed = false

--// 3. Utils — wrappers around task.spawn / :Connect so cleanup is automatic, plus a
--//    tick-based cooldown gate. xenonhub's Utils:Thread / Utils:Connect / Utils:Cooldown.
local Utils = {}

function Utils:Thread(Func, ...)
	local Thread = task.spawn(Func, ...)
	table.insert(Hackler.Threads, Thread)
	return Thread
end

function Utils:Connect(Event, Handler)
	local Connection = Event:Connect(Handler)
	table.insert(Hackler.Connections, Connection)
	return Connection
end

function Utils:Cooldown(Name, Time)
	Utils._Cooldowns = Utils._Cooldowns or {}
	local Now = tick()
	if Now < Utils._Cooldowns[Name] then
		return false
	end
	Utils._Cooldowns[Name] = Now + Time
	return true
end

--// 4. Services + the anti-AFK hook. Idled fires while the player is away; nudging the
--//    VirtualUser every Idled is a Utils:Connect example and keeps the session alive.
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

Utils:Connect(LocalPlayer.Idled, function()
	local VirtualUser = game:GetService("VirtualUser")
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

--// 5. SaveManager — the hub's own flag/value registry and file persistence. Cascade does
--//    not export a SaveManager, so the hub owns one, exactly like xenonhub does.
--//    Templates = defaults, Data = live values, UI = control refs for profile reload.
local SaveManager = {
	Folder = "Hackler",
	SubFolder = "Template",
	Templates = {
		["Auto Farm"] = false,
		["Auto Haki"] = false,
		["Attack Distance"] = 30,

		["Demo Toggle"] = false,
		["Demo Slider"] = 50,
		["Demo Stepper"] = 25,
		["Demo Dropdown"] = "Apple",
		["Demo Multi"] = { "Sword", "Gun" },
		["Demo Radio"] = 1,
		["Demo Input"] = "",
		["Demo Keybind"] = "RightControl",
		["Demo Color"] = "FFA31A",
	},
	Data = {},
	UI = {},
	App = nil,
	Window = nil,
	Cascade = nil,
}

SaveManager.Location = SaveManager.Folder .. "/" .. SaveManager.SubFolder

local function deepClone(Value)
	if type(Value) == "table" then
		local Copy = {}
		for Key, Item in next, Value do
			Copy[Key] = deepClone(Item)
		end
		return Copy
	end
	return Value
end

for Key, Default in next, SaveManager.Templates do
	SaveManager.Data[Key] = deepClone(Default)
end

function SaveManager:Bind(Key, Element)
	if self.Templates[Key] then
		self.UI[Key] = Element
	end
	return Element
end

function SaveManager:GetIndex(Options, Value)
	for Index, Option in next, Options do
		if Option == Value then
			return Index
		end
	end
end

-- Simple controls store the raw value: Toggle (bool), Slider (number), Stepper (number),
-- RadioButtonGroup (index). One factory mirrors Fields.luau's own valued() helper.
local function simple(Builder)
	return function(self, Parent, Key, Props)
		Props = Props or {}
		Props.Value = self.Data[Key]
		local Orig = Props.ValueChanged
		Props.ValueChanged = function(_, Value)
			self.Data[Key] = Value
			self:QueueSave()
			if Orig then
				Orig(_, Value)
			end
		end
		return self:Bind(Key, Parent[Builder](Parent, Props))
	end
end

SaveManager.Toggle = simple("Toggle")
SaveManager.Slider = simple("Slider")
SaveManager.Stepper = simple("Stepper")
SaveManager.RadioButtonGroup = simple("RadioButtonGroup")

-- TextField keeps numbers numeric when the user types one, else stores the string.
function SaveManager:TextField(Parent, Key, Props)
	Props = Props or {}
	Props.Value = tostring(self.Data[Key] or "")
	local Orig = Props.ValueChanged
	Props.ValueChanged = function(_, Value)
		self.Data[Key] = tonumber(Value) or Value
		self:QueueSave()
		if Orig then
			Orig(_, Value)
		end
	end
	return self:Bind(Key, Parent:TextField(Props))
end

-- Keybind stores the key's Name (a string) so the save file survives JSON; seed from it.
function SaveManager:KeybindField(Parent, Key, Props)
	Props = Props or {}
	Props.Value = Enum.KeyCode[self.Data[Key]] or Enum.KeyCode.RightControl
	local Orig = Props.ValueChanged
	Props.ValueChanged = function(_, Value)
		self.Data[Key] = Value.Name
		self:QueueSave()
		if Orig then
			Orig(_, Value)
		end
	end
	return self:Bind(Key, Parent:KeybindField(Props))
end

-- ColorPicker stores hex; seed a Color3 back from it so the swatch opens on the last pick.
function SaveManager:ColorPicker(Parent, Key, Props)
	Props = Props or {}
	local Stored = self.Data[Key]
	local Color = Color3.fromRGB(255, 163, 26)
	if type(Stored) == "string" then
		local Ok, Parsed = pcall(Color3.fromHex, Stored)
		if Ok and Parsed then
			Color = Parsed
		end
	end
	Props.Value = Color
	local Orig = Props.ValueChanged
	Props.ValueChanged = function(_, Value)
		self.Data[Key] = Value:ToHex()
		self:QueueSave()
		if Orig then
			Orig(_, Value)
		end
	end
	return self:Bind(Key, Parent:ColorPicker(Props))
end

-- PopUpButton is single or multi by Maximum. Either way Data stores option names, never
-- indices, so a save survives the option list being reordered.
function SaveManager:PopUpButton(Parent, Key, Props)
	Props = Props or {}
	local Multi = Props.Maximum and Props.Maximum > 1

	if Multi then
		local Stored = self.Data[Key]
		if type(Stored) ~= "table" then
			Stored = {}
		end
		Props.Value = {}
		for i,Name in next, Stored do
			local Index = self:GetIndex(Props.Options, Name)
			if Index then
				table.insert(Props.Value, Index)
			end
		end
	else
		Props.Value = self:GetIndex(Props.Options, self.Data[Key]) or 1
	end

	local Orig = Props.ValueChanged
	Props.ValueChanged = function(Element, Value)
		if Multi then
			local Selected = {}
			Value = typeof(Value) == "number" and { Value } or Value
			for i,Index in next, (Value or {}) do
				table.insert(Selected, Element.Options[Index])
			end
			self.Data[Key] = Selected
		else
			self.Data[Key] = Element.Options[Value]
		end
		self:QueueSave()
		if Orig then
			Orig(Element, Value)
		end
	end
	return self:Bind(Key, Parent:PopUpButton(Props))
end

-- One-call row: one Form per section (cached on the section), Row, Left TitleStack, Right
-- control. Search is off, so the row carries no SearchIndex.
function SaveManager:Field(Section, Key, Config, Make)
	Config = Config or {}

	local Form = Section.__fieldsForm
	if not Form then
		Form = Section:Form()
		Section.__fieldsForm = Form
	end

	local Row = Form:Row({})
	Row:Left():TitleStack({
		Title = Config.Title or Key,
		Subtitle = Config.Description or "",
	})

	if Config.Locked then
		Row.Locked = Config.Locked
	end

	local Props = {}
	for Prop, Value in next, Config do
		Props[Prop] = Value
	end
	Props.Title = nil
	Props.Description = nil
	Props.Locked = nil

	return Make(self, Row:Right(), Key, Props), Row
end

function SaveManager:AddToggle(Section, Key, Config)
	return self:Field(Section, Key, Config, self.Toggle)
end

function SaveManager:AddSlider(Section, Key, Config)
	return self:Field(Section, Key, Config, self.Slider)
end

function SaveManager:AddStepper(Section, Key, Config)
	return self:Field(Section, Key, Config, self.Stepper)
end

function SaveManager:AddDropdown(Section, Key, Config)
	return self:Field(Section, Key, Config, self.PopUpButton)
end

function SaveManager:AddRadio(Section, Key, Config)
	return self:Field(Section, Key, Config, self.RadioButtonGroup)
end

function SaveManager:AddInput(Section, Key, Config)
	return self:Field(Section, Key, Config, self.TextField)
end

function SaveManager:AddKeybind(Section, Key, Config)
	return self:Field(Section, Key, Config, self.KeybindField)
end

function SaveManager:AddColorPicker(Section, Key, Config)
	return self:Field(Section, Key, Config, self.ColorPicker)
end

-- Buttons carry no flag: same row shape, no Bind, fires once per click.
function SaveManager:AddButton(Section, Config)
	return self:Field(Section, Config.Title, Config, function(_, Right, _, Props)
		Props.Label = Props.Label or "Run"
		Props.State = Props.State or "Primary"
		return Right:Button(Props)
	end)
end

function SaveManager:AddLabel(Section, Config)
	return self:Field(Section, Config.Title, Config, function(_, Right, _, Props)
		Props.Text = Props.Text or ""
		return Right:Label(Props)
	end)
end

function SaveManager:QueueSave()
	if self._SaveQueued then
		return
	end
	self._SaveQueued = true
	task.delay(1, function()
		self._SaveQueued = false
		self:Save()
	end)
end

function SaveManager:Save()
	if not isfile then
		return
	end
	pcall(function()
		if not isfolder(SaveManager.Folder) then
			makefolder(SaveManager.Folder)
		end
	end)
	pcall(function()
		if not isfolder(SaveManager.Location) then
			makefolder(SaveManager.Location)
		end
	end)
	local Payload = HttpService:JSONEncode(self.Data)
	pcall(function()
		writefile(SaveManager.Location .. "/" .. LocalPlayer.Name .. ".json", Payload)
	end)
end

function SaveManager:Load()
	if not isfile then
		return
	end
	local Path = SaveManager.Location .. "/" .. LocalPlayer.Name .. ".json"
	if not isfile(Path) then
		return
	end
	local Ok, Raw = pcall(readfile, Path)
	if not Ok or not Raw then
		return
	end
	local Decoded
	local Ok2 = pcall(function()
		Decoded = HttpService:JSONDecode(Raw)
	end)
	if not Ok2 or type(Decoded) ~= "table" then
		return
	end
	for Key, Value in next, Decoded do
		if self.Templates[Key] ~= nil then
			self.Data[Key] = Value
		end
	end
end

function SaveManager:UpdateUI()
	for Key, Element in next, self.UI do
		local Value = self.Data[Key]
		if Value ~= nil and Element.Value ~= Value then
			Element.Value = Value
		end
	end
end

function SaveManager:Toast(Message, Kind)
	if self.App then
		self.App:Notification({
			Title = "Hackler",
			Description = Message,
			Kind = Kind or "info",
			Duration = 4,
		})
	end
end

--// 6. Build the window. Load lands saved values into Data first, so controls open in
--//    their last state. Search is off on the titlebar.
SaveManager:Load()

local app = Cascade.New({})
local window = app:Window({
	Title = "Hackler Hub",
	Game = "Template",
	Size = UDim2.fromOffset(840, 540),
})
window.Searching = false

local main = window:Section({
	Disclosure = false,
	Title = "Main",
})

--// 7. Combat tab — the functional part. Toggles here drive the loop in section 10.
local combat = main:Tab({
	Title = "Combat",
	Icon = Cascade.Symbols.flame,
	Selected = true,
})

local automation = combat:PageSection({
	Title = "Automation",
	Subtitle = "Toggles drive one always-on loop below.",
	Icon = Cascade.Symbols.flame,
	IconColor = Color3.fromRGB(255, 163, 26),
})

local grid = automation:StatGrid({ Minimum = 150 })
local farmTile = grid:StatTile({
	Label = "Farm",
	Value = "Idle",
	Icon = Cascade.Symbols.flame,
	Wide = true,
	Muted = true,
})
local tickTile = grid:StatTile({
	Label = "Ticks",
	Value = "0",
	Icon = Cascade.Symbols.chartBar,
})

SaveManager:AddToggle(automation, "Auto Farm", {
	Title = "Auto Farm",
	Description = "Teleport to and attack the nearest entity.",
})

SaveManager:AddToggle(automation, "Auto Haki", {
	Title = "Auto Haki",
	Description = "Re-buff Buso and Observation when they drop.",
})

SaveManager:AddStepper(automation, "Attack Distance", {
	Title = "Attack Distance",
	Description = "Studs to stop short of the target.",
	Minimum = 5,
	Maximum = 100,
	Step = 1,
	Fielded = true,
})

local actions = combat:PageSection({
	Title = "Actions",
	Subtitle = "One-shot buttons.",
	Icon = Cascade.Symbols.bolt,
	IconColor = Color3.fromRGB(255, 163, 26),
})

SaveManager:AddButton(actions, {
	Title = "Rejoin Server",
	Description = "Reconnect to the same place.",
	Label = "Rejoin",
	State = "Primary",
	Pushed = function()
		TeleportService:Teleport(game.PlaceId, LocalPlayer)
	end,
})

SaveManager:AddButton(actions, {
	Title = "Ping",
	Description = "Fire a toast to prove the button path works.",
	Label = "Ping",
	State = "Secondary",
	Pushed = function()
		SaveManager:Toast("Pong.", "success")
	end,
})

--// 8. Controls tab — one of every basic control the library ships right now.
local controls = main:Tab({
	Title = "Controls",
	Icon = Cascade.Symbols.sliderHorizontal3,
})

local switches = controls:PageSection({
	Title = "Switches",
	Subtitle = "On/off, a range, and a step.",
	Icon = Cascade.Symbols.sliderHorizontal3,
	IconColor = Color3.fromRGB(255, 163, 26),
})

SaveManager:AddToggle(switches, "Demo Toggle", {
	Title = "Toggle",
	Description = "A boolean switch.",
})

SaveManager:AddSlider(switches, "Demo Slider", {
	Title = "Slider",
	Description = "Drag to pick a number in a range.",
	Minimum = 0,
	Maximum = 100,
})

SaveManager:AddStepper(switches, "Demo Stepper", {
	Title = "Stepper",
	Description = "Type a number, or step it up and down.",
	Minimum = 1,
	Maximum = 100,
	Step = 1,
	Fielded = true,
})

local picking = controls:PageSection({
	Title = "Picking",
	Subtitle = "One, several, or one of a row.",
	Icon = Cascade.Symbols.bookmark,
	IconColor = Color3.fromRGB(255, 163, 26),
})

SaveManager:AddDropdown(picking, "Demo Dropdown", {
	Title = "Dropdown",
	Description = "Pick one.",
	Options = { "Apple", "Banana", "Cherry", "Durian" },
})

SaveManager:AddDropdown(picking, "Demo Multi", {
	Title = "Multi select",
	Description = "Pick several, up to the maximum.",
	Options = { "Sword", "Gun", "Fruit", "Melee", "Haki" },
	Maximum = 3,
})

SaveManager:AddRadio(picking, "Demo Radio", {
	Title = "Segmented",
	Description = "A few options that fit on one line.",
	Options = { "Instant", "Tween", "CFrame" },
})

local entry = controls:PageSection({
	Title = "Entry",
	Subtitle = "Text, a key, and a colour.",
	Icon = Cascade.Symbols.info,
	IconColor = Color3.fromRGB(255, 163, 26),
})

SaveManager:AddInput(entry, "Demo Input", {
	Title = "Text field",
	Description = "Type something.",
	Placeholder = "Enter a name...",
})

SaveManager:AddKeybind(entry, "Demo Keybind", {
	Title = "Keybind",
	Description = "Click it, press a key. Escape cancels, Backspace clears.",
})

SaveManager:AddColorPicker(entry, "Demo Color", {
	Title = "Colour picker",
	Description = "Click the swatch, or paste a hex.",
})

local buttons = controls:PageSection({
	Title = "Buttons",
	Subtitle = "Three weights, and a readout.",
	Icon = Cascade.Symbols.bolt,
	IconColor = Color3.fromRGB(255, 163, 26),
})

SaveManager:AddButton(buttons, {
	Title = "Primary",
	Description = "The main action of the page.",
	Label = "Execute",
	State = "Primary",
	Pushed = function()
		SaveManager:Toast("Primary pushed.", "success")
	end,
})

SaveManager:AddButton(buttons, {
	Title = "Secondary",
	Description = "A quieter action beside it.",
	Label = "Cancel",
	State = "Secondary",
	Pushed = function()
		SaveManager:Toast("Secondary pushed.", "info")
	end,
})

SaveManager:AddButton(buttons, {
	Title = "Destructive",
	Description = "An action you cannot take back.",
	Label = "Delete",
	State = "Destructive",
	Pushed = function()
		SaveManager:Toast("Destructive pushed.", "error")
	end,
})

SaveManager:AddLabel(buttons, {
	Title = "Readout",
	Description = "Read-only output on the right.",
	Text = "Idle",
})

--// 9. Wire SaveManager to the app, then push loaded values into the controls.
SaveManager.Cascade = Cascade
SaveManager.App = app
SaveManager.Window = window
SaveManager:UpdateUI()

--// 10. SaveManager thread — one always-on loop, started at load, that reads
--//     SaveManager.Data and acts on the first toggle that is on (priority = order,
--//     one action per tick). This is the h4cler/xenonhub shape, not a per-toggle task.
Utils:Thread(function()
	local Ticks = 0
	while Hackler.Running do
		pcall(function()
			Ticks = Ticks + 1
			tickTile.Value = tostring(Ticks)

			if SaveManager.Data["Auto Farm"] then
				farmTile.Value = "Farming"
				farmTile.Muted = false
				-- // Source the real farm remote from a dump + MCP, then fire it here.
				return
			end
			if SaveManager.Data["Auto Haki"] then
				farmTile.Value = "Haki"
				farmTile.Muted = false
				-- // Read buff attributes here; re-buff if either dropped.
				return
			end
			farmTile.Value = "Idle"
			farmTile.Muted = true
		end)
		task.wait(0.1)
	end
end)

--// 11. Teardown. The window's Destroying event calls this once; the Destroyed flag stops
--//     the recursion that Destroy -> Window:Destroy would otherwise cause.
Utils:Connect(window.Destroying, function()
	Hackler:Destroy()
end)

function Hackler:Destroy()
	if Destroyed then
		return
	end
	Destroyed = true
	Hackler.Running = false

	task.wait(0.5)

	for i,Connection in next, Hackler.Connections do
		pcall(function()
			Connection:Disconnect()
		end)
	end
	for i,Thread in next, Hackler.Threads do
		pcall(function()
			task.cancel(Thread)
		end)
	end
	table.clear(Hackler.Connections)
	table.clear(Hackler.Threads)

	if SaveManager.Window then
		pcall(function()
			SaveManager.Window:Destroy()
		end)
		SaveManager.Window = nil
	end

	getgenv().Hackler = nil
end

do
	getgenv().Hackler = Hackler
end
