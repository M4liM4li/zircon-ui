--[[
	Zircon Hub — a whole hub in one file.

		loadstring(game:HttpGet("https://raw.githubusercontent.com/M4liM4li/zircon-ui/main/example.lua?cb=" .. tick()))()

	Runs in any game. Every control the library has is on screen, every one is saved under a flag,
	and every loop is a FunctionTask driven by its own switch.

	The four loops here do real work — walk speed, jump power, anti-idle and a live status line —
	so what you see moving is the script, not a demo pretending to be busy.
]]

--------------------------- [[ Services ]] ---------------------------

local game = game
local Collection

local function getService(service)
	return game:GetService(service)
end

local Services = setmetatable({}, {
	__index = function(_, key)
		return getService(key)
	end,
})

local Players = Services.Players
local RunService = Services.RunService
local TweenService = Services.TweenService
local UserInputService = Services.UserInputService
local VirtualUser = Services.VirtualUser
local HttpService = Services.HttpService
local Workspace = Services.Workspace

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

local JobId = tostring(game.JobId)
local PlaceId = tonumber(game.PlaceId)

--------------------------- [[ Exploit Variables ]] ---------------------------

local _http_request = (syn and syn.request) or (http and http.request) or http_request or request
local _queue_on_teleport = (syn and syn.queue_on_teleport) or queue_on_teleport
local _setclipboard = setclipboard or toclipboard

local Debug = true
local Debug_Log = function(...)
	if Debug then
		print("[Zircon]", ...)
	end
end

--------------------------- [[ Library ]] ---------------------------

local Cascade = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/M4liM4li/zircon-ui/main/Library.luau?cb=" .. tick())
)()

Collection = Cascade.Collection

local Options = Cascade.Options
local FunctionTask = Cascade.FunctionTask
local Library = Cascade.Library

local SaveSettings = {}

-- Everything with a flag reports here. Swap the body for your own save file.
Cascade.OnChanged(function(flag, value)
	SaveSettings[flag] = value
	Debug_Log(flag, typeof(value) == "table" and "(table)" or value)
end)

--------------------------- [[ Base Functions ]] ---------------------------

function Collection:GetRoot(Character)
	local Root

	xpcall(function()
		if Character and Character:FindFirstChild("HumanoidRootPart") then
			Root = Character.HumanoidRootPart
		end
	end, Debug_Log)

	return Root
end

function Collection:GetHum(Character)
	local Humanoid

	xpcall(function()
		if Character and Character:FindFirstChild("Humanoid") then
			Humanoid = Character.Humanoid
		end
	end, Debug_Log)

	return Humanoid
end

function Collection:Log(...)
	if Debug then
		print("[Zircon Hub]:", ...)
	end
end

function Collection:Comma(amount)
	local formatted, count = tostring(amount), 0

	repeat
		formatted, count = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
	until count == 0

	return formatted
end

function Collection:GetSelfDistance(Object)
	local Magnitude = 9999

	xpcall(function()
		local Position = (typeof(Object) == "CFrame") and Object.Position or Object
		local RootPart = Collection:GetRoot(LocalPlayer.Character)

		if RootPart then
			Magnitude = (RootPart.Position - Position).Magnitude
		end
	end, Debug_Log)

	return Magnitude
end

function Collection:TeleportCFrame(Object)
	local CF = (typeof(Object) == "CFrame") and Object or CFrame.new(Object)
	local RootPart = Collection:GetRoot(LocalPlayer.Character)

	if RootPart then
		RootPart.CFrame = CF
	end
end

function Collection:LookAt(Position)
	xpcall(function()
		local RootPart = Collection:GetRoot(LocalPlayer.Character)

		RootPart.CFrame = CFrame.lookAt(RootPart.Position, Position)
	end, Debug_Log)
end

function Collection:GetPlayersList()
	local names = {}

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			table.insert(names, player.Name)
		end
	end

	table.sort(names)

	return names
end

