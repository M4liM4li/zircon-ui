--[[
	Zircon UI — every control, in one runnable script.

	Run it in any game. Nothing here reads game data, so it works anywhere.

		loadstring(game:HttpGet("https://raw.githubusercontent.com/M4liM4li/zircon-ui/main/example.luau?cb=" .. tick()))()

	Every row is one call. You name it, describe it, give it a default, and that is the whole
	thing — no Row, no TitleStack, no Left and Right:

		section:AddToggle("flag", { Title = "…", Description = "…", Default = false })
]]

local Cascade = loadstring(
	game:HttpGet("https://raw.githubusercontent.com/M4liM4li/zircon-ui/main/Library.luau?cb=" .. tick())
)()

--// Every Add* row writes its value here, keyed by flag.
Cascade.OnChanged(function(flag, value)
	print("[changed]", flag, typeof(value) == "table" and "(table)" or value)
end)

local app = Cascade.New({})

local window = app:Window({
	Title = "Zircon Hub",
	Subtitle = "Example",
	Size = UDim2.fromOffset(900, 560),
})

--------------------------------------------------------------------------------
-- Controls — the one-call way
--------------------------------------------------------------------------------

local main = window:Section({ Disclosure = false, Title = "Main" })

local controlsTab = main:Tab({
	Title = "Controls",
	Icon = Cascade.Symbols.square3Layers3d,
	Selected = true,
})

local basics = controlsTab:PageSection({
	Title = "Every control",
	Subtitle = "One call each. The flag is the first argument.",
	Icon = Cascade.Symbols.sliderHorizontal3,
	IconColor = Color3.fromRGB(255, 163, 26),
})

basics:Callout({
	Kind = "info",
	Text = "Flip anything here and watch the output — every change prints its flag and value.",
})

basics:AddToggle("demo_toggle", {
	Title = "Toggle",
	Description = "A switch. On means the feature is running.",
	Default = true,
})

basics:AddSlider("demo_slider", {
	Title = "Slider",
	Description = "Drag to pick a number in a range.",
	Default = 50,
	Minimum = 0,
	Maximum = 100,
})

basics:AddStepper("demo_stepper", {
	Title = "Stepper",
	Description = "Type a number, or step it up and down.",
	Default = 25,
	Minimum = 1,
	Maximum = 100,
	Step = 1,
	Fielded = true,
})

basics:AddDropdown("demo_dropdown", {
	Title = "Dropdown",
	Description = "Pick one.",
	Options = { "Apple", "Banana", "Cherry", "Durian" },
	Default = 1,
	Maximum = 1,
	Searchable = true,
})

basics:AddDropdown("demo_multi", {
	Title = "Multi select",
	Description = "Pick several, up to the maximum.",
	Options = { "Sword", "Gun", "Fruit", "Melee", "Haki" },
	Default = { 1, 2 },
	Maximum = 3,
})

basics:AddRadio("demo_radio", {
	Title = "Segmented",
	Description = "A few options that fit on one line.",
	Options = { "Instant", "Tween", "CFrame" },
	Default = 1,
})

basics:AddInput("demo_input", {
	Title = "Text field",
	Description = "Type something.",
	Placeholder = "Enter a name...",
	Default = "",
})

basics:AddKeybind("demo_keybind", {
	Title = "Keybind",
	Description = "Click it, press a key. Escape cancels, Backspace clears.",
	Default = Enum.KeyCode.RightControl,
	Owner = "Toggle window",
	BindPressed = function(_, _, complete, processed)
		if complete and not processed then
			window.Minimized = not window.Minimized
		end
	end,
})

basics:AddColorPicker("demo_color", {
	Title = "Colour picker",
	Description = "Click the swatch. Drag the square and the hue rail, or paste a hex.",
	Default = Color3.fromRGB(255, 163, 26),
})

basics:AddLabel("demo_label", {
	Title = "Label",
	Description = "Read-only output on the right.",
	Text = "Idle",
})

print("[zircon] 1/6 controls built")

--------------------------------------------------------------------------------
-- Buttons, and a row that is locked
--------------------------------------------------------------------------------

local actions = controlsTab:PageSection({
	Title = "Buttons",
	Subtitle = "Three weights, and a row that cannot be used yet.",
	Icon = Cascade.Symbols.bolt,
	IconColor = Color3.fromRGB(255, 163, 26),
})

actions:AddButton({
	Title = "Primary",
	Description = "The main action of the page.",
	Label = "Execute",
	State = "Primary",
	Changed = function()
		app:Notification({ Title = "Executed", Subtitle = "Nothing really happened.", Kind = "success" })
	end,
})

