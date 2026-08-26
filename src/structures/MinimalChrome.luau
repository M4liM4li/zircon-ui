--[[
	Minimal window chrome.

	Swaps the macOS traffic lights and the navigation buttons for a brand mark,
	a version chip, a status pill and plain minimize / close buttons.
]]

return function(self, structures, properties)
	--// Imports
	local creator = require("@modules/creator")

	--// References
	local create = creator.Create

	--// Variables
	local titlebar = structures.Titlebar
	local minimal = {}

	--// UI
	structures.WindowControls.Body.Visible = false
	titlebar.NavigationButtons.Visible = false
	titlebar.SidebarButton.Parent.Visible = false
	titlebar.TitleStack.Visible = false

	minimal.Body = create("Frame")({
		Name = "Brand",
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = -1,
		Size = UDim2.fromOffset(0, 34),
		Parent = titlebar.Leading,

		create("UIListLayout")({
			Name = "UIListLayout",
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),

		create("Frame")({
			Name = "Mark",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			LayoutOrder = 1,
			Size = UDim2.fromOffset(30, 30),

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, 9),
			}),

			create("ImageLabel")({
				Name = "Logo",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Image = "rbxassetid://94472643677558",
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(1, 1),
			}),
		}),

		create("TextLabel")({
			Name = "Title",
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Font.new("rbxasset://fonts/families/Code.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			LayoutOrder = 2,
			RichText = true,
			Size = UDim2.fromOffset(0, 28),
			Text = "Window",
			TextSize = 21,
			TextXAlignment = Enum.TextXAlignment.Left,

			__dynamicKeys = {
				TextColor3 = self.Theme.Text.Primary[1],
				TextTransparency = self.Theme.Text.Primary[2],
			},
		}),

		create("TextLabel")({
			Name = "Subtitle",
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Font.new("rbxasset://fonts/families/Code.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			LayoutOrder = 3,
			RichText = true,
			Size = UDim2.fromOffset(0, 28),
			Text = "",
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			Visible = false,

			__dynamicKeys = {
				TextColor3 = self.Theme.Text.Secondary[1],
				TextTransparency = self.Theme.Text.Secondary[2],
			},

			-- Same box height as the title, then nudged down so the two baselines line up.
			create("UIPadding")({
				Name = "UIPadding",
				PaddingTop = UDim.new(0, 5),
			}),
		}),

		create("Frame")({
			Name = "Game",
			AutomaticSize = Enum.AutomaticSize.X,
			BorderSizePixel = 0,
			LayoutOrder = 4,
			Size = UDim2.fromOffset(0, 20),
			Visible = false,

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, 6),
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
				PaddingLeft = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
			}),

			create("TextLabel")({
				Name = "Label",
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Font.new("rbxasset://fonts/families/Code.json"),
				RichText = true,
				Size = UDim2.fromOffset(0, 20),
				Text = "",
				TextSize = 10.5,
				TextTruncate = Enum.TextTruncate.AtEnd,

				__dynamicKeys = {
					TextColor3 = self.Theme.Text.Secondary[1],
					TextTransparency = self.Theme.Text.Secondary[2],
				},
			}),
		}),

		create("Frame")({
			Name = "Version",
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = 5,
			Size = UDim2.fromOffset(0, 18),
			Visible = false,

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, 8),
			}),

			create("UIStroke")({
				Name = "UIStroke",
				Thickness = 1,

				__dynamicKeys = {
					Color = self.Theme.Text.Tertiary[1],
					Transparency = self.Theme.Text.Tertiary[2],
				},
			}),

			create("UIPadding")({
				Name = "UIPadding",
				PaddingLeft = UDim.new(0, 6),
				PaddingRight = UDim.new(0, 6),
			}),

			create("TextLabel")({
				Name = "Label",
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				FontFace = Font.new("rbxasset://fonts/families/Code.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				Size = UDim2.fromOffset(0, 18),
				Text = "v1.0",
				TextSize = 11,

				__dynamicKeys = {
					TextColor3 = self.Theme.Text.Secondary[1],
					TextTransparency = self.Theme.Text.Secondary[2],
				},
			}),
		}),

		create("Frame")({
			Name = "Status",
			AutomaticSize = Enum.AutomaticSize.X,
			BorderSizePixel = 0,
			LayoutOrder = 6,
			Size = UDim2.fromOffset(0, 23),
			Visible = false,

			__dynamicKeys = {
				BackgroundColor3 = self.Theme.Controls.Badge.BackgroundActive[1],
				BackgroundTransparency = self.Theme.Controls.Badge.BackgroundActive[2],
			},

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, 8),
			}),

			create("UIPadding")({
				Name = "UIPadding",
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
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
					BackgroundColor3 = self.Theme.Controls.Badge.TextActive[1],
					BackgroundTransparency = self.Theme.Controls.Badge.TextActive[2],
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
				FontFace = Font.new("rbxasset://fonts/families/Code.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
				LayoutOrder = 2,
				Size = UDim2.fromOffset(0, 20),
				Text = "",
				TextSize = 11.5,

				__dynamicKeys = {
					TextColor3 = self.Theme.Controls.Badge.TextActive[1],
					TextTransparency = self.Theme.Controls.Badge.TextActive[2],
				},
			}),
		}),
	})

	-- Glyphs are drawn from bars instead of text, so no font has to carry them.
	local function bar(rotation: number)
		return create("Frame")({
			Name = "Bar",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BorderSizePixel = 0,
			Position = UDim2.fromScale(0.5, 0.5),
			Rotation = rotation,
			Size = UDim2.fromOffset(12, 1.5),

			__dynamicKeys = {
				BackgroundColor3 = self.Theme.Text.Secondary[1],
				BackgroundTransparency = self.Theme.Text.Secondary[2],
			},

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(1, 0),
			}),
		})
	end

	local function windowButton(name: string, order: number, rotations: { number })
		local button = create("TextButton")({
			Name = name,
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			LayoutOrder = order,
			Size = UDim2.fromOffset(28, 28),
			Text = "",

			__dynamicKeys = {
				BackgroundColor3 = self.Theme.Text.Primary[1],
			},

			create("UICorner")({
				Name = "UICorner",
				CornerRadius = UDim.new(0, 8),
			}),
		})

		for _, rotation in rotations do
			bar(rotation).Parent = button.__instance
		end

		return button
	end

	minimal.Minimize = windowButton("Minimize", 2, { 0 })
	minimal.Close = windowButton("Close", 3, { 45, -45 })

	minimal.Buttons = create("Frame")({
		Name = "WindowButtons",
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 2,
		Size = UDim2.fromOffset(0, 26),
		Parent = titlebar.Trailing,

		create("UIListLayout")({
			Name = "UIListLayout",
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center,
		}),
	})

	minimal.Minimize.Parent = minimal.Buttons.__instance
	minimal.Close.Parent = minimal.Buttons.__instance

	-- The stock trailing area stacks vertically, the minimal chrome needs one row.
	local trailingLayout = titlebar.Trailing:FindFirstChild("UIListLayout") :: UIListLayout

	if trailingLayout then
		trailingLayout.FillDirection = Enum.FillDirection.Horizontal
		trailingLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		trailingLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		trailingLayout.Padding = UDim.new(0, 8)
	end

	--// Initialize
	minimal.Mark = minimal.Body:FindFirstChild("Mark") :: Frame
	minimal.Logo = minimal.Mark:FindFirstChild("Logo") :: ImageLabel
	minimal.Game = minimal.Body:FindFirstChild("Game") :: Frame
	minimal.GameLabel = minimal.Game:FindFirstChild("Label") :: TextLabel
	minimal.Title = minimal.Body:FindFirstChild("Title") :: TextLabel
	minimal.Subtitle = minimal.Body:FindFirstChild("Subtitle") :: TextLabel
	minimal.Version = minimal.Body:FindFirstChild("Version") :: Frame
	minimal.VersionLabel = minimal.Version:FindFirstChild("Label") :: TextLabel
	minimal.Status = minimal.Body:FindFirstChild("Status") :: Frame
	minimal.StatusLabel = minimal.Status:FindFirstChild("Label") :: TextLabel

	-- Kills the engine's blue focus ring on the search box.
	local focusBlocker = create("Frame")({
		Name = "FocusBlocker",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
	}).__instance

	titlebar.SearchField.Field.SelectionImageObject = focusBlocker
	titlebar.SearchField.Body.SelectionImageObject = focusBlocker

	minimal.Title.Text = properties.Title or "Window"

	if properties.Logo then
		minimal.Logo.Image = properties.Logo
	end

	minimal.Game.BackgroundColor3 = self.Theme.Controls.View[1].Value
	minimal.Game.BackgroundTransparency = self.Theme.Controls.View[2].Value

	minimal.Game.Visible = (properties.Game or "") ~= ""
	minimal.GameLabel.Text = properties.Game or ""

	-- An asset that never resolves used to leave a hole where the mark should be. Give it a few
	-- seconds, then take the space back rather than reserving it for a picture that is not coming.
	minimal.CheckLogo = function()
		if minimal.LogoWatch then
			minimal.LogoWatch:Disconnect()
			minimal.LogoWatch = nil
		end

		if minimal.Logo.Image == "" then
			minimal.Mark.Visible = false
			return
		end

		minimal.Mark.Visible = true

		-- A slow image is not a missing one: if it turns up after the grace period, take the slot back.
		minimal.LogoWatch = minimal.Logo:GetPropertyChangedSignal("IsLoaded"):Connect(function()
			if minimal.Logo.IsLoaded then
				minimal.Mark.Visible = true
			end
		end)

		task.delay(4, function()
			if minimal.Mark.Parent and not minimal.Logo.IsLoaded then
				minimal.Mark.Visible = false
			end
		end)
	end

	minimal.CheckLogo()

	minimal.Subtitle.Text = properties.Subtitle or ""
	minimal.Subtitle.Visible = (properties.Subtitle or "") ~= ""

	titlebar.SearchField.Body.LayoutOrder = 1

	return minimal
end
