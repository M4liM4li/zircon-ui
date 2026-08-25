local types = require("@types")

return function(self, properties: types.PageSectionProperties): types.PageSection
	--// Imports
	local creator = require("@modules/creator")
	local binder = require("@modules/binder")

	local titleStack = require("@structures/TitleStack")

	--// References
	local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self
	local structures = titleStack(self)
	local metrics = self.Theme.Metrics or {}

	--// UI
	properties = properties or {}
	properties.Title = properties.Title or "Title"

	local section = create("Frame")({
		Name = "PageSection",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = parent,

		create("UIListLayout")({
			Name = "UIListLayout",
			Padding = UDim.new(0, 9),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		create("UIPadding")({
			PaddingBottom = UDim.new(0, 9)
		}),
	})

	-- Header holds the optional icon, the title stack and a trailing badge on one line.
	structures.Header = create("Frame")({
		Name = "Header",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = -1,
		Size = UDim2.fromScale(1, 0),
		Parent = section.__instance,

		create("UIListLayout")({
			Name = "UIListLayout",
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 11),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		}),

		-- The glyph sits in a chip washed with its own colour, so the header reads as a heading
		-- rather than a row that happens to start with a picture.
		create("Frame")({
			Name = "Icon",
			BackgroundTransparency = 0.88,
			BorderSizePixel = 0,
			LayoutOrder = 1,
			Size = UDim2.fromOffset(30, 30),
			Visible = false,

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, 8),
			}),

			create("ImageLabel")({
				Name = "Image",
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ImageColor3 = Color3.fromRGB(255, 255, 255),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(18, 18),
			}),
		}),

		create("Frame")({
			Name = "Spacer",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 3,
			Size = UDim2.fromOffset(0, 1),

			create("UIFlexItem")({
				Name = "UIFlexItem",
				FlexMode = Enum.UIFlexMode.Fill,
			}),
		}),

		create("Frame")({
			Name = "Badge",
			AutomaticSize = Enum.AutomaticSize.X,
			BorderSizePixel = 0,
			LayoutOrder = 4,
			Size = UDim2.fromOffset(0, 21),
			Visible = false,

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, metrics.Radius or 999),
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
				FontFace = Font.new(metrics.Mono and "rbxasset://fonts/families/Code.json" or "rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				LayoutOrder = 2,
				RichText = true,
				Size = UDim2.fromOffset(0, 21),
				Text = "0/0",
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
		}),
	})

	structures.Body.Parent = structures.Header.__instance

	--// Initialize
	structures.Icon = structures.Header:FindFirstChild("Icon") :: Frame
	structures.IconImage = structures.Icon:FindFirstChild("Image") :: ImageLabel
	structures.Badge = structures.Header:FindFirstChild("Badge") :: Frame
	structures.BadgeDot = structures.Badge:FindFirstChild("Dot") :: Frame
	structures.BadgeLabel = structures.Badge:FindFirstChild("Label") :: TextLabel

	structures.Padding.PaddingLeft = UDim.new(0, 8)
	structures.Padding.PaddingRight = UDim.new(0, 8)

	structures.Title.FontFace = Font.new(structures.Title.FontFace.Family, Enum.FontWeight.Bold)
	structures.Title.TextSize = metrics.SectionTitleSize or structures.Title.TextSize
	structures.Subtitle.TextSize = metrics.Mono and 12.5 or structures.Subtitle.TextSize
	structures.Body.LayoutOrder = 2

	local badgeTheme = self.Theme.Controls.Badge

	local function paintBadge()
		local active = properties.BadgeActive == true
		local background = active and badgeTheme.BackgroundActive or badgeTheme.Background
		local foreground = active and badgeTheme.TextActive or badgeTheme.Text

		structures.Badge.BackgroundColor3 = background[1].Value
		structures.Badge.BackgroundTransparency = background[2].Value

		structures.BadgeDot.BackgroundColor3 = foreground[1].Value
		structures.BadgeDot.BackgroundTransparency = foreground[2].Value

		structures.BadgeLabel.TextColor3 = foreground[1].Value
		structures.BadgeLabel.TextTransparency = foreground[2].Value
	end

	badgeTheme.Background[1]:Connect(paintBadge)
	badgeTheme.TextActive[1]:Connect(paintBadge)
	paintBadge()

	local object = binder.Wrap(properties, {
		Title = function(value: string)
			structures.Title.Text = value
		end,
		Subtitle = function(value: string)
			structures.Subtitle.Visible = true
			structures.Subtitle.Text = value
		end,
		Icon = function(value: string?)
			structures.Icon.Visible = value ~= nil and value ~= ""
			structures.IconImage.Image = value or ""
		end,
		IconColor = function(value: Color3)
			structures.IconImage.ImageColor3 = value
			structures.Icon.BackgroundColor3 = value
		end,
		-- Text only: the component table is applied over every object, and components.Badge
		-- would otherwise land here as a function and switch the badge on with its default text.
		Badge = function(value: string?)
			local text = type(value) == "string" and value or ""

			structures.Badge.Visible = text ~= ""
			structures.BadgeLabel.Text = text
		end,
		BadgeActive = function(value: boolean)
			properties.BadgeActive = value == true
			paintBadge()
		end,
	}, section)

	object.Type = "PageSection"
	object.Theme = self.Theme
	object.Structures = structures
	object.__container = section.__instance

	binder.Apply(properties, object)

	return object
end
