local notificationList = {}

local services = require("@modules/services")
local tweenService = services.TweenService

local activeNotifications = {}
local MAX_NOTIFICATIONS = 4
-- Toasts stack as a plain list, newest at the bottom. The collapsed iOS pile this used to draw
-- overlapped the cards by 12px and shrank each one, which put three titles on top of each other.
local STACK_GAP = 8

function notificationList.AddNotification(notificationObj, frame)
	if #activeNotifications >= MAX_NOTIFICATIONS then
		local oldest = table.remove(activeNotifications, 1)
		if oldest and oldest.Object and oldest.Object.Close then
			oldest.Object:Close()
		end
	end

	table.insert(activeNotifications, {
		Object = notificationObj,
		Frame = frame,
	})

	notificationList.UpdateStack()
end

function notificationList.UpdateStack()
	local total = #activeNotifications
	local offset = 0
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

	-- Newest sits on the bottom edge; each older card is pushed up by the height of the one
	-- below it, so nothing overlaps whatever its size turned out to be.
	for i = total, 1, -1 do
		local notif = activeNotifications[i]
		local frame = notif.Frame.__instance

		if not frame or not frame.Parent then
			continue
		end

		frame.ZIndex = 100 + i

		local scaleObj = frame:FindFirstChild("UIScale")

		if scaleObj then
			scaleObj.Scale = 1
		end

		tweenService:Create(frame, tweenInfo, { Position = UDim2.new(1, -162.5, 1, -offset) }):Play()

		offset += math.max(frame.AbsoluteSize.Y, 56) + STACK_GAP

		-- Every card in the list is fully readable, so none of them get the aged treatment.
		if notif.Object.UpdateState then
			notif.Object:UpdateState(0)
		end
	end
end

function notificationList.RemoveNotification(notificationObj)
	for i, notif in ipairs(activeNotifications) do
		if notif.Object == notificationObj then
			table.remove(activeNotifications, i)
			break
		end
	end

	notificationList.UpdateStack()
end

return notificationList
