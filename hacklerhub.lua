repeat task.wait() until game:IsLoaded()

if getgenv().Hackler then
	getgenv().Hackler:Destroy()
	task.wait(0.5)
end

local Cascade = loadstring(game:HttpGet("https://raw.githubusercontent.com/M4liM4li/zircon-ui/main/Library.luau?cb=" .. tick()))()
local Hackler = {
	Running = true,
	Connections = {},
	Threads = {},
}

local Destroyed = false

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local Collection = {}

function Collection:Thread(Func, ...)
	local Thread = task.spawn(Func, ...)
	table.insert(Hackler.Threads, Thread)
	return Thread
end

function Collection:Connect(Event, Handler)
	local Connection = Event:Connect(Handler)
	table.insert(Hackler.Connections, Connection)
	return Connection
end

function Collection:Cooldown(Name, Time)
	Collection._Cooldowns = Collection._Cooldowns or {}
	local Now = tick()
	if Now < Collection._Cooldowns[Name] then
		return false
	end
	Collection._Cooldowns[Name] = Now + Time
	return true
end

function Collection:GetRoot(Character)
	return Character and Character:FindFirstChild("HumanoidRootPart")
end

function Collection:GetHum(Character)
	return Character and Character:FindFirstChildOfClass("Humanoid")
end

function Collection:Comma(Amount)
	local Text, Count = tostring(Amount), 0
	repeat
		Text, Count = Text:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
	until Count == 0
	return Text
end

function Collection:SelfDistance(Target)
	local Root = Collection:GetRoot(LocalPlayer.Character)
	if not Root then
		return math.huge
	end
	local Position = typeof(Target) == "CFrame" and Target.Position or Target
	return (Root.Position - Position).Magnitude
end

function Collection:TeleportCFrame(Target)
	local Root = Collection:GetRoot(LocalPlayer.Character)
	if not Root then
		return
	end
	Root.CFrame = typeof(Target) == "CFrame" and Target or CFrame.new(Target)
end

function Collection:LookAt(Position)
	local Root = Collection:GetRoot(LocalPlayer.Character)
	if not Root then
		return
	end
	Root.CFrame = CFrame.lookAt(Root.Position, Position)
end

function Collection:PlayerNames()
	local Names = {}
	for i, Player in next, Players:GetPlayers() do
		if Player ~= LocalPlayer then
			table.insert(Names, Player.Name)
		end
	end
	table.sort(Names)
	return Names
end

function Collection:Clock(Seconds)
	Seconds = math.floor(Seconds)
	local Hours = math.floor(Seconds / 3600)
	local Minutes = math.floor(Seconds % 3600 / 60)
	if Hours > 0 then
		return string.format("%d:%02d:%02d", Hours, Minutes, Seconds % 60)
	end
	return string.format("%d:%02d", Minutes, Seconds % 60)
end

Collection:Connect(LocalPlayer.Idled, function()
	local VirtualUser = game:GetService("VirtualUser")
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.new())
end)

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
			Subtitle = Message,
			Kind = Kind or "info",
			Duration = 4,
		})
	end
end

SaveManager:Load()

local app = Cascade.New({})
local window = app:Window({
	Title = "Example",
	Game = "by _h4ckler",
	Size = UDim2.fromOffset(840, 540),
})
window.Searching = false

local main = window:Section({
	Disclosure = false,
	Title = "Main",
})

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

local surfaces = controls:PageSection({
	Title = "Surfaces",
	Subtitle = "Everything that is not a labelled row.",
	Icon = Cascade.Symbols.chartBar,
	IconColor = Color3.fromRGB(255, 163, 26),
})

surfaces:Callout({
	Kind = "info",
	Text = "Callouts carry a caveat that will not fit in a row subtitle. Three tones: info, warn, danger.",
})

surfaces:Callout({
	Kind = "warn",
	Text = "Warn is for a cost you cannot take back.",
})

surfaces:Callout({
	Kind = "danger",
	Text = "Danger is for something already wrong.",
})

local SessionBar = surfaces:ProgressBar({
	Title = "Session",
	Text = "0%",
	Value = 0,
})

local ScanBar = surfaces:ProgressBar({
	Title = "Scanning",
	Indeterminate = true,
})

local LoopStatus = surfaces:StatusLine({ Text = "Idle" })

local LoopBadge = surfaces:Badge({ Text = "off", Active = false })

surfaces:ImageSurface({
	Image = "rbxassetid://94472643677558",
	SurfaceColor = Color3.fromRGB(30, 30, 34),
})

