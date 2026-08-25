local types = require("@types")

return function(self, properties: types.BadgeProperties): types.Badge
	--// Imports
	local creator = require("@modules/creator")
	local binder = require("@modules/binder")

	--// References
	local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self
	local structures = {}

	--// UI
	properties = properties or {}
	properties.Text = properties.Text or "0/0"
	properties.Active = properties.Active == true

	structures.Body = create("Frame")({
		Name = "Badge",
		AutomaticSize = Enum.AutomaticSize.X,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(0, 21),
		Parent = parent,

		__dynamicKeys = {
			BackgroundColor3 = self.Theme.Controls.Badge.Background[1],
			BackgroundTransparency = self.Theme.Controls.Badge.Background[2],
		},

		create("UICorner")({
			Name = "UICorner",
			CornerRadius = UDim.new(1, 0),
		}),

		create("UIPadding")({
			Name = "UIPadding",
			PaddingLeft = UDim.new(0, 9),
			PaddingRight = UDim.new(0, 9),
		}),

		create("UIListLayout")({
			Name = "UIListLayout",
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 6),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		create("Frame")({
			Name = "Dot",
			BorderSizePixel = 0,
			LayoutOrder = 1,
			Size = UDim2.fromOffset(6, 6),

			__dynamicKeys = {
				BackgroundColor3 = self.Theme.Controls.Badge.Text[1],
				BackgroundTransparency = self.Theme.Controls.Badge.Text[2],
			},

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(1, 0),
			}),
		}),

		create("TextLabel")({
			Name = "Label",
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold),
			LayoutOrder = 2,
			RichText = true,
			Size = UDim2.fromOffset(0, 21),
			Text = "0/0",
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,

			__dynamicKeys = {
				TextColor3 = self.Theme.Controls.Badge.Text[1],
				TextTransparency = self.Theme.Controls.Badge.Text[2],
			},
		}),
	})

	structures.Dot = structures.Body.__instance:FindFirstChild("Dot") :: Frame
	structures.Label = structures.Body.__instance:FindFirstChild("Label") :: TextLabel

	--// Initialize
	local function paint(active: boolean, color: Color3?)
		local background = active and self.Theme.Controls.Badge.BackgroundActive or self.Theme.Controls.Badge.Background
		local foreground = active and self.Theme.Controls.Badge.TextActive or self.Theme.Controls.Badge.Text

		structures.Body.BackgroundColor3 = color and active and color:Lerp(Color3.new(0, 0, 0), 0.75) or background[1].Value
		structures.Body.BackgroundTransparency = background[2].Value

		structures.Label.TextColor3 = color and active and color or foreground[1].Value
		structures.Label.TextTransparency = foreground[2].Value

		structures.Dot.BackgroundColor3 = color and active and color or foreground[1].Value
		structures.Dot.BackgroundTransparency = foreground[2].Value
	end

	local object = binder.Wrap(properties, {
		Text = function(value: string)
			structures.Label.Text = value
		end,
		Active = function(value: boolean)
			paint(value, properties.Color)
		end,
		Color = function(value: Color3)
			paint(properties.Active == true, value)
		end,
	}, structures.Body)

	object.Type = "Badge"
	object.Theme = self.Theme
	object.Structures = structures

	binder.Apply(properties, object)

	return object
end