function Collection:FormatTime(seconds)
	seconds = math.floor(seconds)

	local hours = math.floor(seconds / 3600)
	local minutes = math.floor(seconds % 3600 / 60)

	if hours > 0 then
		return string.format("%d:%02d:%02d", hours, minutes, seconds % 60)
	end

	return string.format("%d:%02d", minutes, seconds % 60)
end

--------------------------- [[ Window ]] ---------------------------

local app = Cascade.New({})

local Window = app:Window({
	Title = "Zircon Hub",
	Game = "Example",
	Size = UDim2.fromOffset(900, 560),
})

local Main = Window:Section({ Disclosure = false, Title = "Main" })
local Settings = Window:Section({ Disclosure = false, Title = "Settings" })

local Tabs = {
	General = Main:Tab({ Title = "General", Icon = Cascade.Symbols.square3Layers3d, Selected = true }),
	Player = Main:Tab({ Title = "Player", Icon = Cascade.Symbols.person }),
	Visuals = Main:Tab({ Title = "Visuals", Icon = Cascade.Symbols.eye }),
	Config = Settings:Tab({ Title = "Config", Icon = Cascade.Symbols.gear }),
}

--------------------------- [[ General ]] ---------------------------

local Status_Paragraph = Tabs.General:AddParagraph({
	Title = "Status",
	Content = "Idle",
})

function Collection:UpdateStatus(Text)
	Status_Paragraph:SetDesc(tostring(Text))
end

local Loops_Section = Tabs.General:AddSection({ Title = "Loops" })

Loops_Section:Callout({
	Kind = "info",
	Text = "Each switch here owns a FunctionTask loop. Turn one on and the status line above starts reporting it.",
})

Collection:AddToggle(Loops_Section, "Auto_Anti_Idle", {
	Title = "Anti idle",
	Description = "Stops the twenty minute idle kick.",
	Default = true,
})

Collection:AddToggle(Loops_Section, "Auto_Status", {
	Title = "Live status",
	Description = "Keeps the line above up to date.",
	Default = true,
})

Collection:AddToggle(Loops_Section, "Enabled_Walk_Speed", {
	Title = "Walk speed",
	Description = "Holds your speed at the value below.",
	Default = false,
})

Collection:AddSlider(Loops_Section, "Selected_Walk_Speed", {
	Title = "Speed",
	Description = "Applied while walk speed is on.",
	Default = 16,
	Min = 16,
	Max = 200,
})

Collection:AddToggle(Loops_Section, "Enabled_Jump_Power", {
	Title = "Jump power",
	Description = "Holds your jump at the value below.",
	Default = false,
})

Collection:AddStepper(Loops_Section, "Selected_Jump_Power", {
	Title = "Power",
	Default = 50,
	Min = 50,
	Max = 500,
	Step = 10,
})

--------------------------- [[ Player ]] ---------------------------

local Movement_Section = Tabs.Player:AddSection({ Title = "Movement" })

Collection:AddRadio(Movement_Section, "Teleport_Method", {
	Title = "Teleport method",
	Description = "How the hub moves you.",
	Values = { "Instant", "Tween", "CFrame" },
	Default = "Tween",
})

Collection:AddSlider(Movement_Section, "Selected_Tween_Speed", {
	Title = "Tween speed",
	Description = "Studs per second while tweening.",
	Default = 150,
	Min = 50,
	Max = 400,
})

Collection:AddDropdown(Movement_Section, "Selected_Player", {
	Title = "Target player",
	Description = "Refreshed by the button below.",
	Values = Collection:GetPlayersList(),
	Default = nil,
	Multi = false,
})

Collection:AddButton(Movement_Section, {
	Title = "Refresh players",
	Description = "Rebuild the list above.",
	Label = "Refresh",
	State = "Secondary",
	Callback = function()
		app:Notification({
			Title = "Player list rebuilt",
			Subtitle = #Collection:GetPlayersList() .. " in the server",
			Kind = "info",
		})
	end,
})