surfaces:PullDownButton({
	Label = "Quick action",
	Options = { "Stop everything", "Start auto farm", "Copy settings" },
	OnSelected = function(i, Index)
		if Index == 1 then
			SaveManager.Data["Auto Farm"] = false
			SaveManager.Data["Auto Haki"] = false
		elseif Index == 2 then
			SaveManager.Data["Auto Farm"] = true
		else
			setclipboard(HttpService:JSONEncode(SaveManager.Data))
		end
		SaveManager:UpdateUI()
	end,
})

local travel = controls:PageSection({
	Title = "Travel",
	Subtitle = "Picked by looking, not by reading a dropdown.",
	Icon = Cascade.Symbols.bookmark,
	IconColor = Color3.fromRGB(255, 163, 26),
})

travel:DestinationGrid({
	Selected = "Spawn",
	Places = {
		{ Name = "Spawn", Detail = "you are here" },
		{ Name = "North", Detail = "300 studs" },
		{ Name = "East", Detail = "450 studs" },
		{ Name = "Vault", Locked = "needs a key" },
	},
	Chosen = function(i, Name)
		SaveManager:Toast("Travelling to " .. Name, "info")
	end,
})

local points = controls:PageSection({
	Title = "Points",
	Subtitle = "One pool, three rows, spent in a batch.",
	Icon = Cascade.Symbols.chartBar,
	IconColor = Color3.fromRGB(255, 163, 26),
})

local Stats = { Melee = 620, Defense = 410, Sword = 280 }
local Budget

local function StatRows()
	return {
		{ Name = "Melee", Value = Stats.Melee },
		{ Name = "Defense", Value = Stats.Defense },
		{ Name = "Sword", Value = Stats.Sword },
	}
end

Budget = points:PointBudget({
	Pool = "points to spend",
	Value = 18,
	Rows = StatRows(),
	Committed = function(i, Batch)
		local Spent = 0
		for Name, Amount in next, Batch do
			Stats[Name] = Stats[Name] + Amount
			Spent = Spent + Amount
		end
		Budget.Value = math.max(Budget.Value - Spent, 0)
		Budget.Rows = StatRows()
		SaveManager:Toast(Spent .. " points applied.", "success")
	end,
})

local screens = controls:PageSection({
	Title = "Screens",
	Subtitle = "Splash, key gate, confirm.",
	Icon = Cascade.Symbols.info,
	IconColor = Color3.fromRGB(255, 163, 26),
})

SaveManager:AddButton(screens, {
	Title = "Splash",
	Description = "Walks its steps, then hands the screen back.",
	Label = "Show",
	State = "Secondary",
	Pushed = function()
		local Splash = Cascade.Splash({
			Title = "Hackler Hub",
			Subtitle = "Example",
			Steps = { "Interface", "Profile", "Remotes", "Ready" },
		})
		Collection:Thread(function()
			for i = 1, 4 do
				task.wait(0.6)
				Splash.Advance()
			end
			Splash.Close()
		end)
	end,
})

SaveManager:AddButton(screens, {
	Title = "Key gate",
	Description = "Anything works except the word wrong.",
	Label = "Show",
	State = "Secondary",
	Pushed = function()
		Cascade.KeyGate({
			Title = "Paste your key",
			Text = "Checked once per session.",
			Placeholder = "HK-0000-0000",
			Verify = function(i, Key)
				if Key == "wrong" then
					return false, "That key expired. Get a new one."
				end
				return true
			end,
			Accepted = function()
				SaveManager:Toast("Unlocked.", "success")
			end,
		})
	end,
})

SaveManager:AddButton(screens, {
	Title = "Confirm",
	Description = "Asks before it does anything.",
	Label = "Unload",
	State = "Destructive",
	Pushed = function()
		window:Confirm({
			Title = "Unload Hackler Hub?",
			Text = "Every loop stops and the window closes. Saved settings stay on disk.",
			Confirm = "Unload",
			Cancel = "Keep it open",
			Destructive = true,
			Accepted = function()
				Hackler:Destroy()
			end,
		})
	end,
})

local layout = controls:PageSection({
	Title = "Layout",
	Subtitle = "Row, TitleStack, HStack, VStack, Symbol.",
	Icon = Cascade.Symbols.square3Layers3d,
	IconColor = Color3.fromRGB(255, 163, 26),
})

local layoutForm = layout:Form()

local pairRow = layoutForm:Row({ SearchIndex = "Two controls" })
pairRow:Left():TitleStack({
	Title = "Two in one row",
	Subtitle = "An HStack holds both.",
})

local pairStack = pairRow:Right():HStack({ Padding = UDim.new(0, 8) })
pairStack:Stepper({ Minimum = 1, Maximum = 10, Value = 3, Fielded = true })
pairStack:Button({
	Label = "Apply",
	State = "Secondary",
	Pushed = function()
		SaveManager:Toast("Applied.", "info")
	end,
})

