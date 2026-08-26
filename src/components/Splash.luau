local types = require("@types")

return function(self, properties: types.SplashProperties): types.Splash
	--// Imports
	local creator = require("@modules/creator")
	local binder = require("@modules/binder")
	local symbols = require("@modules/symbols")
	local services = require("@modules/services")

	--// References
	local create = creator.Create

	local tweenService = services.TweenService

	--// Variables
	local parent = self.__container or self.__instance or self
	local metrics = self.Theme.Metrics or {}
	local structures = {}

	local steps = {}
	local index = 1
	local closed = false
	local stallToken = 0

	local accent = self.Theme.Controls.Selection

	--// UI
	properties = properties or {}
	properties.Title = properties.Title or "Starting"
	properties.Steps = properties.Steps or {}
	-- How long one step may sit before the whole list unfolds to show where it is stuck.
	properties.Patience = properties.Patience or 3
	-- Last resort. If whoever raised the splash never gets to Close — because their own setup
	-- threw — it takes itself down anyway rather than sitting on the screen forever.
	properties.Timeout = properties.Timeout or 20

	local function line(text: string, order: number)
		return create("TextLabel")({
			Name = "Step",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Font.new("rbxasset://fonts/families/Code.json"),
			LayoutOrder = order,
			RichText = true,
			Size = UDim2.new(1, 0, 0, 17),
			Text = text,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Center,

			__dynamicKeys = {
				TextColor3 = self.Theme.Text.Tertiary[1],
				TextTransparency = self.Theme.Text.Tertiary[2],
			},
		})
	end

	-- No card and no border: a launch is a moment, not a dialog asking for something.
	structures.Body = create("Frame")({
		Name = "Splash",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 60,
		Parent = parent,

		create("Frame")({
			Name = "Stack",
			AnchorPoint = Vector2.new(0.5, 0.5),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(268, 0),
			ZIndex = 61,

			create("UIListLayout")({
				Name = "UIListLayout",
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = UDim.new(0, 14),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			create("Frame")({
				Name = "Mark",
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Size = UDim2.fromOffset(54, 54),
				ZIndex = 62,

				create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(0, 15) }),

				create("ImageLabel")({
					Name = "Icon",
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0.5, 0.5),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromOffset(28, 28),
					ZIndex = 62,
				}),
			}),

			create("Frame")({
				Name = "Names",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 0),
				ZIndex = 62,

				create("UIListLayout")({
					Name = "UIListLayout",
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0, 2),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),

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
					Size = UDim2.new(1, 0, 0, 26),
					Text = "",
					TextSize = 21,
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
					FontFace = Font.new("rbxasset://fonts/families/Code.json"),
					LayoutOrder = 2,
					RichText = true,
					Size = UDim2.new(1, 0, 0, 16),
					Text = "",
					TextSize = 11.5,
					Visible = false,
					ZIndex = 62,

					__dynamicKeys = {
						TextColor3 = self.Theme.Text.Tertiary[1],
						TextTransparency = self.Theme.Text.Tertiary[2],
					},
				}),
			}),

			create("Frame")({
				Name = "Track",
				BorderSizePixel = 0,
				ClipsDescendants = true,
				LayoutOrder = 3,
				Size = UDim2.new(1, -40, 0, 2),
				ZIndex = 62,

				create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(1, 0) }),

				create("Frame")({
					Name = "Fill",
					BorderSizePixel = 0,
					Size = UDim2.fromScale(0, 1),
					ZIndex = 62,

					create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(1, 0) }),

					__dynamicKeys = {
						BackgroundColor3 = accent[1],
						BackgroundTransparency = accent[2],
					},
				}),

				__dynamicKeys = {
					BackgroundColor3 = self.Theme.Controls.Slider.Track[1],
					BackgroundTransparency = self.Theme.Controls.Slider.Track[2],
				},
			}),

			-- One line, not a checklist. Four steps of prose for two seconds of waiting is noise.
			create("TextLabel")({
				Name = "Status",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Font.new("rbxasset://fonts/families/Code.json"),
				LayoutOrder = 4,
				RichText = true,
				Size = UDim2.new(1, 0, 0, 16),
				Text = "",
				TextSize = 11.5,
				ZIndex = 62,

				__dynamicKeys = {
					TextColor3 = self.Theme.Text.Secondary[1],
					TextTransparency = self.Theme.Text.Secondary[2],
				},
			}),

			-- Unfolds only when a step outstays its welcome, so a hang names itself.
			create("Frame")({
				Name = "Steps",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 5,
				Size = UDim2.new(1, 0, 0, 0),
				Visible = false,
				ZIndex = 62,

				create("UIListLayout")({
					Name = "UIListLayout",
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0, 1),
					SortOrder = Enum.SortOrder.LayoutOrder,
				}),
			}),
		}),
	}) :: Frame

	--// Initialize
	structures.Stack = structures.Body:FindFirstChild("Stack") :: Frame
	structures.Mark = structures.Stack:FindFirstChild("Mark") :: Frame
	structures.Icon = structures.Mark:FindFirstChild("Icon") :: ImageLabel
	structures.Names = structures.Stack:FindFirstChild("Names") :: Frame
	structures.Title = structures.Names:FindFirstChild("Title") :: TextLabel
	structures.Subtitle = structures.Names:FindFirstChild("Subtitle") :: TextLabel
	structures.Track = structures.Stack:FindFirstChild("Track") :: Frame
	structures.Fill = structures.Track:FindFirstChild("Fill") :: Frame
	structures.Status = structures.Stack:FindFirstChild("Status") :: TextLabel
	structures.Steps = structures.Stack:FindFirstChild("Steps") :: Frame

	structures.Mark.BackgroundColor3 = accent[1].Value
	structures.Mark.BackgroundTransparency = 0.86
	structures.Icon.ImageColor3 = accent[1].Value

	local glide = TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

	local function progress()
		local total = math.max(#steps, 1)

		tweenService
			:Create(structures.Fill, glide, { Size = UDim2.fromScale(math.clamp((index - 1) / total, 0, 1), 1) })
			:Play()
	end

	-- A step that takes too long stops being a detail and becomes the whole story.
	local function watch()
		stallToken += 1

		local token = stallToken

		task.delay(properties.Patience, function()
			if token == stallToken and not closed then
				structures.Steps.Visible = #steps > 0
			end
		end)
	end

	local function paintSteps()
		for position, step in steps do
			local done = position < index
			local current = position == index

			step.Instance.Text = (done and "✓  " or current and "•  " or "   ") .. step.Label

			local token = done and self.Theme.Text.Secondary
				or current and accent
				or self.Theme.Text.Tertiary

			step.Instance.TextColor3 = token[1].Value
			step.Instance.TextTransparency = current and token[2].Value or 0.45
		end
	end

	local function say()
		local step = steps[index]

		structures.Status.Text = step and step.Label or ""

		paintSteps()
		progress()
		watch()
	end

	local function build(list: { string })
		for _, step in steps do
			step.Instance:Destroy()
		end

		steps = {}
		index = 1

		for order, text in ipairs(list) do
			local label = line(text, order)

			label.Parent = structures.Steps

			table.insert(steps, { Label = text, Instance = label.__instance or label })
		end

		say()
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

	object.Advance = function()
		index += 1
		say()
	end

	object.Fail = function(_, text: string?)
		stallToken += 1

		local step = steps[index]

		if step then
			step.Instance.Text = "✕  " .. (text or step.Label)
			step.Instance.TextColor3 = self.Theme.Accents.Red[1].Value
			step.Instance.TextTransparency = self.Theme.Accents.Red[2].Value
		end

		structures.Steps.Visible = #steps > 0
		structures.Status.Text = text or "Stopped"
		structures.Status.TextColor3 = self.Theme.Accents.Red[1].Value
	end

	-- Fades everything out, then hands the screen to whatever was waiting behind it.
	object.Close = function()
		if closed then
			return
		end

		closed = true
		stallToken += 1

		-- Whatever happens above, the splash comes down and the window comes up. A launch screen
		-- that can outlive its own Close is worse than no launch screen.
		local function finish()
			if properties.Reveal then
				pcall(function()
					properties.Reveal.Visible = true
				end)
			end

			pcall(function()
				structures.Body:Destroy()
			end)
		end

		-- TweenService wants Instances; structures.Body is the creator proxy around one.
		local faded = pcall(function()
			local fade = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

			tweenService:Create(structures.Body.__instance, fade, { BackgroundTransparency = 1 }):Play()
			tweenService:Create(structures.Mark, fade, { BackgroundTransparency = 1 }):Play()
			tweenService:Create(structures.Icon, fade, { ImageTransparency = 1 }):Play()
			tweenService:Create(structures.Track, fade, { BackgroundTransparency = 1 }):Play()
			tweenService:Create(structures.Fill, fade, { BackgroundTransparency = 1 }):Play()

			for _, label in { structures.Title, structures.Subtitle, structures.Status } do
				tweenService:Create(label, fade, { TextTransparency = 1 }):Play()
			end

			for _, step in steps do
				tweenService:Create(step.Instance, fade, { TextTransparency = 1 }):Play()
			end
		end)

		task.delay(faded and 0.3 or 0, finish)
	end

	binder.Apply(properties, object)

	if properties.Timeout > 0 then
		task.delay(properties.Timeout, function()
			if not closed then
				object.Close()
			end
		end)
	end

	if structures.Icon.Image == "" then
		structures.Icon.Image = symbols.boltFill or ""
	end

	return object
end