actions:AddButton({
	Title = "Secondary",
	Description = "A quieter action beside it.",
	Label = "Cancel",
	State = "Secondary",
	Changed = function()
		app:Notification({ Title = "Cancelled", Subtitle = "Also nothing.", Kind = "info" })
	end,
})

actions:AddButton({
	Title = "Destructive",
	Description = "Asks before it does anything.",
	Label = "Delete",
	State = "Destructive",
	Changed = function()
		window:Confirm({
			Title = 'Delete "example"?',
			Text = "The profile and its 34 saved settings go away. This cannot be undone.",
			Confirm = "Delete",
			Cancel = "Keep it",
			Destructive = true,
			Accepted = function()
				app:Notification({ Title = "Deleted", Subtitle = "Not really.", Kind = "error" })
			end,
		})
	end,
})

-- Locked takes the reason as its value, so the row can say how far off you are.
local _, lockedRow = actions:AddToggle("demo_locked", {
	Title = "Locked switch",
	Description = "Dimmed, and it says why.",
	Default = false,
})

if lockedRow then
	lockedRow.Locked = "Needs level 2500 · you are 62"
end

print("[zircon] 2/6 buttons built")

--------------------------------------------------------------------------------
-- Status surfaces
--------------------------------------------------------------------------------

local statusTab = main:Tab({ Title = "Status", Icon = Cascade.Symbols.chartBar })

local session = statusTab:PageSection({
	Title = "Session",
	Subtitle = "Tiles, progress and callouts.",
	Icon = Cascade.Symbols.chartBar,
	IconColor = Color3.fromRGB(255, 163, 26),
})

local grid = session:StatGrid({ Minimum = 150 })

local farmTile = grid:StatTile({ Label = "Farm", Value = "Idle", Icon = Cascade.Symbols.flame, Wide = true, Muted = true })
local countTile = grid:StatTile({ Label = "Ticks", Value = "0", Icon = Cascade.Symbols.chartBar })
local uptimeTile = grid:StatTile({ Label = "Uptime", Value = "0:00", Icon = Cascade.Symbols.clock })

local determinate = session:ProgressBar({ Title = "Determinate", Text = "0%", Value = 0 })
local sweeping = session:ProgressBar({ Title = "Indeterminate", Text = "working", Indeterminate = true })

session:Callout({ Kind = "warn", Text = "Warning tone. Use it when an action has a cost you cannot take back." })
session:Callout({ Kind = "danger", Text = "Danger tone. Use it when something is already wrong." })

--// Everything above is driven from here, so nothing on screen is a made-up number.
local started = os.clock()
local ticks = 0

task.spawn(function()
	while window and window.Structures and window.Structures.Body.Parent do
		ticks += 1

		local elapsed = math.floor(os.clock() - started)
		local running = Cascade.Options["demo_toggle"] and Cascade.Options["demo_toggle"].Value

		countTile.Value = tostring(ticks)
		uptimeTile.Value = string.format("%d:%02d", math.floor(elapsed / 60), elapsed % 60)

		farmTile.Value = running and "Running" or "Idle"
		farmTile.Muted = not running

		local fraction = (elapsed % 20) / 20

		determinate.Value = fraction
		determinate.Text = string.format("%d%%", math.floor(fraction * 100))

		sweeping.Indeterminate = running

		session.Badge = running and "Running" or "Idle"
		session.BadgeActive = running

		task.wait(1)
	end
end)

print("[zircon] 3/6 status built")

--------------------------------------------------------------------------------
-- Pages that are not lists
--------------------------------------------------------------------------------

local pagesTab = main:Tab({ Title = "Pages", Icon = Cascade.Symbols.bookmark })

local travel = pagesTab:PageSection({
	Title = "Destinations",
	Subtitle = "A grid you pick from by looking, not by reading a dropdown.",
	Icon = Cascade.Symbols.bookmark,
	IconColor = Color3.fromRGB(255, 163, 26),
})

travel:DestinationGrid({
	Selected = "Blue Planet",
	Places = {
		{ Name = "Blue Planet", Detail = "1.2K studs" },
		{ Name = "Academy Island", Detail = "2.4K studs" },
		{ Name = "Boss Island", Detail = "2.8K studs" },
		{ Name = "Desert Island", Detail = "3.1K studs" },
		{ Name = "Frost Island", Detail = "4.4K studs" },
		{ Name = "Hero Kingdom", Locked = "needs Lv.900" },
		{ Name = "Hollow Island", Locked = "needs Lv.1,400" },
		{ Name = "Bizarre Island", Detail = "6.0K studs" },
	},
	Chosen = function(_, name)
		app:Notification({ Title = "Travelling", Subtitle = name, Kind = "info" })
	end,
})

local points = pagesTab:PageSection({
	Title = "Stat points",
	Subtitle = "One pool, four rows. The pale segment is what you are about to spend.",
	Icon = Cascade.Symbols.chartBar,
	IconColor = Color3.fromRGB(255, 163, 26),
})

