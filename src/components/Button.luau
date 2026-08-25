local types = require("@types")

return function(self, properties: types.ButtonProperties): types.Button
	--// Imports
	local creator = require("@modules/creator")
	local binder = require("@modules/binder")
	local services = require("@modules/services")

	--// References
	local create = creator.Create

	local tweenService = services.TweenService

	--// Variables
	local parent = self.__container or self.__instance or self
	local theme = self.Theme.Controls.Button
	local structures = {}
	local metrics = self.Theme.Metrics or {}
	-- Squared density trades the gradient capsule for a flat, bordered box.
	local compact = metrics.Squared == true
	local labelFont = metrics.Mono and "rbxasset://fonts/families/Code.json" or "rbxassetid://12187365364"

	--// Functions
	-- Dense fills are flat: the accent for Primary, red for Destructive, the recessed surface otherwise.
	local function compactFill()
		local state = properties.State

		return state == "Primary" and self.Theme.Controls.SelectionFocused
			or state == "Destructive" and self.Theme.Accents.Red
			or self.Theme.Controls.Background
	end

	--// UI
	properties = properties or {}
	properties.State = properties.State or "Primary"
	properties.Label = properties.Label or "Label"

	structures.Body = binder.Apply(
		properties,
		create("TextButton")({
			Name = "Button",
			AutoButtonColor = false,
			AutomaticSize = compact and Enum.AutomaticSize.X or Enum.AutomaticSize.XY,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = compact and UDim2.fromOffset(0, metrics.ControlHeight or 31) or nil,
			Text = "",
			Parent = parent,

			__dynamicKeys = compact and {
				BackgroundColor3 = self.Theme.Controls.SelectionFocused[1],
				BackgroundTransparency = self.Theme.Controls.SelectionFocused[2],
			} or nil,
			__contextKeys = compact and {
				BackgroundColor3 = function()
					return compactFill()[1].Value
				end,
				BackgroundTransparency = function()
					return compactFill()[2].Value
				end,
			} or nil,

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, compact and (metrics.Radius or 2) or 5),
			}),

			compact and create("UIStroke")({
				Name = "UIStroke",
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 1,

				__dynamicKeys = {
					Color = self.Theme.Controls.ViewBorder[1],
					Transparency = self.Theme.Controls.ViewBorder[2],
				},
			}) or nil,

			create("Folder")({
				Name = "ShadowLayers",

				create("Frame")({
					Name = "Layer1",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 1),
					ZIndex = 0,

					create("UICorner")({
						Name = "UICorner",
						CornerRadius = UDim.new(0, 8),
					}),

					create("UIStroke")({
						Name = "UIStroke",
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Enabled = not compact,
						Transparency = 0.95,

						__dynamicKeys = {
							Color = theme.Shadow,
						},
					}),
				}),

				create("Frame")({
					Name = "Layer2",
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					BackgroundTransparency = 1,
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 1),
					ZIndex = -1,

					create("UICorner")({
						Name = "UICorner",
						CornerRadius = UDim.new(0, 8),
					}),

					create("UIStroke")({
						Name = "UIStroke",
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Enabled = not compact,
						Thickness = 2,
						Transparency = 0.98,

						__dynamicKeys = {
							Color = theme.Shadow,
						},
					}),
				}),
			}),

			create("Folder")({
				Name = "PressOverlay",

				create("Frame")({
					Name = "Overlay",
					BackgroundColor3 = Color3.fromRGB(0, 0, 0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Size = UDim2.fromScale(1, 1),
					ZIndex = 0,

					create("UICorner")({
						Name = "UICorner",
						CornerRadius = UDim.new(0, compact and (metrics.Radius or 2) or 5),
					}),
				}),
			}),
		})
	) :: TextButton

	--// Initialize
	structures.PressOverlay = structures.Body:FindFirstChild("PressOverlay"):FindFirstChild("Overlay")
	structures.Shadows = structures.Body:FindFirstChild("ShadowLayers")
	structures.Shadow1 = structures.Shadows:FindFirstChild("Layer1"):FindFirstChild("UIStroke")
	structures.Shadow2 = structures.Shadows:FindFirstChild("Layer2"):FindFirstChild("UIStroke")
	structures.Stroke = compact and structures.Body:FindFirstChild("UIStroke") or nil

	local labelContext = {
		TextColor3 = function()
			local state = properties.State

			if compact then
				-- Near-black ink on the accent fill, white on the red one.
				return state == "Primary" and self.Theme.Controls.Background[1].Value
					or state == "Destructive" and self.Theme.Text.SelectionPrimary[1].Value
					or self.Theme.Text.Primary[1].Value
			end

			return state == "Primary" and self.Theme.Text.SelectionPrimary[1].Value
				or state == "Secondary" and self.Theme.Text.Primary[1].Value
				or state == "Destructive" and self.Theme.Accents.Red[1].Value
		end,
		TextTransparency = function()
			local state = properties.State

			if compact then
				return state == "Primary" and self.Theme.Controls.Background[2].Value
					or state == "Destructive" and self.Theme.Text.SelectionPrimary[2].Value
					or self.Theme.Text.Primary[2].Value
			end

			return state == "Primary" and self.Theme.Text.SelectionPrimary[2].Value
				or state == "Secondary" and self.Theme.Text.Primary[2].Value
				or state == "Destructive" and self.Theme.Accents.Red[2].Value
		end,
	}
	local fillContext = {
		Color = function()
			local state = properties.State

			return state == "Primary" and theme.FillPrimary.Value
				or (state == "Secondary" or state == "Destructive") and theme.FillSecondary.Value
		end,
	}

	structures.Label = create("TextLabel")({
		Size = compact and UDim2.new(0, 0, 1, 0) or UDim2.fromScale(1, 1),
		Name = "Label",
		AutomaticSize = compact and Enum.AutomaticSize.X or Enum.AutomaticSize.XY,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		BorderColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		FontFace = compact and Font.new(labelFont, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
			or Font.new("rbxassetid://12187365364"),
		RichText = true,
		TextSize = compact and (metrics.ControlTextSize or 13.5) or 14,
		TextWrapped = not compact,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Parent = structures.Body.__instance,

		__dynamicKeys = {
			TextColor3 = self.Theme.Text.SelectionPrimary[1],
			TextTransparency = self.Theme.Text.SelectionPrimary[2],
		},
		__contextKeys = labelContext,

		create("UIPadding")({
			Name = "UIPadding",
			PaddingBottom = UDim.new(0, compact and 0 or 3),
			PaddingLeft = UDim.new(0, compact and 13 or 7),
			PaddingRight = UDim.new(0, compact and 13 or 7),
			PaddingTop = UDim.new(0, compact and 0 or 3),
		}),
	}) :: TextLabel
	structures.Fill = create("UIGradient")({
		Name = "UIGradient",
		Enabled = not compact,
		Rotation = 90,
		Parent = structures.Body.__instance,

		__dynamicKeys = {
			Color = theme.FillPrimary,
		},
		__contextKeys = fillContext,
	}) :: UIGradient

	if compact then
		-- Paint the starting state now, the binding below only runs a frame later.
		local fill = compactFill()

		structures.Body.BackgroundColor3 = fill[1].Value
		structures.Body.BackgroundTransparency = fill[2].Value
		structures.Stroke.Enabled = properties.State == "Secondary"
	end

	local object
	local bindings = {
		State = function()
			task.defer(function()
				structures.Label.TextColor3 = labelContext.TextColor3()
				structures.Label.TextTransparency = labelContext.TextTransparency()
				structures.Fill.Color = fillContext.Color()

				if compact then
					local fill = compactFill()

					structures.Body.BackgroundColor3 = fill[1].Value
					structures.Body.BackgroundTransparency = fill[2].Value
					-- Only the secondary box keeps its hairline; the filled states drop it.
					structures.Stroke.Enabled = properties.State == "Secondary"
				end
			end)
		end,
		Label = function(value: string)
			structures.Label.Text = value
		end,
	}

	object = binder.Wrap(properties, bindings, structures.Body)

	object.Type = "Button"
	object.Theme = self.Theme
	object.Structures = structures

	structures.Body.MouseButton1Click:Connect(function()
		if properties.Pushed then
			task.spawn(properties.Pushed, object)
		end
	end)

	local function animateRelease()
		local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

		tweenService
			:Create(structures.PressOverlay, tweenInfo, {
				BackgroundTransparency = 1,
			})
			:Play()
	end

	structures.Body.MouseButton1Down:Connect(function()
		local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)

		tweenService
			:Create(structures.PressOverlay, tweenInfo, {
				BackgroundTransparency = 0.8,
			})
			:Play()
	end)

	structures.Body.MouseButton1Up:Connect(animateRelease)
	structures.Body.MouseLeave:Connect(animateRelease)

	binder.Apply(properties, object)

	return object
end
