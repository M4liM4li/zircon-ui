--// Imports
local utility = require("@modules/utility")
local types = require("@types")
local creator = require("@modules/creator")
local binder = require("@modules/binder")
local services = require("@modules/services")
local appRecorder = require("@modules/appRecorder")

local symbols = require("@modules/symbols")
local components = require("@components/init")

local themes = require("@themes/init")
local accents = require("@themes/accents")

--// References
local create = creator.Create

local tweenService = services.TweenService

--// Variables
local cascade = {
	Themes = themes,
	Accents = accents,
	Symbols = symbols,

	Creator = creator,
	Binder = binder,
	Components = components,
	AppRecorder = appRecorder,
}

local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
local currentTween: Tween? = nil

--// Functions
local function deepCopy(original, identifier: string?)
	local copy = {}
	for key, value in pairs(original) do
		local vType = typeof(value)
		if vType == "table" then
			if value.Value ~= nil and value.Connect and typeof(value.Connect) == "function" then
				copy[key] = creator.Value(value.Value)
			else
				copy[key] = deepCopy(value)
			end
		else
			copy[key] = value
		end
	end

	if identifier and not original._id then
		original._id = identifier
	end

	return copy
end

local function parseAccent(theme, overrides)
	for key, override in pairs(overrides) do
		local themeObj = theme[key]

		if not themeObj and type(theme) == "table" and type(theme.Controls) == "table" then
			themeObj = theme.Controls[key]
		end

		if not themeObj then
			continue
		end

		if type(themeObj) == "table" and themeObj.Connect then
			themeObj.Value = override
		elseif type(themeObj) == "table" and themeObj[1] and themeObj[1].Connect and typeof(override) == "Color3" then
			themeObj[1].Value = override
		elseif type(themeObj) == "table" and type(override) == "table" then
			parseAccent(themeObj, override)
		end
	end
end

-- Compact trades the subtitles and the row breathing room for more rows on screen.
-- Runs after every theme update, since those copy the base metrics back in.
local function applyDensity(theme, density: string?)
	if density ~= "Compact" or type(theme) ~= "table" or type(theme.Metrics) ~= "table" then
		return
	end

	theme.Metrics.RowPadding = 8
	theme.Metrics.TitleSize = 15
	theme.Metrics.SubtitleVisible = true
	theme.Metrics.Mono = true
	theme.Metrics.Squared = true
	theme.Metrics.Radius = 8
	theme.Metrics.ControlHeight = 30
	theme.Metrics.ControlTextSize = 14
	theme.Metrics.SectionTitleSize = 18

	local controls = theme.Controls

	local function paint(token, hex: string, alpha: number?)
		if not token or not token[1] then
			return
		end

		token[1].Value = Color3.fromHex(hex)

		if alpha and token[2] then
			token[2].Value = 1 - (alpha / 100)
		end
	end

	-- True black, fully opaque. Any translucency mixes the lit scene behind the window into
	-- the fill and reads as grey, so the window stays solid.
	paint(controls.Background, "050506", 100)
	paint(controls.View, "131315", 100)
	paint(controls.ViewBorder, "242427", 100)
	paint(controls.Sidebar, "000000", 100)
	paint(controls.Titlebar, "000000", 100)
	paint(controls.Separator and controls.Separator.Background, "242427", 100)

	-- Text ramp stays bright so it holds up against the black.
	paint(theme.Text and theme.Text.Primary, "F7F7F9", 97)
	paint(theme.Text and theme.Text.Secondary, "9EA1A8", 94)
	paint(theme.Text and theme.Text.Tertiary, "6E7178", 96)

	paint(controls.StatTile and controls.StatTile.Surface, "141416", 100)
	paint(controls.StatTile and controls.StatTile.Border, "242427", 100)
	paint(controls.StatTile and controls.StatTile.Label, "7E8188", 100)
	paint(controls.StatTile and controls.StatTile.Delta, "4ADE80", 100)
	paint(controls.StatTile and controls.StatTile.Track, "242427", 100)

	paint(controls.Badge and controls.Badge.Background, "242427", 70)
	paint(controls.Badge and controls.Badge.BackgroundActive, "FFA31A", 18)
	paint(controls.Badge and controls.Badge.Text, "7E8188", 100)
	paint(controls.Badge and controls.Badge.TextActive, "FFA31A", 100)

	paint(controls.Toggle and controls.Toggle.SwitchOff, "323235", 100)

	-- Secondary control surfaces — one step off black, no further.
	paint(controls.Stepper and controls.Stepper.Background, "141416", 100)
	paint(controls.RadioButtonGroup and controls.RadioButtonGroup.Background, "141416", 100)
	paint(controls.MenuButton and controls.MenuButton.MenuBackground, "0D0D0F", 100)
	paint(controls.Slider and controls.Slider.Track, "242427", 100)
	paint(controls.ScrollBar, "6E6E73", 30)

	if controls.Button and controls.Button.FillSecondary then
		controls.Button.FillSecondary.Value = ColorSequence.new(Color3.fromHex("1E1E21"), Color3.fromHex("161619"))
	end

	paint(theme.Accents and theme.Accents.Red, "F87171", 100)
	paint(theme.Accents and theme.Accents.Warning, "FBBF24", 100)
	paint(theme.Accents and theme.Accents.Green, "4ADE80", 100)

	-- One accent everywhere: the stripe, the toggle, the progress fill and the primary button.
	local accent = controls.SwitchAccent and controls.SwitchAccent[1].Value

	if accent then
		paint(controls.Selection, accent:ToHex(), 100)
		paint(controls.SelectionFocused, accent:ToHex(), 18)
		paint(controls.SelectionStroke, accent:ToHex(), 70)
		paint(controls.Toggle and controls.Toggle.SwitchOn, accent:ToHex(), 100)
	end
