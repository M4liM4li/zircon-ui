local types = require("@types")

return function(self, properties: types.RowProperties): types.Row
	--// Imports
	local creator = require("@modules/creator")
	local binder = require("@modules/binder")
	local symbols = require("@modules/symbols")

	--// References
	local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self
	local structures = {}
	local metrics = self.Theme.Metrics or { RowPadding = 10 }

	--// UI
	properties = properties or {}

	structures.Body = binder.Apply(
		properties,
		create("Frame")({
			Name = "Row",
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, metrics.Mono and 42 or 0),
			Parent = parent,

			create("Frame")({
				Name = "LeftAccessory",
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				Size = UDim2.fromScale(0, 1),

				create("UIListLayout")({
					Name = "UIListLayout",
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					Padding = UDim.new(0, 10),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Wraps = true,
				}),

				create("UIPadding")({
					Name = "UIPadding",
					PaddingBottom = UDim.new(0, metrics.RowPadding),
					PaddingLeft = UDim.new(0, metrics.Mono and 12 or 10),
					PaddingRight = UDim.new(0, metrics.Mono and 12 or 10),
					PaddingTop = UDim.new(0, metrics.RowPadding),
				}),
			}),

			create("Frame")({
				Name = "RightAccessory",
				AnchorPoint = Vector2.new(1, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				BackgroundTransparency = 1,
				BorderColor3 = Color3.fromRGB(0, 0, 0),
				BorderSizePixel = 0,
				LayoutOrder = 1,
				Position = UDim2.fromScale(1, 0),
				Size = UDim2.fromScale(0, 1),

				create("UIListLayout")({
					Name = "UIListLayout",
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					Padding = UDim.new(0, 10),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Wraps = true,
				}),

				create("UIPadding")({
					Name = "UIPadding",
					PaddingBottom = UDim.new(0, metrics.RowPadding),
					PaddingLeft = UDim.new(0, metrics.Mono and 12 or 11),
					PaddingRight = UDim.new(0, metrics.Mono and 12 or 11),
					PaddingTop = UDim.new(0, metrics.RowPadding),
				}),
			}),

			create("Folder")({
				Name = "LayoutIgnore",

				create("Frame")({
					Name = "Divider",
					AnchorPoint = Vector2.new(0, 1),
					BorderColor3 = Color3.fromRGB(0, 0, 0),
					BorderSizePixel = 0,
					Position = UDim2.fromScale(0, 1),
					Size = UDim2.new(1, 0, 0, 1),
					Visible = false,

					__dynamicKeys = {
						BackgroundColor3 = self.Theme.Controls.ViewBorder[1],
						BackgroundTransparency = self.Theme.Controls.ViewBorder[2],
					},
				}),
			}),
		})
	) :: Frame

	--// Initialize
	structures.LeftAccessories = structures.Body:FindFirstChild("LeftAccessory") :: Frame
	structures.RightAccessories = structures.Body:FindFirstChild("RightAccessory") :: Frame

	-- A locked row is dimmed, not hidden: seeing what you cannot reach yet is half of knowing
	-- what to aim for. The scrim doubles as the input blocker, so the controls under it go inert.
	structures.Scrim = create("TextButton")({
		Name = "Scrim",
		Active = true,
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Text = "",
		Visible = false,
		ZIndex = 5,
		Parent = structures.Body.__instance or structures.Body,

		__dynamicKeys = {
			BackgroundColor3 = self.Theme.Controls.Background[1],
		},
	})

	structures.Scrim.BackgroundTransparency = 0.62

	structures.Guide = create("Frame")({
		Name = "Guide",
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(7, 0),
		Size = UDim2.new(0, 1, 1, 0),
		Visible = false,
		Parent = structures.Body.__instance or structures.Body,

		__dynamicKeys = {
			BackgroundColor3 = self.Theme.Controls.ViewBorder[1],
			BackgroundTransparency = self.Theme.Controls.ViewBorder[2],
		},
	})

	structures.Reason = create("Frame")({
		Name = "Reason",
		AutomaticSize = Enum.AutomaticSize.X,
		BorderSizePixel = 0,
		LayoutOrder = -1,
		Size = UDim2.fromOffset(0, 21),
		Visible = false,
		Parent = structures.RightAccessories,

		create("UICorner")({
			Name = "UICorner",
			CornerRadius = UDim.new(0, metrics.Radius or 5),
		}),

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
			PaddingLeft = UDim.new(0, 7),
			PaddingRight = UDim.new(0, 7),
		}),

		create("UIListLayout")({
			Name = "UIListLayout",
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 5),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		create("ImageLabel")({
			Name = "Icon",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Image = symbols.lockFill or "",
			LayoutOrder = 1,
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromOffset(12, 12),

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
			FontFace = Font.new("rbxasset://fonts/families/Code.json"),
			LayoutOrder = 2,
			RichText = true,
			Size = UDim2.fromOffset(0, 21),
			Text = "",
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,

			__dynamicKeys = {
				TextColor3 = self.Theme.Text.Tertiary[1],
				TextTransparency = self.Theme.Text.Tertiary[2],
			},
		}),
	})

	structures.Reason.BackgroundColor3 = self.Theme.Controls.View[1].Value
	structures.Reason.BackgroundTransparency = self.Theme.Controls.View[2].Value

	structures.ReasonLabel = (structures.Reason.__instance or structures.Reason):FindFirstChild("Label") :: TextLabel
	structures.ReasonIcon = (structures.Reason.__instance or structures.Reason):FindFirstChild("Icon") :: ImageLabel

	local function updateAccessories()
		local parentWidth = structures.LeftAccessories.Parent.AbsoluteSize.X
		local rightWidth = structures.RightAccessories.AbsoluteSize.X

		local minLeftWidth = 75
		local calculatedLeftWidth = math.max(parentWidth - rightWidth, minLeftWidth)

		if parentWidth - rightWidth < minLeftWidth then
			structures.LeftAccessories.Size = UDim2.new(0, minLeftWidth, 1, 0)
		else
			structures.LeftAccessories.Size = UDim2.new(0, calculatedLeftWidth, 1, 0)
		end
	end

	updateAccessories()
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
			updateAccessories()
		end)
	end

