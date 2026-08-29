--[[
	The shape the hub scripts already speak.

		local Section = Tabs.General:AddSection({ Title = "…" })
		Collection:AddToggle(Section, "Flag", { Title = …, Description = …, Default = false })
		Collection:AddDropdown(Path, "Flag", { Title = …, Values = {…}, Default = …, Multi = true })
		Collection:AddSlider(Path, "Flag", { Title = …, Default = 1, Min = 1, Max = 100 })

		FunctionTask["Flag"] = function() while true do … end end
		Collection:RunTasks()

	Everything routes to the components underneath; the point is that a script written against the
	old library keeps its call sites. Values go in and come back as values — the index juggling that
	dropdowns want is handled here rather than at every call site.
]]

local fields = require("@components/Fields")

local compat = {}

compat.Options = fields.Options
compat.FunctionTask = {}

-- Mirrors of the flags the old loops break on, so `if Library.Unloaded or Collection.UnLoaded
-- or Collection.BreakLoop then break end` keeps working untouched.
compat.UnLoaded = false
compat.BreakLoop = false

local function indexOf(list, value)
	for index, entry in ipairs(list or {}) do
		if entry == value then
			return index
		end
	end

	return nil
end

-- Wraps a control so the old :OnChanged / :SetValue / :SetValues calls still land.
local function wrap(control, flag: string, decode: ((any) -> any)?)
	local handlers = {}

	local shim = setmetatable({
		Control = control,
		Flag = flag,
	}, { __index = control })

	function shim:OnChanged(handler)
		table.insert(handlers, handler)
		return shim
	end

	function shim:SetValue(value)
		control.Value = value
		return shim
	end

	function shim:SetValues(values)
		control.Options = values
		return shim
	end

	fields.Watch(function(changed, value)
		if changed ~= flag then
			return
		end

		local decoded = decode and decode(value) or value

		fields.Options[flag].Value = decoded

		for _, handler in handlers do
			task.spawn(handler, decoded)
		end
	end)

	return shim
end

--// Publish
function compat:AddToggle(path, flag: string, configuration)
	configuration = configuration or {}

	local control = path:AddToggle(flag, {
		Title = configuration.Title,
		Description = configuration.Description,
		Default = configuration.Default,
	})

	return wrap(control, flag)
end

function compat:AddSlider(path, flag: string, configuration)
	configuration = configuration or {}

	local control = path:AddSlider(flag, {
		Title = configuration.Title,
		Description = configuration.Description,
		Default = configuration.Default,
		Minimum = configuration.Min or configuration.Minimum or 0,
		Maximum = configuration.Max or configuration.Maximum or 100,
		Step = configuration.Decimal or configuration.Step,
	})

	return wrap(control, flag)
end

function compat:AddInput(path, flag: string, configuration)
	configuration = configuration or {}

	local control = path:AddInput(flag, {
		Title = configuration.Title,
		Description = configuration.Description,
		Default = configuration.Default,
		Placeholder = configuration.Placeholder,
	})

	return wrap(control, flag)
end

-- Values in, values out. The old scripts store the chosen strings, not their positions.
function compat:AddDropdown(path, flag: string, configuration)
	configuration = configuration or {}

	local values = configuration.Values or configuration.Options or {}
	local multi = configuration.Multi == true
	local default = configuration.Default

	local start

	if multi then
		start = {}

		for _, value in ipairs(type(default) == "table" and default or { default }) do
			local index = indexOf(values, value)

			if index then
				table.insert(start, index)
			end
		end
	else
		start = indexOf(values, type(default) == "table" and default[1] or default) or 1
	end

	local control = path:AddDropdown(flag, {
		Title = configuration.Title,
		Description = configuration.Description,
		Options = values,
		Default = start,
		Maximum = multi and #values or 1,
	})

	local function decode(value)
		if not multi then
			return values[value]
		end

		local picked = {}

		for _, index in ipairs(type(value) == "table" and value or { value }) do
			table.insert(picked, values[index])
		end

		return picked
	end

	fields.Options[flag].Value = decode(start)

	return wrap(control, flag, decode)
end

function compat:AddStepper(path, flag: string, configuration)
	configuration = configuration or {}

	local control = path:AddStepper(flag, {
		Title = configuration.Title,
		Description = configuration.Description,
		Default = configuration.Default,
		Minimum = configuration.Min or configuration.Minimum or 0,
		Maximum = configuration.Max or configuration.Maximum or 100,
		Step = configuration.Step or 1,
		Fielded = configuration.Fielded ~= false,
	})

	return wrap(control, flag)
end

function compat:AddKeybind(path, flag: string, configuration)
	configuration = configuration or {}

	local control = path:AddKeybind(flag, {
		Title = configuration.Title,
		Description = configuration.Description,
		Default = configuration.Default,
		Owner = configuration.Owner or configuration.Title,
		BindPressed = configuration.BindPressed,
	})

	return wrap(control, flag)
end

function compat:AddColorPicker(path, flag: string, configuration)
	configuration = configuration or {}

	local control = path:AddColorPicker(flag, {
		Title = configuration.Title,
		Description = configuration.Description,
		Default = configuration.Default,
	})

	return wrap(control, flag)
end

function compat:AddRadio(path, flag: string, configuration)
	configuration = configuration or {}

	local values = configuration.Values or configuration.Options or {}

	local control = path:AddRadio(flag, {
		Title = configuration.Title,
		Description = configuration.Description,
		Options = values,
		Default = indexOf(values, configuration.Default) or 1,
	})

	fields.Options[flag].Value = configuration.Default or values[1]

	return wrap(control, flag, function(value)
		return values[value]
	end)
end

function compat:AddButton(path, configuration)
	configuration = configuration or {}

	return path:AddButton({
		Title = configuration.Title,
		Description = configuration.Description,
		Label = configuration.Label or configuration.Button or "Run",
		State = configuration.State or "Primary",
		Changed = configuration.Callback or configuration.Changed or configuration.Pushed,
	})
end

function compat:AddLabel(path, flag: string, configuration)
	configuration = configuration or {}

	return path:AddLabel(flag, {
		Title = configuration.Title,
		Description = configuration.Description,
		Text = configuration.Default or configuration.Text or "",
	})
end

-- Starts every registered loop. The loops check their own flag, so there is nothing to wait for.
function compat:RunTasks()
	for name, work in pairs(compat.FunctionTask) do
		task.spawn(function()
			local ok, err = pcall(work)

			if not ok then
				warn("[" .. tostring(name) .. "] stopped: " .. tostring(err))
			end
		end)
	end
end

function compat:StopTasks()
	compat.BreakLoop = true
	compat.UnLoaded = true
end

return compat
