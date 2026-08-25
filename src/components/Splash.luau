local types = require("@types")

return function(self, properties: types.SplashProperties): types.Splash
	--// Imports
	local creator = require("@modules/creator")
	local binder = require("@modules/binder")
	local symbols = require("@modules/symbols")

	--// References
	local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self
	local metrics = self.Theme.Metrics or {}
	local structures = {}

	local steps = {}
	local index = 1

	--// UI
	properties = properties or {}
	properties.Title = properties.Title or "Starting"
	properties.Steps = properties.Steps or {}

	local function line(text: string, order: number)
		return create("Frame")({
			Name = "Step",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = order,
			Size = UDim2.new(1, 0, 0, 20),

			create("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			create("ImageLabel")({
				Name = "Mark",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = symbols.circle or "",
				LayoutOrder = 1,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromOffset(14, 14),

				__dynamicKeys = {
					ImageColor3 = self.Theme.Text.Tertiary[1],
					ImageTransparency = self.Theme.Text.Tertiary[2],
				},
			}),

			create("TextLabel")({
				Name = "Label",
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Font.new("rbxassetid://12187365364"),
				LayoutOrder = 2,
				RichText = true,
				Size = UDim2.fromOffset(0, 20),
				Text = text,
				TextSize = 12.5,
				TextXAlignment = Enum.TextXAlignment.Left,

				__dynamicKeys = {
					TextColor3 = self.Theme.Text.Tertiary[1],
					TextTransparency = self.Theme.Text.Tertiary[2],
				},
			}),
		})
	end

	structures.Body = create("Frame")({
		Name = "Splash",
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
				PaddingTop = UDim.new(0, 20),
				PaddingBottom = UDim.new(0, 20),
				PaddingLeft = UDim.new(0, 20),
				PaddingRight = UDim.new(0, 20),
			}),

			create("UIListLayout")({
				Name = "UIListLayout",
				Padding = UDim.new(0, 13),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			create("Frame")({
				Name = "Head",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Size = UDim2.new(1, 0, 0, 34),
				ZIndex = 62,

				create("UIListLayout")({
					Name = "UIListLayout",
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0, 11),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				create("Frame")({
					Name = "Chip",
					BorderSizePixel = 0,
					LayoutOrder = 1,
					Size = UDim2.fromOffset(34, 34),
					ZIndex = 62,

					create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(0, 9) }),

					create("ImageLabel")({
						Name = "Icon",
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						Position = UDim2.fromScale(0.5, 0.5),
						ScaleType = Enum.ScaleType.Fit,
						Size = UDim2.fromOffset(19, 19),
						ZIndex = 62,
					}),
				}),

				create("Frame")({
					Name = "Titles",
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = 2,
					Size = UDim2.new(1, -45, 0, 0),
					ZIndex = 62,

					create("UIListLayout")({ Name = "UIListLayout", SortOrder = Enum.SortOrder.LayoutOrder }),

					create("TextLabel")({
						Name = "Title",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						FontFace = Font.new(
							metrics.Mono and "rbxasset://fonts/families/Code.json" or "rbxassetid://12187365364",
							Enum.FontWeight.Bold,
							Enum.FontStyle.Normal
						),
						LayoutOrder = 1,
						RichText = true,
						Size = UDim2.new(1, 0, 0, 20),
						Text = "",
						TextSize = metrics.SectionTitleSize or 16,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = 62,

						__dynamicKeys = {
							TextColor3 = self.Theme.Text.Primary[1],
							TextTransparency = self.Theme.Text.Primary[2],
						},
					}),

					create("TextLabel")({
						Name = "Subtitle",
						BackgroundTransparency = 1,
						BorderSizePixel = 0,
						FontFace = Font.new("rbxassetid://12187365364"),
						LayoutOrder = 2,
						RichText = true,
						Size = UDim2.new(1, 0, 0, 16),
						Text = "",
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
						Visible = false,
						ZIndex = 62,

						__dynamicKeys = {
							TextColor3 = self.Theme.Text.Secondary[1],
							TextTransparency = self.Theme.Text.Secondary[2],
						},
					}),
				}),
			}),

			create("Frame")({
				Name = "Track",
				BorderSizePixel = 0,
				ClipsDescendants = true,
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 4),
				ZIndex = 62,

				create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(1, 0) }),

				create("Frame")({
					Name = "Fill",
					BorderSizePixel = 0,
					Size = UDim2.fromScale(0, 1),
					ZIndex = 62,

					create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(1, 0) }),

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

			create("Frame")({
				Name = "Steps",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 3,
				Size = UDim2.new(1, 0, 0, 0),
				ZIndex = 62,

				create("UIListLayout")({
					Name = "UIListLayout",
					Padding = UDim.new(0, 3),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			}),
		}),
	}) :: Frame

	--// Initialize
	structures.Card = structures.Body:FindFirstChild("Card") :: Frame
	structures.Head = structures.Card:FindFirstChild("Head") :: Frame
	structures.Chip = structures.Head:FindFirstChild("Chip") :: Frame
	structures.Icon = structures.Chip:FindFirstChild("Icon") :: ImageLabel
	structures.Titles = structures.Head:FindFirstChild("Titles") :: Frame
	structures.Title = structures.Titles:FindFirstChild("Title") :: TextLabel
	structures.Subtitle = structures.Titles:FindFirstChild("Subtitle") :: TextLabel
	structures.Track = structures.Card:FindFirstChild("Track") :: Frame
	structures.Fill = structures.Track:FindFirstChild("Fill") :: Frame
	structures.Steps = structures.Card:FindFirstChild("Steps") :: Frame

	local accent = self.Theme.Controls.Selection

	structures.Chip.BackgroundColor3 = accent[1].Value
	structures.Chip.BackgroundTransparency = 0.88
	structures.Icon.ImageColor3 = accent[1].Value

	local function paintStep(step, state: string)
		local token = state == "done" and (self.Theme.Accents.Green or accent)
			or state == "failed" and self.Theme.Accents.Red
			or state == "now" and accent
			or self.Theme.Text.Tertiary

		step.Mark.Image = (state == "done" and symbols.checkmarkCircleFill)
			or (state == "failed" and symbols.exclamationmarkOctagonFill)
			or (state == "now" and symbols.circleDotted)
			or symbols.circle
			or ""

		step.Mark.ImageColor3 = token[1].Value
		step.Mark.ImageTransparency = token[2].Value

		local text = state == "pending" and self.Theme.Text.Tertiary
			or state == "now" and self.Theme.Text.Primary
			or self.Theme.Text.Secondary

		step.Label.TextColor3 = text[1].Value
		step.Label.TextTransparency = text[2].Value
	end

	local function progress()
		local total = math.max(#steps, 1)

		structures.Fill.Size = UDim2.fromScale(math.clamp((index - 1) / total, 0, 1), 1)
	end

	local function build(list: { string })
		for _, step in steps do
			step.Frame:Destroy()
		end

		steps = {}
		index = 1

		for order, text in ipairs(list) do
			local frame = line(text, order)
			frame.Parent = structures.Steps

			local instance = frame.__instance or frame

			table.insert(steps, {
				Frame = instance,
				Mark = instance:FindFirstChild("Mark"),
				Label = instance:FindFirstChild("Label"),
			})
		end

		for position, step in steps do
			paintStep(step, position == 1 and "now" or "pending")
		end

		progress()
	end

	local object = binder.Wrap(properties, {
		Title = function(value: string?)
			structures.Title.Text = type(value) == "string" and value or ""
		end,
		Subtitle = function(value: string?)
			local text = type(value) == "string" and value or ""

			structures.Subtitle.Text = text
			structures.Subtitle.Visible = text ~= ""
		end,
		Icon = function(value: string?)
			structures.Icon.Image = type(value) == "string" and value or (symbols.boltFill or "")
		end,
		Steps = function(value: { string }?)
			if type(value) ~= "table" then
				return
			end

			properties.Steps = value
			build(value)
		end,
	}, structures.Body)

	object.Type = "Splash"
	object.Theme = self.Theme
	object.Structures = structures

	-- Marks the current step done and lights the next one.
	object.Advance = function()
		local step = steps[index]

		if step then
			paintStep(step, "done")
		end

		index += 1
		progress()

		local following = steps[index]

		if following then
			paintStep(following, "now")
		end
	end

	-- Stops on the step that broke, so a hang is diagnosable instead of mysterious.
	object.Fail = function(_, text: string?)
		local step = steps[index]

		if not step then
			return
		end

		if text then
			step.Label.Text = text
		end

		paintStep(step, "failed")
	end

	object.Close = function()
		structures.Body:Destroy()
	end

	binder.Apply(properties, object)

	if structures.Icon.Image == "" then
		structures.Icon.Image = symbols.boltFill or ""
	end

	return object
end
