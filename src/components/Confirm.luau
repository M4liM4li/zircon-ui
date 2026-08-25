local types = require("@types")

return function(self, properties: types.ConfirmProperties): types.Confirm
	--// Imports
	local creator = require("@modules/creator")
	local binder = require("@modules/binder")
	local symbols = require("@modules/symbols")

	--// References
	local create = creator.Create

	--// Variables
	-- Modals cover the whole window, not the page they were raised from.
	local host = (self.Structures and self.Structures.Body) or self.__container or self.__instance or self
	local metrics = self.Theme.Metrics or {}
	local structures = {}

	--// UI
	properties = properties or {}
	properties.Title = properties.Title or "Are you sure?"
	properties.Text = properties.Text or ""
	properties.Confirm = properties.Confirm or "Confirm"
	properties.Cancel = properties.Cancel or "Cancel"
	properties.Destructive = properties.Destructive == true

	local accent = properties.Destructive and self.Theme.Accents.Red or self.Theme.Controls.Selection

	local function button(name: string, order: number, filled: boolean)
		return create("TextButton")({
			Name = name,
			AutomaticSize = Enum.AutomaticSize.X,
			AutoButtonColor = false,
			BackgroundTransparency = filled and 0 or 1,
			BorderSizePixel = 0,
			FontFace = Font.new(
				metrics.Mono and "rbxasset://fonts/families/Code.json" or "rbxassetid://12187365364",
				Enum.FontWeight.Bold,
				Enum.FontStyle.Normal
			),
			LayoutOrder = order,
			Size = UDim2.fromOffset(0, metrics.ControlHeight or 30),
			Text = "",
			TextSize = metrics.ControlTextSize or 14,

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, metrics.Radius or 6),
			}),

			create("UIPadding")({
				Name = "UIPadding",
				PaddingLeft = UDim.new(0, 14),
				PaddingRight = UDim.new(0, 14),
			}),

			create("UIStroke")({
				Name = "UIStroke",
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Enabled = not filled,
				Thickness = 1,

				__dynamicKeys = {
					Color = self.Theme.Controls.ViewBorder[1],
					Transparency = self.Theme.Controls.ViewBorder[2],
				},
			}),
		})
	end

	structures.Body = create("Frame")({
		Name = "Confirm",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 50,
		Parent = host,

		create("UICorner")({
			Name = "UICorner",
			CornerRadius = UDim.new(0, metrics.Radius or 8),
		}),

		create("Frame")({
			Name = "Card",
			AnchorPoint = Vector2.new(0.5, 0.5),
			AutomaticSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(330, 0),
			ZIndex = 51,

			__dynamicKeys = {
				BackgroundColor3 = self.Theme.Controls.View[1],
				BackgroundTransparency = self.Theme.Controls.View[2],
			},

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, 12),
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

			create("UIPadding")({
				Name = "UIPadding",
				PaddingTop = UDim.new(0, 18),
				PaddingBottom = UDim.new(0, 18),
				PaddingLeft = UDim.new(0, 18),
				PaddingRight = UDim.new(0, 18),
			}),

			create("UIListLayout")({
				Name = "UIListLayout",
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			create("Frame")({
				Name = "IconChip",
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Size = UDim2.fromOffset(32, 32),
				ZIndex = 52,

				create("UICorner")({
					Name = "UICorner",
					CornerRadius = UDim.new(0, 8),
				}),

				create("ImageLabel")({
					Name = "Icon",
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 0.5),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromOffset(18, 18),
					ZIndex = 52,
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
				TextSize = metrics.SectionTitleSize or 16,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 52,

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
				TextSize = 12,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				Visible = false,
				ZIndex = 52,

				__dynamicKeys = {
					TextColor3 = self.Theme.Text.Secondary[1],
					TextTransparency = self.Theme.Text.Secondary[2],
				},
			}),

			create("Frame")({
				Name = "Actions",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 4,
				Size = UDim2.new(1, 0, 0, metrics.ControlHeight or 30),
				ZIndex = 52,

				create("UIListLayout")({
					Name = "UIListLayout",
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					Padding = UDim.new(0, 8),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

				button("CancelButton", 1, false),
				button("ConfirmButton", 2, true),
			}),
		}),
	}) :: Frame

	--// Initialize
	structures.Card = structures.Body:FindFirstChild("Card") :: Frame
	structures.IconChip = structures.Card:FindFirstChild("IconChip") :: Frame
	structures.Icon = structures.IconChip:FindFirstChild("Icon") :: ImageLabel
	structures.Title = structures.Card:FindFirstChild("Title") :: TextLabel
	structures.Text = structures.Card:FindFirstChild("Text") :: TextLabel
	structures.Actions = structures.Card:FindFirstChild("Actions") :: Frame
	structures.CancelButton = structures.Actions:FindFirstChild("CancelButton") :: TextButton
	structures.ConfirmButton = structures.Actions:FindFirstChild("ConfirmButton") :: TextButton

	for _, part in { structures.CancelButton, structures.ConfirmButton, structures.Actions } do
		part.ZIndex = 52
	end

	local function paint()
		local color = accent[1].Value
		local transparency = accent[2].Value

		structures.IconChip.BackgroundColor3 = color
		structures.IconChip.BackgroundTransparency = 0.88

		structures.Icon.ImageColor3 = color
		structures.Icon.ImageTransparency = transparency

		structures.ConfirmButton.BackgroundColor3 = color
		structures.ConfirmButton.BackgroundTransparency = transparency
		-- Dark ink on the fill, the same trick the primary button uses.
		structures.ConfirmButton.TextColor3 = self.Theme.Controls.Background[1].Value

		structures.CancelButton.TextColor3 = self.Theme.Text.Primary[1].Value
		structures.CancelButton.TextTransparency = self.Theme.Text.Primary[2].Value
	end

	accent[1]:Connect(paint)

	local closed = false

	local function close(accepted: boolean)
		if closed then
			return
		end

		closed = true

		local callback = accepted and properties.Accepted or properties.Declined

		structures.Body:Destroy()

		if callback then
			task.spawn(callback, accepted)
		end
	end

	structures.ConfirmButton.MouseButton1Click:Connect(function()
		close(true)
	end)

	structures.CancelButton.MouseButton1Click:Connect(function()
		close(false)
	end)

	local object = binder.Wrap(properties, {
		Title = function(value: string?)
			structures.Title.Text = type(value) == "string" and value or ""
		end,
		Text = function(value: string?)
			local text = type(value) == "string" and value or ""

			structures.Text.Text = text
			structures.Text.Visible = text ~= ""
		end,
		-- Keep the label when handed a non-string: this key collides with the Confirm component,
		-- which the component table applies over every object after it is built.
		Confirm = function(value: string?)
			if type(value) ~= "string" then
				return
			end

			structures.ConfirmButton.Text = value
		end,
		Cancel = function(value: string?)
			if type(value) ~= "string" then
				return
			end

			structures.CancelButton.Text = value
		end,
		Icon = function(value: string?)
			structures.Icon.Image = type(value) == "string" and value or ""
		end,
	}, structures.Body)

	object.Type = "Confirm"
	object.Theme = self.Theme
	object.Structures = structures

	object.Close = function()
		close(false)
	end

	binder.Apply(properties, object)

	if structures.Icon.Image == "" then
		structures.Icon.Image = properties.Destructive and symbols.trash or symbols.questionmarkCircleFill
	end

	paint()

	return object
end