structures.RightAccessories:GetPropertyChangedSignal("AbsoluteSize"):Connect(schedule)
	structures.LeftAccessories.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(schedule)

	local object = binder.Wrap(properties, {
		SearchIndex = function(value: string)
			structures.Body:SetAttribute("SearchIndex", value)
		end,
		-- Pass the reason, not just a flag: "Needs 250K · you have 26.2K" tells you how far off
		-- you are, which is the only thing worth saying at this point.
		Locked = function(value: string?)
			local reason = type(value) == "string" and value or ""
			local locked = reason ~= "" or value == true

			properties.Locked = value

			structures.Scrim.Visible = locked
			structures.Reason.Visible = reason ~= ""
			structures.ReasonLabel.Text = reason

			structures.Body:SetAttribute("Locked", locked)
		end,
		LockIcon = function(value: string?)
			structures.ReasonIcon.Image = type(value) == "string" and value or (symbols.lockFill or "")
		end,
		-- A feature that died. Same chip as Locked, danger palette, and the row is left usable so
		-- the switch can be turned off — a fault must never trap you in it.
		Fault = function(value: string?)
			local reason = type(value) == "string" and value or ""

			properties.Fault = value

			structures.Reason.Visible = reason ~= "" or (properties.Locked or "") ~= ""

			if reason ~= "" then
				structures.ReasonLabel.Text = reason
				structures.ReasonIcon.Image = symbols.exclamationmarkOctagonFill or ""

				local token = self.Theme.Accents.Red

				structures.ReasonLabel.TextColor3 = token[1].Value
				structures.ReasonIcon.ImageColor3 = token[1].Value
				structures.Reason.BackgroundColor3 = token[1].Value
				structures.Reason.BackgroundTransparency = 0.9
			else
				structures.ReasonLabel.Text = type(properties.Locked) == "string" and properties.Locked or ""
				structures.ReasonIcon.Image = symbols.lockFill or ""

				local token = self.Theme.Text.Tertiary

				structures.ReasonLabel.TextColor3 = token[1].Value
				structures.ReasonIcon.ImageColor3 = token[1].Value
				structures.Reason.BackgroundColor3 = self.Theme.Controls.View[1].Value
				structures.Reason.BackgroundTransparency = self.Theme.Controls.View[2].Value
			end

			structures.Body:SetAttribute("Fault", reason ~= "")
		end,
		-- Children indent under the switch that governs them and dim together when it goes off.
		DependsOn = function(value)
			if type(value) ~= "table" then
				return
			end

			properties.DependsOn = value

			structures.Padding.PaddingLeft += UDim.new(0, 18)
			structures.Guide.Visible = true

			local label = value.Title or "the switch above"

			local function follow(on: boolean?)
				object.Locked = (on == false or on == nil) and `{label} is off` or nil
			end

			follow(value.Value)

			local previous = value.ValueChanged

			value.ValueChanged = function(control, on)
				follow(on)

				if previous then
					previous(control, on)
				end
			end
		end,
	}, structures.Body)

	object.Type = "Row"
	object.Theme = self.Theme
	object.Structures = structures
	object.Left = function()
		local newObject = table.clone(object)

		newObject.__container = structures.LeftAccessories

		return newObject
	end
	object.Right = function()
		local newObject = table.clone(object)

		newObject.__container = structures.RightAccessories

		return newObject
	end

	binder.Apply(properties, object)

	return object
end
