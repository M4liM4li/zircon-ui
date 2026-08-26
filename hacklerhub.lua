--// Hackler Hub — a xenonhub-style scaffold on the Cascade UI library.
--// Read top to bottom: each --// block is one xenonhub pattern, done the h4cler way.

repeat task.wait() until game:IsLoaded()

if getgenv().Hackler then
	getgenv().Hackler:Destroy()
	task.wait(0.5)
end

--// 1. Load Cascade. Same shape example.lua uses: pull the bundled library off main.
local Cascade = loadstring(game:HttpGet("https://raw.githubusercontent.com/M4liM4li/zircon-ui/main/Library.luau?cb=" .. tick()))()

--// 2. Singleton. One table owns the Running flag, the thread list, and the connection
--//    list, so Destroy can tear everything down in one pass. xenonhub calls this Androssy.
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

--// 5. SaveManager — the hub's own flag/value registry and file persistence. Cascade
--//    does not export a SaveManager, so the hub owns one, exactly like xenonhub does.
--//    Templates = defaults, Data = live values, UI = control refs for profile reload.
local SaveManager = {
	Folder = "Hackler",
	SubFolder = "Template",
	Templates = {
		["Auto Farm"] = false,
		["Auto Haki"] = false,
		["Attack Distance"] = 30,
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

-- The one control wrapper every other wrapper copies: seed Value from Data, intercept
-- ValueChanged to write Data[Key] and queue a save, then forward to the caller's callback.
function SaveManager:Toggle(Parent, Key, Props)
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
	return self:Bind(Key, Parent:Toggle(Props))
end

function SaveManager:Stepper(Parent, Key, Props)
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
	return self:Bind(Key, Parent:Stepper(Props))
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
	Row:Left():TitleStack({ Title = Config.Title or Key, Subtitle = Config.Description or "" })

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

function SaveManager:AddStepper(Section, Key, Config)
	return self:Field(Section, Key, Config, self.Stepper)
end

-- Buttons carry no flag: same row shape, no Bind, fires once per click.
function SaveManager:AddButton(Section, Config)
	return self:Field(Section, Config.Title, Config, function(_, Right, _, Props)
		Props.Label = Props.Label or "Run"
		Props.State = Props.State or "Primary"
		return Right:Button(Props)
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
		self.App:Notification({ Title = "Hackler", Description = Message, Kind = Kind or "info", Duration = 4 })
	end
end

--// 6. Build the window. Load lands saved values into Data first, so toggles open in
--//    their last state. Search is off on the titlebar.
SaveManager:Load()

local app = Cascade.New({})
local window = app:Window({
	Title = "Hackler Hub",
	Game = "Template",
	Size = UDim2.fromOffset(840, 540),
})
window.Searching = false

local main = window:Section({ Disclosure = false, Title = "Main" })

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
local farmTile = grid:StatTile({ Label = "Farm", Value = "Idle", Icon = Cascade.Symbols.flame, Wide = true, Muted = true })
local tickTile = grid:StatTile({ Label = "Ticks", Value = "0", Icon = Cascade.Symbols.chartBar })

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

SaveManager.Cascade = Cascade
SaveManager.App = app
SaveManager.Window = window
SaveManager:UpdateUI()

--// 7. The loop. One always-on thread, started at load, that checks each toggle inside
--//    and acts on the first one that is on (priority = order, one action per tick).
--//    This is the h4cler/xenonhub shape — NOT a per-toggle task that only spawns on ON.
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

--// 8. Teardown. The window's Destroying event calls this once; the Destroyed flag stops
--//    the recursion that Destroy -> Window:Destroy would otherwise cause.
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

	for i, Connection in next, Hackler.Connections do
		pcall(function()
			Connection:Disconnect()
		end)
	end
	for i, Thread in next, Hackler.Threads do
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