local stackRow = layoutForm:Row({ SearchIndex = "Stacked" })
local stackLeft = stackRow:Left():HStack({ Padding = UDim.new(0, 8) })
stackLeft:Symbol({ Image = Cascade.Symbols.bolt, Style = "Primary" })
stackLeft:TitleStack({ Title = "Stacked cell", Subtitle = "A VStack on the right." })

local stackRight = stackRow:Right():VStack({ Padding = UDim.new(0, 6) })
stackRight:Toggle({ Value = false })
stackRight:Label({ Text = "second line", TextSize = 12 })

local rawForm = layout:Form()

local rawRow = rawForm:Row({ SearchIndex = "Direct" })
rawRow:Left():TitleStack({ Title = "Called directly", Subtitle = "No flag, nothing saved." })
rawRow:Right():PopUpButton({ Options = { "One", "Two", "Three" }, Value = 1, Maximum = 1 })

local fieldRow = rawForm:Row({ SearchIndex = "Field" })
fieldRow:Left():TitleStack({ Title = "Text field", Subtitle = "TextField on its own." })
fieldRow:Right():TextField({ Placeholder = "Type here..." })

local segmentRow = rawForm:Row({ SearchIndex = "Segment" })
segmentRow:Left():TitleStack({ Title = "Segmented", Subtitle = "RadioButtonGroup on its own." })
segmentRow:Right():RadioButtonGroup({ Options = { "A", "B", "C" }, Value = 1 })

local bindRow = rawForm:Row({ SearchIndex = "Bind" })
bindRow:Left():TitleStack({ Title = "Keybind", Subtitle = "KeybindField on its own." })
bindRow:Right():KeybindField({ Value = Enum.KeyCode.F, Owner = "Direct keybind" })

SaveManager.Cascade = Cascade
SaveManager.App = app
SaveManager.Window = window
SaveManager:UpdateUI()

Collection:Thread(function()
	local Ticks = 0
	while Hackler.Running do
		pcall(function()
			Ticks = Ticks + 1
			tickTile.Value = tostring(Ticks)

			local Elapsed = Ticks * 0.1
			local Live = SaveManager.Data["Auto Farm"] or SaveManager.Data["Auto Haki"]

			LoopStatus.Text = Live and "Running" or "Idle"
			LoopStatus.Active = Live
			LoopBadge.Text = Live and Collection:Clock(Elapsed) or "off"
			LoopBadge.Active = Live
			ScanBar.Indeterminate = Live
			SessionBar.Value = math.min(Elapsed % 60 / 60, 1)
			SessionBar.Text = math.floor(Elapsed % 60 / 60 * 100) .. "%"

			if SaveManager.Data["Auto Farm"] then
				farmTile.Value = "Farming"
				farmTile.Muted = false
				return
			end

			if SaveManager.Data["Auto Haki"] then
				farmTile.Value = "Haki"
				farmTile.Muted = false
				return
			end
			farmTile.Value = "Idle"
			farmTile.Muted = true
		end)
		task.wait(0.1)
	end
end)

Collection:Thread(function()
	local Running = false

	while Hackler.Running do
		local On = SaveManager.Data["Auto Farm"] == true

		if On ~= Running then
			Running = On
			print("[Auto Farm] " .. (On and "started" or "stopped"))
		end

		if On then
			local Passed, Statement = pcall(function()
				-- Teleport to and attack the nearest entity here.
			end)

			if not Passed then
				warn("[Auto Farm] Error:", Statement)
			end
		end

		task.wait(1)
	end
end)

Collection:Thread(function()
	local Running = false

	while Hackler.Running do
		local On = SaveManager.Data["Auto Haki"] == true

		if On ~= Running then
			Running = On
			print("[Auto Haki] " .. (On and "started" or "stopped"))
		end

		if On then
			local Passed, Statement = pcall(function()
				-- Re-buff Buso and Observation here.
			end)

			if not Passed then
				warn("[Auto Haki] Error:", Statement)
			end
		end

		task.wait(1)
	end
end)

Collection:Thread(function()
	local Running = false

	while Hackler.Running do
		local On = SaveManager.Data["Demo Toggle"] == true

		if On ~= Running then
			Running = On
			print("[Demo Toggle] " .. (On and "started" or "stopped"))
		end

		if On then
			local Passed, Statement = pcall(function()
				-- Whatever this switch is meant to do.
			end)

			if not Passed then
				warn("[Demo Toggle] Error:", Statement)
			end
		end

		task.wait(1)
	end
end)

Collection:Connect(window.Destroying, function()
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