end

local function updateThemes(target, theme, accent)
	local function deepUpdate(target, new)
		for key, value in pairs(new) do
			if type(value) ~= "table" then
				-- Plain metrics (numbers, booleans) are copied as-is, they hold no value state.
				if type(target) == "table" and type(target[key]) ~= "table" then
					target[key] = value
				end
			elseif type(target[key]) == "table" and not value.Value then
				deepUpdate(target[key], value)
			elseif target[key] and value.Value ~= nil then
				target[key].Value = value.Value
			end
		end
	end
	deepUpdate(target, theme)

	if accent and accent[theme._id] then
		parseAccent(target, accent[theme._id])
	end
end

--// Initialize
cascade.New = function(properties: types.AppProperties): types.App
	if not game:IsLoaded() then
		game.Loaded:Wait()
	end

	properties = properties or {}

	local initialTheme = properties.Theme or themes.Dark
	local initialAccent = properties.Accent or accents.Amber

	local currentBaseTheme = initialTheme

	properties.Theme = deepCopy(initialTheme)
	properties.Accent = deepCopy(initialAccent)

	updateThemes(properties.Theme, initialTheme, initialAccent)
	applyDensity(properties.Theme, properties.Density or "Compact")

	local container = utility.ProtectUI(create("ScreenGui")({
		Name = "Cascade",
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 2147483646,

		OnTopOfCoreBlur = true,
	})) :: ScreenGui

	local pill = create("ImageButton")({
		Name = "WindowPill",
		AnchorPoint = Vector2.new(0.5, 0),
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Image = "rbxassetid://93520763686656",
		ImageTransparency = 0.5,
		Position = UDim2.new(0.5, 0, 0, 10),
		Size = UDim2.fromOffset(180, 5),
		Parent = container.__instance,

		create("UICorner")({
			Name = "UICorner",
			CornerRadius = UDim.new(1, 0),
		}),
	}) :: ImageButton

	pill.MouseEnter:Connect(function()
		if currentTween then
			currentTween:Cancel()
		end

		currentTween = tweenService:Create(pill.__instance, tweenInfo, {
			ImageTransparency = 0.15,
		})

		if currentTween then
			currentTween:Play()
		end
	end)

	pill.MouseLeave:Connect(function()
		if currentTween then
			currentTween:Cancel()
		end

		currentTween = tweenService:Create(pill.__instance, tweenInfo, {
			ImageTransparency = 0.5,
		})

		if currentTween then
			currentTween:Play()
		end
	end)

	local object = binder.Wrap(properties, {
		WindowPill = function(value: boolean)
			pill.Visible = value
		end,
		-- Same Density default as New. Without it, passing an explicit Theme copies the raw
		-- theme back over the skin and applyDensity bails out, leaving the window unpainted.
		Theme = function(newTheme)
			currentBaseTheme = newTheme
			updateThemes(properties.Theme, newTheme, properties.Accent)
			applyDensity(properties.Theme, properties.Density or "Compact")
		end,
		Accent = function(newAccent)
			properties.Accent = deepCopy(newAccent, newAccent._id)
			updateThemes(properties.Theme, currentBaseTheme, newAccent)
			applyDensity(properties.Theme, properties.Density or "Compact")
		end,
	}, container, { "Theme", "Accent" })

	object.Structures = {
		WindowPill = pill,
	}

	setmetatable(properties, { __index = components })

	binder.Apply(properties, object)
	task.defer(binder.Apply, properties, object)

	return object
