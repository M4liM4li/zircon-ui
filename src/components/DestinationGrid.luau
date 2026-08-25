local types = require("@types")

return function(self, properties: types.DestinationGridProperties): types.DestinationGrid
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

	local gutter = 8
	local cards = {}
	local query = ""

	--// UI
	properties = properties or {}
	properties.Places = properties.Places or {}
	properties.Placeholder = properties.Placeholder or "Where to"
	properties.Minimum = properties.Minimum or 122

	local accent = self.Theme.Controls.Selection

	structures.Body = create("Frame")({
		Name = "DestinationGrid",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = parent,

		create("UIListLayout")({
			Name = "UIListLayout",
			Padding = UDim.new(0, 11),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		create("Frame")({
			Name = "Search",
			BorderSizePixel = 0,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, metrics.ControlHeight or 30),

			create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(0, metrics.Radius or 8) }),

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
				PaddingLeft = UDim.new(0, 11),
				PaddingRight = UDim.new(0, 11),
			}),

			create("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 9),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			create("ImageLabel")({
				Name = "Icon",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = symbols.magnifyingglass or "",
				LayoutOrder = 1,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromOffset(15, 15),

				__dynamicKeys = {
					ImageColor3 = self.Theme.Text.Tertiary[1],
					ImageTransparency = self.Theme.Text.Tertiary[2],
				},
			}),

			create("TextBox")({
				Name = "Field",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ClearTextOnFocus = false,
				FontFace = Font.new("rbxassetid://12187365364"),
				LayoutOrder = 2,
				PlaceholderText = "",
				Size = UDim2.new(1, -110, 1, 0),
				Text = "",
				TextSize = metrics.ControlTextSize or 14,
				TextXAlignment = Enum.TextXAlignment.Left,

				__dynamicKeys = {
					TextColor3 = self.Theme.Text.Primary[1],
					TextTransparency = self.Theme.Text.Primary[2],
					PlaceholderColor3 = self.Theme.Text.Tertiary[1],
				},
			}),

			create("TextLabel")({
				Name = "Count",
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Font.new("rbxasset://fonts/families/Code.json"),
				LayoutOrder = 3,
				Size = UDim2.fromOffset(0, 20),
				Text = "",
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Right,

				__dynamicKeys = {
					TextColor3 = accent[1],
					TextTransparency = accent[2],
				},
			}),
		}),

		create("Frame")({
			Name = "Grid",
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, 0),

			create("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, gutter),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				Wraps = true,
			}),
		}),
	}) :: Frame

	--// Initialize
	structures.Search = structures.Body:FindFirstChild("Search") :: Frame
	structures.Field = structures.Search:FindFirstChild("Field") :: TextBox
	structures.Count = structures.Search:FindFirstChild("Count") :: TextLabel
	structures.Grid = structures.Body:FindFirstChild("Grid") :: Frame

	structures.Search.BackgroundColor3 = self.Theme.Controls.View[1].Value
	structures.Search.BackgroundTransparency = self.Theme.Controls.View[2].Value

	local function card(place, order: number)
		local body = create("TextButton")({
			Name = "Destination",
			AutoButtonColor = false,
			AutomaticSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0,
			LayoutOrder = order,
			Size = UDim2.fromOffset(properties.Minimum, 0),
			Text = "",

			create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(0, metrics.Radius or 8) }),

			create("UIStroke")({ Name = "UIStroke", ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 1 }),

			create("UIPadding")({
				Name = "UIPadding",
				PaddingTop = UDim.new(0, 9),
				PaddingBottom = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 11),
				PaddingRight = UDim.new(0, 11),
			}),

			create("UIListLayout")({ Name = "UIListLayout", Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder }),

			create("TextLabel")({
				Name = "Name",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Font.new("rbxassetid://12187365364"),
				LayoutOrder = 1,
				RichText = true,
				Size = UDim2.new(1, 0, 0, 0),
				Text = place.Name,
				TextSize = 13,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left,

				__dynamicKeys = {
					TextColor3 = self.Theme.Text.Primary[1],
					TextTransparency = self.Theme.Text.Primary[2],
				},
			}),

			create("TextLabel")({
				Name = "Detail",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Font.new("rbxasset://fonts/families/Code.json"),
				LayoutOrder = 2,
				Size = UDim2.new(1, 0, 0, 14),
				Text = place.Detail or "",
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Left,
				Visible = (place.Detail or "") ~= "",

				__dynamicKeys = {
					TextColor3 = self.Theme.Text.Tertiary[1],
					TextTransparency = self.Theme.Text.Tertiary[2],
				},
			}),
		})

		local instance = body.__instance or body

		instance.Parent = structures.Grid

		return {
			Place = place,
			Frame = instance,
			Name = instance:FindFirstChild("Name"),
			Detail = instance:FindFirstChild("Detail"),
			Stroke = instance:FindFirstChild("UIStroke"),
			Button = instance,
		}
	end

	local function paint(entry)
		local place = entry.Place
		local here = properties.Selected ~= nil and properties.Selected == place.Name
		local locked = (place.Locked or "") ~= ""

		entry.Frame.BackgroundColor3 = here and accent[1].Value or self.Theme.Controls.View[1].Value
		entry.Frame.BackgroundTransparency = here and 0.92 or self.Theme.Controls.View[2].Value

		entry.Stroke.Color = here and accent[1].Value or self.Theme.Controls.ViewBorder[1].Value
		entry.Stroke.Transparency = here and accent[2].Value or self.Theme.Controls.ViewBorder[2].Value

		local detail = here and (place.Here or "you are here") or (locked and place.Locked or place.Detail or "")

		entry.Detail.Text = detail
		entry.Detail.Visible = detail ~= ""

		local token = here and accent or self.Theme.Text.Tertiary

		entry.Detail.TextColor3 = token[1].Value
		entry.Detail.TextTransparency = token[2].Value

		-- Out of reach stays visible, just dimmed: the list is also a map of what to aim for.
		entry.Name.TextTransparency = locked and 0.55 or self.Theme.Text.Primary[2].Value
	end

	local function fits(place)
		if query == "" then
			return true
		end

		return string.find(string.lower(place.Name), query, 1, true) ~= nil
	end

	local function measure()
		local available = structures.Grid.AbsoluteSize.X

		if available <= 0 then
			return
		end

		local columns = math.max(1, math.floor((available + gutter) / (properties.Minimum + gutter)))
		local cell = math.floor((available - gutter * (columns - 1)) / columns)
		local shown = 0

		for _, entry in cards do
			local visible = fits(entry.Place)

			entry.Frame.Visible = visible
			entry.Frame.Size = UDim2.fromOffset(cell, 0)

			if visible then
				shown += 1
			end
		end

		structures.Count.Text = query == "" and `{#cards} places` or `{shown} of {#cards}`
	end

	local function build(places)
		for _, entry in cards do
			entry.Frame:Destroy()
		end

		cards = {}

		for order, place in ipairs(places) do
			local entry = card(type(place) == "table" and place or { Name = tostring(place) }, order)

			entry.Button.MouseButton1Click:Connect(function()
				if (entry.Place.Locked or "") ~= "" then
					return
				end

				properties.Selected = entry.Place.Name

				for _, other in cards do
					paint(other)
				end

				if properties.Chosen then
					task.spawn(properties.Chosen, nil, entry.Place.Name, entry.Place)
				end
			end)

			table.insert(cards, entry)
			paint(entry)
		end

		measure()
	end

	structures.Grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(measure)

	structures.Field:GetPropertyChangedSignal("Text"):Connect(function()
		query = string.lower(structures.Field.Text)
		measure()
	end)

	local object = binder.Wrap(properties, {
		Placeholder = function(value: string?)
			structures.Field.PlaceholderText = type(value) == "string" and value or ""
		end,
		Places = function(value)
			if type(value) ~= "table" then
				return
			end

			properties.Places = value
			build(value)
		end,
		Selected = function(value: string?)
			properties.Selected = value

			for _, entry in cards do
				paint(entry)
			end
		end,
	}, structures.Body)

	object.Type = "DestinationGrid"
	object.Theme = self.Theme
	object.Structures = structures

	object.Refresh = function()
		build(properties.Places)
	end

	binder.Apply(properties, object)

	return object
end
