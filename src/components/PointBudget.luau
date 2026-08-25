local types = require("@types")

return function(self, properties: types.PointBudgetProperties): types.PointBudget
	--// Imports
	local creator = require("@modules/creator")
	local binder = require("@modules/binder")

	--// References
	local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self
	local metrics = self.Theme.Metrics or {}
	local structures = {}

	local lines = {}
	local pending = {}

	--// UI
	properties = properties or {}
	properties.Pool = properties.Pool or "points to spend"
	properties.Value = properties.Value or 0
	properties.Rows = properties.Rows or {}
	properties.Apply = properties.Apply or "Apply"

	local accent = self.Theme.Controls.Selection

	local function queued()
		local total = 0

		for _, amount in pending do
			total += amount
		end

		return total
	end

	local function stepButton(name: string, glyph: string, order: number)
		return create("TextButton")({
			Name = name,
			AutoButtonColor = false,
			BorderSizePixel = 0,
			FontFace = Font.new("rbxasset://fonts/families/Code.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			LayoutOrder = order,
			Size = UDim2.fromOffset(20, 20),
			Text = glyph,
			TextSize = 13,

			create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(0, 5) }),

			create("UIStroke")({
				Name = "UIStroke",
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 1,

				__dynamicKeys = {
					Color = self.Theme.Controls.ViewBorder[1],
					Transparency = self.Theme.Controls.ViewBorder[2],
				},
			}),

			__dynamicKeys = {
				BackgroundColor3 = self.Theme.Controls.Stepper.Background[1],
				BackgroundTransparency = self.Theme.Controls.Stepper.Background[2],
				TextColor3 = self.Theme.Text.Secondary[1],
				TextTransparency = self.Theme.Text.Secondary[2],
			},
		})
	end

	structures.Body = create("Frame")({
		Name = "PointBudget",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		Parent = parent,

		create("UIListLayout")({
			Name = "UIListLayout",
			Padding = UDim.new(0, 13),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),

		create("Frame")({
			Name = "Budget",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 1,
			Size = UDim2.new(1, 0, 0, 30),

			create("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 9),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
			}),

			create("TextLabel")({
				Name = "Points",
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Font.new("rbxasset://fonts/families/Code.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				LayoutOrder = 1,
				Size = UDim2.fromOffset(0, 30),
				Text = "0",
				TextSize = 26,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom,

				__dynamicKeys = {
					TextColor3 = accent[1],
					TextTransparency = accent[2],
				},
			}),

			create("TextLabel")({
				Name = "Pool",
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Font.new("rbxasset://fonts/families/Code.json"),
				LayoutOrder = 2,
				Size = UDim2.fromOffset(0, 20),
				Text = "",
				TextSize = 11,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom,

				__dynamicKeys = {
					TextColor3 = self.Theme.Text.Tertiary[1],
					TextTransparency = self.Theme.Text.Tertiary[2],
				},
			}),

			create("Frame")({
				Name = "Spacer",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 3,
				Size = UDim2.fromOffset(0, 1),

				create("UIFlexItem")({ Name = "UIFlexItem", FlexMode = Enum.UIFlexMode.Fill }),
			}),

			create("TextButton")({
				Name = "Commit",
				AutoButtonColor = false,
				AutomaticSize = Enum.AutomaticSize.X,
				BorderSizePixel = 0,
				FontFace = Font.new("rbxasset://fonts/families/Code.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				LayoutOrder = 4,
				Size = UDim2.fromOffset(0, metrics.ControlHeight or 28),
				Text = "",
				TextSize = metrics.ControlTextSize or 13,
				Visible = false,

				create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(0, metrics.Radius or 7) }),

				create("UIPadding")({
					Name = "UIPadding",
					PaddingLeft = UDim.new(0, 13),
					PaddingRight = UDim.new(0, 13),
				}),
			}),
		}),

		create("Frame")({
			Name = "Rows",
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 2,
			Size = UDim2.new(1, 0, 0, 0),

			create("UIListLayout")({
				Name = "UIListLayout",
				Padding = UDim.new(0, 10),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		}),
	}) :: Frame

	--// Initialize
	structures.Budget = structures.Body:FindFirstChild("Budget") :: Frame
	structures.Points = structures.Budget:FindFirstChild("Points") :: TextLabel
	structures.PoolLabel = structures.Budget:FindFirstChild("Pool") :: TextLabel
	structures.Commit = structures.Budget:FindFirstChild("Commit") :: TextButton
	structures.Rows = structures.Body:FindFirstChild("Rows") :: Frame

	structures.Commit.BackgroundColor3 = accent[1].Value
	structures.Commit.BackgroundTransparency = accent[2].Value
	structures.Commit.TextColor3 = self.Theme.Controls.Background[1].Value

	local function line(row, order: number)
		local body = create("Frame")({
			Name = "Stat",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = order,
			Size = UDim2.new(1, 0, 0, 20),

			create("UIListLayout")({
				Name = "UIListLayout",
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0, 11),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			}),

			create("TextLabel")({
				Name = "Name",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Font.new("rbxassetid://12187365364"),
				LayoutOrder = 1,
				Size = UDim2.fromOffset(88, 20),
				Text = row.Name,
				TextSize = metrics.TitleSize or 14,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Left,

				__dynamicKeys = {
					TextColor3 = self.Theme.Text.Primary[1],
					TextTransparency = self.Theme.Text.Primary[2],
				},
			}),

			create("Frame")({
				Name = "Bar",
				BorderSizePixel = 0,
				ClipsDescendants = true,
				LayoutOrder = 2,
				Size = UDim2.new(1, -210, 0, 6),

				create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(1, 0) }),

				create("UIFlexItem")({ Name = "UIFlexItem", FlexMode = Enum.UIFlexMode.Fill }),

				create("Frame")({
					Name = "Fill",
					BorderSizePixel = 0,
					Size = UDim2.fromScale(0, 1),

					create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(1, 0) }),

					__dynamicKeys = {
						BackgroundColor3 = accent[1],
						BackgroundTransparency = accent[2],
					},
				}),

				-- What you are about to add, shown before you commit it.
				create("Frame")({
					Name = "Queued",
					BorderSizePixel = 0,
					Size = UDim2.fromScale(0, 1),
					Visible = false,

					create("UICorner")({ Name = "UICorner", CornerRadius = UDim.new(1, 0) }),

					__dynamicKeys = {
						BackgroundColor3 = accent[1],
					},
				}),

				__dynamicKeys = {
					BackgroundColor3 = self.Theme.Controls.Slider.Track[1],
					BackgroundTransparency = self.Theme.Controls.Slider.Track[2],
				},
			}),

			create("Frame")({
				Name = "Amount",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				LayoutOrder = 3,
				Size = UDim2.fromOffset(112, 20),

				create("UIListLayout")({
					Name = "UIListLayout",
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					Padding = UDim.new(0, 7),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),

				stepButton("Down", "−", 1),

				create("TextLabel")({
					Name = "Value",
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					FontFace = Font.new("rbxasset://fonts/families/Code.json"),
					LayoutOrder = 2,
					RichText = true,
					Size = UDim2.fromOffset(0, 20),
					Text = "0",
					TextSize = 12,

					__dynamicKeys = {
						TextColor3 = self.Theme.Text.Primary[1],
						TextTransparency = self.Theme.Text.Primary[2],
					},
				}),

				stepButton("Up", "+", 3),
			}),
		})

		local instance = body.__instance or body

		instance.Parent = structures.Rows

		local bar = instance:FindFirstChild("Bar")
		local amount = instance:FindFirstChild("Amount")

		return {
			Row = row,
			Frame = instance,
			Fill = bar:FindFirstChild("Fill"),
			Queued = bar:FindFirstChild("Queued"),
			Value = amount:FindFirstChild("Value"),
			Down = amount:FindFirstChild("Down"),
			Up = amount:FindFirstChild("Up"),
		}
	end

	local function ceiling()
		local top = 1

		for _, entry in lines do
			top = math.max(top, (entry.Row.Value or 0) + (pending[entry.Row.Name] or 0))
		end

		return top
	end

	local function refresh()
		local left = math.max((properties.Value or 0) - queued(), 0)
		local top = ceiling()

		structures.Points.Text = tostring(left)
		structures.Commit.Visible = queued() > 0
		structures.Commit.Text = `{properties.Apply} {queued()}`

		for _, entry in lines do
			local base = entry.Row.Value or 0
			local extra = pending[entry.Row.Name] or 0

			entry.Fill.Size = UDim2.fromScale(base / top, 1)

			entry.Queued.Visible = extra > 0
			entry.Queued.Position = UDim2.fromScale(base / top, 0)
			entry.Queued.Size = UDim2.fromScale(extra / top, 1)
			entry.Queued.BackgroundTransparency = 0.65

			entry.Value.Text = extra > 0
					and `{base}  <font color="#{accent[1].Value:ToHex()}">+{extra}</font>`
				or tostring(base)

			-- Plus stops at zero left, so a spend that cannot happen never leaves the panel.
			entry.Up.TextTransparency = left > 0 and self.Theme.Text.Secondary[2].Value or 0.72
			entry.Down.TextTransparency = extra > 0 and self.Theme.Text.Secondary[2].Value or 0.72
		end
	end

	local function build(rows)
		for _, entry in lines do
			entry.Frame:Destroy()
		end

		lines = {}
		pending = {}

		for order, row in ipairs(rows) do
			local entry = line(row, order)

			entry.Up.MouseButton1Click:Connect(function()
				if (properties.Value or 0) - queued() <= 0 then
					return
				end

				pending[row.Name] = (pending[row.Name] or 0) + 1
				refresh()
			end)

			entry.Down.MouseButton1Click:Connect(function()
				local extra = pending[row.Name] or 0

				if extra <= 0 then
					return
				end

				pending[row.Name] = extra - 1
				refresh()
			end)

			table.insert(lines, entry)
		end

		refresh()
	end

	local object = binder.Wrap(properties, {
		Pool = function(value: string?)
			structures.PoolLabel.Text = type(value) == "string" and string.upper(value) or ""
		end,
		Apply = function(value: string?)
			if type(value) ~= "string" then
				return
			end

			properties.Apply = value
			refresh()
		end,
		Value = function(value: number?)
			properties.Value = tonumber(value) or 0
			refresh()
		end,
		Rows = function(value)
			if type(value) ~= "table" then
				return
			end

			properties.Rows = value
			build(value)
		end,
	}, structures.Body)

	object.Type = "PointBudget"
	object.Theme = self.Theme
	object.Structures = structures

	structures.Commit.MouseButton1Click:Connect(function()
		if queued() <= 0 then
			return
		end

		local batch = table.clone(pending)

		pending = {}
		refresh()

		if properties.Committed then
			task.spawn(properties.Committed, object, batch)
		end
	end)

	binder.Apply(properties, object)

	return object
end
