util.AddNetworkString("VoidFactions.CapturePoints.SyncCapturePoints")

util.AddNetworkString("VoidFactions.CapturePoints.CreateCapturePoint")
util.AddNetworkString("VoidFactions.CapturePoints.DeleteCapturePoint")
util.AddNetworkString("VoidFactions.CapturePoints.UpdateCapturePoint")

local L = VoidFactions.Lang.GetPhrase

-- Functions

function VoidFactions.CapturePoints:SyncCapturePoints(ply)
	net.Start("VoidFactions.CapturePoints.SyncCapturePoints")
	net.WriteUInt(table.Count(VoidFactions.PointsTable), 6)
	for id, point in pairs(VoidFactions.PointsTable) do
		VoidFactions.CapturePoints:WriteCapturePoint(point)
	end
	if (ply) then
		net.Send(ply)
	else
		net.Broadcast()
	end
end

function VoidFactions.CapturePoints:StartCapture(point, faction, startTime, endTime)
	net.Start("VoidFactions.CapturePoints.UpdateCapturePoint")
		net.WriteUInt(VoidFactions.CapturePoints.UpdateEnums.CAPTURE_CHANGE, 3)
		net.WriteUInt(point.id, 6)

		net.WriteBool(true)
		net.WriteFloat(startTime)
		net.WriteFloat(endTime)

		net.WriteUInt(faction.id, 20)
	net.Broadcast()
end

function VoidFactions.CapturePoints:EndCapture(point)
	hook.Run("VoidFactions.CapturePoints.PointCaptureEnd")

	net.Start("VoidFactions.CapturePoints.UpdateCapturePoint")
		net.WriteUInt(VoidFactions.CapturePoints.UpdateEnums.CAPTURE_CHANGE, 3)
		net.WriteUInt(point.id, 6)
		
		net.WriteBool(false)
	net.Broadcast()
end

function VoidFactions.CapturePoints:NetworkFactionChange(point, faction)
	net.Start("VoidFactions.CapturePoints.UpdateCapturePoint")
		net.WriteUInt(VoidFactions.CapturePoints.UpdateEnums.CAPTURE_RESULT, 3)
		net.WriteUInt(point.id, 6)
		net.WriteUInt(faction and faction.id or 0, 20)
	net.Broadcast()
end

function VoidFactions.CapturePoints:NetworkContestFactionChange(point)
	net.Start("VoidFactions.CapturePoints.UpdateCapturePoint")
		net.WriteUInt(VoidFactions.CapturePoints.UpdateEnums.CAPTURE_FACTIONCHANGE, 3)
		net.WriteUInt(point.id, 6)
		net.WriteUInt(point.capturingBy and point.capturingBy.id or 0, 20)
		net.WriteFloat(point.captureStart)
		net.WriteFloat(point.captureEnd)
	net.Broadcast()
end

function VoidFactions.CapturePoints:NetworkContestChange(point, isContested)
	net.Start("VoidFactions.CapturePoints.UpdateCapturePoint")
		net.WriteUInt(VoidFactions.CapturePoints.UpdateEnums.POINT_CONTESTED, 3)
		net.WriteUInt(point.id, 6)
		net.WriteBool(isContested)
	net.Broadcast()
end

function VoidFactions.CapturePoints:NetworkPauseChange(point, timerLeft, isContested)
	net.Start("VoidFactions.CapturePoints.UpdateCapturePoint")
		net.WriteUInt(VoidFactions.CapturePoints.UpdateEnums.POINT_PAUSED, 3)
		net.WriteUInt(point.id, 6)

		net.WriteBool(point.isPaused)
		if (!point.isPaused) then
			net.WriteFloat(point.captureEnd)
		end
	net.Broadcast()
end

-- Net handlers

net.Receive("VoidFactions.CapturePoints.CreateCapturePoint", function (len, ply)
	local radius = net.ReadUInt(16)
	local pos = net.ReadVector()

	if (CAMI.PlayerHasAccess(ply, "VoidFactions_ManageCapturePoints")) then
		VoidFactions.CapturePoints:CreatePoint(pos, radius)
		VoidLib.Notify(ply, L"success", L"capturePointCreated", VoidUI.Colors.Green, 5)
	end
end)

net.Receive("VoidFactions.CapturePoints.DeleteCapturePoint", function (len, ply)
	local id = net.ReadUInt(6)

	local point = VoidFactions.PointsTable[id]
	if (!point) then return end

	if (CAMI.PlayerHasAccess(ply, "VoidFactions_ManageCapturePoints")) then
		VoidFactions.CapturePoints:DeletePoint(point)
		VoidLib.Notify(ply, L"success", L"capturePointDeleted", VoidUI.Colors.Blue, 5)
	end
end)