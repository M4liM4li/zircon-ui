local types = require("@types")

return function(self, properties: types.StatusLineProperties): types.StatusLine
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
	properties.Text = properties.Text or "Idle"
	properties.Active = properties.Active == true

	structures.Body = create("Frame")({
		Name = "StatusLine",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 20),
		Parent = parent,

		create("UIListLayout")({
			Name = "UIListLayout",
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 9),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		create("Frame")({
			Name = "Dot",
			BorderSizePixel = 0,
			LayoutOrder = 1,
			Size = UDim2.fromOffset(8, 8),

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(1, 0),
			}),

			create("UIStroke")({
				Name = "Halo",
				Thickness = 3,
				Transparency = 0.8,
			}),
		}),

		create("TextLabel")({
			Name = "Label",
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Font.new("rbxasset://fonts/families/Code.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			LayoutOrder = 2,
			RichText = true,
			Size = UDim2.fromOffset(0, 18),
			Text = "Idle",
			TextSize = 13.5,
			TextXAlignment = Enum.TextXAlignment.Left,
		}),
	}) :: Frame

	--// Initialize
	structures.Dot = structures.Body:FindFirstChild("Dot") :: Frame
	structures.Halo = structures.Dot:FindFirstChild("Halo") :: UIStroke
	structures.Label = structures.Body:FindFirstChild("Label") :: TextLabel

	local function paint()
		local color = properties.Active
			and (properties.Color or self.Theme.Controls.Badge.TextActive[1].Value)
			or self.Theme.Text.Tertiary[1].Value

		structures.Dot.BackgroundColor3 = color
		structures.Halo.Color = color
		structures.Halo.Enabled = properties.Active == true
		structures.Label.TextColor3 = color
		structures.Label.TextTransparency = properties.Active and 0 or self.Theme.Text.Tertiary[2].Value
	end

	self.Theme.Text.Tertiary[1]:Connect(paint)
	self.Theme.Controls.Badge.TextActive[1]:Connect(paint)
	paint()

	local object = binder.Wrap(properties, {
		Text = function(value: string)
			structures.Label.Text = value
		end,
		Active = function(value: boolean)
			properties.Active = value == true
			paint()
		end,
		Color = function(value: Color3?)
			properties.Color = value
			paint()
		end,
	}, structures.Body)

	object.Type = "StatusLine"
	object.Theme = self.Theme
	object.Structures = structures

	binder.Apply(properties, object)

	return object
end
