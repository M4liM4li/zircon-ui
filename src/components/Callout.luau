local types = require("@types")

return function(self, properties: types.CalloutProperties): types.Callout
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

	local defaultIcons = {
		info = symbols.infoCircleFill,
		warn = symbols.exclamationmarkTriangleFill,
		danger = symbols.exclamationmarkOctagonFill,
	}

	--// UI
	properties = properties or {}
	properties.Text = properties.Text or ""
	properties.Kind = properties.Kind or "info"

	-- Height is measured off the wrapped label and written in offset. AutomaticSize here fought
	-- the rail and the wrapped text and lost, stretching the box to fill the page.
	structures.Body = create("Frame")({
		Name = "Callout",
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 36),
		Parent = parent,

		create("UICorner")({
			Name = "UICorner",
			CornerRadius = UDim.new(0, metrics.Radius or 6),
		}),

		create("UIPadding")({
			Name = "UIPadding",
			PaddingTop = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
		}),

		create("UIListLayout")({
			Name = "UIListLayout",
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 9),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
		}),

		-- The rail carries the severity colour at full strength; the fill behind it stays a wash.
		-- It lives in a Folder so the list layout leaves it alone, and its height is written in
		-- offset from the body's measured size — a scaled height would fight AutomaticSize.Y.
		create("Folder")({
			Name = "LayoutIgnore",

			create("Frame")({
				Name = "Rail",
				BorderSizePixel = 0,
				Position = UDim2.fromScale(0, 0),
				Size = UDim2.fromOffset(2, 0),
				ZIndex = 2,
			}),
		}),

		create("ImageLabel")({
			Name = "Icon",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromOffset(15, 15),
		}),

		create("TextLabel")({
			Name = "Label",
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Font.new("rbxassetid://12187365364"),
			LayoutOrder = 2,
			RichText = true,
			Size = UDim2.new(1, -24, 0, 0),
			Text = "",
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,

			__dynamicKeys = {
				TextColor3 = self.Theme.Text.Secondary[1],
				TextTransparency = self.Theme.Text.Secondary[2],
			},
		}),
	}) :: Frame

	--// Initialize
	structures.Rail = structures.Body:FindFirstChild("LayoutIgnore"):FindFirstChild("Rail") :: Frame
	structures.Icon = structures.Body:FindFirstChild("Icon") :: ImageLabel
	structures.Label = structures.Body:FindFirstChild("Label") :: TextLabel

	local function tokenFor(kind: string)
		local accents = self.Theme.Accents

		if kind == "danger" then
			return accents.Red
		elseif kind == "warn" then
			return accents.Warning or accents.Red
		end

		return self.Theme.Controls.Selection
	end

	local function paint()
		local token = tokenFor(properties.Kind)
		local color = token[1].Value

		structures.Rail.BackgroundColor3 = color
		structures.Rail.BackgroundTransparency = token[2].Value

		structures.Icon.ImageColor3 = color
		structures.Icon.ImageTransparency = token[2].Value

		structures.Body.BackgroundColor3 = color
		structures.Body.BackgroundTransparency = 0.93
	end

	local verticalPadding = 20
	local horizontalPadding = 12

	local function measure()
		local height = math.max(structures.Label.AbsoluteSize.Y, structures.Icon.AbsoluteSize.Y)

		structures.Body.Size = UDim2.new(1, 0, 0, height + verticalPadding)

		-- The rail has to undo the body's padding: children start inside it, so a rail placed at
		-- 0,0 begins 10px down and overhangs the bottom by the same amount.
		structures.Rail.Position = UDim2.fromOffset(-horizontalPadding, -verticalPadding / 2)
		structures.Rail.Size = UDim2.fromOffset(2, height + verticalPadding)
	end

		-- Size changes arrive in bursts while a window resizes. Coalesce them: one pass per frame
	-- instead of one per signal, per row, per burst.
	local queued = false

	local function schedule()
		if queued then
			return
		end

		queued = true

		task.defer(function()
			queued = false
			measure()
		end)
	end

structures.Label:GetPropertyChangedSignal("AbsoluteSize"):Connect(schedule)
	structures.Body:GetPropertyChangedSignal("AbsoluteSize"):Connect(schedule)
	task.defer(measure)

	self.Theme.Controls.Selection[1]:Connect(paint)
	self.Theme.Accents.Red[1]:Connect(paint)

	local object = binder.Wrap(properties, {
		Kind = function(value: string?)
			properties.Kind = (value == "warn" or value == "danger") and value or "info"

			if not properties.Icon then
				structures.Icon.Image = defaultIcons[properties.Kind] or ""
			end

			paint()
		end,
		Icon = function(value: string?)
			local icon = type(value) == "string" and value or nil

			properties.Icon = icon
			structures.Icon.Image = icon or defaultIcons[properties.Kind] or ""
		end,
		Text = function(value: string?)
			structures.Label.Text = type(value) == "string" and value or ""
			task.defer(measure)
		end,
	}, structures.Body)

	object.Type = "Callout"
	object.Theme = self.Theme
	object.Structures = structures

	binder.Apply(properties, object)

	paint()

	return object
end
