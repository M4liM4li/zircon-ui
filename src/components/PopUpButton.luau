local types = require("@types")

return function(self, properties: types.PopUpButtonProperties): types.PopUpButton
	--// Imports
	local creator = require("@modules/creator")
	local binder = require("@modules/binder")
	local dropdownMenu = require("@modules/dropdownMenu")

	--// References
	local create = creator.Create

	--// Constants
	local MAX_DISPLAY_LENGTH = 30
	local CHEVRON_DOWN = "rbxassetid://116067852952871"

	--// Variables
	local parent = self.__container or self.__instance or self
	local theme = self.Theme.Controls.MenuButton
	local structures = {
		Options = {},
	}
	local metrics = self.Theme.Metrics or {}
	-- Squared density draws the pop up as a bordered box with a bare chevron.
	local compact = metrics.Squared == true
	local labelFont = metrics.Mono and "rbxasset://fonts/families/Code.json" or "rbxassetid://12187365364"
	local indicatorTint = compact and self.Theme.Text.Tertiary or self.Theme.Text.Primary

	--// Private Methods
	local function truncate(text: string): string
		if #text > MAX_DISPLAY_LENGTH then
			return string.sub(text, 1, MAX_DISPLAY_LENGTH) .. "..."
		end

		return text
	end

	local function selectedMap(value)
		local map = {}

		if typeof(value) == "table" then
			for _, optionIndex in ipairs(value) do
				map[optionIndex] = true
			end
		elseif value then
			map[value] = true
		end

		return map
	end

	local function selectedLabels(value)
		local labels = {}
		local map = selectedMap(value)

		for index, option in ipairs(structures.Options) do
			local label = option and option:FindFirstChild("Label")
			if map[index] and label then
				table.insert(labels, label.Text)
			end
		end

		return labels
	end

	--// UI
	properties = properties or {}
	properties.Maximum = properties.Maximum or 1
	properties.Expanded = properties.Expanded or false
	properties.Options = properties.Options or {}

	structures.Body = binder.Apply(
		properties,
		create("TextButton")({
			Name = "PopUpButton",
			AutomaticSize = compact and Enum.AutomaticSize.X or Enum.AutomaticSize.XY,
			BackgroundColor3 = not compact and Color3.fromRGB(255, 255, 255) or nil,
			BackgroundTransparency = not compact and 1 or nil,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Selectable = false,
			Size = compact and UDim2.fromOffset(0, metrics.ControlHeight or 31) or nil,
			Text = "",
			Parent = parent,

			__dynamicKeys = compact and {
				BackgroundColor3 = self.Theme.Controls.Background[1],
				BackgroundTransparency = self.Theme.Controls.Background[2],
			} or nil,

			compact and create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, metrics.Radius or 2),
			}) or nil,

			compact and create("UIStroke")({
				Name = "UIStroke",
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 1,

				__dynamicKeys = {
					Color = self.Theme.Controls.ViewBorder[1],
					Transparency = self.Theme.Controls.ViewBorder[2],
				},
			}) or nil,

			create("UIPadding")({
				Name = "UIPadding",
				PaddingBottom = UDim.new(0, compact and 0 or 3),
				PaddingLeft = UDim.new(0, compact and 11 or 3),
				PaddingRight = UDim.new(0, compact and 11 or 3),
				PaddingTop = UDim.new(0, compact and 0 or 3),
			}),

			create("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 7),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			create("Frame")({
				Name = "PopUpIndicator",
				BackgroundTransparency = compact and 1 or nil,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Selectable = true,
				Size = compact and UDim2.fromOffset(11, 11) or UDim2.fromOffset(16, 16),

				__dynamicKeys = not compact and {
					BackgroundColor3 = theme.IndicatorBackground[1],
					BackgroundTransparency = theme.IndicatorBackground[2],
				} or nil,

				not compact and create("UICorner")({
					Name = "UICorner",
					CornerRadius = UDim.new(0, 8),
				}) or nil,

				create("ImageLabel")({
					Name = "Indicators",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Image = compact and CHEVRON_DOWN or "rbxassetid://89151647333378",
					ScaleType = compact and Enum.ScaleType.Fit or Enum.ScaleType.Stretch,
					Size = UDim2.fromScale(1, 1),

					__dynamicKeys = {
						ImageColor3 = indicatorTint[1],
						ImageTransparency = indicatorTint[2],
					},
				}),
			}),

			create("TextLabel")({
				Name = "Label",
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				FontFace = compact and Font.new(labelFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
					or Font.new(labelFont),
				RichText = true,
				Text = "None",
				TextSize = metrics.ControlTextSize or 15,
				TextTransparency = 0.15,
				TextTruncate = Enum.TextTruncate.AtEnd,

				__dynamicKeys = {
					TextColor3 = self.Theme.Text.Primary[1],
					TextTransparency = self.Theme.Text.Primary[2],
				},
			}),
		})
	) :: TextButton

	--// Initialize
	structures.PopUpIndicator = structures.Body:FindFirstChild("PopUpIndicator") :: Frame
	structures.CurrentTab = structures.Body:FindFirstChild("Label") :: TextLabel

	local object
	local menu = dropdownMenu.new(self, structures, {
		Name = "PopUpMenu",
		Anchor = properties.Anchor,
		AnchorMode = "SelectedLabel",
		ShowsCheckmarks = true,
		MaxHeight = 239,
		OnSelected = function(target, index)
			if target.Maximum and target.Maximum > 1 then
				local current = target.Value or {}
				if typeof(current) ~= "table" then
					current = current and { current } or {}
				else
					current = table.clone(current)
				end

				local foundIndex = nil
				for currentIndex, value in ipairs(current) do
					if value == index then
						foundIndex = currentIndex
						break
					end
				end

				if foundIndex then
					table.remove(current, foundIndex)
				else
					if #current < target.Maximum then
						table.insert(current, index)
					else
						table.remove(current, 1)
						table.insert(current, index)
					end
				end

				target.Value = current
			else
				target.Expanded = false
				task.wait(0.2)
				target.Value = index
			end
		end,
	})

	local function updateValue(value, fireChanged: boolean)
		local isMulti = object and object.Maximum and object.Maximum > 1

		menu:SetAnchorMode(isMulti and "BelowButton" or "SelectedLabel")
		menu:SetValue(value)

		if isMulti then
			local labels = selectedLabels(value)

			if #labels == 0 then
				structures.CurrentTab.Text = "None"
			else
				structures.CurrentTab.Text = truncate(table.concat(labels, ", "))
			end

			menu:SetSelectedMap(selectedMap(value))
		else
			local optionLabel = value and structures.Options[value] and structures.Options[value]:FindFirstChild("Label")

			if not optionLabel then
				structures.CurrentTab.Text = "None"
			else
				structures.CurrentTab.Text = truncate(optionLabel.Text)
			end

			menu:SetSelectedMap(selectedMap(value))
		end

		if fireChanged and properties.ValueChanged then
			properties.Value = value
			task.spawn(properties.ValueChanged, object, value)
		end
	end

	local bindings = {
		Anchor = function(value)
			menu:SetAnchor(value)
		end,

		Options = function(value: { [number]: string })
			menu:ClearOptions()

			for index, optionName in ipairs(value) do
				menu:AddOption(optionName, index)
			end

			if object then
				updateValue(object.Value, false)
			end
		end,

		Expanded = function(value: boolean)
			menu:SetAnchorMode(object and object.Maximum and object.Maximum > 1 and "BelowButton" or "SelectedLabel")
			menu:SetExpanded(value)
		end,

		Value = function(value)
			updateValue(value, true)
		end,
	}

	object = binder.Wrap(properties, bindings, structures.Body)

	menu:SetObject(object)

	object.Type = "PopUpButton"
	object.Theme = self.Theme
	object.Structures = structures
	object.Option = function(self, name: string?)
		local index = #structures.Options + 1
		local option = menu:AddOption(name, index)

		table.insert(object.Options, name)
		updateValue(object.Value, false)

		return option
	end
	object.Remove = function(self, index: number?)
		if index then
			menu:RemoveOption(index)
			object.Options[index] = nil
			updateValue(object.Value, false)
		end
	end

	binder.Apply(properties, object)
	updateValue(object.Value, false)

	return object
end
