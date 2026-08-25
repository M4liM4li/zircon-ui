local types = require("@types")

return function(self, properties: types.ProgressBarProperties): types.ProgressBar
	--// Imports
	local creator = require("@modules/creator")
	local binder = require("@modules/binder")
	local services = require("@modules/services")

	--// References
	local create = creator.Create

	local tweenService = services.TweenService

	--// Variables
	local parent = self.__container or self.__instance or self
	local metrics = self.Theme.Metrics or {}
	local structures = {}

	local sweep: Tween? = nil

	--// UI
	properties = properties or {}
	properties.Value = properties.Value or 0
	properties.Indeterminate = properties.Indeterminate == true

	structures.Body = create("Frame")({
		Name = "ProgressBar",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = parent,

		create("UIListLayout")({
			Name = "UIListLayout",
			Padding = UDim.new(0, 9),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		-- The head only exists when there is something to say; an unlabelled bar is just the track.
		create("Frame")({
			Name = "Head",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 18),
			Visible = false,

			create("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			create("TextLabel")({
				Name = "Title",
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Font.new(
					metrics.Mono and "rbxasset://fonts/families/Code.json" or "rbxassetid://12187365364",
					Enum.FontWeight.Regular,
					Enum.FontStyle.Normal
				),
				LayoutOrder = 1,
				RichText = true,
				Size = UDim2.fromOffset(0, 18),
				Text = "",
				TextSize = metrics.TitleSize or 15,
				TextXAlignment = Enum.TextXAlignment.Left,

				__dynamicKeys = {
					TextColor3 = self.Theme.Text.Primary[1],
					TextTransparency = self.Theme.Text.Primary[2],
				},
			}),

			create("Frame")({
				Name = "Spacer",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 2,
				Size = UDim2.fromOffset(0, 1),

				create("UIFlexItem")({
					Name = "UIFlexItem",
					FlexMode = Enum.UIFlexMode.Fill,
				}),
			}),

			-- The readout is the one accented thing here, so it reads as live output.
			create("TextLabel")({
				Name = "Readout",
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Font.new(
					"rbxasset://fonts/families/Code.json",
					Enum.FontWeight.Bold,
					Enum.FontStyle.Normal
				),
				LayoutOrder = 3,
				RichText = true,
				Size = UDim2.fromOffset(0, 18),
				Text = "",
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Right,

				__dynamicKeys = {
					TextColor3 = self.Theme.Controls.Selection[1],
					TextTransparency = self.Theme.Controls.Selection[2],
				},
			}),
		}),

		create("Frame")({
			Name = "Track",
			BorderSizePixel = 0,
			ClipsDescendants = true,
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, 4),

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(1, 0),
			}),

			create("Frame")({
				Name = "Fill",
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0, 1),

				create("UICorner")({
					Name = "UICorner",
					CornerRadius = UDim.new(1, 0),
				}),

				__dynamicKeys = {
					BackgroundColor3 = self.Theme.Controls.Selection[1],
					BackgroundTransparency = self.Theme.Controls.Selection[2],
				},
			}),

			__dynamicKeys = {
				BackgroundColor3 = self.Theme.Controls.Slider.Track[1],
				BackgroundTransparency = self.Theme.Controls.Slider.Track[2],
			},
		}),

		create("TextLabel")({
			Name = "Subtitle",
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

			__dynamicKeys = {
				TextColor3 = self.Theme.Text.Tertiary[1],
				TextTransparency = self.Theme.Text.Tertiary[2],
			},
		}),
	}) :: Frame

	--// Initialize
	structures.Head = structures.Body:FindFirstChild("Head") :: Frame
	structures.Title = structures.Head:FindFirstChild("Title") :: TextLabel
	structures.Readout = structures.Head:FindFirstChild("Readout") :: TextLabel
	structures.Track = structures.Body:FindFirstChild("Track") :: Frame
	structures.Fill = structures.Track:FindFirstChild("Fill") :: Frame
	structures.Subtitle = structures.Body:FindFirstChild("Subtitle") :: TextLabel

	local function updateHead()
		structures.Head.Visible = structures.Title.Text ~= "" or structures.Readout.Text ~= ""
	end

	-- Accent means "this is moving". A parked bar reports in the muted ink instead.
	local function paintReadout()
		local live = properties.Indeterminate or (properties.Value or 0) > 0
		local token = live and self.Theme.Controls.Selection or self.Theme.Text.Tertiary

		structures.Readout.TextColor3 = token[1].Value
		structures.Readout.TextTransparency = token[2].Value
	end

	-- Length is unknown, so the bar reports motion instead of a number.
	local function setSweeping(sweeping: boolean)
		if sweep then
			sweep:Cancel()
			sweep = nil
		end

		if not sweeping then
			return
		end

		structures.Fill.Size = UDim2.fromScale(0.32, 1)
		structures.Fill.Position = UDim2.fromScale(-0.32, 0)

		sweep = tweenService:Create(
			structures.Fill,
			TweenInfo.new(1.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
			{ Position = UDim2.fromScale(1, 0) }
		)

		if sweep then
			sweep:Play()
		end
	end

	local object = binder.Wrap(properties, {
		Value = function(value: number)
			properties.Value = math.clamp(tonumber(value) or 0, 0, 1)

			if properties.Indeterminate then
				return
			end

			structures.Fill.Position = UDim2.fromScale(0, 0)
			structures.Fill.Size = UDim2.fromScale(properties.Value, 1)

			paintReadout()
		end,
		Indeterminate = function(value: boolean)
			properties.Indeterminate = value == true

			setSweeping(properties.Indeterminate)

			if not properties.Indeterminate then
				structures.Fill.Position = UDim2.fromScale(0, 0)
				structures.Fill.Size = UDim2.fromScale(properties.Value or 0, 1)
			end

			paintReadout()
		end,
		Title = function(value: string?)
			structures.Title.Text = type(value) == "string" and value or ""
			updateHead()
		end,
		Text = function(value: string?)
			structures.Readout.Text = type(value) == "string" and value or ""
			updateHead()
		end,
		Subtitle = function(value: string?)
			local text = type(value) == "string" and value or ""

			structures.Subtitle.Text = text
			structures.Subtitle.Visible = text ~= ""
		end,
	}, structures.Body)

	object.Type = "ProgressBar"
	object.Theme = self.Theme
	object.Structures = structures

	structures.Body.Destroying:Connect(function()
		setSweeping(false)
	end)

	binder.Apply(properties, object)

	paintReadout()

	return object
end
