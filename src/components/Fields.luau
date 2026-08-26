--[[
	One-call rows.

	The long form builds a Row, a TitleStack and a control by hand — three or four lines for one
	switch, and a page of forty switches is a hundred and sixty lines of scaffolding. These wrap
	that into a single call, register the value under a flag, and report changes to one hook.

	The Add prefix is load-bearing: a method named Toggle would collide with the Toggle component,
	which is applied over every object after it is built.
]]

local options = {}
local rows = {}
local listeners = {}

local registry = { Options = options, Rows = rows, OnChanged = nil :: ((string, any) -> ())? }

-- Anything that needs to react to a switch subscribes here; the task runner is the first customer.
function registry.Watch(handler: (flag: string, value: any) -> ())
	table.insert(listeners, handler)
end

local function split(properties)
	properties = properties or {}

	local control = {}

	for key, value in pairs(properties) do
		control[key] = value
	end

	-- Row-level keys never reach the control.
	control.Title = nil
	control.Description = nil
	control.Default = nil
	control.Flag = nil
	control.Locked = nil
	control.SearchIndex = nil
	control.Changed = nil

	return control
end

local function build(self, flag, properties, make)
	if type(flag) == "table" then
		properties = flag
		flag = properties.Flag
	end

	properties = properties or {}

	-- One form per section, not one per row: the form is what draws the hairline between
	-- consecutive rows, and a form holding a single row has nothing to draw it against.
	local form = properties.Form

	if not form then
		if self.Type == "Form" then
			form = self
		else
			form = self.__fieldsForm

			if not form then
				form = self:Form()
				self.__fieldsForm = form
			end
		end
	end
	local row = form:Row({ SearchIndex = properties.SearchIndex or properties.Title or flag })

	row:Left():TitleStack({
		Title = properties.Title or flag or "Option",
		Subtitle = properties.Description or "",
	})

	if properties.Locked then
		row.Locked = properties.Locked
	end

	local control = make(row:Right(), split(properties), properties)

	if flag then
		options[flag] = options[flag] or { Value = nil }
		options[flag].Value = properties.Default
		rows[flag] = row
	end

	control.Row = row
	control.Flag = flag

	return control, row
end

-- Every field reports the same way: store under the flag, then tell the one hook.
local function report(flag, value, changed, control)
	if flag then
		options[flag] = options[flag] or { Value = nil }
		options[flag].Value = value
	end

	if changed then
		task.spawn(changed, control, value)
	end

	if flag and registry.OnChanged then
		task.spawn(registry.OnChanged, flag, value)
	end

	if flag then
		for _, handler in listeners do
			task.spawn(handler, flag, value)
		end
	end
end

local function valued(builder: string)
	return function(self, flag, properties)
		local control, row

		control, row = build(self, flag, properties, function(right, config, source)
			config.Value = source.Default

			local outer = source.Changed or config.ValueChanged

			config.ValueChanged = function(_, value)
				report(control and control.Flag or nil, value, outer, control)
			end

			return right[builder](right, config)
		end)

		return control, row
	end
end

registry.AddToggle = valued("Toggle")
registry.AddSlider = valued("Slider")
registry.AddStepper = valued("Stepper")
registry.AddInput = valued("TextField")
registry.AddKeybind = valued("KeybindField")
registry.AddRadio = valued("RadioButtonGroup")
registry.AddColorPicker = valued("ColorPicker")

registry.AddDropdown = function(self, flag, properties)
	local control, row

	control, row = build(self, flag, properties, function(right, config, source)
		config.Options = source.Values or source.Options
		config.Value = source.Default

		-- Multi mirrors the flag most hubs already pass; Maximum is what the control speaks.
		if source.Multi and not config.Maximum then
			config.Maximum = #(config.Options or {})
		end

		config.Values = nil
		config.Multi = nil

		local outer = source.Changed or config.ValueChanged

		config.ValueChanged = function(_, value)
			report(control and control.Flag or nil, value, outer, control)
		end

		return right:PopUpButton(config)
	end)

	return control, row
end

registry.AddButton = function(self, flag, properties)
	local control, row

	control, row = build(self, flag, properties, function(right, config, source)
		config.Label = source.Label or source.Button or "Run"
		config.State = source.State or "Primary"

		local outer = source.Changed or config.Pushed

		config.Pushed = function(button)
			if outer then
				task.spawn(outer, button)
			end
		end

		config.Button = nil

		return right:Button(config)
	end)

	return control, row
end

registry.AddLabel = function(self, flag, properties)
	local control, row

	control, row = build(self, flag, properties, function(right, config, source)
		config.Text = source.Default or source.Text or ""

		return right:Label(config)
	end)

	return control, row
end

return registry