local stats = { Melee = 620, Defense = 410, Sword = 280, ["Devil fruit"] = 110 }

local budget

local function statRows()
	return {
		{ Name = "Melee", Value = stats.Melee },
		{ Name = "Defense", Value = stats.Defense },
		{ Name = "Sword", Value = stats.Sword },
		{ Name = "Devil fruit", Value = stats["Devil fruit"] },
	}
end

budget = points:PointBudget({
	Pool = "points to spend",
	Value = 18,
	Rows = statRows(),
	Committed = function(_, batch)
		local spent = 0

		for name, amount in batch do
			stats[name] = (stats[name] or 0) + amount
			spent += amount
		end

		budget.Value = math.max((budget.Value or 0) - spent, 0)
		budget.Rows = statRows()

		app:Notification({ Title = "Points applied", Subtitle = spent .. " spent", Kind = "success" })
	end,
})

print("[zircon] 4/6 pages built")

--------------------------------------------------------------------------------
-- Toasts and the screens that come before the hub
--------------------------------------------------------------------------------

local screensTab = main:Tab({ Title = "Screens", Icon = Cascade.Symbols.info })

local toasts = screensTab:PageSection({
	Title = "Toasts",
	Subtitle = "The hairline underneath is the time left. Errors hold until dismissed.",
	Icon = Cascade.Symbols.info,
	IconColor = Color3.fromRGB(255, 163, 26),
})

for _, kind in { "info", "success", "error" } do
	toasts:AddButton({
		Title = kind,
		Description = kind == "error" and "Stays until you close it." or "Expires on its own.",
		Label = "Show",
		State = "Secondary",
		Changed = function()
			app:Notification({
				Title = "A " .. kind .. " toast",
				Subtitle = "This is what it looks like.",
				Kind = kind,
			})
		end,
	})
end

local screens = screensTab:PageSection({
	Title = "Before the hub",
	Subtitle = "Both carry their own ScreenGui, so they run without a window.",
	Icon = Cascade.Symbols.bolt,
	IconColor = Color3.fromRGB(255, 163, 26),
})

screens:AddButton({
	Title = "Splash",
	Description = "Walks its step list, then closes.",
	Label = "Show",
	State = "Secondary",
	Changed = function()
		local splash = Cascade.Splash({
			Title = "Starting Zircon",
			Subtitle = "Example",
			Steps = { "Interface loaded", "Profile restored", "Waiting for the game", "Hooking remotes" },
		})

		task.spawn(function()
			for _ = 1, 4 do
				task.wait(0.7)
				splash.Advance()
			end

			task.wait(0.4)
			splash.Close()
		end)
	end,
})

screens:AddButton({
	Title = "Key gate",
	Description = "Any key works except the word wrong.",
	Label = "Show",
	State = "Secondary",
	Changed = function()
		Cascade.KeyGate({
			Title = "Paste your key",
			Text = "Checked once per session. This example accepts anything except the word wrong.",
			Placeholder = "XN-0000-0000",
			Help = "Get one from the Discord.",
			Verify = function(_, key)
				if key == "wrong" then
					return false, "That key expired on 22 Aug. Get a new one."
				end

				return true
			end,
			Accepted = function()
				app:Notification({ Title = "Unlocked", Subtitle = "Welcome in.", Kind = "success" })
			end,
		})
	end,
})

print("[zircon] 5/6 screens built")

--------------------------------------------------------------------------------
-- Window options — the long form, to show what Add* is doing underneath
--------------------------------------------------------------------------------

local settings = window:Section({ Disclosure = false, Title = "Settings" })
local windowTab = settings:Tab({ Title = "Window", Icon = Cascade.Symbols.sidebarLeft })

local windowSection = windowTab:PageSection({
	Title = "Window",
	Subtitle = "Reads and writes the window itself.",
	Icon = Cascade.Symbols.sidebarLeft,
	IconColor = Color3.fromRGB(255, 163, 26),
})

for _, option in
	{
		{ key = "Searching", title = "Searchable", sub = "Search box in the titlebar." },
		{ key = "Draggable", title = "Draggable", sub = "Move the window by its titlebar." },
		{ key = "Resizable", title = "Resizable", sub = "Drag the corner to resize." },
		{ key = "Dropshadow", title = "Drop shadow", sub = "Shadow behind the window." },
		{ key = "UIBlur", title = "Background blur", sub = "Frosted glass behind the window." },
	}
do
	windowSection:AddToggle(option.key, {
		Title = option.title,
		Description = option.sub,
		Default = window[option.key],
		Changed = function(_, value)
			window[option.key] = value
		end,
	})
end

print("[zircon] 6/6 example loaded — every control is on screen")
