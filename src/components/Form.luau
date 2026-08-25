local types = require("@types")

return function(self, properties: types.Frame): types.Form
	--// Imports
	local creator = require("@modules/creator")
	local binder = require("@modules/binder")

	--// References
	local create = creator.Create

	--// Variables
	local parent = self.__container or self.__instance or self
	local structures = {}
	local metrics = self.Theme.Metrics or {}
	local queue = {}
	local entries = {}

	--// UI
	properties = properties or {}

	structures.Body = binder.Apply(
		properties,
		create("Frame")({
			Name = "Form",
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 0),
			Parent = parent,

			create("UIListLayout")({
				Name = "UIListLayout",
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),

			create("UIPadding")({
				Name = "Margins",
				PaddingLeft = UDim.new(0, metrics.Mono and 0 or 10),
				PaddingRight = UDim.new(0, metrics.Mono and 0 or 10),
			}),
		})
	) :: Frame

	--// Initialize
	local object = binder.Wrap(properties, {}, structures.Body)

	object.Type = "Form"
	object.Theme = self.Theme
	object.Structures = structures

	local function updateDivs()
		for i, entry in ipairs(entries) do
			local currentVisible = entry.section.Visible
			local nextEntry = entries[i + 1]
			local nextVisible = nextEntry and nextEntry.section.Visible

			entry.divider.Visible = currentVisible and nextVisible == true
		end
	end

	structures.Body.ChildAdded:Connect(function(child)
		if child:IsA("Frame") and child:FindFirstChild("LayoutIgnore") then
			local divider = child.LayoutIgnore:FindFirstChild("Divider")

			if divider then
				table.insert(queue, divider)
				table.insert(entries, { section = child, divider = divider })

				child:GetPropertyChangedSignal("Visible"):Connect(function()
					updateDivs()
				end)

				updateDivs()
			end
		end
	end)

	binder.Apply(properties, object)

	return object
end