end

cascade.Component = function(properties: types.ComponentProperties?): types.ComponentContext
	properties = properties or {}

	local initialTheme = properties.Theme or themes.Dark
	local initialAccent = properties.Accent or accents.Amber

	local currentBaseTheme = initialTheme

	properties.Theme = deepCopy(initialTheme)
	properties.Accent = deepCopy(initialAccent)

	updateThemes(properties.Theme, initialTheme, initialAccent)
	applyDensity(properties.Theme, properties.Density or "Compact")

	local object = binder.Wrap(properties, {
		Theme = function(newTheme)
			currentBaseTheme = newTheme
			updateThemes(properties.Theme, newTheme, properties.Accent)
			applyDensity(properties.Theme, properties.Density or "Compact")
		end,
		Accent = function(newAccent)
			properties.Accent = deepCopy(newAccent, newAccent._id)
			updateThemes(properties.Theme, currentBaseTheme, newAccent)
			applyDensity(properties.Theme, properties.Density or "Compact")
		end,
	}, nil, { "Theme", "Accent" })

	if properties.Parent then
		object.__container = properties.Parent
	end

	setmetatable(properties, { __index = components })

	binder.Apply(properties, object)
	task.defer(binder.Apply, properties, object)

	return object
end

-- Screens that have to exist before the app does: they carry their own ScreenGui, so they can
-- run while the window is still being built, or instead of it.
local function screen(name: string)
	return function(properties)
		properties = properties or {}

		local container = utility.ProtectUI(create("ScreenGui")({
			Name = "Cascade" .. name,
			IgnoreGuiInset = true,
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			DisplayOrder = 2147483647,

			OnTopOfCoreBlur = true,
		}))

		local context = cascade.Component({
			Theme = properties.Theme,
			Accent = properties.Accent,
			Density = properties.Density,
			Parent = container.__instance or container,
		})

		local object = context[name](context, properties)
		local close = object.Close

		object.Close = function(...)
			if close then
				close(...)
			end

			container:Destroy()
		end

		return object
	end
end

cascade.Splash = screen("Splash")
cascade.KeyGate = screen("KeyGate")

-- Values registered by the one-call Add* rows, keyed by flag, mirroring Options[flag].Value.
cascade.Options = require("@components/Fields").Options

cascade.OnChanged = function(handler: (flag: string, value: any) -> ())
	require("@components/Fields").OnChanged = handler
end

-- The call shape the existing hub scripts already use, so one can move over without a rewrite.
local compat = require("@modules/compat")

cascade.Collection = compat
cascade.FunctionTask = compat.FunctionTask
cascade.Library = compat

-- Loops tied to switches: the flag decides when they run, and a broken one marks its own row.
local tasks = require("@modules/tasks")

cascade.Tasks = tasks

cascade.Task = function(flag: string, interval: number, work: () -> (), options: { [string]: any }?)
	tasks.Register(flag, interval, work, options)
end

cascade.StopTasks = function()
	tasks.StopAll()
end

cascade.RegisterComponent = function(name: string, make: (self: any, properties: any) -> any)
	components.register(name, make)
end

cascade.AppDump = function(app: types.App, options: { [string]: any }?)
	return appRecorder.DumpApp(app, options)
end

return cascade
