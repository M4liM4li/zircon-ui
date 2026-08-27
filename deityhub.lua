
-- _G.Configs = {}

--------------------------- [[ Whitelist ]] ---------------------------

local Debug = false
local Script = "Anime_Apocalypse"

local Players = game:GetService('Players')
local HttpService = game:GetService('HttpService')
local InsertService = game:GetService('InsertService')
local AvatarChatService = game:GetService('AvatarChatService')

local LocalPlayer = Players.LocalPlayer

local xorCrypt = function(data, key)
    local result = {}
    for i = 1, #data do
        local keyChar = key:byte((i - 1) % #key + 1)
        local dataChar = data:byte(i)
        table.insert(result, string.char(bit32.bxor(dataChar, keyChar)))
    end
    return table.concat(result)
end

local xorEncrypt = function(data, secretKey)
    return (
        xorCrypt(data, secretKey):gsub('.', function(c)
            return string.format('%02X', string.byte(c))
        end)
    )
end

repeat wait() until AvatarChatService:GetAttribute("Enabled") == xorEncrypt(Script .. tostring(LocalPlayer.UserId), tostring(LocalPlayer.UserId))

local AddOns = HttpService:JSONDecode(InsertService:GetAttribute("_"))

InsertService:SetAttribute("_", nil)
AvatarChatService:SetAttribute("Enabled", nil)
--------------------------- [[ Prepare Headders ]] ---------------------------

-- if not LPH_OBFUSCATED then
--     LPH_NO_VIRTUALIZE = LPH_NO_VIRTUALIZE or function(...) return ... end
-- end

local _Blank = function() end
local Debug_Log = function(...) if Debug then print(...) end end 

local game = game
local Collection = {}; Collection.__index = Collection
local function getService(service)
	return game:GetService(service); -- create service return stuff
end
local Services = setmetatable({}, {
	__index = function(_, k) 
		return getService(k)
	end
})

---------------------------------------------- [ Exploits Variables ] ----------------------------------------------

_sethiddenproperty = sethiddenproperty or set_hidden_property or set_hidden_prop
_gethiddenproperty = gethiddenproperty or get_hidden_property or get_hidden_prop
_setsimulationradius = setsimulationradius or set_simulation_radius
_clone_function_ = clonefunction or clone_function or function(...) return ... end

_queue_on_teleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
_http_request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
_getcustomasset = (syn and getsynasset) or getcustomasset
local IsWave = getexecutorname and getexecutorname():find("Wave")

--------------------------- [[ Services ]] ---------------------------

local JobId = tostring(game.JobId)
local PlaceId = tonumber(game.PlaceId);
local TweenService = Services.TweenService
local VirtualUser = Services.VirtualUser
local UserInputService = Services.UserInputService
local ReplicatedStorage = Services.ReplicatedStorage
local CoreGui = Services.CoreGui
local TeleportService = Services.TeleportService
local Lighting = Services.Lighting
local HttpService = Services.HttpService
local PathfindingService = Services.PathfindingService
local RunService = Services.RunService
local CollectionService = Services.CollectionService
local Teams = Services.Teams
local GuiService = Services.GuiService
local Players = Services.Players
local CurrentCamera = workspace.CurrentCamera
local WorldToViewportPoint = CurrentCamera.WorldToViewportPoint
local Camera = Workspace:FindFirstChildOfClass("Camera")
local Client = LocalPlayer
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Mobile = false

local LocalPlayer = Players.LocalPlayer;
local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse();

local Signals_List = {'Activated'}
local IsLoaded = false

if UserInputService.TouchEnabled then
    Mobile = true
end

local Version = "1"
local ProjectName = "AnimeApocalypse"
local filename = "Deity_Hub_Next_Generation/SaveSettings/" .. ProjectName.."/" .. tostring(game.Players.LocalPlayer.Name) ..".json"

_G.GrabageCollection = {
    Functions = {},
    Included = { "MB1" },
}
for _, v in next, getgc() do
    if type(v) == "function" and islclosure(v) then
        local ok, env = pcall(getfenv, v)
        if ok and env and rawget(env, "script") then
            local name = debug.getinfo(v).name
            if name and table.find(_G.GrabageCollection.Included, name) then
                _G.GrabageCollection.Functions[name] = v
            end
        end
    end
end

local HUD = PlayerGui:WaitForChild("HUD")
local MainGui = HUD:WaitForChild("Main")
local Assets = ReplicatedStorage:WaitForChild("Assets")
local Modules = Assets:WaitForChild("Modules")
local Remotes = Assets:WaitForChild("Remotes")
local Interact = Remotes:WaitForChild("Interact")
local ItemsData = require(Modules:WaitForChild("ItemsData"))
Collection.Codes = require(Modules:WaitForChild("CodeRewards"))
Collection.Gadgets = {}



for Gadget, _ in next, ItemsData.Gadgets do
	table.insert(Collection.Gadgets, Gadget)
end
table.sort(Collection.Gadgets)

Collection.Skills = {
	"Z",
	"X",
	"C",
	"V",
	"F",
	"G",
	"E"
}
Collection.Map = {
	"Shibuya",
	"Impel Down",
	"Hidden Village",

}

Collection.Raid = {
	"Endless Fortress",
	"Shadow Garden",
	"The Wild West",
	"Shibuya Crossing"
}
Collection.Difficulty = {
	"Normal",
	"Hard",
	"Nightmare",
	"Gravewalker"
}
Collection.Titan_Defense = {
	"Trose"
}
Collection.Wave_Defense = {
	"Hidden Village"
}
Collection.Mode = {
	"Survival",
	"Infinite",
	"Raid",
	"Payload",
	"Wave Defense"
}
Collection.Cards = {
	Map = {},
	Data = {}
}

for Card, Data in next, ItemsData.Cards do
	local CardName = Card:gsub("CD", "Cooldown")
	if Card:find("CD") then
		CardName = Card:gsub("CD", "Cooldown")
	end
	if Card:find("speed") then
		CardName = Card:gsub("speed", "Speed")
	end
	if Card:find("Ult") then
		CardName = Card:gsub("Ult", "Ultimate")
	end
	if Card:find("UltGain") then
		CardName = "UltimateMastery"
	end

	CardName = CardName:gsub("(%l)(%u)", "%1 %2")
	-- warn(Card, CardName)
	table.insert(Collection.Cards.Map, CardName)
	Collection.Cards.Data[CardName] = Card
end
--------------------------- [[ Games Varibles ]] ---------------------------

print("[Deity Hub] " .. ProjectName .. " Loaded")
print("[Deity Hub] White List Loaded")

local Phase_ = 0
function Phase()
	if not Debug then return end
	Phase_ = Phase_ + 1 ; print("Phase:", Phase_)
end

--------------------------- [[ Specific Varibles ]] ---------------------------

local FunctionTask = {}
local Part_Proprerties = {Name = "Deity-Tween",Anchored = true,Transparency = 1,CanCollide = false}
local Billboard_Property = {
	Name = "ESP_Billboard";
	Enabled = true;
	AlwaysOnTop = true;
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
	Active = true;
	LightInfluence = 1.000;
	Size = UDim2.new(0, 150, 0, 25);
	StudsOffset = Vector3.new(0, 0, 0);
}
local TexT_Property = {
	Name = "ESP_Billboard_Text";
	BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	BackgroundTransparency = 1.000;
	Size = UDim2.new(0, 150, 0, 25);
	Font = Enum.Font.FredokaOne;
	RichText = true;
	Font = Enum.Font.Code;
	TextScaled = true;
	TextSize = 14.000;
	TextStrokeTransparency = 0;
	TextStrokeColor3 = Color3.fromRGB(0, 0, 0);
	TextWrapped = true;
}

--------------------------- [[ Save Settings ]] ---------------------------

getgenv().SaveSettings = SaveSettings or {}

function Collection:Load()
	if readfile and writefile and isfile and isfolder then
		if not isfolder("Deity_Hub_Next_Generation") then
			makefolder("Deity_Hub_Next_Generation")
		end
		if not isfolder("Deity_Hub_Next_Generation/SaveSettings") then
			makefolder("Deity_Hub_Next_Generation/SaveSettings")
		end
		if not isfolder("Deity_Hub_Next_Generation/SaveSettings/" .. ProjectName) then
			makefolder("Deity_Hub_Next_Generation/SaveSettings/" .. ProjectName)
		end
		if not isfile(filename) then
			writefile(filename, HttpService:JSONEncode(SaveSettings))
		else
			local fileContent = readfile(filename)
			-- print("File content:", fileContent) -- Debugging print

			local success, Decode = pcall(function()
				return HttpService:JSONDecode(fileContent)
			end)

			if not success then
				warn("Failed to parse JSON. Check the content of the file:", filename)
				return false -- Early exit if JSON is invalid
			end

			for i, v in pairs(Decode) do
				SaveSettings[i] = v
			end
		end
	else
		warn("[Deity Hub] Failed to load script... (Please Contact Admins)")
		return false
	end
end

function Collection:Save()
	if readfile and writefile and isfile then
		if not isfile(filename) then
			Collection:Load()
		else
			local fileContent = readfile(filename)
			-- print("File content before saving:", fileContent) -- Debugging print

			local success, Decode = pcall(function()
				return HttpService:JSONDecode(fileContent)
			end)

			if not success then
				warn("Failed to parse JSON while saving. Check the content of the file:", filename)
				return false -- Early exit if JSON is invalid
			end

			local Array = {}
			for i, v in pairs(SaveSettings) do
				Array[i] = v
			end
			writefile(filename, HttpService:JSONEncode(Array))
		end
	else
		warn("[Deity Hub] Failed to save")
		return false
	end
end

Collection:Load()

-- print(request({Url = 'https://deity.alphes.net/Files/customui.lua', ["Method"] = "GET"}).Body)
--------------------------- [[ Global Variable ]] ---------------------------

local Options = {}
-- local Library, Utility = loadstring(game:HttpGet('https://deity.alphes.net/Files/customui.lua'))()
local Library, Utility = loadstring(game:HttpGet('https://api.deityhub.pro/Files/customui.lua'))()

local MOOD_Notifier = loadstring([[
		local notifier = Instance.new("ScreenGui")
		local bg = Instance.new("Frame")
		local UIListLayout = Instance.new("UIListLayout")
	
		if game.CoreGui:FindFirstChild("notifier") then
			game.CoreGui:FindFirstChild("notifier"):Destroy()
		end
		notifier.Name = "notifier"
		notifier.Parent = game.CoreGui
		notifier.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
		bg.Name = "bg"
		bg.Parent = notifier
		bg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		bg.BackgroundTransparency = 1.000
		bg.Position = UDim2.new(0.288473517, 0, 0.320685446, 0)
		bg.Size = UDim2.new(0.422429919, 0, 0.358629137, 0)
		bg.ZIndex = 99
	
		UIListLayout.Parent = bg
		UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	
		return function(Text,Time)
			local TextLabel = Instance.new("TextLabel")
			local Frame = Instance.new("Frame")
			Frame.Parent = bg
			Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Frame.Position = UDim2.new(0.426253676, 0, 0.479522198, 0)
			Frame.Size = UDim2.new(0.17699115, 0, 0.0, 0)
			Frame.BackgroundTransparency = 1
			TextLabel.Parent = bg
			TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.BackgroundTransparency = 1.000
			TextLabel.Position = UDim2.new(0, 0, 0.450000018, 0)
			TextLabel.Size = UDim2.new(1, 0, 0.0658702999, 0)
			TextLabel.Font = Enum.Font.GothamBold
			TextLabel.Text = Text
			TextLabel.TextTransparency = 1
			TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			TextLabel.TextSize = 19.000
			game:GetService("TweenService"):Create(Frame,TweenInfo.new(0.2, Enum.EasingStyle.Linear),{Size = UDim2.new(0.17699115, 0, 0.0170648471, 0)}):Play()
			game:GetService("TweenService"):Create(TextLabel,TweenInfo.new(0.2, Enum.EasingStyle.Linear),{TextTransparency = 0}):Play()
			spawn(function()
				wait(Time)
				game:GetService("TweenService"):Create(Frame,TweenInfo.new(0.2, Enum.EasingStyle.Linear),{Size = UDim2.new(0.17699115, 0, 0, 0)}):Play()
				game:GetService("TweenService"):Create(TextLabel,TweenInfo.new(0.2, Enum.EasingStyle.Linear),{TextTransparency = 1}):Play()
				wait(0.2)
				Frame:Destroy()
				TextLabel:Destroy()
			end)
			wait()
		end]]
)() ; Phase()

local Window

if Mobile then
	Window = Library:Window({
		Title = "[🧟‍♂️] Deity Hub | Anime Apocalypse",
		SubTitle = os.date("%A")..", "..os.date("%B").." "..os.date("%d") ..", ".. os.date("%Y")..".",
		TabWidth = 160,
		Size = UDim2.fromOffset(480, 420),
		Theme = "Violet",
		MinimizeKey = Enum.KeyCode.LeftControl
	}) ; Phase()
else
	Window = Library:Window({
		Title = "[🧟‍♂️] Deity Hub | Anime Apocalypse",
		SubTitle = os.date("%A")..", "..os.date("%B").." "..os.date("%d") ..", ".. os.date("%Y")..".",
		TabWidth = 160,
		Size = UDim2.fromOffset(580, 520),
		Theme = "Violet",
		MinimizeKey = Enum.KeyCode.LeftControl
	}) ; Phase()
end



Utility:SetTheme("Snow")
Utility:SetBackgroundTransparency(0)

local NEXT_UI
local LeftControlToggle 
local ScreenGui_NEXT = LocalPlayer.PlayerGui:FindFirstChild("NEXT") or CoreGui:FindFirstChild("NEXT")

if ScreenGui_NEXT then
	ScreenGui_NEXT.Name = "NEXT_"..tostring(os.time())
	NEXT_UI = ScreenGui_NEXT
	for i,v in pairs(ScreenGui_NEXT:GetDescendants()) do
		if v:IsA("ImageLabel") and v.Image == "rbxassetid://9886659671" then
			v.Parent.Activated:Connect(function()
				if CoreGui:FindFirstChild("DeityToggle") then 
					CoreGui:FindFirstChild("DeityToggle"):Destroy()
				end 
				print("Disconnect all thread")
				if Connection_New_Card then
					Connection_New_Card:Disconnect()
				end
				if LeftControlToggle then
					LeftControlToggle:Disconnect()
				end
				for i,v in pairs(LocalPlayer.PlayerGui:GetChildren()) do 
					if string.find(v.Name,"NEXT") then 
						v:Destroy()
					end 
				end 
				Library.Unloaded = true
			end)
		end
	end
end

local Tabs = {
	General = Window:AddTab({ Title = "General", Icon = "home" }),
	["Auto Join"] = Window:AddTab({ Title = "Auto Join", Icon = "gamepad" }),
	Gadgets = Window:AddTab({ Title = "Gadgets", Icon = "bomb" }),
	Card = Window:AddTab({ Title = "Card", Icon = "layers" }),
	Players = Window:AddTab({ Title = "Players", Icon = "user" }),
	Miscellaneous = Window:AddTab({ Title = "Miscellaneous", Icon = "component" }),
	Webhook = Window:AddTab({ Title = "Webhook", Icon = "bell" }),
	Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
} Tabs.General:Select()

--------------------------- [[ UI Function ]] ---------------------------

function Collection:AddToggle(Path, Flag, Configuration)
	local Toggles_ = Path:AddToggle(Configuration)
	Options[Flag] = {Value = false}
	Options[Flag].Value = Configuration.Default
	Toggles_:OnChanged(function(Value_)
		Options[Flag].Value = Value_
		if IsLoaded and not Value_ then
			if tostring(Flag) == "Spectate_Player" then
                delay(0.25,function()
                    workspace.Camera.CameraSubject = LocalPlayer.Character
                end)
            end
		end
		SaveSettings[Flag] = Value_
		Collection:Save()
	end)
	return Toggles_
end
function Collection:AddDropdown(Path, Flag, Configuration)
	Configuration.Flags = Flag
	local Dropdown_ = Path:AddDropdown(Configuration)
	Options[Flag] = {Value = nil}
	Options[Flag].Value = Configuration.Default
	Dropdown_:OnChanged(function(Value_)
		if IsLoaded then
			SaveSettings[Flag] = Value_
			Collection:Save()
		end
		Options[Flag].Value = Value_
	end)
	return Dropdown_
end
function Collection:AddInput(Path, Flag, Configuration)
	Configuration.Flags = Flag
	local Input_ = Path:AddInput(Configuration)
	Options[Flag] = {Value = nil}
	Options[Flag].Value = Configuration.Default
	Input_:OnChanged(function(Value_)
		if IsLoaded then
			SaveSettings[Flag] = Value_
			Collection:Save()
		end
		Options[Flag].Value = Value_
	end)
	return Input_
end

function Collection:AddSlider(Path, Flag, Configuration)
	Configuration.Flags = Flag
	local Slider_ = Path:AddSlider(Configuration)
	Options[Flag] = {Value = nil}
	Options[Flag].Value = Configuration.Default
	Slider_:OnChanged(function(Value_)
		if IsLoaded then
			SaveSettings[Flag] = Value_
			Collection:Save()
		end
		Options[Flag].Value = Value_
	end)
	return Slider_
end

---------------------------------------------- [ Game Functions ] ----------------------------------------------

function Collection:GetRoot(Character)
	local Root
	xpcall(function()
		if Character and Character:FindFirstChild("HumanoidRootPart") then
			Root = Character.HumanoidRootPart
		end
	end,Debug_Log)
	return Root
end
function Collection:GetHum(Character)
	local Humanoid
	xpcall(function()
		if Character and Character:FindFirstChild("Humanoid") then
			Humanoid = Character.Humanoid
		end
	end,Debug_Log)
	return Humanoid
end
function Collection:Log(...)
	if Debug then
		print("[Deity Hub]:",...)
	end
end
function Collection:Comma(amount)
	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end
function Collection:GetSelfDistance(Object)
	local _Magnitude = 9999
	xpcall(function()
		local Position = (typeof(Object) == "CFrame") and Object.Position or Object
		local RootPart = Collection:GetRoot(LocalPlayer.Character)
		if RootPart then
			_Magnitude = (RootPart.Position - Position).Magnitude
		end
	end,Debug_Log)
	return _Magnitude
end
function Collection:TeleportCFrame(Object)
    local CF = (typeof(Object) == "CFrame") and Object or CFrame.new(Object)
    local HumanoidRootPart = Collection:GetRoot(LocalPlayer.Character)
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = CF
    end
end
function Collection:Teleport(Object, MaxSpeed)
    local Position = (typeof(Object) == "CFrame") and Object.Position or Object 
    local HumanoidRootPart = Collection:GetRoot(LocalPlayer.Character)
    local Always_Distancing =  Collection:GetSelfDistance(Position)
    local InBetween_Part = Workspace:FindFirstChild("Deity-Tween") or Instance.new("Part",workspace)
    for Proprerty,Value in pairs(Part_Proprerties) do InBetween_Part[Proprerty] = Value end
    local DistanceFromPart = Collection:GetSelfDistance(InBetween_Part.Position)
    local Max_Distance = 20
    local Max_Speed = MaxSpeed or Options["Selected_Tween_Speed"].Value or 150

	if Options["Teleport_Method"].Value == "Instant (Risk)" then
		return Collection:TeleportCFrame(Position) 
	end

    if Always_Distancing <= Max_Distance then
        return Collection:TeleportCFrame(Position)  
    end
    
    if DistanceFromPart >= Max_Distance then
        InBetween_Part.CFrame = HumanoidRootPart.CFrame
    end
    
    TweenService:Create(InBetween_Part, TweenInfo.new(Always_Distancing / Max_Speed, Enum.EasingStyle.Linear), { CFrame = CFrame.new(Position) }):Play()
    Collection:TeleportCFrame(InBetween_Part.CFrame)
end
function Collection:LookAt(_Position)
	xpcall(function()
		local RootPart = Collection:GetRoot(LocalPlayer.Character)
		RootPart.CFrame = CFrame.lookAt(RootPart.Position, _Position)
	end,Debug_Log)
end
function Collection:GetObjectDistance(Position_1,Position_2)
	return (Position_1 - click).Magnitude
end
function Collection:fireclickbutton(button)
    if game:GetService("GuiService").SelectedObject ~= nil then 
		game:GetService("GuiService").SelectedObject = nil
	end 
	if not button then return end 
	xpcall(function()
		local UserInputService = game:GetService("UserInputService")
		local GuiService = game:GetService("GuiService")
		local playerGui = game:GetService("Players").LocalPlayer.PlayerGui

		local VisibleUI = playerGui:FindFirstChild("") or Instance.new("Frame")
		VisibleUI.Name = "_"
		VisibleUI.BackgroundTransparency = 1
		VisibleUI.Parent = playerGui
		playerGui.SelectionImageObject = VisibleUI
		GuiService.SelectedObject = button
		if GuiService.SelectedObject == button then
			VirtualInputManager:SendKeyEvent(true, 'Return', false, game)
			VirtualInputManager:SendKeyEvent(false, 'Return', false, game)
		end
	end, Debug_Log)
end

function Collection:Keyboard(Key,Holding)
	spawn(function()
		xpcall(function()
			if Holding == nil then
				Holding = 0 
			end
			VirtualInputManager:SendKeyEvent(true, Key, false, Collection:GetRoot(LocalPlayer.Character))
			wait(Holding)
			VirtualInputManager:SendKeyEvent(false, Key, false, Collection:GetRoot(LocalPlayer.Character)) 
		end,Debug_Log)
	end)
end

function Collection:fireproximityprompt(Obj, Amount, Skip)
	spawn(function()
		xpcall(function()
			if Obj.ClassName == "ProximityPrompt" then 
				Obj.RequiresLineOfSight = false
				Amount = Amount or 1
				local PromptTime = Obj.HoldDuration
				if Skip then 
					Obj.HoldDuration = 0
				end
				for i = 1, Amount do 
					Obj:InputHoldBegin()
					if not Skip then 
						wait(Obj.HoldDuration)
					end
					Obj:InputHoldEnd()
				end
				Obj.HoldDuration = PromptTime
			else 
				error("userdata<ProximityPrompt> expected")
			end
		end,Debug_Log)
	end)
end
function Collection:New(Object,Property)
	local Object_ = Instance.new(Object)
	for i,v in pairs(Property) do
		Object_[i] = v
	end
	return Object_
end
local function CountTable(t)
	local count, key = 0
	repeat
		key = next(t, key)
		if key ~= nil then
			count = count + 1
		end
	until key == nil
	return count
end
local PrintTable
local function ParseObject(object, spacing, scope, checkedTables)
	local objectType = type(object)
	if objectType == "string" then
		return spacing .. string.format("%q", object)
	elseif objectType == "nil" then
		return spacing .. "nil"
	elseif objectType == "table" then
		if checkedTables[object] then
			return spacing .. tostring(object) .. " [recursive table]"
		else
			checkedTables[object] = true
			return spacing .. PrintTable(object, scope + 1, checkedTables)
		end
	elseif objectType == "userdata" then
		if typeof(object) == "userdata" then
			return spacing .. "userdata"
		else
			return spacing .. tostring(object)
		end
	else -- userdata, function, boolean, thread, number
		return spacing .. tostring(object)
	end
end
function PrintTable(t, scope, checkedTables)
	local mt = getrawmetatable(t)
	local backup = {}
	if mt and mt ~= t then
		for i, v in pairs(mt) do
			rawset(backup, i, v)
			rawset(mt, i, nil)
		end
	end

	checkedTables = checkedTables or {}
	scope = scope or 1
	local result = (checkedTables and "{" or "") .. "\n"
	local spacing = string.rep("\t", scope)
	local function parse(index, value)
		result = result .. ParseObject(index, spacing, scope, checkedTables) .. " -: " .. ParseObject(value, "", scope, checkedTables) .. "\n"
	end

	if CountTable(t) ~= #t then
		table.foreach(t, parse) -- I'm very aware this is a deprecated function
	else
		for index = 1, select("#", unpack(t)) do
			parse(index, t[index])
		end
	end

	if mt and mt ~= t then
		for i, _ in pairs(backup) do
			rawset(mt, i, rawget(backup, i))
		end
	end

	return result .. string.sub(spacing, 1, #spacing - 1) .. (checkedTables and "}" or "")
end

--------------------------- [[ Start up notifier ]] ---------------------------

coroutine.wrap(function()
	MOOD_Notifier("Starting up! Deity Hub",4)
	wait(1)
	MOOD_Notifier("Initializing the UI...",5)
	wait(2)
end)()

--------------------------- [[ UI Toggle ]] ---------------------------

if _G.Deity_Toggle then
	_G.Deity_Toggle:Destroy()
	_G.Deity_Toggle = nil
end

local UserInputService = game:GetService("UserInputService")

if game.CoreGui:FindFirstChild("DeityToggle") then game.CoreGui["DeityToggle"]:Destroy() end

local DeityToggle = Instance.new("ScreenGui")
local ImageButton = Instance.new("ImageButton")
local UICorner = Instance.new("UICorner")
local ImageLabel = Instance.new("ImageLabel")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")

DeityToggle.Name = "DeityToggle"
DeityToggle.Parent = game.CoreGui
DeityToggle.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

ImageButton.Parent = DeityToggle
ImageButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ImageButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
ImageButton.BorderSizePixel = 0
ImageButton.Position = UDim2.new(0.485, 0, 0.046683047, 0)
ImageButton.Size = UDim2.new(0.0362654328, 0, 0.0577395596, 0)
ImageButton.AutoButtonColor = false

UICorner.Parent = ImageButton

ImageLabel.Parent = ImageButton
ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageLabel.BackgroundTransparency = 1.000
ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
ImageLabel.BorderSizePixel = 0
ImageLabel.Position = UDim2.new(0, 0, 0.0500000007, 0)
ImageLabel.Size = UDim2.new(0.957446814, 0, 0.957446814, 0)
ImageLabel.Image = "rbxassetid://109816771524527"

UIAspectRatioConstraint.Parent = ImageLabel
UIAspectRatioConstraint.AspectRatio = 1.010

UIAspectRatioConstraint_2.Parent = ImageButton
UIAspectRatioConstraint_2.AspectRatio = 1.010

local dragging = false
local dragStart
local startPos

ImageButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = ImageButton.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		ImageButton.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
local Debounce = true
ImageButton.Activated:Connect(function()
	if Debounce then
		Debounce = false
		Library:Toggle()
		wait(.5)
		Debounce = true
	end
end)

LeftControlToggle = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if input.KeyCode == Enum.KeyCode.LeftControl and not Library.Unloaded then
		Library:Toggle()
	end
end)

--------------------------- [[ Game Spacial Function ]] ---------------------------

function Collection:getNearbyEntity(Distance)
	local nearest, nearestDistance = nil, math.huge
	local priority, priorityDistance = nil, math.huge
	local Zombies = workspace:FindFirstChild("Zombies")
	if not Zombies then return nil end
	for _, entity in next, Zombies:GetChildren() do
		if entity:IsA("Model") then
			local HumanoidRootPart = entity:FindFirstChild("HumanoidRootPart")
			local Humanoid = entity:FindFirstChildOfClass("Humanoid")
			local Config = entity:FindFirstChild("Config")
			local HealthValue = Config and Config:FindFirstChild("Health")
			local Health = HealthValue and HealthValue.Value
			local Alive = (not Humanoid or Humanoid.Health > 0) and (Health == nil or Health > 0)
			if HumanoidRootPart and Alive then
				local distance = Collection:GetSelfDistance(HumanoidRootPart.Position)
				if entity.Name == "Samurai" and distance <= 100 and distance < priorityDistance then
					priority = entity
					priorityDistance = distance
				end
				if distance < nearestDistance and distance <= Distance then
					nearest = entity
					nearestDistance = distance
				end
			end
		end
	end
	return priority or nearest
end

function Collection:GetMatchOptions(SelectionName)
	local ok, result = pcall(function()
		local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
		local HUD = PlayerGui:WaitForChild("HUD", 10)
		local Holder = HUD:WaitForChild("Tabs"):WaitForChild("MatchPanel"):WaitForChild("Navigations"):WaitForChild("Holder")
		local Selection = Holder:WaitForChild(SelectionName, 10)
		local List = {}
		for _, v in ipairs(Selection:WaitForChild("Holder"):GetChildren()) do
			if v:IsA("GuiButton") then
				table.insert(List, v.Name)
			end
		end
		return List
	end)
	if ok and #result > 0 then return result end
	if SelectionName == "MapSelection" then
		return {"Shibuya","Impel Down","Infinity Castle","Shadow Garden","Hidden Village"}
	elseif SelectionName == "ModeSelection" then
		return {"Survival","Infinite","Raid","Payload","Wave Defense"}
	elseif SelectionName == "DifficultySelection" then
		return {"Normal","Hard","Nightmare","Gravewalker"}
	end
	return {}
end
function Collection:createMatching(Map, Mode, Difficulty, FriendsOnly)
	local args = {
		"CreateMatch",
		workspace:WaitForChild("Platforms"):WaitForChild("Platform"),
		{
			IsTaken = true,
			Difficulty = Difficulty,
			Map = Map,
			Mode = Mode,
			FriendsOnly = FriendsOnly == true,
			MaxPlayers = 1
		}
	}

	Interact:FireServer(unpack(args))

end
function Collection:IsInLobby()
	return game.PlaceId == 140409475718339
end
function Collection:IsMatchEnded()
	return workspace:FindFirstChild("GameFinished") ~= nil
end

function Collection:UseAutoSkill(Skills)
	for Index, Skill in next, Skills do
		Collection:Keyboard(Skill, 0.1)
	end
end
function Collection:Attack()
	local Humanoid = Collection:GetHum(LocalPlayer.Character)
	if not Humanoid or Humanoid.Health <= 0 then return false end
	local ShowcasingAbility = getrenv and getrenv()._G and getrenv()._G.LocalShowcasingAbility
	if not ShowcasingAbility then return false end
	local Success = pcall(function()
		Interact:FireServer("M1", ShowcasingAbility, workspace:GetServerTimeNow())
	end)
	return Success
end

function Collection:GetEquippedSlots()
	local Slots = {}
	xpcall(function()
		local Decoded = HttpService:JSONDecode(LocalPlayer.Data.AbilitySlots.Value)
		for Key, Slot in pairs(Decoded) do
			if type(Slot) == "table" and Slot.Name and Slot.Name ~= "" then
				table.insert(Slots, Key)
			end
		end
		table.sort(Slots)
	end, Debug_Log)
	return Slots
end

function Collection:GetAbilityNames()
	local Names, Seen = {}, {}
	xpcall(function()
		local Decoded = HttpService:JSONDecode(LocalPlayer.Data.AbilitySlots.Value)
		for _, Slot in pairs(Decoded) do
			if type(Slot) == "table" and Slot.Name and Slot.Name ~= "" and not Seen[Slot.Name] then
				Seen[Slot.Name] = true
				table.insert(Names, Slot.Name)
			end
		end
		table.sort(Names)
	end, Debug_Log)
	return Names
end

function Collection:GetSlotByName(Name)
	local Found
	xpcall(function()
		local Decoded = HttpService:JSONDecode(LocalPlayer.Data.AbilitySlots.Value)
		for Key, Slot in pairs(Decoded) do
			if type(Slot) == "table" and Slot.Name == Name then
				Found = Key
				return
			end
		end
	end, Debug_Log)
	return Found
end

function Collection:SwapAbility(SlotKey)
	xpcall(function()
		local Requests = Assets:WaitForChild("Requests")
		local FuncInteract = Requests:WaitForChild("FuncInteract")
		FuncInteract:InvokeServer("EquipAbility", SlotKey)
	end, Debug_Log)
end

function Collection:RotateAbility(SkipSlot)
	local Slots = Collection:GetEquippedSlots()
	if #Slots <= 1 then return end
	Collection.SlotIndex = (Collection.SlotIndex or 0) % #Slots + 1
	if Slots[Collection.SlotIndex] == SkipSlot then
		Collection.SlotIndex = (Collection.SlotIndex % #Slots) + 1
	end
	Collection:SwapAbility(Slots[Collection.SlotIndex])
end
--------------------------- [[ General ]] ---------------------------

local _Paragraph = Tabs.General:AddParagraph({ Title = "[\xF0\x9F\x9F\xA2] Status", Content = "Idle" })
function Collection:UpdateStatus(Text)
	pcall(function()
		_Paragraph:SetDesc("\x20\x20\xE2\x95\xB0\xE2\x94\x88> " .. tostring(Text))
	end)
end
local Combat_Section = Tabs.General:AddSection({
	Title = "[\xE2\x9A\x94\xEF\xB8\x8F] Combat",
})
Collection:AddToggle(Combat_Section, "Auto_Farm_Entity", {
	Title = "Auto Farm Entity",
	Description = "Automatics teleport and attack to closest entity.",
	Default = _G.Configs and _G.Configs["Auto_Farm_Entity"] or SaveSettings["Auto_Farm_Entity"] or false
})
Collection:AddToggle(Combat_Section, "Auto_Collect", {
	Title = "Auto Collect Items",
	Description = "Automatically collect Coin / Health drops from the floor.",
	Default = _G.Configs and _G.Configs["Auto_Collect"] or SaveSettings["Auto_Collect"] or false
})
Collection:AddToggle(Combat_Section, "Auto_Dodge_Boss", {
	Title = "Auto Dodge Boss",
	Description = "Listen for boss AOE/ult effects via LocalEffect remote and teleport you out of range.",
	Default = _G.Configs and _G.Configs["Auto_Dodge_Boss"] or SaveSettings["Auto_Dodge_Boss"] or false
})
Collection:AddToggle(Combat_Section, "Auto_Skip_Wave", {
	Title = "Auto Skip Wave",
	Description = "Automatically vote-skip the wave in Infinite mode when the StartInfinite prompt appears.",
	Default = _G.Configs and _G.Configs["Auto_Skip_Wave"] or SaveSettings["Auto_Skip_Wave"] or false
})
Combat_Section:AddButton({
	Title = "[🏠] Back to Lobby",
	Description = "Click this button to teleport back to lobby.",
	Callback = function()
		Interact:FireServer("BackToLobby")
		-- TeleportService:Teleport(140409475718339, LocalPlayer)
	end
})

local Configuration_Section = Tabs.General:AddSection({
	Title = "[\xE2\x9A\x99] Configuration",
})
Collection:AddDropdown(Configuration_Section, "Selected_Position", {
	Title = 'Selected Position:',
	Values = {"Above","Below","Behind"},
	Default = _G.Configs and _G.Configs["Selected_Position"] or SaveSettings["Selected_Position"] or "Above",
	Multi = false,
	Flags = "Selected_Position",
})
local _AbilityNames = Collection:GetAbilityNames()
local Selected_First_Ability_Dropdown = Collection:AddDropdown(Configuration_Section, "Selected_First_Ability", {
	Title = 'Selected Ability:',
	Description = "Pick the ability you want auto-attack to focus on (sets LocalShowcasingAbility).",
	Values = _AbilityNames,
	Default = _G.Configs and _G.Configs["Selected_First_Ability"] or SaveSettings["Selected_First_Ability"] or _AbilityNames[1] or "",
	Multi = false,
	Flags = "Selected_First_Ability",
})
xpcall(function()
	local AbilitySlots = LocalPlayer:WaitForChild("Data"):WaitForChild("AbilitySlots")
	AbilitySlots:GetPropertyChangedSignal("Value"):Connect(function()
		local Names = Collection:GetAbilityNames()
		Selected_First_Ability_Dropdown:SetValues(Names, Options["Selected_First_Ability"].Value or Names[1])
	end)
end, Debug_Log)
Collection:AddSlider(Configuration_Section, "Selected_Distance", {
	Title = "Distance:",
	Description = "Distance offset from target (height for Above/Below, behind distance for Behind).",
	Default = _G.Configs and _G.Configs["Selected_Distance"] or SaveSettings["Selected_Distance"] or 20,
	Min = 1,
	Max = 50,
	Decimal = 1,
})

local Skills_Section = Tabs.General:AddSection({
	Title = "[\xE2\x9A\x94] Skills",
})
Collection:AddDropdown(Skills_Section, "Selected_Skill", {
	Title = 'Selected Skill:',
	Values = Collection.Skills,
	Default = _G.Configs and _G.Configs["Selected_Skill"] or SaveSettings["Selected_Skill"] or {"X"},
	Multi = true,
	Flags = "Selected_Skill",
})
Collection:AddToggle(Tabs.Card, "Auto_Pick_Card", {
	Title = "Auto Picking Card",
	Description = "Automatically pick the card after you finish the stage. (It will pick the card you set in priority)",
	Default = _G.Configs and _G.Configs["Auto_Pick_Card"] or SaveSettings["Auto_Pick_Card"] or false
})

for i = 1, #Collection.Cards.Map do
	local Flag = "Card_Priority_" .. i
	Collection:AddDropdown(Tabs.Card, Flag, {
		Title = "Priority " .. i,
		Values = Collection.Cards.Map,
		Default = _G.Configs and _G.Configs[Flag] or SaveSettings[Flag] or Collection.Cards.Map[i],
		Multi = false,
		Flags = Flag,
	})
end


----------------------------------- [[ Auto Join ]] -----------------------------------


Collection:AddDropdown(Tabs["Auto Join"], "Selected_Map", {
	Title = 'Selected Map:',
	Values = Collection.Map,
	Default = _G.Configs and _G.Configs["Selected_Map"] or SaveSettings["Selected_Map"] or "Shibuya",
	Multi = false,
	Flags = "Selected_Map",
})
Collection:AddDropdown(Tabs["Auto Join"], "Selected_Mode", {
	Title = 'Selected Mode:',
	Values = Collection.Mode,
	Default = _G.Configs and _G.Configs["Selected_Mode"] or SaveSettings["Selected_Mode"] or "Survival",
	Multi = false,
	Flags = "Selected_Mode",
})
Collection:AddDropdown(Tabs["Auto Join"], "Selected_Difficulty", {
	Title = 'Selected Difficulty:',
	Values = Collection.Difficulty,
	Default = _G.Configs and _G.Configs["Selected_Difficulty"] or SaveSettings["Selected_Difficulty"] or "Normal",
	Multi = false,
	Flags = "Selected_Difficulty",
})

Collection:AddToggle(Tabs["Auto Join"], "Enabled_Matching", {
	Title = "Enabled",
	Description = "If enabled, You will be matched with the player you selected.",
	Default = _G.Configs and _G.Configs["Enabled Matching"] or SaveSettings["Enabled_Matching"] or false
})
Collection:AddToggle(Tabs["Auto Join"], "Auto_Play_Again", {
	Title = "Auto Play Again",
	Description = "Automatically request Play Again after the match ends.",
	Default = _G.Configs and _G.Configs["Auto_Play_Again"] or SaveSettings["Auto_Play_Again"] or false
})
Collection:AddToggle(Tabs["Auto Join"], "Auto_Back_To_Lobby", {
	Title = "Auto Back To Lobby",
	Description = "Automatically return to lobby after the match ends.",
	Default = _G.Configs and _G.Configs["Auto_Back_To_Lobby"] or SaveSettings["Auto_Back_To_Lobby"] or false
})

local Raid_Section = Tabs["Auto Join"]:AddSection({
	Title = "[\xF0\x9F\x92\x80] Join Raid",
})
Collection:AddDropdown(Raid_Section, "Selected_Raid", {
	Title = 'Selected Raid:',
	Values = Collection.Raid,
	Default = _G.Configs and _G.Configs["Selected_Raid"] or SaveSettings["Selected_Raid"] or Collection.Raid[1],
	Multi = false,
	Flags = "Selected_Raid",
})

Collection:AddToggle(Raid_Section, "Auto_Join_Raid", {
	Title = "Auto Join Raid",
	Description = "If enabled, You will be matched into the selected raid.",
	Default = _G.Configs and _G.Configs["Auto_Join_Raid"] or SaveSettings["Auto_Join_Raid"] or false
})
local Titan_Section = Tabs["Auto Join"]:AddSection({
	Title = "[👹] Titan Defense",
})
Collection:AddDropdown(Titan_Section, "Selected_Titan_Defense", {
	Title = 'Selected Titan Defense":',
	Values = Collection.Titan_Defense,
	Default = _G.Configs and _G.Configs["Selected_Titan_Defense"] or SaveSettings["Selected_Titan_Defense"] or Collection.Titan_Defense[1],
	Multi = false,
	Flags = "Selected_Titan_Defense",
})

Collection:AddToggle(Titan_Section, "Auto_Join_Titan_Defense", {
	Title = "Auto Join Titan Defense",
	Description = "If enabled, You will be matched into the selected titan defense.",
	Default = _G.Configs and _G.Configs["Auto_Join_Titan_Defense"] or SaveSettings["Auto_Join_Titan_Defense"] or false
})
local Wave_Defense_Section = Tabs["Auto Join"]:AddSection({
	Title = "[\xF0\x9F\x8C\x8A] Wave Defense",
})
Collection:AddDropdown(Wave_Defense_Section, "Selected_Wave_Defense", {
	Title = 'Selected Wave Defense:',
	Values = Collection.Wave_Defense,
	Default = _G.Configs and _G.Configs["Selected_Wave_Defense"] or SaveSettings["Selected_Wave_Defense"] or Collection.Wave_Defense[1],
	Multi = false,
	Flags = "Selected_Wave_Defense",
})

Collection:AddToggle(Wave_Defense_Section, "Auto_Join_Wave_Defense", {
	Title = "Auto Join Wave Defense",
	Description = "If enabled, You will be matched into the selected wave defense.",
	Default = _G.Configs and _G.Configs["Auto_Join_Wave_Defense"] or SaveSettings["Auto_Join_Wave_Defense"] or false
})



----------------------------------- [[ Gadgets ]] -----------------------------------

local Gadgets_Paragraph = Tabs.Gadgets:AddParagraph({ Title = "[🔥] Gadgets: Medkit", Content = "\x20\x20\xE2\x95\xB0\xE2\x94\x88> Spin Exists: 0" })


Collection:AddToggle(Tabs.Gadgets, "Auto_Spin_Gadgets", {
	Title = "Auto Spin Gadgets",
	Description = "Automatically spin gadgets after you finish the stage.",
	Default = _G.Configs and _G.Configs["Auto_Spin_Gadgets"] or SaveSettings["Auto_Spin_Gadgets"] or false
})
Collection:AddDropdown(Tabs.Gadgets, "Selected_Gadgets_Slot", {
	Title = 'Select Method:',
	Values = { "1", "2", "3", "4", "5" },
	Default = _G.Configs and _G.Configs["Selected_Gadgets_Slot"] or SaveSettings["Selected_Gadgets_Slot"] or "1",
	Multi = false,
	Flags = "Selected_Gadgets_Slot",
})
Collection:AddDropdown(Tabs.Gadgets, "Selected_Gadgets_Method", {
	Title = 'Select Method:',
	Values = { "Coins", "Spins"},
	Default = _G.Configs and _G.Configs["Selected_Gadgets_Method"] or SaveSettings["Selected_Gadgets_Method"] or "Coins",
	Multi = false,
	Flags = "Selected_Gadgets_Method",
})
Collection:AddDropdown(Tabs.Gadgets, "Selected_Gadgets", {
	Title = 'Select Gadgets:',
	Values = Collection.Gadgets,
	Default = _G.Configs and _G.Configs["Selected_Gadgets"] or SaveSettings["Selected_Gadgets"] or {},
	Multi = true,
	Flags = "Selected_Gadgets",
})

----------------------------------- [[ Players ]] -----------------------------------

function Collection:GetPlayersList()
	local PlayersList = {}
	for _, v in pairs(Players:GetChildren()) do
		if v.Name ~= LocalPlayer.Name then 
			table.insert(PlayersList, v.Name)
		end
	end
	return PlayersList
end

local Selected_Player_Dropdown = Collection:AddDropdown(Tabs.Players, "Selected_Player", {
	Title = 'Select Player:',
	Values = Collection:GetPlayersList(),
	Default = _G.Configs and _G.Configs["Selected_Player"] or SaveSettings["Selected_Player"] or "",
	Multi = false,
	Flags = "Selected_Player",
})
Collection:AddToggle(Tabs.Players, "Teleport_To_Player", {
	Title = "Teleport To Player",
	Description = "Teleort yourself to the player you selected.",
	Default = _G.Configs and _G.Configs["Teleport_To_Player"] or SaveSettings["Teleport_To_Player"] or false
})
Collection:AddToggle(Tabs.Players, "Spectate_Player", {
	Title = "Spectate Player",
	Description = "If enabled, you will spectate the player you selected.",
	Default = _G.Configs and _G.Configs["Spectate_Player"] or SaveSettings["Spectate_Player"] or false
})

Players.ChildAdded:Connect(function(v)
	local PlayersList = Collection:GetPlayersList()
	Selected_Player_Dropdown:SetValues(PlayersList, PlayersList[1])
end)
Players.ChildRemoved:Connect(function(v)
	local PlayersList = Collection:GetPlayersList()
	Selected_Player_Dropdown:SetValues(PlayersList, PlayersList[1])
end)

----------------------------------- [[ Character ]] -----------------------------------

local Fly_Section = Tabs.Players:AddSection({
	Title = "[\xF0\x9F\x9B\xAB] Fly",
})
Collection:AddToggle(Fly_Section, "Enabled_Fly", {
	Title = "Enabled",
	Description = 'If enabled, You can fly everywhere you want (Hold "Q" to Up, "E" to Down)',
	Default = _G.Configs and _G.Configs["Enabled Fly"] or SaveSettings["Enabled_Fly"] or false
})
Collection:AddSlider(Fly_Section, "Fly_Speed", {
	Title = "Fly Speed:",
	Description = "Change fly speed here. (Becareful if you set it too high, you will be kicked)",
	Default = _G.Configs and _G.Configs["Fly Speed"] or SaveSettings["Fly_Speed"] or 16,
	Min = 100,
	Max = 400,
	Decimal = 1,
})

local Character_Section = Tabs.Players:AddSection({
	Title = "[\xF0\x9F\x8D\x83] Character",
})
Collection:AddToggle(Character_Section, "Enabled_Walk_Speed", {
	Title = "Enabled Walk Speed",
	Description = "If enabled, Your character will run faster than normal speed.",
	Default = _G.Configs and _G.Configs["Enabled Walk Speed"] or SaveSettings["Enabled_Walk_Speed"] or false
})
Collection:AddSlider(Character_Section, "Speed", {
	Title = "Speed:",
	Description = "Change speed here. (Becareful if you set it too high, you will be kicked)",
	Default = _G.Configs and _G.Configs["Speed"] or SaveSettings["Speed"] or 16,
	Min = 16,
	Max = 200,
	Decimal = 1,
})
Collection:AddToggle(Character_Section, "Enabled_Jump_Power", {
	Title = "Enabled Jump Power",
	Description = "If enabled, Your character will jump higher than normal jump power.",
	Default = _G.Configs and _G.Configs["Enabled Jump Power"] or SaveSettings["Enabled_Jump_Power"] or false
})
Collection:AddSlider(Character_Section, "JumpPower", {
	Title = "Jump Power:",
	Description = "Change jump power here.",
	Default = _G.Configs and _G.Configs["JumpPower"] or SaveSettings["JumpPower"] or 50,
	Min = 50,
	Max = 300,
	Decimal = 1,
})

----------------------------------- [[ Miscellaneous ]] -----------------------------------

local Quest_Section = Tabs.Miscellaneous:AddSection({
	Title = "[📜] Quests",
})

Collection:AddToggle(Quest_Section, "Auto_Claim_All_Quest", {
	Title = "Auto Claim All Quest",
	Description = "If enabled, You will automatically claim all quests reward after you finish the quest.",
	Default = _G.Configs and _G.Configs["Auto_Claim_All_Quest"] or SaveSettings["Auto_Claim_All_Quest"] or false
})

local Rewards_Section = Tabs.Miscellaneous:AddSection({
	Title = "[\xF0\x9F\x8E\x81] Rewards",
})

Collection:AddToggle(Rewards_Section, "Auto_Claim_Battlepass", {
	Title = "Auto Claim Battlepass",
	Description = "Automatically claim all available Battlepass (Zombie Pass) rewards.",
	Default = _G.Configs and _G.Configs["Auto_Claim_Battlepass"] or SaveSettings["Auto_Claim_Battlepass"] or false
})

local CodeAmount = 0 ; for _, _ in pairs(Collection.Codes) do CodeAmount = CodeAmount + 1 end
Rewards_Section:AddButton({
	Title = "Redeem All Codes",
	Description = "Redeems every known code (" .. CodeAmount .. " total). Already-used codes are silently ignored.",
	Callback = function()
		local Requests = Assets:WaitForChild("Requests")
		local FuncInteract = Requests:WaitForChild("FuncInteract")
		for Code, _ in ipairs(Collection.Codes) do
			pcall(function()
				FuncInteract:InvokeServer("UseCode", Code)
			end)
			task.wait(0.5)
		end
		Library:Notify({ Title = "[✅] Redeemed All Codes", Content = "Tried to redeem " .. CodeAmount .. " codes successfully!", Duration = 3 })
	end
})

local Visuals_Section = Tabs.Miscellaneous:AddSection({
	Title = "[\xF0\x9F\x91\x80] Visuals",
})

Collection:AddToggle(Tabs.Miscellaneous, "Protect_Name", {
	Title = "Protect Name",
	Description = "Change your username in the player list and overhead to something that is not your real name.",
	Default = _G.Configs and _G.Configs["Protect_Name"] or SaveSettings["Protect_Name"] or false
})

Collection:AddToggle(Visuals_Section, "ESP_Players", {
	Title = "ESP: Players",
	Description = "If enabled, you will see the players in the game with distance how far they are.",
	Default = _G.Configs and _G.Configs["ESP Players"] or SaveSettings["ESP_Players"] or false
})

----------------------------------- [[ Webhook ]] -----------------------------------

Collection:AddInput(Tabs.Webhook, "Webhook_URL", {
	Title = "Webhook URL (Discord)",
	Default = _G.Configs and _G.Configs["Webhook_URL"] or SaveSettings["Webhook_URL"] or "",
	Placeholder = "<Enter Webhook_Link>",
	Numeric = false,
	Finished = false,
})
Collection:AddToggle(Tabs.Webhook, "Auto_Webhook_End_Match", {
	Title = "Send Match Result on End",
	Description = "Send player stats to the webhook when the match finishes (GameFinished triggers).",
	Default = _G.Configs and _G.Configs["Auto_Webhook_End_Match"] or SaveSettings["Auto_Webhook_End_Match"] or false
})
Tabs.Webhook:AddButton({
	Title = "[\xF0\x9F\x93\xA7] Send Test Message",
	Description = "Send a test embed to verify the webhook URL is working.",
	Callback = function()
		pcall(function()
			local data = {
				["username"] = "Deity Hub - " .. ProjectName .. " | #" .. tostring(math.random(1111, 9999)),
				["avatar_url"] = "https://sv1.img.in.th/7Vw6dr.png",
				["content"] = " ",
				["embeds"] = { {
					["description"] = "```[\xF0\x9F\x8E\x89] Webhook is working!```",
					["color"] = 0xFFFFFF,
					["author"] = {
						["name"] = "TEST WEBHOOK SUCCESSFULLY!",
						["icon_url"] = "https://sv1.img.in.th/7VwM4k.png"
					}
				} }
			}
			_http_request({
				Url = Options["Webhook_URL"].Value,
				Body = HttpService:JSONEncode(data),
				Method = "POST",
				Headers = { ["content-type"] = "application/json" }
			})
		end)
	end
})

--------------------------- [[ Configuration_Section ]] ---------------------------

local ThemeName = {}

for i, v in pairs(Library.Presets) do
	table.insert(ThemeName, i)
end

table.sort(ThemeName)
function Collection:CustomSwitchServers()

	if not isfolder("Deity_Hub_Next_Generation") then
		makefolder("Deity_Hub_Next_Generation")
	end
	if not isfolder("Deity_Hub_Next_Generation/Temp") then
		makefolder("Deity_Hub_Next_Generation/Temp")
	end
	if not isfolder("Deity_Hub_Next_Generation/Temp/" .. ProjectName) then
		makefolder("Deity_Hub_Next_Generation/Temp/" .. ProjectName)
	end

	if not isfile("Deity_Hub_Next_Generation/Temp/" .. ProjectName .. "/ServerTemp.json") then
		writefile("Deity_Hub_Next_Generation/Temp/" .. ProjectName .. "/ServerTemp.json", "[]")
	end
	if isfile("Deity_Hub_Next_Generation/Temp/" .. ProjectName .. "/ServerTemp.json") then
		local Server_Temp = readfile("Deity_Hub_Next_Generation/Temp/" .. ProjectName .. "/ServerTemp.json")
		local De_Server_Temp = HttpService:JSONDecode(Server_Temp)
		if Servers_Browser == nil then
			Servers_Browser = {}
			local Fuck_ = _http_request({
				["Url"] = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100",
				["Method"] = "GET"
			}).Body
			for i,v in pairs(HttpService:JSONDecode(Fuck_).data) do
				Servers_Browser[v.id] = {
					JobId = v.id,
					GetPlayers = v.playing,
					MaxPlayers = v.maxPlayers,
					PlaceId = PlaceId,
				}
			end
			-- Servers_Browser
		end
		if Servers_Browser then
			for JobId, Data in pairs(Servers_Browser) do
				if tostring(Data.PlaceId) == tostring(PlaceId) and not table.find(De_Server_Temp, Data.JobId) and tonumber(Data.GetPlayers) < Players.MaxPlayers/2 then
					table.insert(De_Server_Temp, Data.JobId)
					writefile("Deity_Hub_Next_Generation/Temp/" .. ProjectName .. "/ServerTemp.json", HttpService:JSONEncode(De_Server_Temp))
					-- warn("PlaceId, Data.JobId", PlaceId, Data.JobId)
					TeleportService:TeleportToPlaceInstance(PlaceId, Data.JobId)
					break
				end
			end
		end
	end
end

local Global_Settings = Tabs.Settings:AddSection({
	Title = "[\xF0\x9F\x8C\xBE] Global Settings",
})

Collection:AddDropdown(Global_Settings, "Teleport_Method", {
	Title = 'Teleport Method:',
	Values = { "Float", "Instant (Risk)" },
	Default = _G.Configs and _G.Configs["Teleport Method"] or SaveSettings["Teleport_Method"] or "Float",
	Multi = false,
	Flags = "Teleport_Method",
})
Collection:AddSlider(Global_Settings, "Selected_Tween_Speed", {
	Title = "Select Floating Speed:",
	Description = "Choose you speed do you want while teleporting. (If speed is more than 200, It risk to kick you out of the game.)",
	Default = _G.Configs and _G.Configs["Tween Speed"] or SaveSettings["Selected_Tween_Speed"] or 150,
	Min = 10,
	Max = 250,
	Decimal = 1,
})

local Switch_Server = Tabs.Settings:AddSection({
	Title = "[\xF0\x9F\x8C\x90] Switch Server",
})

Switch_Server:AddButton({
	Title = "Hop Server",
	Description = "If you click this button, You will hop the server.",
	Callback = function()
		-- TeleportService:Teleport(PlaceId, LocalPlayer)
		Collection:CustomSwitchServers()
	end
})
Switch_Server:AddButton({
	Title = "Rejoin Server",
	Description = "If you click this button, You will rejoin the server.",
	Callback = function()
		-- game.TeleportService:Teleport(game.PlaceId, game.JobId)
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
	end
})
local Performance = Tabs.Settings:AddSection({
	Title = "[\xF0\x9F\x92\xBB] Performance",
})

Collection:AddSlider(Performance, "Selected_Fps_Cap", {
	Title = "Select FPS Cap:",
	Description = "Choose fps cap do you want to lock.",
	Default = _G.Configs and _G.Configs["Selected_Fps_Cap"] or SaveSettings["Selected_FPS_Cap"] or 240,
	Min = 1,
	Max = 240,
	Decimal = 1,
})
Collection:AddToggle(Performance, "Lock_FPS", {
	Title = "Lock FPS",
	Description = "If you turn this feature on, It will make your fps lock forever until you turn off.",
	Default = _G.Configs and _G.Configs["Lock_FPS"] or SaveSettings["Lock_FPS"] or false,
})
if SaveSettings["WhiteScreen"] == nil then
	SaveSettings["WhiteScreen"] = false
end

Collection:AddToggle(Performance, "White_Screen", {
	Title = "White Screen",
	Description = "If you turn this feature on, It will make your screen white.",
	Default = _G.Configs and _G.Configs["White_Screen"] or SaveSettings["White_Screen"] or false,
})


--------------------------- [[ Custom_Switch_Server_Section ]] ---------------------------

local Custom_Switch_Server_Section = Tabs.Settings:AddSection({
	Title = "[\xF0\x9F\x94\x84] Custom Switch Server",
})
Custom_Switch_Server_Section:AddInput({
	Title = "Job-ID",
	Default = "",
	Placeholder = "<Enter Job-ID>",
	Numeric = false,
	Finished = false,
	Flags = "Job_ID",
	Callback = _Blank
})
Custom_Switch_Server_Section:AddButton({
	Title = "Switch Server",
	Description = "If you click this button, You will switch the server.",
	Callback = function()
		TeleportService:TeleportToPlaceInstance(game.PlaceId, Library.Flags["Job_ID"])
	end
})
Custom_Switch_Server_Section:AddButton({
	Title = "Copy Server Job-ID",
	Description = "If you click this button, it will copy server Job-ID.",
	Callback = function()
		setclipboard(game.JobId)
	end
})

local Configuration_Section = Tabs.Settings:AddSection({
	Title = "[\xF0\x9F\x8E\xA8] Theme Configuration",
})

Configuration_Section:AddDropdown({
	Title = "Select Theme",
	Values = ThemeName,
	Multi = false,
	Default = "Default",
	Flags = "ThemeFlag",
}) -- game:GetService("Players").LocalPlayer.Stats.RaidDamageTracker

Configuration_Section:AddButton({
	Title = "Update Theme",
	Description = "Very important button",
	Callback = function()
		Utility:SetTheme(Library.Flags["ThemeFlag"])
	end
})

Configuration_Section:AddSlider({
	Title = "Background Transparency",
	Description = "This is a slider",
	Default = 0.85,
	Min = 0,
	Max = 1,
	Decimal = 0.01,
	Flags = "AnimationSpeedFlag",
}):OnChanged(function(Value)
	Utility:SetBackgroundTransparency(Value)
end)

---------------------------------------------- [ #Coroutine : Main_Loop ] ----------------------------------------------
coroutine.wrap(function()
	Collection.AttackCooldown = Collection.AttackCooldown or 0
	Collection.DodgeUntil = Collection.DodgeUntil or 0

	local AnimIds = {
		["rbxassetid://131384248061586"] = true,
		["rbxassetid://81071597273835"] = true,
	}

    task.spawn(function()
        pcall(function()
            local AbilityHotbarGui = MainGui:WaitForChild("AbilityHotbar")
            local UltimateGui = MainGui:WaitForChild("Ultimate")

            RunService.Heartbeat:Connect(function()
                if not UltimateGui:GetAttribute("Setup") then return end

                local UltimateName = UltimateGui:GetAttribute("AbilityName")
                if not UltimateName then
                    UltimateGui:SetAttribute("AbilityName", UltimateGui.AbilityName.Text)
                    UltimateName = UltimateGui.AbilityName.Text
                end

                UltimateGui.AbilityName.Text = UltimateName
            end)
            for _, Ability in next, AbilityHotbarGui:GetChildren() do
                if Ability:IsA("TextButton") then
                    if Ability:FindFirstChild("AbilityName") then
                        RunService.Heartbeat:Connect(function()
                            if not Ability:GetAttribute("Setup") then return end
                
                            local AbilityName = Ability:GetAttribute("AbilityName")
                            if not AbilityName then
                                Ability:SetAttribute("AbilityName", Ability.AbilityName.Text)
                                AbilityName = Ability.AbilityName.Text
                            end
                
                            Ability.AbilityName.Text = AbilityName
                        end)
                    elseif Ability:FindFirstChild("ImageLabel") then
                        RunService.Heartbeat:Connect(function()
                            if not Ability:GetAttribute("Setup") then return end

                            local AbilityName = Ability:GetAttribute("AbilityName")
                            if not AbilityName then
                                Ability:SetAttribute("AbilityName", Ability.ImageLabel.StarImage.AbilityName.Text)
                                AbilityName = Ability.ImageLabel.StarImage.AbilityName.Text
                            end
                
                            Ability.ImageLabel.StarImage.AbilityName.Text = AbilityName
                        end)
                    end
                end
            end

            _G.DeityAblilityHooked = true
        end)
    end)


	while task.wait() do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then break end
		local Succ, Err = pcall(function()
			if Options["Auto_Dodge_Boss"].Value then
				local Zombies = workspace:FindFirstChild("Zombies")
				if Zombies then
					for _, Boss in next, Zombies:GetChildren() do
						local Tracks = {}
						local Hum = Boss:FindFirstChildOfClass("Humanoid")
						local AnimCtrl = Boss:FindFirstChildOfClass("AnimationController")
						if Hum then
							Tracks = Hum:GetPlayingAnimationTracks()
						elseif AnimCtrl then
							local Animator = AnimCtrl:FindFirstChildOfClass("Animator")
							if Animator then
								Tracks = Animator:GetPlayingAnimationTracks()
							end
						end
						local UltMatched
						for _, Track in next, Tracks do
							if Track.Animation and AnimIds[Track.Animation.AnimationId] then
								UltMatched = Track
								break
							end
						end
						if UltMatched then
							local BossHRP = Boss:FindFirstChild("HumanoidRootPart")
							local SelfRoot = Collection:GetRoot(LocalPlayer.Character)
							if BossHRP and SelfRoot then
								local Direction = SelfRoot.Position - BossHRP.Position
								if Direction.Magnitude < 0.1 then
									Direction = Vector3.new(1, 0, 0)
								end
								local Away = BossHRP.Position + Direction.Unit * 300 + Vector3.new(0, 10, 0)
								Collection.DodgeUntil = tick() + 3
								Collection:TeleportCFrame(CFrame.new(Away))
							end
							break
						end
					end
				end
			end

			if tick() < Collection.DodgeUntil then return end

			if Options["Auto_Farm_Entity"].Value then
				local Map = workspace:FindFirstChild("Map")
				if Map then
					for _, Folder in next, Map:GetChildren() do
						for _, Gate in next, Folder:GetChildren() do
							if Gate:GetAttribute("GateType") and not Gate:GetAttribute("Opened") then
								pcall(function() Interact:FireServer("GateHit", Gate) end)
							end
						end
					end
				end
				local Target = Collection:getNearbyEntity(20000)
				local TargetHRP = Target and Target:FindFirstChild("HumanoidRootPart")
				if Target then
					local Config = Target:FindFirstChild("Config")
					local Health = (Config and Config:FindFirstChild("Health") and Config.Health.Value) or 0
					Collection:UpdateStatus(("Farming: %s | HP: %d"):format(Target.Name, Health))
				else
					local Objective = Map and Map:FindFirstChild("Objective")
					local Entries = Objective and Objective:FindFirstChild("Entries")
					local Prompt = Entries and Entries:FindFirstChildWhichIsA("ProximityPrompt", true)
					if Prompt then
						local Attachment = Prompt.Parent
						if Attachment and Attachment:IsA("Attachment") then
							Collection:TeleportCFrame(CFrame.new(Attachment.WorldPosition))
						end
						Collection:fireproximityprompt(Prompt, 1, true)
						Collection:UpdateStatus("Finishing stage")
						return
					end
					Collection:UpdateStatus("Farming: searching...")
				end
				if TargetHRP then
					local Mode = Options["Selected_Position"] and Options["Selected_Position"].Value or "Above"
					local Dist = Options["Selected_Distance"] and Options["Selected_Distance"].Value or 8
					local Position
					if Mode == "Above" then
						Position = CFrame.lookAt(
							TargetHRP.Position + Vector3.new(0, Dist, 3),
							TargetHRP.Position
						)
					elseif Mode == "Below" then
						Position = CFrame.lookAt(
							TargetHRP.Position - Vector3.new(0, Dist, 3),
							TargetHRP.Position
						)
					else
						Position = CFrame.lookAt(
							TargetHRP.Position + (TargetHRP.CFrame.LookVector * -Dist),
							TargetHRP.Position
						)
					end
					Collection:TeleportCFrame(Position)
				end

				if Target and tick() >= Collection.AttackCooldown then
					-- Point LocalShowcasingAbility at the user-picked ability so
					-- M1 attacks fire that one. No slot swap, no GUI hook — just
					-- tell the game which ability is "selected" for the M1 call.
					local FirstName = Options["Selected_First_Ability"] and Options["Selected_First_Ability"].Value
					if FirstName and FirstName ~= "" then
						local FirstSlot = Collection:GetSlotByName(FirstName)
						if FirstSlot then
							pcall(function()
								local Env = getrenv and getrenv() or _G
								Env._G.LocalShowcasingSlot = FirstSlot
								Env._G.LocalShowcasingAbility = FirstName
							end)
						end
					end
					if Collection:Attack() then
						Collection:UseAutoSkill(Options["Selected_Skill"].Value)
					end
					Collection.AttackCooldown = tick() + 0.5
				end
			end
		end)
		if Err and Debug then
			warn("[Main Coroutine] Caught Error:", Err)
		end
	end
end)()


---------------------------------------------- [ #Task : Auto_Webhook_End_Match]----------------------------------------------

local Currency_Fields = {
	Coins = { "Coins" },
	Crystal = { "Crystal" },
	Diamond = { "Diamond" },
	Tickets = { "Raid Ticket", "RaidTicket", "Tickets" },
	PetCoin = { "Pet Coin", "PetCoin" },
	SlayerCoins = { "Slayer Coins", "SlayerCoins" },
	ShadowCoins = { "Shadow Coins", "ShadowCoins" },
	DungeonKey = { "Dungeon Key", "DungeonKey" },
}

local Spin_Fields = {
	{ Label = "Normal Ability", Names = { "NormalAbilitySpins", "NormalAbilitySpin" } },
	{ Label = "Lucky Ability", Names = { "LuckyAbilitySpins",  "LuckyAbilitySpin"  } },
	{ Label = "Normal Gadget", Names = { "NormalGadgetSpins",  "NormalGadgetSpin"  } },
	{ Label = "Lucky Gadget", Names = { "LuckyGadgetSpins",   "LuckyGadgetSpin"   } },
}

local Item_Fields = {
	{ Label = "Diamond", Names = { "Diamond", "Diamonds" } },
	{ Label = "Crystal", Names = { "Crystal", "Crystals" } },
	{ Label = "Dungeon Key", Names = { "DungeonKey", "DungeonKeys" } },
	{ Label = "Leaf", Names = { "Leaf", "Leaves" } },
	{ Label = "Cloth", Names = { "Cloth" } },
	{ Label = "Metal", Names = { "Metal" } },
	{ Label = "Screw", Names = { "Screw", "Screws" } },
	{ Label = "Cursed Finger", Names = { "CursedFinger", "CursedFingers" } },
	{ Label = "Cursed Orb", Names = { "CursedOrb", "CursedOrbs" } },
	{ Label = "Inverted Spear", Names = { "InvertedSpear", "InvertedSpears" } },
	{ Label = "Trait Reroll", Names = { "TraitReroll", "TraitRerolls" } },
	{ Label = "Pet Coin", Names = { "PetCoin", "PetCoins" } },
	{ Label = "Slayer Coins", Names = { "SlayerCoins" } },
	{ Label = "Shadow Coins", Names = { "ShadowCoins" } },
}

function Collection:FormatNumber(Number)
	local Formatted = tostring(math.floor(tonumber(Number) or 0))
	while true do
		local Replaced
		Formatted, Replaced = Formatted:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
		if Replaced == 0 then break end
	end
	return Formatted
end

function Collection:GetDataValue(Names)
	local Result = 0
	xpcall(function()
		local Data = LocalPlayer:FindFirstChild("Data")
		if not Data then return end
		for _, Name in ipairs(Names) do
			local Object = Data:FindFirstChild(Name)
			if Object and tonumber(Object.Value) then
				Result = tonumber(Object.Value)
				return
			end
		end
	end, Debug_Log)
	return Result
end

function Collection:GetSpinsList()
	local List = {}
	for _, Spin in ipairs(Spin_Fields) do
		local Amount = Collection:GetDataValue(Spin.Names)
		table.insert(List, Spin.Label .. ": " .. Collection:FormatNumber(Amount))
	end
	return table.concat(List, ", ")
end

local Inventory_Allow = {}
for ItemName, _ in pairs(ItemsData.Items or {}) do
	Inventory_Allow[ItemName] = true
	Inventory_Allow[ItemName:gsub(" ", "")] = true
end
Inventory_Allow["Coins"] = nil

local function PrettifyName(name)
	if name:find(" ") then return name end
	return (name:gsub("(%l)(%u)", "%1 %2"))
end

function Collection:GetItemsInventory()
	local List = {}
	xpcall(function()
		local Items = HttpService:JSONDecode(LocalPlayer.Data.Items.Value)
		if type(Items) ~= "table" then return end
		for ItemName, Amount in pairs(Items) do
			local Number = tonumber(Amount) or (type(Amount) == "table" and tonumber(Amount.Amount)) or 0
			if Number > 0 and ItemName ~= "Coins" then
				table.insert(List, ItemName .. " x" .. Collection:FormatNumber(Number))
			end
		end
		table.sort(List)
	end, Debug_Log)
	return (#List > 0) and table.concat(List, ", ") or "-"
end

function Collection:GetMatchPlayTime()
	local Seconds = 0
	xpcall(function()
		local Cfg = workspace:FindFirstChild("MatchConfig")
		if not Cfg then return end
		local PT = Cfg:FindFirstChild("MatchPlaytime") or Cfg:FindFirstChild("PlayTime") or Cfg:FindFirstChild("Playtime")
		if PT and tonumber(PT.Value) then
			Seconds = tonumber(PT.Value)
			return
		end
		local Attr = Cfg:GetAttribute("MatchPlaytime") or Cfg:GetAttribute("PlayTime") or workspace:GetAttribute("MatchPlaytime")
		if tonumber(Attr) then Seconds = tonumber(Attr) end
	end, Debug_Log)
	if Seconds <= 0 then return "-" end
	local M = math.floor(Seconds / 60)
	local S = math.floor(Seconds % 60)
	if M > 0 then
		return string.format("%dm %ds", M, S)
	end
	return string.format("%ds", S)
end

function Collection:GetMatchWave()
	local Wave = "-"
	xpcall(function()
		local Cfg = workspace:FindFirstChild("MatchConfig")
		for _, Source in ipairs({
			workspace:GetAttribute("Wave"),
			workspace:GetAttribute("CurrentWave"),
			workspace:GetAttribute("WaveCount"),
			Cfg and Cfg:GetAttribute("Wave"),
			Cfg and Cfg:GetAttribute("CurrentWave"),
			LocalPlayer:GetAttribute("Wave"),
		}) do
			if tonumber(Source) then
				Wave = tostring(math.floor(tonumber(Source)))
				return
			end
		end

		local PG = LocalPlayer:FindFirstChild("PlayerGui")
		local HUD = PG and PG:FindFirstChild("HUD")
		if not HUD then return end
		for _, Descendant in ipairs(HUD:GetDescendants()) do
			if (Descendant:IsA("TextLabel") or Descendant:IsA("TextButton")) and Descendant.Text then
				local Text = Descendant.Text
				local Number = Text:match("[Ww]ave%s*[:%s]?%s*(%d+)")
				if Number then
					Wave = Number
					return
				end
			end
		end
	end, Debug_Log)
	return Wave
end

function Collection:IsMatchVictory()
	local Result = false
	xpcall(function()
		local Cfg = workspace:FindFirstChild("MatchConfig")
		local Attr = workspace:GetAttribute("MatchResult") or (Cfg and Cfg:GetAttribute("MatchResult"))
		if Attr then
			local A = tostring(Attr):upper()
			if A:find("VICTORY") or A:find("WIN") then
				Result = true
				return
			elseif A:find("LOSE") or A:find("DEFEAT") or A:find("LOSS") then
				Result = false
				return
			end
		end

		local EndScreen = LocalPlayer.PlayerGui:FindFirstChild("HUD")
		EndScreen = EndScreen and EndScreen:FindFirstChild("EndScreen")
		local Main = EndScreen and EndScreen:FindFirstChild("Main")
		if not Main then return end

		for _, Descendant in ipairs(Main:GetDescendants()) do
			if Descendant:IsA("UIGradient") and Descendant.Enabled then
				if Descendant.Name == "Victory" then Result = true return end
				if Descendant.Name == "Lose" then Result = false return end
			end
			if Descendant:IsA("TextLabel") and Descendant.Text then
				local T = Descendant.Text:upper()
				if T:find("VICTORY") then Result = true return end
				if T:find("LOSE") or T:find("DEFEAT") then Result = false return end
			end
		end
	end, Debug_Log)
	return Result
end

function Collection:GetMatchPlayerStats()
	local Stats = {}
	xpcall(function()
		local Data = HttpService:JSONDecode(workspace.MatchConfig.PlayersStats.Value)
		Stats = Data[LocalPlayer.Name] or {}
	end, Debug_Log)
	return Stats
end

function Collection:GetMatchValue(Name)
	local Result = "-"
	xpcall(function()
		Result = workspace.MatchConfig[Name].Value
	end, Debug_Log)
	return Result
end

function Collection:GetEquippedAbility()
	local Ability = "-"
	xpcall(function()
		local Decoded = HttpService:JSONDecode(LocalPlayer.Data.AbilitySlots.Value)
		for _, Slot in pairs(Decoded) do
			if type(Slot) == "table" and Slot.Showcasing and Slot.Name then
				Ability = Slot.Name
				return
			end
		end
		for _, Slot in pairs(Decoded) do
			if type(Slot) == "table" and Slot.Equipped and Slot.Name then
				Ability = Slot.Name
				return
			end
		end
	end, Debug_Log)
	return Ability
end

function Collection:GetEquippedGadgets()
	local Gadgets = "-"
	xpcall(function()
		local Decoded = HttpService:JSONDecode(LocalPlayer.Data.GadgetSlots.Value)
		local List = {}
		for i = 1, 5 do
			local Slot = Decoded["Slot" .. i]
			if Slot and Slot.Name and Slot.Name ~= "" then
				table.insert(List, Slot.Name)
			end
		end
		if #List > 0 then Gadgets = table.concat(List, ", ") end
	end, Debug_Log)
	return Gadgets
end

function Collection:FormatDrops(Drops)
	local Result = "-"
	xpcall(function()
		if type(Drops) == "table" and #Drops > 0 then
			local List = {}
			for _, Drop in ipairs(Drops) do
				table.insert(List, (Drop.Name or "?") .. " x" .. tostring(Drop.Amount or 1))
			end
			Result = table.concat(List, ", ")
		end
	end, Debug_Log)
	return Result
end

function Collection:SendMatchWebhook()
	local Url = Options["Webhook_URL"].Value
	if Url == "" then return end

	local Stats = Collection:GetMatchPlayerStats()
	local Map = Collection:GetMatchValue("Map")
	local Mode = Collection:GetMatchValue("Mode")
	local Difficulty = Collection:GetMatchValue("Difficulty")
	local Ability = Collection:GetEquippedAbility()
	local Gadgets= Collection:GetEquippedGadgets()
	local Drops = Collection:FormatDrops(Stats.Drops)
	local Kills = Collection:FormatNumber(Stats.Kills)
	local Damage = Collection:FormatNumber(Stats.DamageDealt)
	local EarnedCoins = Collection:FormatNumber(Stats.Coins or LocalPlayer:GetAttribute("CoinsGained") or 0)
	local Victory = Collection:IsMatchVictory()

	local UserHeader = LocalPlayer.Name
	local Money = Collection:FormatNumber(Collection:GetDataValue(Currency_Fields.Coins))
	local Spins = Collection:GetSpinsList()
	local Inventory = Collection:GetItemsInventory()
	local PlayTime = Collection:GetMatchPlayTime()
	local Wave = Collection:GetMatchWave()

	xpcall(function()
		local data = {
			["username"]   = "Deity Hub - " .. ProjectName .. " | #" .. tostring(math.random(1111, 9999)),
			["avatar_url"] = "https://sv1.img.in.th/7Vw6dr.png",
			["content"]    = " ",
			["embeds"] = {
				{
					["color"]  = Victory and 0x00FF7F or 0xFF4444,
					["author"] = {
						["name"]     = "[\xF0\x9F\x8E\xAE] MATCH RESULT - " .. (Victory and "VICTORY" or "DEFEAT"),
						["icon_url"] = "https://sv1.img.in.th/7VwM4k.png",
					},
					["fields"] = {
						{ ["name"] = "[\xF0\x9F\xA7\x9F] # USERNAME", ["value"] = "```" .. UserHeader .. "```", ["inline"] = false },
						{ ["name"] = "[\xF0\x9F\x92\xB0] # Money", ["value"] = "```" .. Money .. "```", ["inline"] = true },
						{ ["name"] = "[\xE2\x8F\xB1\xEF\xB8\x8F] # Play Time", ["value"] = "```" .. PlayTime .. "```", ["inline"] = true },
						{ ["name"] = "[\xF0\x9F\x8E\xB0] # Spins", ["value"] = "```" .. Spins .. "```", ["inline"] = false },
						{ ["name"] = "[\xF0\x9F\x93\xA6] # Items Inventory", ["value"] = "```" .. Inventory .. "```", ["inline"] = false },
						{ ["name"] = "[\xE2\x9A\x94\xEF\xB8\x8F] # Equipped Ability", ["value"] = "```" .. Ability .. "```", ["inline"] = true },
						{ ["name"] = "[\xF0\x9F\x92\xA3] # Equipped Gadgets", ["value"] = "```" .. Gadgets .. "```", ["inline"] = true },
						{ ["name"] = "[\xF0\x9F\x97\xBA\xEF\xB8\x8F] # Map", ["value"] = "```" .. Map .. "```", ["inline"] = true },
						{ ["name"] = "[\xE2\x9A\x94\xEF\xB8\x8F] # Mode", ["value"] = "```" .. Mode .. "```", ["inline"] = true },
						{ ["name"] = "[\xF0\x9F\x94\xA5] # Difficulty", ["value"] = "```" .. Difficulty .. "```", ["inline"] = true },
						{ ["name"] = "[\xF0\x9F\x8C\x8A] # Wave", ["value"] = "```" .. Wave .. "```", ["inline"] = true },
						{ ["name"] = "[\xF0\x9F\x92\x80] # Kills", ["value"] = "```" .. Kills .. "```", ["inline"] = true },
						{ ["name"] = "[\xF0\x9F\x92\xA5] # Damage", ["value"] = "```" .. Damage .. "```", ["inline"] = true },
						{ ["name"] = "[\xF0\x9F\x92\xB0] # Earned", ["value"] = "```" .. EarnedCoins .. "```", ["inline"] = true },
						{ ["name"] = "[\xF0\x9F\x93\xA6] # Drops This Match", ["value"] = "```" .. Drops .. "```", ["inline"] = false },
					},
					["footer"] = { ["text"] = "\xF0\x9F\xA4\x96 NOTES : Webhook is sent when the match finishes." },
				}
			},
		}
		_http_request({
			Url     = Url,
			Body    = HttpService:JSONEncode(data),
			Method  = "POST",
			Headers = { ["content-type"] = "application/json" },
		})
	end, Debug_Log)
end

function Collection:IsMatchFinished()
	if workspace:FindFirstChild("GameFinished") then return true end
	if workspace:GetAttribute("MatchEnded") == true then return true end
	if workspace:GetAttribute("FinishedMatch") == true then return true end
	if workspace:GetAttribute("MatchResult") then return true end

	local Cfg = workspace:FindFirstChild("MatchConfig")
	if Cfg then
		if Cfg:GetAttribute("MatchEnded") == true then return true end
		if Cfg:GetAttribute("FinishedMatch") == true then return true end
		if Cfg:GetAttribute("MatchResult") then return true end
	end

	if LocalPlayer:GetAttribute("MatchResult") then return true end

	local PG = LocalPlayer:FindFirstChild("PlayerGui")
	local HUD = PG and PG:FindFirstChild("HUD")
	local EndScreen = HUD and HUD:FindFirstChild("EndScreen")
	local Main = EndScreen and EndScreen:FindFirstChild("Main")
	local LobbyReturn = Main and Main:FindFirstChild("LobbyReturn")
	if EndScreen and EndScreen:IsA("GuiObject") and EndScreen.Visible
		and Main and Main:IsA("GuiObject") and Main.Visible
		and LobbyReturn and LobbyReturn:IsA("GuiObject") and LobbyReturn.Visible
	then
		return true
	end

	return false
end

FunctionTask["Auto_Webhook_End_Match"] = function()
	local LastSeen = false
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then break end
		local _, Err = pcall(function()
			if Options["Auto_Webhook_End_Match"] and Options["Auto_Webhook_End_Match"].Value then
				local Finished = Collection:IsMatchFinished()
				if Finished and not LastSeen then
					warn("[Auto_Webhook_End_Match] Match end detected — sending webhook now")
					Collection:SendMatchWebhook()
					warn("[Auto_Webhook_End_Match] Webhook sent")
				end
				LastSeen = Finished
			end
		end)
		if Err then
			warn("[Auto_Webhook_End_Match] Caught Error: ", Err)
		end
		task.wait()
	end
end

---------------------------------------------- [ #Task : Auto_Skip_Wave]----------------------------------------------
FunctionTask["Auto_Skip_Wave"] = function()
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then break end
		local Success, Err = pcall(function()
			if Options["Auto_Skip_Wave"].Value then
				local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
				local HUD = PlayerGui and PlayerGui:FindFirstChild("HUD")

				local Tabs_ = HUD and HUD:FindFirstChild("Tabs")
				local InfinitePanel = Tabs_ and Tabs_:FindFirstChild("InfinitePanel")
				local StartInfinite = InfinitePanel and InfinitePanel:FindFirstChild("StartInfinite")
				if StartInfinite and StartInfinite.Visible then
					Interact:FireServer("VoteSkipInfinite")
				end

				local StartRaid = HUD and HUD:FindFirstChild("StartRaid")
				if StartRaid and StartRaid.Visible then
					Interact:FireServer("VoteSkipRaid")
				end
			end
		end)
		if Err and Debug then
			warn("[Auto_Skip_Wave] Caught Error: ", Err)
		end
		task.wait(0.5)
	end
end

---------------------------------------------- [ #Task : Auto_Collect]----------------------------------------------
Collection.CollectableNames = { CoinDrop = true, HealthDrop = true }
FunctionTask["Auto_Collect"] = function()
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then break end
		local Success, Err = pcall(function()
			if Options["Auto_Collect"].Value then
				local Thrown = workspace:FindFirstChild("Thrown")
				if not Thrown then return end
				for _, Drop in next, Thrown:GetChildren() do
					local Pickup = Drop:FindFirstChild("Pickup")
					if Pickup and Pickup:IsA("RemoteEvent") then
						Collection:UpdateStatus("Collecting: " .. Drop.Name)
						pcall(function() Pickup:FireServer() end)
					end
				end
			end
		end)
		if Err and Debug then
			warn("[Auto_Collect] Caught Error: ", Err)
		end
		task.wait(0.2)
	end
end

---------------------------------------------- [ #Task : Auto_Pick_Card]----------------------------------------------

FunctionTask["Auto_Claim_All_Quest"] = function()
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then break end
		local Success, Err = pcall(function()
			if Options["Auto_Claim_All_Quest"].Value then
				Interact:FireServer("ClaimAllQuests")
			end
		end)
		if Err and Debug then
			warn("[Auto_Claim_All_Quest] Caught Error: ", Err)
		end
		task.wait(0.5)
	end
end

---------------------------------------------- [ #Task : Auto_Pick_Card]----------------------------------------------

FunctionTask["Auto_Pick_Card"] = function()
	local Requests = Assets:WaitForChild("Requests")
	local FuncInteract = Requests:WaitForChild("FuncInteract")
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then break end
		local Succ, Err = pcall(function()
			if not Options["Auto_Pick_Card"].Value then return end
			local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
			local HUD = PlayerGui and PlayerGui:FindFirstChild("HUD")
			local Main = HUD and HUD:FindFirstChild("Main")
			local Cards = Main and Main:FindFirstChild("Cards")
			local CardsFrame = Cards and Cards:FindFirstChild("CardsFrame")
			local Container = CardsFrame and CardsFrame:FindFirstChild("Container")
			if not Container then return end
			local OfferedCards = {}
			local CardButtons = {}
			for _, Child in ipairs(Container:GetChildren()) do
				local CardAttrName = Child:GetAttribute("CardName")
				if CardAttrName then
					OfferedCards[CardAttrName] = true
					CardButtons[CardAttrName] = Child
				end
			end
			if not next(OfferedCards) then return end
			local SeenCards = {}
			for PriorityIndex = 1, #Collection.Cards.Map do
				local PriorityOption = Options["Card_Priority_" .. PriorityIndex]
				local CardName = PriorityOption and Collection.Cards.Data[PriorityOption.Value]
				print("CardName:", CardName)
				if CardName and not SeenCards[CardName] and OfferedCards[CardName] then
					local InvokeSuccess = pcall(function()
						FuncInteract:InvokeServer("DrawCard", CardName)
					end)
					if InvokeSuccess then
						local CardButton = CardButtons[CardName]
						if CardButton and CardButton.Parent then
							pcall(function() CardButton:Destroy() end)
						end
					end
					task.wait(1)
					return
				end
				if CardName then SeenCards[CardName] = true end
			end
		end)
		if Err and Debug then
			warn("[Auto_Pick_Card] Caught Error: ", Err)
		end
		task.wait(0.5)
	end
end

---------------------------------------------- [ #Task : Auto_Claim_Battlepass]----------------------------------------------
FunctionTask["Auto_Claim_Battlepass"] = function()
	local Requests = Assets:WaitForChild("Requests")
	local FuncInteract = Requests:WaitForChild("FuncInteract")
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then break end
		local Succ, Err = pcall(function()
			if Options["Auto_Claim_Battlepass"].Value then
				pcall(function()
					FuncInteract:InvokeServer("ClaimBattlepass", nil, nil, true)
				end)
			end
		end)
		if Err and Debug then
			warn("[Auto_Claim_Battlepass] Caught Error: ", Err)
		end
		task.wait(10)
	end
end

---------------------------------------------- [ #Task : Auto_Play_Again]----------------------------------------------
FunctionTask["Auto_Play_Again"] = function()
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then break end
		local Succ, Err = pcall(function()
			if Options["Auto_Play_Again"].Value then
				if Collection:IsInLobby() then return end
				if not Collection:IsMatchEnded() then return end
				pcall(function()
					task.wait(5)
					Interact:FireServer("PlayAgain")
				end)
			end
		end)
		if Err and Debug then
			warn("[Auto_Play_Again] Caught Error: ", Err)
		end
		task.wait(2)
	end
end

---------------------------------------------- [ #Task : Auto_Back_To_Lobby]----------------------------------------------
FunctionTask["Auto_Back_To_Lobby"] = function()
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then break end
		local Succ, Err = pcall(function()
			if Options["Auto_Back_To_Lobby"].Value then
				if Collection:IsInLobby() then return end
				if not Collection:IsMatchEnded() then return end
				pcall(function()
					Interact:FireServer("BackToLobby")
				end)
			end
		end)
		if Err and Debug then
			warn("[Auto_Back_To_Lobby] Caught Error: ", Err)
		end
		task.wait(2)
	end
end

---------------------------------------------- [ #Task : Auto_Join_Raid]----------------------------------------------
FunctionTask["Auto_Join_Raid"] = function()
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then break end
		local Succ, Err = pcall(function()
			if Options["Auto_Join_Raid"].Value then
				if not Collection:IsInLobby() then return end
				local Raid = Options["Selected_Raid"].Value
				if Raid and Raid ~= "" then
					Collection:createMatching(Raid, "Raid", "Normal", true)
					task.wait(3)
				end
			end
		end)
		if Err and Debug then
			warn("[Auto_Join_Raid] Caught Error: ", Err)
		end
		task.wait()
	end
end

---------------------------------------------- [ #Task : Auto_Join_Titan_Defense]----------------------------------------------
FunctionTask["Auto_Join_Titan_Defense"] = function()
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then break end
		local Succ, Err = pcall(function()
			if Options["Auto_Join_Titan_Defense"].Value then
				if not Collection:IsInLobby() then return end
				local Titan_Defense = Options["Selected_Titan_Defense"].Value
				if Titan_Defense and Titan_Defense ~= "" then
					Collection:createMatching(Titan_Defense, "Titan Defense", "Normal", true)
					task.wait(3)
				end
			end
		end)
		if Err and Debug then
			warn("[Auto_Join_Titan_Defense] Caught Error: ", Err)
		end
		task.wait()
	end
end

---------------------------------------------- [ #Task : Auto_Join_Wave_Defense]----------------------------------------------
FunctionTask["Auto_Join_Wave_Defense"] = function()
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then break end
		local Succ, Err = pcall(function()
			if Options["Auto_Join_Wave_Defense"].Value then
				if not Collection:IsInLobby() then return end
				local Wave_Defense = Options["Selected_Wave_Defense"].Value
				if Wave_Defense and Wave_Defense ~= "" then
					Collection:createMatching(Wave_Defense, "Wave Defense", "Normal", true)
					task.wait(3)
				end
			end
		end)
		if Err and Debug then
			warn("[Auto_Join_Wave_Defense] Caught Error: ", Err)
		end
		task.wait()
	end
end


---------------------------------------------- [ #Task : Join_Matching]----------------------------------------------
FunctionTask["Enabled_Matching"] = function()
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then break end
		local Succ, Err = pcall(function()
			if Options["Enabled_Matching"].Value then
				if not Collection:IsInLobby() then return end
				local Map = Options["Selected_Map"] and Options["Selected_Map"].Value
				local Mode = Options["Selected_Mode"] and Options["Selected_Mode"].Value
				local Difficulty = Options["Selected_Difficulty"] and Options["Selected_Difficulty"].Value
				if Map and Mode and Difficulty and Map ~= "" and Mode ~= "" and Difficulty ~= "" then
					Collection:createMatching(Map, Mode, Difficulty)
					task.wait(3)
				end
			end
		end)
		if Err and Debug then
			warn("[Enabled_Matching] Caught Error: ", Err)
		end
		task.wait()
	end
end

---------------------------------------------- [ #Task : ESP_Players ] ----------------------------------------------

FunctionTask["ESP_Players"] = function()
    while true do
        if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then
            for i,v in pairs(Players:GetChildren()) do
                if v ~= LocalPlayer then
                    pcall(function()
                        if v.Character.Head:FindFirstChild("ESP_Billboard") then
                            v.Character.Head.ESP_Billboard:Destroy()
                        end
                    end)
                end
            end
            break 
        end
        local Succ,Err = pcall(function()
            for i,v in pairs(Players:GetChildren()) do
                if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                    if v.Character.Head:FindFirstChild("ESP_Billboard") then
                        if not v.Character.Head["ESP_Billboard"]:FindFirstChild("ESP_Billboard_Text") then
                            v.Character.Head["ESP_Billboard"]:Destroy()
                        end

                        v.Character.Head.ESP_Billboard.Enabled = Options["ESP_Players"].Value
                        v.Character.Head.ESP_Billboard.ESP_Billboard_Text.Text = [[<font color="rgb(255,255,255)">]] .. v.Name .. "</font>\n" .. '<font color="rgb(64,255,70)">Distance : [' .. math.floor(Collection:GetSelfDistance(v.Character.HumanoidRootPart.Position)) ..']</font>'
                    else
                        local Billboard = Instance.new("BillboardGui", v.Character.Head)
                        local TexT = Instance.new("TextLabel",Billboard)
                        for Property,Value in pairs(Billboard_Property) do
                            Billboard[Property] = Value
                        end
                        for Property,Value in pairs(TexT_Property) do
                            TexT[Property] = Value
                        end
                    end
                end
            end
        end)
        if Err and Debug then
            warn("[ESP_Players] Caught Error: ",Err)
        end
        task.wait(.1)
    end
end
---------------------------------------------- [ #Task : Auto_Spin_Gadgets ] ----------------------------------------------

FunctionTask["Auto_Spin_Gadgets"] = function()
	local CalledDisabled = true
	local JumpPowerConnection

	local Requests = Assets:WaitForChild("Requests")
	local FuncInteract = Requests:WaitForChild("FuncInteract")

	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then
			break
		end

		local Succ,Err = pcall(function()
			local Humanoid = Collection:GetHum(LocalPlayer.Character)
			if Options["Auto_Spin_Gadgets"].Value then
				local GadgetSlots = Options["Selected_Gadgets_Slot"].Value
				local CurrentGadgets = HttpService:JSONDecode(LocalPlayer.Data.GadgetSlots.Value)["Slot" .. GadgetSlots].Name

				if table.find(Options["Selected_Gadgets"].Value, CurrentGadgets) then
					Library:Notify({ Title = "[✅] Congratulation!", Content = 'You just got "' .. CurrentGadgets .. '" gadget', Duration = 2 })
					task.wait(1)
					return 
				end

				if Options["Selected_Gadgets_Method"].Value == "Coins" then
					FuncInteract:InvokeServer("RollGadget", "Slot1", "Normal")
				elseif Options["Selected_Gadgets_Method"].Value == "Coins" then
					FuncInteract:InvokeServer("RollGadget", "Slot1", "Lucky")
				end
			end
		end)
		if Err and Debug then
			warn("[Auto_Spin_Gadgets] Caught Error: ",Err)
		end 
		task.wait(.1)
	end
end

---------------------------------------------- [ #Task : Enabled_Jump_Power ] ----------------------------------------------

FunctionTask["Enabled_Jump_Power"] = function()
	local CalledDisabled = true
	local JumpPowerConnection
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then
			break
		end

		local Succ,Err = pcall(function()
			local Humanoid = Collection:GetHum(LocalPlayer.Character)
			if Options["Enabled_Jump_Power"].Value then
				if not JumpPowerConnection then
					JumpPowerConnection = Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
						if Options["Enabled_Jump_Power"].Value and Humanoid.JumpPower ~= Options["Speed"].Value then
							Humanoid.JumpPower = Options["Speed"].Value
						end
					end)

					Humanoid.JumpPower = Options["Speed"].Value
					Humanoid.UseJumpPower = true
				end
			else
				if JumpPowerConnection then
					JumpPowerConnection:Disconnect()
					JumpPowerConnection = nil
				end
				if CalledDisabled then
					CalledDisabled = false
					Humanoid.UseJumpPower = false
					Humanoid.JumpPower = 16
				end
			end
		end)
		if Err and Debug then
			warn("[Enabled_Walk_Speed] Caught Error: ",Err)
		end 
		task.wait()
	end
end

---------------------------------------------- [ #Task : Enabled_Walk_Speed ] ----------------------------------------------

FunctionTask["Enabled_Walk_Speed"] = function()
	local CalledDisabled = true
	local WalkSpeedConnection
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then
			break
		end

		local Succ,Err = pcall(function()
			local Humanoid = Collection:GetHum(LocalPlayer.Character)
			if Options["Enabled_Walk_Speed"].Value then
				if not WalkSpeedConnection then
					WalkSpeedConnection = Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
						if Options["Enabled_Walk_Speed"].Value and Humanoid.WalkSpeed ~= Options["Speed"].Value then
							Humanoid.WalkSpeed = Options["Speed"].Value
						end
					end)

					Humanoid.WalkSpeed = Options["Speed"].Value
				end
			else
				if WalkSpeedConnection then
					WalkSpeedConnection:Disconnect()
					WalkSpeedConnection = nil
				end
				if CalledDisabled then
					CalledDisabled = false
					Humanoid.WalkSpeed = 16
				end
			end
		end)
		if Err and Debug then
			warn("[Enabled_Walk_Speed] Caught Error: ",Err)
		end 
		task.wait()
	end
end

---------------------------------------------- [ #Task : Spectate_Player ] ----------------------------------------------

FunctionTask["Spectate_Player"] = function()
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then break end

		local Succ,Err = pcall(function()
			if Options["Spectate_Player"].Value then
				workspace.Camera.CameraSubject = Players[Options["Selected_Player"].Value].Character
			end
		end)
		if Err and Debug then
			warn("[Spectate_Player] Caught Error: ",Err)
		end 
		wait()
	end
end

---------------------------------------------- [ #Task : Protect_Name ] ----------------------------------------------

FunctionTask["Protect_Name"] = function()
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then break end
		local Succ,Err = pcall(function()
			local CoreGuiPlayerName = CoreGui.PlayerList.Children.OffsetFrame.PlayerScrollList.SizeOffsetFrame.ScrollingFrameContainer.ScrollingFrameClippingFrame.ScollingFrame.OffsetUndoFrame["p_"..game.Players.LocalPlayer.UserId].ChildrenFrame.NameFrame.BGFrame.OverlayFrame.PlayerName.PlayerName
			local RootPart = Collection:GetRoot(LocalPlayer.Character) 
			if Options["Protect_Name"].Value then
				if CoreGuiPlayerName.Text ~= "Protected By Deity Hub" then 
					CoreGuiPlayerName.Text = "Protected By Deity Hub"
				end
			else 
				if CoreGuiPlayerName.Text == "Protected By Deity Hub" then 
					CoreGuiPlayerName.Text = LocalPlayer.DisplayName
				end
			end

		end)
		if Err and Debug then
			warn("[Protect_Name] Caught Error: ",Err)
		end
		wait()
	end
end

---------------------------------------------- [ #Task : Teleport_To_Player ] ----------------------------------------------

FunctionTask["Teleport_To_Player"] = function()
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then break end

		local Succ,Err = pcall(function()
			if Options["Teleport_To_Player"].Value then
				if Players:FindFirstChild(Options["Selected_Player"].Value) then
					local TargetRoot = Collection:GetRoot(Players[Options["Selected_Player"].Value].Character)
					Collection:Teleport(TargetRoot.CFrame)
				else
					Library:Notify({ Title = "[\xE2\x9D\x8C] Teleport To Player", Content = "This player isn't in the server.", Duration = 2 })
					wait(1.5)
				end
			end
		end)
		if Err and Debug then
			warn("[Teleport_To_Player] Caught Error: ",Err)
		end 
		task.wait()
	end
end

---------------------------------------------- [ #Task : Enabled_Fly ] ----------------------------------------------

local FLYING = false
local QEfly = true
local flySpeed = 50
local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local bodyVelocity, bodyGyro
function Collection:startFlying()
    if FLYING then return end
    FLYING = true

	local humanoidRootPart = Collection:GetRoot(LocalPlayer.Character)

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = humanoidRootPart

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.CFrame = humanoidRootPart.CFrame
    bodyGyro.Parent = humanoidRootPart

    RunService.Heartbeat:Connect(function()
        if FLYING then
            local cam = workspace.CurrentCamera
            bodyVelocity.Velocity = (
                (cam.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + 
                (cam.CFrame.RightVector * (CONTROL.L + CONTROL.R)) + 
                (Vector3.new(0, (CONTROL.Q + CONTROL.E), 0))
            ) * flySpeed
            bodyGyro.CFrame = cam.CFrame
        end
    end)
end

function Collection:stopFlying()
    FLYING = false
    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    local key = input.KeyCode
    if key == Enum.KeyCode.F then
        if FLYING then
            stopFlying()
        else
            startFlying()
        end
    elseif key == Enum.KeyCode.W then
        CONTROL.F = 1
    elseif key == Enum.KeyCode.S then
        CONTROL.B = -1
    elseif key == Enum.KeyCode.A then
        CONTROL.L = -1
    elseif key == Enum.KeyCode.D then
        CONTROL.R = 1
    elseif QEfly and key == Enum.KeyCode.E then
        CONTROL.Q = 1
    elseif QEfly and key == Enum.KeyCode.Q then
        CONTROL.E = -1
    elseif key == Enum.KeyCode.Equals then
        flySpeed = flySpeed + 10
    elseif key == Enum.KeyCode.Minus then
        flySpeed = math.max(10, flySpeed - 10)
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    local key = input.KeyCode
    if key == Enum.KeyCode.W then
        CONTROL.F = 0
    elseif key == Enum.KeyCode.S then
        CONTROL.B = 0
    elseif key == Enum.KeyCode.A then
        CONTROL.L = 0
    elseif key == Enum.KeyCode.D then
        CONTROL.R = 0
    elseif key == Enum.KeyCode.E then
        CONTROL.Q = 0
    elseif key == Enum.KeyCode.Q then
        CONTROL.E = 0
    end
end)

FunctionTask["Enabled_Fly"] = function()
	while true do
		if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then
			break
		end
		local Succ,Err = pcall(function()

			
			flySpeed = Options["Fly_Speed"].Value
			if Options["Enabled_Fly"].Value then
				Collection:startFlying()
			else
				Collection:stopFlying()
			end
		end)
		if Err and Debug then
			warn("[Enabled_Fly] Caught Error: ",Err)
		end 
		task.wait()
	end
end

--------------------------- [[ Script: White_Screen ]] ---------------------------

UserInputService.WindowFocused:Connect(function()
    RunService:Set3dRenderingEnabled(true)
end)
UserInputService.WindowFocusReleased:Connect(function()
    if Options["White_Screen"].Value then
        RunService:Set3dRenderingEnabled(false)
    end
end)

---------------------------------------------- [ Start Task ] ----------------------------------------------

for TaskName,TaskFunction in pairs(FunctionTask) do
	coroutine.wrap(function()
		repeat task.wait(1) until Options[TaskName] ~= nil and Options[TaskName].Value == true
		TaskFunction()
	end)()
end 
Tabs.General:Select(); IsLoaded = true
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)
coroutine.wrap(function()
    while true do task.wait()
        if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then break end
        pcall(function()
            local Dir = CoreGui:FindFirstChild("RobloxPromptGui"):FindFirstChild("promptOverlay")
            for i,v in pairs(Dir:GetDescendants()) do
                if v.Name == "ErrorTitle" then
                    if v.Text:sub(0, 12) == "Disconnected" then
                        if LocalPlayer then
                            LocalPlayer:Kick("\nRejoining...")
                        end
                        task.wait(5)
                        TeleportService:Teleport(game.PlaceId)
                    end
                end
            end
        end)
        task.wait(10)
    end
end)()
coroutine.wrap(function()
	local setfpscap = setfpscap or set_fps_cap
    while true do wait(.1)
        if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then break end
        pcall(function()
            if Options["Lock_FPS"].Value then 
				pcall(setfpscap, Options["Selected_Fps_Cap"].Value)
			else 
				pcall(setfpscap, 240)
			end
        end)
    end
end)()


coroutine.wrap(function()
    while RunService.Stepped:wait() do
        if Library.Unloaded or Collection.UnLoaded or Collection.BreakLoop then break end
        local Success , err = pcall(function()
            if Options["Auto_Farm_Entity"].Value then
                local Character = LocalPlayer.Character
                local Root = Character and Collection:GetRoot(Character)
                if not Root or not Character then return end
                if not Root:FindFirstChild("KRNLONAIR") then
                    local KRNLONAIR = Instance.new("BodyVelocity")
                    KRNLONAIR.Parent = Root
                    KRNLONAIR.Name = "KRNLONAIR"
                    KRNLONAIR.MaxForce = Vector3.new(100000,100000,100000)
                    KRNLONAIR.Velocity = Vector3.new(0,0,0)
                end
                for i, v in pairs(Character:GetDescendants()) do
                    if v:IsA("BasePart") and v.CanCollide == true then
                        v.CanCollide = false
                    end
                end
            elseif Collection:GetRoot(LocalPlayer.Character):FindFirstChild("KRNLONAIR") then
                Collection:GetRoot(LocalPlayer.Character)["KRNLONAIR"]:Destroy()
            end
            if sethiddenproperty then
                _sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            end

			pcall(function()
				local GadgetSlots = Options["Selected_Gadgets_Slot"].Value
				local GadgetData = HttpService:JSONDecode(LocalPlayer.Data.GadgetSlots.Value)["Slot" .. GadgetSlots]

				Gadgets_Paragraph:SetTitle("[🔥] Gadgets: " .. ((GadgetData and GadgetData.Name) or "Unknown"))
				Gadgets_Paragraph:SetDesc("\x20\x20\xE2\x95\xB0\xE2\x94\x88> Spin Exists: " .. tostring(LocalPlayer.Data.NormalGadgetSpins.Value))
			end)
        end)
        if err and Debug then
            warn("CAUGHT ERROR! : " .. err)
        end 
    end
end)()

Utility:SetBackgroundTransparency(0)