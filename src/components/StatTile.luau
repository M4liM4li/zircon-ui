local types = require("@types")

return function(self, properties: types.StatTileProperties): types.StatTile
	--// Imports
	local creator = require("@modules/creator")
	local binder = require("@modules/binder")

	--// References
	local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self
	local theme = self.Theme.Controls.StatTile
	local structures = {}
	local metrics = self.Theme.Metrics or {}

	--// UI
	properties = properties or {}
	properties.Value = properties.Value or "0"
	properties.Muted = properties.Muted == true

	structures.Body = create("Frame")({
		Name = "StatTile",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Size = UDim2.fromScale(1, 0),
		Parent = parent,

		__dynamicKeys = {
			BackgroundColor3 = theme.Surface[1],
			BackgroundTransparency = theme.Surface[2],
		},

		create("UICorner")({
			Name = "UICorner",
			CornerRadius = UDim.new(0, metrics.Radius or 8),
		}),

		create("UIStroke")({
			Name = "UIStroke",
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = 1,

			__dynamicKeys = {
				Color = theme.Border[1],
				Transparency = theme.Border[2],
			},
		}),

		create("UIPadding")({
			Name = "UIPadding",
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingTop = UDim.new(0, 9),
		}),

		create("UIListLayout")({
			Name = "UIListLayout",
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		create("Frame")({
			Name = "Header",
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(0, 0),

			create("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 6),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			create("ImageLabel")({
				Name = "Icon",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.fromOffset(12, 12),
				Visible = false,
			}),

			create("TextLabel")({
				Name = "Label",
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Font.new(metrics.Mono and "rbxasset://fonts/families/Code.json" or "rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				RichText = true,
				Size = UDim2.fromOffset(0, 12),
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Left,
				Visible = false,

				__dynamicKeys = {
					TextColor3 = theme.Label[1],
					TextTransparency = theme.Label[2],
				},
			}),
		}),

		create("TextLabel")({
			Name = "Value",
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Font.new("rbxasset://fonts/families/Code.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal),
			LayoutOrder = 1,
			RichText = true,
			Size = UDim2.fromOffset(0, 19),
			Text = "0",
			TextSize = 19,
			TextXAlignment = Enum.TextXAlignment.Left,

			__dynamicKeys = {
				TextColor3 = self.Theme.Text.Primary[1],
				TextTransparency = self.Theme.Text.Primary[2],
			},
		}),

		create("TextLabel")({
			Name = "Delta",
			AutomaticSize = Enum.AutomaticSize.XY,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Font.new(metrics.Mono and "rbxasset://fonts/families/Code.json" or "rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			LayoutOrder = 2,
			RichText = true,
			Size = UDim2.fromOffset(0, 14),
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			Visible = false,
		}),

		create("Frame")({
			Name = "Progress",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 3,
			ClipsDescendants = true,
			Size = UDim2.new(1, 0, 0, 5),
			Visible = false,

			create("UICorner")({
				Name = "TrackCorner",
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
				BackgroundColor3 = theme.Track[1],
				BackgroundTransparency = theme.Track[2],
			},
		}),
	}) :: Frame

	--// Initialize
	structures.Header = structures.Body:FindFirstChild("Header") :: Frame
	structures.Icon = structures.Header:FindFirstChild("Icon") :: ImageLabel
	structures.Label = structures.Header:FindFirstChild("Label") :: TextLabel
	structures.Value = structures.Body:FindFirstChild("Value") :: TextLabel
	structures.Delta = structures.Body:FindFirstChild("Delta") :: TextLabel
	structures.Progress = structures.Body:FindFirstChild("Progress") :: Frame
	structures.Fill = structures.Progress:FindFirstChild("Fill") :: Frame

	local function applyDeltaColor()
		local source = properties.Muted and theme.Label or theme.Delta
		structures.Delta.TextColor3 = source[1].Value
		structures.Delta.TextTransparency = source[2].Value
	end

	local function applyIconColor()
		if properties.IconColor then
			structures.Icon.ImageColor3 = properties.IconColor
			structures.Icon.ImageTransparency = 0
		else
			structures.Icon.ImageColor3 = theme.Label[1].Value
			structures.Icon.ImageTransparency = theme.Label[2].Value
		end
	end

	theme.Delta[1]:Connect(applyDeltaColor)
	theme.Delta[2]:Connect(applyDeltaColor)
	theme.Label[1]:Connect(applyDeltaColor)
	theme.Label[2]:Connect(applyDeltaColor)
	theme.Label[1]:Connect(applyIconColor)
	theme.Label[2]:Connect(applyIconColor)
	applyDeltaColor()
	applyIconColor()

	local object = binder.Wrap(properties, {
		-- Text only: this key collides with the Label component, which is applied over every
		-- object after it is built and would otherwise arrive here as a function.
		Label = function(value: string?)
			if type(value) ~= "string" then
				return
			end

			structures.Label.Visible = value ~= ""

			if value ~= "" then
				structures.Label.Text = string.upper(value)
			end
		end,
		Value = function(value: string)
			structures.Value.Text = value
		end,
		Delta = function(value: string?)
			if value == nil or value == "" then
				structures.Delta.Visible = false
				return
			end

			structures.Delta.Visible = true
			structures.Delta.Text = value
		end,
		Icon = function(value: string?)
			if value == nil or value == "" then
				structures.Icon.Visible = false
				return
			end

			structures.Icon.Visible = true
			structures.Icon.Image = value
		end,
		IconColor = function(value: Color3?)
			properties.IconColor = value
			applyIconColor()
		end,
		Progress = function(value: number?)
			if value == nil then
				structures.Progress.Visible = false
				return
			end

			structures.Progress.Visible = true
			structures.Fill.Size = UDim2.fromScale(math.clamp(value, 0, 1), 1)
		end,
		Wide = function(value: boolean?)
			structures.Body:SetAttribute("Wide", value == true)
		end,
		Muted = function(value: boolean?)
			properties.Muted = value == true
			applyDeltaColor()
		end,
	}, structures.Body)

	object.Type = "StatTile"
	object.Theme = self.Theme
	object.Structures = structures

	binder.Apply(properties, object)

	return object
end