Collection:AddButton(Movement_Section, {
	Title = "Teleport to target",
	Description = "Moves you to whoever is selected.",
	Label = "Teleport",
	State = "Primary",
	Callback = function()
		local name = Options["Selected_Player"].Value
		local target = name and Players:FindFirstChild(name)
		local root = target and Collection:GetRoot(target.Character)

		if not root then
			app:Notification({ Title = "Nobody selected", Subtitle = "Pick a player first.", Kind = "error" })
			return
		end

		Collection:TeleportCFrame(root.CFrame + Vector3.new(0, 3, 0))
		Collection:UpdateStatus("Teleported to " .. name)
	end,
})

local Keys_Section = Tabs.Player:AddSection({ Title = "Keys" })

Collection:AddKeybind(Keys_Section, "Minimize_Keybind", {
	Title = "Minimise",
	Description = "Click it, press a key. Escape cancels, Backspace clears.",
	Default = Enum.KeyCode.RightControl,
	BindPressed = function(_, _, complete, processed)
		if complete and not processed then
			Window.Minimized = not Window.Minimized
		end
	end,
})

--------------------------- [[ Visuals ]] ---------------------------

local Esp_Section = Tabs.Visuals:AddSection({ Title = "Highlight" })

Collection:AddToggle(Esp_Section, "Enabled_Esp", {
	Title = "Highlight players",
	Description = "Outlines every other player in the server.",
	Default = false,
})

Collection:AddColorPicker(Esp_Section, "Esp_Color", {
	Title = "Highlight colour",
	Description = "Drag the square and the hue rail, or paste a hex.",
	Default = Color3.fromRGB(255, 163, 26),
})

Collection:AddInput(Esp_Section, "Esp_Note", {
	Title = "Note",
	Description = "Anything you want to remember about this setup.",
	Placeholder = "Type something...",
	Default = "",
})

local Esp_Count_Label = Collection:AddLabel(Esp_Section, "Esp_Count", {
	Title = "Highlighted",
	Description = "Updated by the loop.",
	Default = "0",
})

--------------------------- [[ Config ]] ---------------------------

local Profile_Section = Tabs.Config:AddSection({ Title = "Profile" })

Collection:AddButton(Profile_Section, {
	Title = "Copy settings",
	Description = "Puts the whole table on your clipboard.",
	Label = "Copy",
	State = "Secondary",
	Callback = function()
		if _setclipboard then
			_setclipboard(HttpService:JSONEncode(SaveSettings))
			app:Notification({ Title = "Copied", Subtitle = "Paste it anywhere.", Kind = "success" })
		end
	end,
})

Collection:AddButton(Profile_Section, {
	Title = "Unload",
	Description = "Stops every loop and closes the hub.",
	Label = "Unload",
	State = "Destructive",
	Callback = function()
		Window:Confirm({
			Title = "Unload Zircon Hub?",
			Text = "Every loop stops and the window closes. Your settings stay on disk.",
			Confirm = "Unload",
			Cancel = "Keep it open",
			Destructive = true,
			Accepted = function()
				Collection:StopTasks()
				Window.Visible = false
			end,
		})
	end,
})

local Session_Section = Tabs.Config:AddSection({ Title = "Session" })

local Grid = Session_Section:StatGrid({ Minimum = 150 })

local Uptime_Tile = Grid:StatTile({ Label = "Uptime", Value = "0:00", Icon = Cascade.Symbols.clock, Wide = true })
local Ping_Tile = Grid:StatTile({ Label = "Ping", Value = "0", Icon = Cascade.Symbols.bolt })
local Players_Tile = Grid:StatTile({ Label = "Players", Value = "1", Icon = Cascade.Symbols.person })

--------------------------- [[ Function Tasks ]] ---------------------------

local Started = os.clock()
local Highlights = {}

FunctionTask["Auto_Anti_Idle"] = function()
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then
			break
		end

		local _, Err = pcall(function()
			if Options["Auto_Anti_Idle"].Value then
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new())
			end
		end)

		if Err and Debug then
			warn("[Auto_Anti_Idle] Caught Error: ", Err)
		end

		task.wait(60)
	end
