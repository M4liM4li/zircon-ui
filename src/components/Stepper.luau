local types = require("@types")

return function(self, properties: types.StepperProperties): types.Stepper
	--// Imports
	local creator = require("@modules/creator")
	local binder = require("@modules/binder")

	local textField = require("@structures/TextField")

	--// References
	local create = creator.Create

	--// Constants
	local CHEVRON_UP = "rbxassetid://71994936177602"
	local CHEVRON_DOWN = "rbxassetid://116067852952871"

	--// Variables
	local parent = self.__container or self.__instance or self
	local theme = self.Theme.Controls.Stepper
	local structures = {}
	local metrics = self.Theme.Metrics or {}
	-- Squared density folds the field and the arrows into a single bordered box.
	local compact = metrics.Squared == true
	local controlHeight = metrics.ControlHeight or 31
	local fieldFont = metrics.Mono and "rbxasset://fonts/families/Code.json" or "rbxassetid://12187365364"

	local holding = false
	local stepConnections = {}
	local repeatDelay = 0.35
	local repeatInterval = 0.083

	--// Functions
	local function getPrecision(step)
		local stepStr = tostring(step)
		local dot = string.find(stepStr, "%.")
		local precision = 0

		if dot then
			precision = #stepStr - dot
		end

		return precision
	end

	local function stepFormat(value, step)
		local stepPrecision = getPrecision(step)
		local valuePrecision = getPrecision(value)

		local displayPrecision = math.max(stepPrecision, valuePrecision)

		local formatStr = "%." .. displayPrecision .. "f"
		return string.format(formatStr, value)
	end

	local function round(value, decimals)
		local mult = 10 ^ (decimals or 0)
		return math.floor(value * mult + 0.5) / mult
	end

	--// UI
	properties = properties or {}
	properties.Value = properties.Value or 0
	properties.Step = properties.Step or 0.1
	properties.Maximum = properties.Maximum or 1
	properties.Minimum = properties.Minimum or 0
	properties.Fielded = properties.Fielded or false

	local function denseBody()
		-- One bordered box: number field, hairline rule, then the arrow column.
		return create("ImageLabel")({
			Name = "Stepper",
			AutomaticSize = Enum.AutomaticSize.X,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Image = "",
			Size = UDim2.fromOffset(0, controlHeight),
			Parent = parent,

			__dynamicKeys = {
				BackgroundColor3 = self.Theme.Controls.Background[1],
				BackgroundTransparency = self.Theme.Controls.Background[2],
			},

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, metrics.Radius or 2),
			}),

			create("UIStroke")({
				Name = "UIStroke",
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 1,

				__dynamicKeys = {
					Color = self.Theme.Controls.ViewBorder[1],
					Transparency = self.Theme.Controls.ViewBorder[2],
				},
			}),

			create("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			create("Frame")({
				Name = "Divider",
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Size = UDim2.new(0, 1, 1, 0),

				__dynamicKeys = {
					BackgroundColor3 = theme.Separator[1],
					BackgroundTransparency = theme.Separator[2],
				},
			}),

			create("Frame")({
				Name = "Arrows",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				LayoutOrder = 2,
				Size = UDim2.new(0, 20, 1, 0),

				create("UIListLayout")({
					Name = "UIListLayout",
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				create("ImageButton")({
					Name = "Up",
					AutoButtonColor = false,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Image = "",
					Size = UDim2.fromOffset(20, 14.5),

					__dynamicKeys = {
						ImageColor3 = self.Theme.Text.Primary[1],
						ImageTransparency = self.Theme.Text.Primary[2],
					},

					__contextKeys = {
						ImageColor3 = function()
							if properties.Value >= properties.Maximum then
								return self.Theme.Text.Tertiary[1].Value
							else
								return self.Theme.Text.Primary[1].Value
							end
						end,
						ImageTransparency = function()
							if properties.Value >= properties.Maximum then
								return self.Theme.Text.Tertiary[2].Value
							else
								return self.Theme.Text.Primary[2].Value
							end
						end,
					},

					create("ImageLabel")({
						Name = "Glyph",
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Image = CHEVRON_UP,
						Position = UDim2.fromScale(0.5, 0.5),
						ScaleType = Enum.ScaleType.Fit,
						Size = UDim2.fromOffset(9, 9),
					}),
				}),

				create("Frame")({
					Name = "Rule",
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					LayoutOrder = 1,
					Size = UDim2.new(1, 0, 0, 1),

					__dynamicKeys = {
						BackgroundColor3 = theme.Separator[1],
						BackgroundTransparency = theme.Separator[2],
					},
				}),

				create("ImageButton")({
					Name = "Down",
					AutoButtonColor = false,
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Image = "",
					LayoutOrder = 2,
					Size = UDim2.fromOffset(20, 14.5),

					__dynamicKeys = {
						ImageColor3 = self.Theme.Text.Primary[1],
						ImageTransparency = self.Theme.Text.Primary[2],
					},

					__contextKeys = {
						ImageColor3 = function()
							if properties.Value <= properties.Minimum then
								return self.Theme.Text.Tertiary[1].Value
							else
								return self.Theme.Text.Primary[1].Value
							end
						end,
						ImageTransparency = function()
							if properties.Value <= properties.Minimum then
								return self.Theme.Text.Tertiary[2].Value
							else
								return self.Theme.Text.Primary[2].Value
							end
						end,
					},

					create("ImageLabel")({
						Name = "Glyph",
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						Image = CHEVRON_DOWN,
						Position = UDim2.fromScale(0.5, 0.5),
						ScaleType = Enum.ScaleType.Fit,
						Size = UDim2.fromOffset(9, 9),
					}),
				}),
			}),
		})
	end

	local function macBody()
		return create("ImageLabel")({
			Name = "Stepper",
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Image = "rbxassetid://85888499115674",
			Size = UDim2.fromOffset(13, 20),
			Parent = parent,

			__dynamicKeys = {
				ImageColor3 = theme.Background[1],
				ImageTransparency = theme.Background[2],
			},

			create("ImageLabel")({
				Name = "Shadow",
				BackgroundTransparency = 1,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Image = "rbxassetid://105571270097608",
				LayoutOrder = 1,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(19, 27),

				__dynamicKeys = {
					ImageColor3 = theme.Dropshadow[1],
					ImageTransparency = theme.Dropshadow[2],
				},
			}),

			create("ImageButton")({
				Name = "Up",
				AutoButtonColor = false,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Image = "rbxassetid://133515997946294",
				Size = UDim2.new(1, 0, 0, 9),
				Position = UDim2.fromOffset(0, 1),

				__dynamicKeys = {
					ImageColor3 = self.Theme.Text.Primary[1],
					ImageTransparency = self.Theme.Text.Primary[2],
				},

				__contextKeys = {
					ImageColor3 = function()
						if properties.Value >= properties.Maximum then
							return self.Theme.Text.Tertiary[1].Value
						else
							return self.Theme.Text.Primary[1].Value
						end
					end,
					ImageTransparency = function()
						if properties.Value >= properties.Maximum then
							return self.Theme.Text.Tertiary[2].Value
						else
							return self.Theme.Text.Primary[2].Value
						end
					end,
				},
			}),

			create("ImageButton")({
				Name = "Down",
				AnchorPoint = Vector2.new(0, 1),
				AutoButtonColor = false,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Image = "rbxassetid://83836660987173",
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.new(1, 0, 0, 9),

				__dynamicKeys = {
					ImageColor3 = self.Theme.Text.Primary[1],
					ImageTransparency = self.Theme.Text.Primary[2],
				},

				__contextKeys = {
					ImageColor3 = function()
						if properties.Value <= properties.Minimum then
							return self.Theme.Text.Tertiary[1].Value
						else
							return self.Theme.Text.Primary[1].Value
						end
					end,
					ImageTransparency = function()
						if properties.Value <= properties.Minimum then
							return self.Theme.Text.Tertiary[2].Value
						else
							return self.Theme.Text.Primary[2].Value
						end
					end,
				},
			}),

			create("Frame")({
				Name = "Top",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, 6),
				Size = UDim2.new(1, 0, 0, 4),
				ZIndex = 0,

				create("UIGradient")({
					Name = "UIGradient",
					Rotation = 90,
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.949),
						NumberSequenceKeypoint.new(1, 0.949),
					}),

					__dynamicKeys = {
						Color = theme.SegmentShadow,
					},
				}),
			}),

			create("Frame")({
				Name = "Separator",
				AnchorPoint = Vector2.new(0, 0.5),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.new(1, 0, 0, 1),
				ZIndex = 0,

				__dynamicKeys = {
					BackgroundColor3 = theme.Separator[1],
					BackgroundTransparency = theme.Separator[2],
				},
			}),

			create("Frame")({
				Name = "Bottom",
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromOffset(0, 10),
				Size = UDim2.new(1, 0, 0, 4),
				ZIndex = 0,

				create("UIGradient")({
					Name = "UIGradient",
					Rotation = -90,
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0.949),
						NumberSequenceKeypoint.new(1, 0.949),
					}),

					__dynamicKeys = {
						Color = theme.SegmentShadow,
					},
				}),
			}),

			create("Frame")({
				Name = "Filler",
				AnchorPoint = Vector2.new(0, 0.5),
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.new(1, 0, 0, 2),
				ZIndex = 0,

				__dynamicKeys = {
					BackgroundColor3 = theme.Filler[1],
					BackgroundTransparency = theme.Filler[2],
				},
			}),
		})
	end

	structures.Body = binder.Apply(properties, (compact and denseBody or macBody)()) :: ImageLabel

	--// Initialize
	structures.Arrows = compact and structures.Body:FindFirstChild("Arrows") or nil
	structures.Divider = compact and structures.Body:FindFirstChild("Divider") or nil
	structures.IPlus = (structures.Arrows or structures.Body):FindFirstChild("Up") :: ImageButton
	structures.IMinus = (structures.Arrows or structures.Body):FindFirstChild("Down") :: ImageButton

	structures.Field = textField(self)

	if compact then
		-- The 9x9 glyphs are drawn inside the arrows, so they follow the button tint.
		local function mirror(button: ImageButton)
			local glyph = button:FindFirstChild("Glyph") :: ImageLabel

			local function sync()
				glyph.ImageColor3 = button.ImageColor3
				glyph.ImageTransparency = button.ImageTransparency
			end

			button:GetPropertyChangedSignal("ImageColor3"):Connect(sync)
			button:GetPropertyChangedSignal("ImageTransparency"):Connect(sync)
			sync()
		end

		mirror(structures.IPlus)
		mirror(structures.IMinus)

		-- The field is the left half of the box, so it drops its own chrome.
		structures.Field.Stroke.Enabled = false
		structures.Field.Corner.CornerRadius = UDim.new(0, 8)
		structures.Field.Padding.PaddingLeft = UDim.new(0, 0)
		structures.Field.Padding.PaddingRight = UDim.new(0, 0)
		structures.Field.Body.AutomaticSize = Enum.AutomaticSize.None
		structures.Field.Body.Size = UDim2.fromOffset(46, controlHeight - 2)
		structures.Field.Field.AutomaticSize = Enum.AutomaticSize.None
		structures.Field.Field.Size = UDim2.fromScale(1, 1)
		structures.Field.Field.FontFace = Font.new(fieldFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
		structures.Field.Field.TextSize = metrics.ControlTextSize or 13.5
		structures.Field.Field.TextXAlignment = Enum.TextXAlignment.Center
		structures.Field.FieldPadding:Destroy()
		structures.Field.Body.Parent = structures.Body.__instance
	else
		structures.Field.Padding.PaddingBottom = UDim.new(0, 2)
		structures.Field.Padding.PaddingTop = UDim.new(0, 2)
		structures.Field.Padding.PaddingRight = UDim.new(0, 2)
		structures.Field.Body.Size = UDim2.fromOffset(0, 23)
		structures.Field.Field.Size = UDim2.fromOffset(0, 0)
		structures.Field.Corner.CornerRadius = UDim.new(0, 8)
		structures.Field.FieldPadding:Destroy()
	end

	local object
	local bindings = {
		Fielded = function(value: boolean)
			if compact then
				-- Nothing to reparent: the field already lives inside the box.
				structures.Field.Body.Visible = value
				structures.Divider.Visible = value
				return
			end

			if value then
				structures.Field.Body.Parent = parent
				structures.Body.Parent = structures.Field.Body.__instance
				structures.Body.LayoutOrder = 1
			else
				structures.Field.Body.Parent = nil
				structures.Body.Parent = parent
				structures.Body.LayoutOrder = 0
			end
		end,
		Value = function(value: number)
			if value <= properties.Minimum then
				structures.IMinus.ImageColor3 = self.Theme.Text.Tertiary[1].Value
				structures.IMinus.ImageTransparency = self.Theme.Text.Tertiary[2].Value
				structures.IMinus.Interactable = false
			else
				structures.IMinus.ImageColor3 = self.Theme.Text.Primary[1].Value
				structures.IMinus.ImageTransparency = self.Theme.Text.Primary[2].Value
				structures.IMinus.Interactable = true
			end

			if value >= properties.Maximum then
				structures.IPlus.ImageColor3 = self.Theme.Text.Tertiary[1].Value
				structures.IPlus.ImageTransparency = self.Theme.Text.Tertiary[2].Value
				structures.IPlus.Interactable = false
			else
				structures.IPlus.ImageColor3 = self.Theme.Text.Primary[1].Value
				structures.IPlus.ImageTransparency = self.Theme.Text.Primary[2].Value
				structures.IPlus.Interactable = true
			end

			if structures.Field then
				structures.Field.Field.Text = stepFormat(value, properties.Step)
			end

			if properties.ValueChanged then
				properties.Value = value
				task.spawn(properties.ValueChanged, object, value)
			end
		end,
	}

	object = binder.Wrap(properties, bindings, structures.Body)

	object.Type = "Stepper"
	object.Theme = self.Theme
	object.Structures = structures
	object.Increment = function()
		assert(properties.Minimum)
		assert(properties.Maximum)

		local precision = math.max(getPrecision(object.Value), getPrecision(properties.Step))
		local rawValue = object.Value + properties.Step
		local newValue = round(rawValue, precision)

		object.Value = math.clamp(newValue, properties.Minimum, properties.Maximum)
	end

	object.Decrement = function()
		assert(properties.Minimum)
		assert(properties.Maximum)

		local precision = math.max(getPrecision(object.Value), getPrecision(properties.Step))
		local rawValue = object.Value - properties.Step
		local newValue = round(rawValue, precision)

		object.Value = math.clamp(newValue, properties.Minimum, properties.Maximum)
	end

	local function stepStart(direction: string)
		holding = true

		local action = (direction == "Up") and object.Increment or object.Decrement

		stepConnections[direction] = task.spawn(function()
			if  holding then
				task.wait(repeatDelay)
			end

			if not  holding then return end

			action()

			while  holding do
				task.wait(repeatInterval)
				if  holding then
					action()
				end
			end
		end)
	end

	local function stepStop(direction: string)
		 holding = false
		if stepConnections[direction] then
			task.cancel(stepConnections[direction])
			stepConnections[direction] = nil
		end
	end

	structures.IPlus.MouseButton1Down:Connect(function()
		object.Increment()
		stepStart("Up")
	end)
	structures.IPlus.MouseButton1Up:Connect(function()
		stepStop("Up")
	end)
	structures.IPlus.MouseLeave:Connect(function()
		stepStop("Up")
	end)

	structures.IMinus.MouseButton1Down:Connect(function()
		object.Decrement()
		stepStart("Down")
	end)
	structures.IMinus.MouseButton1Up:Connect(function()
		stepStop("Down")
	end)
	structures.IMinus.MouseLeave:Connect(function()
		stepStop("Down")
	end)

	structures.Body.AncestryChanged:Connect(function(_, parent)
		if not parent then
			stepStop("Up")
			stepStop("Down")
			for _, conn in pairs(stepConnections) do
				if typeof(conn) == "RBXScriptConnection" then
					conn:Disconnect()
				end
			end
			stepConnections = {}
		end
	end)

	structures.Field.Field.FocusLost:Connect(function(fromEnter)
		if fromEnter then
			assert(properties.Minimum)
			assert(properties.Maximum)

			local text = structures.Field.Field.Text
			local number = tonumber(text)

			if number and properties.Fielded then
				properties.Value = math.clamp(number, properties.Minimum, properties.Maximum)

				if properties.Value then
					bindings.Value(properties.Value)
				end
			end
		else
			structures.Field.Field.Text = tostring(properties.Value)
		end
	end)

	binder.Apply(properties, object)

	return object
end
