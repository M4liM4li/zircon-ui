local types = require("@types")

return function(self, properties: types.KeyGateProperties): types.KeyGate
	--// Imports
	local creator = require("@modules/creator")
	local binder = require("@modules/binder")
	local symbols = require("@modules/symbols")

	--// References
	local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self
	local metrics = self.Theme.Metrics or {}
	local structures = require("@structures/TextField")(self)

	local checking = false

	--// UI
	properties = properties or {}
	properties.Title = properties.Title or "Paste your key"
	properties.Text = properties.Text or ""
	properties.Placeholder = properties.Placeholder or "Key"
	properties.Confirm = properties.Confirm or "Unlock"

	local accent = self.Theme.Controls.Selection

	structures.Gate = create("Frame")({
		Name = "KeyGate",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.35,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 60,
		Parent = parent,

		create("Frame")({
			Name = "Card",
			AnchorPoint = Vector2.new(0.5, 0.5),
			AutomaticSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(320, 0),
			ZIndex = 61,

			__dynamicKeys = {
				BackgroundColor3 = self.Theme.Controls.View[1],
				BackgroundTransparency = self.Theme.Controls.View[2],
			},

			create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(0, 12) }),

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
				PaddingTop = UDim.new(0, 22),
				PaddingBottom = UDim.new(0, 22),
				PaddingLeft = UDim.new(0, 22),
				PaddingRight = UDim.new(0, 22),
			}),

			create("UIListLayout")({
				Name = "UIListLayout",
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 11),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			create("Frame")({
				Name = "Chip",
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Size = UDim2.fromOffset(44, 44),
				ZIndex = 62,

				create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(0, 12) }),

				create("ImageLabel")({
					Name = "Icon",
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Image = symbols.keyFill or "",
					Position = UDim2.fromScale(0.5, 0.5),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromOffset(24, 24),
					ZIndex = 62,
				}),
			}),

			create("TextLabel")({
				Name = "Title",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Font.new(
					metrics.Mono and "rbxasset://fonts/families/Code.json" or "rbxassetid://12187365364",
					Enum.FontWeight.Bold,
					Enum.FontStyle.Normal
				),
				LayoutOrder = 2,
				RichText = true,
				Size = UDim2.new(1, 0, 0, 0),
				Text = "",
				TextSize = metrics.SectionTitleSize or 18,
				TextWrapped = true,
				ZIndex = 62,

				__dynamicKeys = {
					TextColor3 = self.Theme.Text.Primary[1],
					TextTransparency = self.Theme.Text.Primary[2],
				},
			}),

			create("TextLabel")({
				Name = "Text",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Font.new("rbxassetid://12187365364"),
				LayoutOrder = 3,
				RichText = true,
				Size = UDim2.new(1, 0, 0, 0),
				Text = "",
				TextSize = 12.5,
				TextWrapped = true,
				Visible = false,
				ZIndex = 62,

				__dynamicKeys = {
					TextColor3 = self.Theme.Text.Secondary[1],
					TextTransparency = self.Theme.Text.Secondary[2],
				},
			}),

			create("Frame")({
				Name = "Field",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 4,
				Size = UDim2.new(1, 0, 0, metrics.ControlHeight or 30),
				ZIndex = 62,

				create("UIListLayout")({
					Name = "UIListLayout",
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 8),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				create("TextButton")({
					Name = "Submit",
					AutomaticSize = Enum.AutomaticSize.X,
					AutoButtonColor = false,
					BorderSizePixel = 0,
					FontFace = Font.new(
						metrics.Mono and "rbxasset://fonts/families/Code.json" or "rbxassetid://12187365364",
						Enum.FontWeight.Bold,
						Enum.FontStyle.Normal
					),
					LayoutOrder = 2,
					Size = UDim2.fromOffset(0, metrics.ControlHeight or 30),
					Text = "",
					TextSize = metrics.ControlTextSize or 14,
					ZIndex = 62,

					create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(0, metrics.Radius or 7) }),

					create("UIPadding")({
						Name = "UIPadding",
						PaddingLeft = UDim.new(0, 15),
						PaddingRight = UDim.new(0, 15),
					}),
				}),
			}),

			create("Frame")({
				Name = "Error",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 5,
				Size = UDim2.new(1, 0, 0, 0),
				Visible = false,
				ZIndex = 62,

				create("UIListLayout")({
					Name = "UIListLayout",
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 7),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Top,
				}),

				create("ImageLabel")({
					Name = "Icon",
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Image = symbols.exclamationmarkOctagonFill or "",
					LayoutOrder = 1,
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromOffset(14, 14),
					ZIndex = 62,

					__dynamicKeys = {
						ImageColor3 = self.Theme.Accents.Red[1],
						ImageTransparency = self.Theme.Accents.Red[2],
					},
				}),

				create("TextLabel")({
					Name = "Label",
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					FontFace = Font.new("rbxassetid://12187365364"),
					LayoutOrder = 2,
					RichText = true,
					Size = UDim2.new(1, -21, 0, 0),
					Text = "",
					TextSize = 12,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 62,

					__dynamicKeys = {
						TextColor3 = self.Theme.Accents.Red[1],
						TextTransparency = self.Theme.Accents.Red[2],
					},
				}),
			}),

			create("TextLabel")({
				Name = "Help",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Font.new("rbxasset://fonts/families/Code.json"),
				LayoutOrder = 6,
				RichText = true,
				Size = UDim2.new(1, 0, 0, 0),
				Text = "",
				TextSize = 11,
				TextWrapped = true,
				Visible = false,
				ZIndex = 62,

				__dynamicKeys = {
					TextColor3 = self.Theme.Text.Tertiary[1],
					TextTransparency = self.Theme.Text.Tertiary[2],
				},
			}),
		}),
	}) :: Frame

	--// Initialize
	structures.Card = structures.Gate:FindFirstChild("Card") :: Frame
	structures.Chip = structures.Card:FindFirstChild("Chip") :: Frame
	structures.ChipIcon = structures.Chip:FindFirstChild("Icon") :: ImageLabel
	structures.Title = structures.Card:FindFirstChild("Title") :: TextLabel
	structures.Text = structures.Card:FindFirstChild("Text") :: TextLabel
	structures.Row = structures.Card:FindFirstChild("Field") :: Frame
	structures.Submit = structures.Row:FindFirstChild("Submit") :: TextButton
	structures.Error = structures.Card:FindFirstChild("Error") :: Frame
	structures.ErrorLabel = structures.Error:FindFirstChild("Label") :: TextLabel
	structures.Help = structures.Card:FindFirstChild("Help") :: TextLabel

	-- The shared text field drops into the row beside the button.
	structures.Body.Parent = structures.Row.__instance or structures.Row
	structures.Body.LayoutOrder = 1
	structures.Body.AutomaticSize = Enum.AutomaticSize.None
	structures.Body.Size = UDim2.new(1, -96, 0, metrics.ControlHeight or 30)
	structures.Field.Size = UDim2.new(1, 0, 0, metrics.ControlHeight or 30)
	structures.Field.TextXAlignment = Enum.TextXAlignment.Left

	structures.Chip.BackgroundColor3 = accent[1].Value
	structures.Chip.BackgroundTransparency = 0.88
	structures.ChipIcon.ImageColor3 = accent[1].Value

	structures.Submit.BackgroundColor3 = accent[1].Value
	structures.Submit.BackgroundTransparency = accent[2].Value
	structures.Submit.TextColor3 = self.Theme.Controls.Background[1].Value

	local function fault(message: string?)
		local text = type(message) == "string" and message or ""

		structures.ErrorLabel.Text = text
		structures.Error.Visible = text ~= ""
	end

	local object

	local function submit()
		if checking then
			return
		end

		local key = structures.Field.Text

		if key == "" then
			fault("Paste the key first.")
			return
		end

		fault(nil)

		if not properties.Verify then
			object:Accept()
			return
		end

		checking = true
		structures.Submit.Text = "Checking…"

		task.spawn(function()
			local ok, message = properties.Verify(object, key)

			checking = false
			structures.Submit.Text = properties.Confirm

			if ok then
				object:Accept()
			else
				fault(message or "That key did not work. Check it and try again.")
			end
		end)
	end

	object = binder.Wrap(properties, {
		Title = function(value: string?)
			structures.Title.Text = type(value) == "string" and value or ""
		end,
		Text = function(value: string?)
			local text = type(value) == "string" and value or ""

			structures.Text.Text = text
			structures.Text.Visible = text ~= ""
		end,
		Placeholder = function(value: string?)
			structures.Field.PlaceholderText = type(value) == "string" and value or ""
		end,
		Confirm = function(value: string?)
			if type(value) ~= "string" then
				return
			end

			structures.Submit.Text = value
		end,
		Help = function(value: string?)
			local text = type(value) == "string" and value or ""

			structures.Help.Text = text
			structures.Help.Visible = text ~= ""
		end,
		Error = function(value: string?)
			fault(value)
		end,
	}, structures.Gate)

	object.Type = "KeyGate"
	object.Theme = self.Theme
	object.Structures = structures

	function object:Accept()
		structures.Gate:Destroy()

		if properties.Accepted then
			task.spawn(properties.Accepted, object, structures.Field.Text)
		end
	end

	function object:Close()
		structures.Gate:Destroy()
	end

	structures.Submit.MouseButton1Click:Connect(submit)
	structures.Field.FocusLost:Connect(function(enterPressed: boolean)
		if enterPressed then
			submit()
		end
	end)

	binder.Apply(properties, object)

	return object
end
