local types = require("@types")

return function(self, properties: types.StatGridProperties): types.StatGrid
	--// Imports
	local creator = require("@modules/creator")
	local binder = require("@modules/binder")

	--// References
	local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self
	local structures = {}

	local gutter = 9

	--// UI
	properties = properties or {}
	properties.Minimum = properties.Minimum or 150

	structures.Body = create("Frame")({
		Name = "StatGrid",
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 0),
		Parent = parent,

		create("UIListLayout")({
			Name = "UIListLayout",
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, gutter),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			Wraps = true,
		}),
	}) :: Frame

	structures.Layout = structures.Body:FindFirstChild("UIListLayout") :: UIListLayout

	--// Initialize
	-- Tiles are sized by the grid: fit as many columns of at least `Minimum`
	-- as the width allows, then split the leftover evenly so rows stay flush.
	local function measure()
		local available = structures.Body.AbsoluteSize.X

		if available <= 0 then
			return
		end

		local minimum = properties.Minimum
		local columns = math.max(1, math.floor((available + gutter) / (minimum + gutter)))
		local cell = math.floor((available - gutter * (columns - 1)) / columns)

		for _, child in structures.Body:GetChildren() do
			if not child:IsA("GuiObject") or child.Name ~= "StatTile" then
				continue
			end

			local wide = child:GetAttribute("Wide") == true and columns > 1

			child.Size = UDim2.fromOffset(wide and (cell * 2 + gutter) or cell, 0)
		end
	end

	structures.Body:GetPropertyChangedSignal("AbsoluteSize"):Connect(measure)
	structures.Body.ChildAdded:Connect(function(child: Instance)
		if child:IsA("GuiObject") then
			task.defer(measure)
		end
	end)

	local object = binder.Wrap(properties, {
		Minimum = function(value: number)
			properties.Minimum = value
			measure()
		end,
	}, structures.Body)

	object.Type = "StatGrid"
	object.Theme = self.Theme
	object.Structures = structures
	object.__container = structures.Body.__instance

	binder.Apply(properties, object)

	task.defer(measure)

	return object
end
