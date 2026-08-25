local types = require("@types")

return function(self, properties: types.ColorPickerProperties): types.ColorPicker
	--// Imports
	local creator = require("@modules/creator")
	local binder = require("@modules/binder")
	local utility = require("@modules/utility")
	local services = require("@modules/services")

	--// References
	local create = creator.Create

	local userInputService = services.UserInputService

	--// Variables
	local parent = self.__container or self.__instance or self
	local metrics = self.Theme.Metrics or {}
	local structures = {}

	local hue, saturation, value = 0.09, 0.9, 1
	local dragging: string? = nil

	--// UI
	properties = properties or {}
	properties.Value = properties.Value or Color3.fromRGB(255, 163, 26)
	properties.Presets = properties.Presets
		or { "FFA31A", "F87171", "FBBF24", "4ADE80", "38BDF8", "A78BFA", "F5F5F7", "6E7178" }

	-- Closed state: the swatch plus the hex, because the number is what gets copied and pasted.
	structures.Body = create("TextButton")({
		Name = "ColorPicker",
		AutoButtonColor = false,
		AutomaticSize = Enum.AutomaticSize.X,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(0, metrics.ControlHeight or 30),
		Text = "",
		Parent = parent,

		create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(0, metrics.Radius or 7) }),

		create("UIStroke")({
			Name = "UIStroke",
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 1,

			__dynamicKeys = {
				Color = self.Theme.Controls.ViewBorder[1],
				Transparency = self.Theme.Controls.ViewBorder[2],
			},
		}),

		create("UIPadding")({
			Name = "UIPadding",
			PaddingLeft = UDim.new(0, 9),
			PaddingRight = UDim.new(0, 11),
		}),

		create("UIListLayout")({
			Name = "UIListLayout",
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		create("Frame")({
			Name = "Swatch",
			BorderSizePixel = 0,
			LayoutOrder = 1,
			Size = UDim2.fromOffset(14, 14),

			create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(0, 4) }),
		}),

		create("TextLabel")({
			Name = "Hex",
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Font.new("rbxasset://fonts/families/Code.json"),
			LayoutOrder = 2,
			Size = UDim2.fromOffset(0, 20),
			Text = "",
			TextSize = metrics.ControlTextSize or 13,

			__dynamicKeys = {
				TextColor3 = self.Theme.Text.Primary[1],
				TextTransparency = self.Theme.Text.Primary[2],
			},
		}),
	}) :: TextButton

	structures.Body.BackgroundColor3 = self.Theme.Controls.View[1].Value
	structures.Body.BackgroundTransparency = self.Theme.Controls.View[2].Value

	-- The popover lives in its own ScreenGui so it is never clipped by a scrolling page.
	structures.Container = utility.ProtectUI(create("ScreenGui")({
		Name = "CascadeColorPicker",
		DisplayOrder = 2147483647,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Enabled = false,

		OnTopOfCoreBlur = true,

		create("TextButton")({
			Name = "Catcher",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1),
			Text = "",
		}),

		create("Frame")({
			Name = "Popover",
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(222, 0),
			AutomaticSize = Enum.AutomaticSize.Y,

			__dynamicKeys = {
				BackgroundColor3 = self.Theme.Controls.View[1],
				BackgroundTransparency = self.Theme.Controls.View[2],
			},

			create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(0, 10) }),

			create("UIStroke")({
				Name = "UIStroke",
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 1,

				__dynamicKeys = {
					Color = self.Theme.Controls.ViewBorder[1],
					Transparency = self.Theme.Controls.ViewBorder[2],
				},
			}),

			create("UIPadding")({
				Name = "UIPadding",
				PaddingTop = UDim.new(0, 11),
				PaddingBottom = UDim.new(0, 11),
				PaddingLeft = UDim.new(0, 11),
				PaddingRight = UDim.new(0, 11),
			}),

			create("UIListLayout")({
				Name = "UIListLayout",
				Padding = UDim.new(0, 9),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			create("Frame")({
				Name = "Field",
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 112),

				create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(0, 7) }),

				create("Frame")({
					Name = "White",
					BackgroundColor3 = Color3.new(1, 1, 1),
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 1),

					create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(0, 7) }),

					create("UIGradient")({
						Name = "UIGradient",
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(1, 1),
						}),
					}),
				}),

				create("Frame")({
					Name = "Black",
					BackgroundColor3 = Color3.new(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 1),

					create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(0, 7) }),

					create("UIGradient")({
						Name = "UIGradient",
						Rotation = 90,
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(1, 0),
						}),
					}),
				}),

				create("Frame")({
					Name = "Pin",
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.fromOffset(12, 12),
					ZIndex = 3,

					create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(1, 0) }),

					create("UIStroke")({ Name = "UIStroke", Color = Color3.new(1, 1, 1), Thickness = 2 }),
				}),
			}),

			create("Frame")({
				Name = "Hue",
				BorderSizePixel = 0,
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 9),

				create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(1, 0) }),

				create("UIGradient")({
					Name = "UIGradient",
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
						ColorSequenceKeypoint.new(0.17, Color3.fromHSV(0.17, 1, 1)),
						ColorSequenceKeypoint.new(0.33, Color3.fromHSV(0.33, 1, 1)),
						ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
						ColorSequenceKeypoint.new(0.67, Color3.fromHSV(0.67, 1, 1)),
						ColorSequenceKeypoint.new(0.83, Color3.fromHSV(0.83, 1, 1)),
						ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
					}),
				}),

				create("Frame")({
					Name = "Pin",
					AnchorPoint = Vector2.new(0.5, 0.5),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0, 0.5),
					Size = UDim2.fromOffset(15, 15),
					ZIndex = 3,

					create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(1, 0) }),

					create("UIStroke")({ Name = "UIStroke", Color = Color3.new(1, 1, 1), Thickness = 2 }),
				}),
			}),

			create("Frame")({
				Name = "HexRow",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 3,
				Size = UDim2.new(1, 0, 0, 28),

				create("UIListLayout")({
					Name = "UIListLayout",
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 7),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				create("TextBox")({
					Name = "Input",
					BorderSizePixel = 0,
					ClearTextOnFocus = false,
					FontFace = Font.new("rbxasset://fonts/families/Code.json"),
					LayoutOrder = 1,
					Size = UDim2.new(1, -66, 0, 28),
					Text = "",
					TextSize = 12,

					create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(0, 6) }),

					create("UIStroke")({
						Name = "UIStroke",
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Thickness = 1,

						__dynamicKeys = {
							Color = self.Theme.Controls.ViewBorder[1],
							Transparency = self.Theme.Controls.ViewBorder[2],
						},
					}),

					__dynamicKeys = {
						BackgroundColor3 = self.Theme.Controls.Background[1],
						TextColor3 = self.Theme.Text.Primary[1],
					},
				}),

				create("TextButton")({
					Name = "Copy",
					AutoButtonColor = false,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					FontFace = Font.new("rbxasset://fonts/families/Code.json"),
					LayoutOrder = 2,
					Size = UDim2.fromOffset(59, 28),
					Text = "Copy",
					TextSize = 12,

					create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(0, 6) }),

					create("UIStroke")({
						Name = "UIStroke",
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Thickness = 1,

						__dynamicKeys = {
							Color = self.Theme.Controls.ViewBorder[1],
							Transparency = self.Theme.Controls.ViewBorder[2],
						},
					}),

					__dynamicKeys = {
						TextColor3 = self.Theme.Text.Secondary[1],
						TextTransparency = self.Theme.Text.Secondary[2],
					},
				}),
			}),

			create("Frame")({
				Name = "Presets",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 4,
				Size = UDim2.new(1, 0, 0, 0),

				create("UIListLayout")({
					Name = "UIListLayout",
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 5),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Wraps = true,
				}),
			}),
		}),
	})) :: ScreenGui

	--// Initialize
	structures.Catcher = structures.Container:FindFirstChild("Catcher") :: TextButton
	structures.Popover = structures.Container:FindFirstChild("Popover") :: Frame
	structures.Field = structures.Popover:FindFirstChild("Field") :: Frame
	structures.FieldPin = structures.Field:FindFirstChild("Pin") :: Frame
	structures.HueBar = structures.Popover:FindFirstChild("Hue") :: Frame
	structures.HuePin = structures.HueBar:FindFirstChild("Pin") :: Frame
	structures.Hex = structures.Popover:FindFirstChild("HexRow"):FindFirstChild("Input") :: TextBox
	structures.Copy = structures.Popover:FindFirstChild("HexRow"):FindFirstChild("Copy") :: TextButton
	structures.Presets = structures.Popover:FindFirstChild("Presets") :: Frame
	structures.Swatch = structures.Body:FindFirstChild("Swatch") :: Frame
	structures.HexLabel = structures.Body:FindFirstChild("Hex") :: TextLabel

	local function paint(fromField: boolean?)
		local colour = Color3.fromHSV(hue, saturation, value)

		properties.Value = colour

		structures.Swatch.BackgroundColor3 = colour
		structures.HexLabel.Text = string.upper(colour:ToHex())
		structures.Field.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		structures.FieldPin.BackgroundColor3 = colour
		structures.HuePin.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)

		structures.FieldPin.Position = UDim2.fromScale(saturation, 1 - value)
		structures.HuePin.Position = UDim2.fromScale(hue, 0.5)

		if not fromField then
			structures.Hex.Text = string.upper(colour:ToHex())
		end

		if properties.ValueChanged then
			task.spawn(properties.ValueChanged, nil, colour)
		end
	end

	local function adopt(colour: Color3, fromField: boolean?)
		hue, saturation, value = colour:ToHSV()
		paint(fromField)
	end

	local function place()
		local position = structures.Body.AbsolutePosition
		local size = structures.Body.AbsoluteSize
		local viewport = structures.Container.AbsoluteSize
		local popover = structures.Popover.AbsoluteSize

		local x = math.clamp(position.X + size.X - popover.X, 8, math.max(viewport.X - popover.X - 8, 8))
		local y = position.Y + size.Y + 6

		-- Flip above when there is no room below.
		if y + popover.Y > viewport.Y - 8 then
			y = math.max(position.Y - popover.Y - 6, 8)
		end

		structures.Popover.Position = UDim2.fromOffset(x, y)
	end

	local function open(state: boolean)
		structures.Container.Enabled = state

		if state then
			place()
			task.defer(place)
		end
	end

	for order, preset in ipairs(properties.Presets) do
		local swatch = create("TextButton")({
			Name = "Preset",
			AutoButtonColor = false,
			BackgroundColor3 = typeof(preset) == "Color3" and preset or Color3.fromHex(preset),
			BorderSizePixel = 0,
			LayoutOrder = order,
			Size = UDim2.fromOffset(20, 20),
			Text = "",

			create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(0, 5) }),
		})

		swatch.Parent = structures.Presets.__instance or structures.Presets

		local instance = swatch.__instance or swatch

		instance.MouseButton1Click:Connect(function()
			adopt(instance.BackgroundColor3)
		end)
	end

	-- Dragging: the pointer keeps control of whichever strip it started on until it lets go.
	local function track(frame: Frame, name: string)
		frame.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end

			dragging = name
		end)
	end

	track(structures.Field, "field")
	track(structures.HueBar, "hue")

	userInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local point = Vector2.new(input.Position.X, input.Position.Y)

		if dragging == "field" then
			local origin = structures.Field.AbsolutePosition
			local size = structures.Field.AbsoluteSize

			saturation = math.clamp((point.X - origin.X) / size.X, 0, 1)
			value = 1 - math.clamp((point.Y - origin.Y) / size.Y, 0, 1)
		else
			local origin = structures.HueBar.AbsolutePosition
			local size = structures.HueBar.AbsoluteSize

			hue = math.clamp((point.X - origin.X) / size.X, 0, 1)
		end

		paint()
	end)

	userInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = nil
		end
	end)

	structures.Body.MouseButton1Click:Connect(function()
		open(not structures.Container.Enabled)
	end)

	structures.Catcher.MouseButton1Click:Connect(function()
		open(false)
	end)

	-- Paste with or without the hash; anything unreadable puts the current value back.
	structures.Hex.FocusLost:Connect(function()
		local text = string.gsub(structures.Hex.Text, "#", "")
		local ok, colour = pcall(Color3.fromHex, text)

		if ok and colour then
			adopt(colour, true)
		else
			structures.Hex.Text = string.upper(properties.Value:ToHex())
		end
	end)

	structures.Copy.MouseButton1Click:Connect(function()
		if setclipboard then
			setclipboard("#" .. string.upper(properties.Value:ToHex()))
		end
	end)

	local object = binder.Wrap(properties, {
		Value = function(colour: Color3?)
			if typeof(colour) ~= "Color3" then
				return
			end

			adopt(colour)
		end,
	}, structures.Body)

	object.Type = "ColorPicker"
	object.Theme = self.Theme
	object.Structures = structures

	object.Close = function()
		open(false)
	end

	structures.Body.Destroying:Connect(function()
		structures.Container:Destroy()
	end)

	binder.Apply(properties, object)

	adopt(properties.Value)

	return object
end
