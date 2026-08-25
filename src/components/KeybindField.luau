local types = require("@types")

-- Shared across every field, so two features cannot quietly claim the same key.
local registry: { [Enum.KeyCode]: string } = {}

return function(self, properties: types.KeybindFieldProperties): types.KeybindFieldProperties
	--// Imports
	local binder = require("@modules/binder")
	local services = require("@modules/services")

	--// References
	local userInputService = services.UserInputService

	--// Variables
	local structures = require("@structures/TextField")(self)

	local clashToken = 0

	--// UI
	properties = properties or {}
	properties.Placeholder = properties.Placeholder or "Not bound"
	properties.Owner = properties.Owner or "another keybind"

	--// Initialize
	structures.Field.TextXAlignment = Enum.TextXAlignment.Right
	structures.Field.TextEditable = false
	structures.Body.Parent = self.__container or self.__instance or self
	structures.Body.AutomaticSize = Enum.AutomaticSize.XY
	structures.Body.Size = UDim2.fromOffset(0, 23)
	structures.Field.Size = UDim2.fromOffset(0, 23)
	structures.Corner.CornerRadius = UDim.new(0, 8)

	-- Text colour has to be written after the text: TextField repaints on every Text change.
	local function say(text: string, token)
		structures.Field.Text = text

		if token then
			structures.Field.TextColor3 = token[1].Value
			structures.Field.TextTransparency = token[2].Value
		end
	end

	local function rest()
		clashToken += 1
		say(properties.Value and properties.Value.Name or "", nil)
	end

	local function listen()
		clashToken += 1
		say("Press a key…", self.Theme.Controls.Selection)
	end

	local function clash(key: Enum.KeyCode, owner: string)
		clashToken += 1

		local token = clashToken

		say(`{key.Name} — used by {owner}`, self.Theme.Accents.Red)

		task.delay(1.8, function()
			if token == clashToken then
				rest()
			end
		end)
	end

	local object
	object = binder.Wrap(properties, {
		Placeholder = function(value: string)
			structures.Field.PlaceholderText = value
		end,
		-- Named Owner, not Label: a Label setter would be overwritten by the Label component
		-- when the component table is applied over this object.
		Owner = function(value: string)
			properties.Owner = value
		end,
		Value = function(value: Enum.KeyCode?)
			if properties.Value and registry[properties.Value] == properties.Owner then
				registry[properties.Value] = nil
			end

			properties.Value = value

			if value then
				registry[value] = properties.Owner
			end

			rest()

			if properties.ValueChanged then
				task.spawn(properties.ValueChanged, object, value)
			end
		end,
	}, structures.Body)

	structures.Field.Focused:Connect(listen)
	structures.Field.FocusLost:Connect(rest)

	userInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if input.KeyCode == properties.Value and properties.BindPressed then
			properties.BindPressed(object, input.KeyCode, false, gameProcessedEvent)
		end
	end)

	userInputService.InputEnded:Connect(function(input, gameProcessedEvent)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end

		if not structures.Field:IsFocused() then
			if input.KeyCode == properties.Value and properties.BindPressed then
				properties.BindPressed(object, input.KeyCode, true, gameProcessedEvent)
			end

			return
		end

		local key = input.KeyCode

		structures.Field:ReleaseFocus()

		-- Escape backs out and keeps whatever was bound before.
		if key == Enum.KeyCode.Escape then
			rest()
			return
		end

		if key == Enum.KeyCode.Backspace or key == Enum.KeyCode.Delete then
			object.Value = nil
			return
		end

		local owner = registry[key]

		-- Taken by someone else: refuse and say who has it, rather than double-binding in silence.
		if owner and owner ~= properties.Owner then
			clash(key, owner)
			return
		end

		object.Value = key
	end)

	object.Type = "KeybindField"
	object.Theme = self.Theme
	object.Structures = structures

	structures.Body.Destroying:Connect(function()
		if properties.Value and registry[properties.Value] == properties.Owner then
			registry[properties.Value] = nil
		end
	end)

	binder.Apply(properties, object)

	return object
end