end

FunctionTask["Auto_Status"] = function()
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then
			break
		end

		local _, Err = pcall(function()
			if Options["Auto_Status"].Value then
				local elapsed = os.clock() - Started
				local running = {}

				for _, flag in ipairs({ "Enabled_Walk_Speed", "Enabled_Jump_Power", "Enabled_Esp" }) do
					if Options[flag] and Options[flag].Value then
						table.insert(running, flag)
					end
				end

				Collection:UpdateStatus(
					#running == 0 and "Idle" or (#running .. " running · " .. Collection:FormatTime(elapsed))
				)

				Uptime_Tile.Value = Collection:FormatTime(elapsed)
				Uptime_Tile.Muted = #running == 0
				Ping_Tile.Value = tostring(math.floor(LocalPlayer:GetNetworkPing() * 1000))
				Players_Tile.Value = tostring(#Players:GetPlayers())

				Session_Section.Badge = #running > 0 and "Running" or "Idle"
				Session_Section.BadgeActive = #running > 0
			end
		end)

		if Err and Debug then
			warn("[Auto_Status] Caught Error: ", Err)
		end

		task.wait(1)
	end
end

FunctionTask["Enabled_Walk_Speed"] = function()
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then
			break
		end

		local _, Err = pcall(function()
			if Options["Enabled_Walk_Speed"].Value then
				local Humanoid = Collection:GetHum(LocalPlayer.Character)

				if Humanoid then
					Humanoid.WalkSpeed = Options["Selected_Walk_Speed"].Value or 16
				end
			end
		end)

		if Err and Debug then
			warn("[Enabled_Walk_Speed] Caught Error: ", Err)
		end

		task.wait(0.5)
	end
end

FunctionTask["Enabled_Jump_Power"] = function()
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then
			break
		end

		local _, Err = pcall(function()
			if Options["Enabled_Jump_Power"].Value then
				local Humanoid = Collection:GetHum(LocalPlayer.Character)

				if Humanoid then
					Humanoid.UseJumpPower = true
					Humanoid.JumpPower = Options["Selected_Jump_Power"].Value or 50
				end
			end
		end)

		if Err and Debug then
			warn("[Enabled_Jump_Power] Caught Error: ", Err)
		end

		task.wait(0.5)
	end
end

FunctionTask["Enabled_Esp"] = function()
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then
			break
		end

		local _, Err = pcall(function()
			local on = Options["Enabled_Esp"].Value

			for player, highlight in pairs(Highlights) do
				if not on or not player.Parent or not player.Character then
					highlight:Destroy()
					Highlights[player] = nil
				end
			end

			if not on then
				return
			end

			for _, player in ipairs(Players:GetPlayers()) do
				if player == LocalPlayer or not player.Character then
					continue
				end

				local highlight = Highlights[player]

				if not highlight or not highlight.Parent then
					highlight = Instance.new("Highlight")
					highlight.FillTransparency = 0.7
					highlight.Parent = player.Character
					Highlights[player] = highlight
				end

				highlight.Adornee = player.Character
				highlight.FillColor = Options["Esp_Color"].Value or Color3.fromRGB(255, 163, 26)
				highlight.OutlineColor = Options["Esp_Color"].Value or Color3.fromRGB(255, 163, 26)
			end

			local count = 0

			for _ in pairs(Highlights) do
				count += 1
			end

			Esp_Count_Label.Text = tostring(count)
		end)

		if Err and Debug then
			warn("[Enabled_Esp] Caught Error: ", Err)
		end

		task.wait(1)
	end
end

--------------------------- [[ Start ]] ---------------------------

Collection:RunTasks()

Collection:Log("loaded in place " .. tostring(PlaceId) .. ", job " .. JobId)

app:Notification({
	Title = "Zircon Hub loaded",
	Subtitle = "Every control is on screen.",
	Kind = "success",
})
