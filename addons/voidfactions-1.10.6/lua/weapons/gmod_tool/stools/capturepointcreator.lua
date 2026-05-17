TOOL.Category = "VoidFactions"
TOOL.Name = "Capture Point Creator"


function TOOL:CanCreatePoint(trace)
	if (!trace.Hit) then return end
	local normal = trace.HitNormal
	local x, y = normal.x, normal.y
	local isWithinRing, point = self:IsWithinRing(trace.HitPos.x, trace.HitPos.y)

	if (isWithinRing) then return false end

	if (math.abs(x) > 0.9 or math.abs(y) > 0.9) then
		return false
	else
		return true
	end
end

function TOOL:GetSelectedPoint()
	for k, point in pairs(VoidFactions.PointsTable) do
		if (point.isSelected) then
			return point
		end
	end
end

function TOOL:IsWithinRing(x, y)
	for k, point in pairs(VoidFactions.PointsTable) do
		local pointCenterX = point.pos.x
		local pointCenterY = point.pos.y

		local pointRadius = point.radius
		
		local distSq = math.pow(x - pointCenterX, 2) + math.pow(y - pointCenterY, 2)
		local radSumSq = math.pow((self.radius or 0) + pointRadius, 2) 

		if (distSq <= radSumSq) then
			self.prevPoint = point
			return true, point
		end
	end

	
	return false
end

function TOOL:PointIsWithinRing(x, y)
	for k, point in pairs(VoidFactions.PointsTable) do
		local pointX = point.pos.x
		local pointY = point.pos.y
		local r = point.radius

		local xVal = (x - pointX) * (x - pointX)
		local yVal = (y - pointY) * (y - pointY)
		local rVal = r * r

		if (xVal + yVal < rVal) then
			self.prevPoint = point
			return true, point
		end
	end

	if (self.prevPoint) then
		self.prevPoint.isSelected = false
		self.prevPoint = nil
	end

	return false
end

function TOOL:CreateRing()
	self.ringExists = true
	local ply = LocalPlayer()
	hook.Add("PostDrawOpaqueRenderables", "VoidFactions.CPC.DrawPreview", function ()
		local trace = ply:GetEyeTrace()
		local canPlace = self:CanCreatePoint(trace)

		local ringColor = canPlace and VoidUI.Colors.Green or VoidUI.Colors.Red

		local isInPoint, point = self:PointIsWithinRing(trace.HitPos.x, trace.HitPos.y)
		if (!isInPoint) then
			VoidLib.StartWorldRings()
				VoidLib.AddWorldRing(trace.HitPos, self.radius or 200, 6, 50)
			VoidLib.FinishWorldRings(ringColor)
		else
			point.isSelected = true
		end
	end)
end

function TOOL:Think()
	if (!CLIENT) then return end
	if (!self.ringExists) then
		self:CreateRing()
	end

	if (!self.radius) then
		self.radius = 200
	end

	if (!self.pressingRFrames or !self.pressingEFrames) then
		self.pressingRFrames = 0
		self.pressingEFrames = 0
	end

	if (input.WasKeyPressed(KEY_R)) then
		-- Add to radius
		self.radius = math.min(self.radius + 10, 2000)
	end

	if (input.WasKeyPressed(KEY_E)) then
		-- Remove from radius
		self.radius = math.max(self.radius - 10, 50)
	end

	if (input.IsKeyDown(KEY_R)) then
		self.pressingRFrames = self.pressingRFrames + 1
	else
		self.pressingRFrames = 0
	end

	if (input.IsKeyDown(KEY_E)) then
		self.pressingEFrames = self.pressingEFrames + 1
	else
		self.pressingEFrames = 0
	end

	if (self.pressingRFrames > 40) then
		self.radius = math.min(self.radius + 2, 2000)
	end
	if (self.pressingEFrames > 40) then
		self.radius = math.max(self.radius - 2, 50)
	end

end


function TOOL:Holster()
	if (!CLIENT) then return end

	for k, point in pairs(VoidFactions.PointsTable) do
		if (point.isSelected) then
			point.isSelected = false
		end
	end

	hook.Remove("PostDrawOpaqueRenderables", "VoidFactions.CPC.DrawPreview")
	self.ringExists = false
end

if (CLIENT) then

	TOOL.Information = {
		{ name = "info", stage = 1 },
		{ name = "left" },
		{ name = "right" },

		{ name = "plus", icon = "gui/r.png" },
		{ name = "minus", icon = "gui/e.png" }
	}

	language.Add( "tool.capturepointcreator.name", "Capture Point Creator" )
	language.Add( "tool.capturepointcreator.desc", "Create capture points for VoidFactions!" )

	language.Add( "tool.capturepointcreator.left", "Create a capture point" )
	language.Add( "tool.capturepointcreator.right", "Delete existing capture point" )

	language.Add( "tool.capturepointcreator.plus", "Increase capture point radius" )
	language.Add( "tool.capturepointcreator.minus", "Decrease capture point radius" )

end

function TOOL:LeftClick(trace)
	if (self.prevPos == trace.HitPos) then return end

	local canPlace = self:CanCreatePoint(trace)
	if (!canPlace) then return end

	if (CLIENT) then
		VoidFactions.CapturePoints:CreatePoint(trace.HitPos, self.radius)
		self.prevPos = trace.HitPos
	end

	return true
end

function TOOL:RightClick(trace)
	if (SERVER) then return end
	local activePoint = self:GetSelectedPoint()
	if (!activePoint) then return end

	VoidFactions.CapturePoints:DeletePoint(activePoint)
end

function TOOL:DrawToolScreen(w, h)
	surface.SetDrawColor(VoidUI.Colors.Primary)
	surface.DrawRect(0,0,w,h)

	draw.SimpleText("VoidFactions", "VoidUI.R40", w/2, 60, VoidUI.Colors.White, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("Capture point creator", "VoidUI.R26", w/2, 90, VoidUI.Colors.GrayTransparent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end