VoidFactions.CapturePoints = VoidFactions.CapturePoints or {}
VoidFactions.PointsTable = VoidFactions.PointsTable or {}

local L = VoidFactions.Lang.GetPhrase

-- Functions

function VoidFactions.CapturePoints:CreatePoint(pos, radius)
	VoidFactions.SQL:CreateCapturePoint(pos, radius, function (id)
		local capturePoint = VoidFactions.CapturePoints:InitCapturePoint(id, pos, radius)
		VoidFactions.PointsTable[id] = capturePoint

		VoidFactions.CapturePoints:SyncCapturePoints()
	end)
end

function VoidFactions.CapturePoints:DeletePoint(point)
	VoidFactions.SQL:DeleteCapturePoint(point)

	VoidFactions.PointsTable[point.id] = nil
	point = nil

	VoidFactions.CapturePoints:SyncCapturePoints()
end

function VoidFactions.CapturePoints:PlayerStartCapture(ply, point)

	local faction = ply:GetVFFaction()
	if (!faction) then return end
	faction = faction:GetRootFaction()

	local isOwnPoint = point.captureFaction and point.captureFaction.id == faction.id or false

	if (point.isPaused) then
		local timerId = "VoidFactions.CapturePoint." .. point.id .. ".Expire"
		local timerLeft = timer.TimeLeft(timerId)

		VoidFactions.CapturePoints:ChangePaused(point, false, timerLeft)
		timer.Remove(timerId)

		if (point.captureInProgress and point.capturingBy != faction) then
						
			local startTime = CurTime()
			local endTime = startTime + math.max((VoidFactions.Config.CaptureTime - faction:SumOfUpgradeValues("upgr_capturetime")), 0)

			if (point.captureFaction and point.captureFaction.id != faction.id) then
				endTime = endTime + point.captureFaction:SumOfUpgradeValues("upgr_longercapture")
			end

			VoidFactions.CapturePoints:StartCapture(point, faction, startTime, endTime)
			point.captureInProgress = true

			point.captureStart = startTime
			point.captureEnd = endTime

			point.capturingBy = faction
		end

		if (point.captureInProgress and isOwnPoint) then
			-- Enemy captured it and it's paused - clear the old capturers
			point.isPaused = false
			point.captureInProgress = false
			point.capturingBy = nil

			VoidFactions.CapturePoints:EndCapture(point)
			return
		end

	end

	if (point.isContested) then return end

	if (point.captureInProgress and point.capturingBy and point.capturingBy.id != faction.id) then
		-- Enemy is capturing it, contest!
		VoidFactions.CapturePoints:ChangeContest(point, true)
	end

	if (point.captureInProgress and !point.captureFaction) then

		local pts = point.capturingPlayers
		pts[#pts + 1] = ply

		local totalDiffFactions = 0
		local factionsSort = {}
		for k, v in ipairs(pts) do
			local faction = v:GetVFFaction():GetRootFaction()
			if (!factionsSort[faction]) then
				totalDiffFactions = totalDiffFactions + 1
			end
			factionsSort[faction] = true
		end

		if (totalDiffFactions > 1) then
			VoidFactions.CapturePoints:ChangeContest(point, true)
		end
	end

	if (isOwnPoint) then return end

	if (point.captureInProgress) then return end

	local startTime = CurTime()
	local endTime = startTime + math.max((VoidFactions.Config.CaptureTime - faction:SumOfUpgradeValues("upgr_capturetime")), 0)

	if (point.captureFaction and point.captureFaction.id != faction.id) then
		endTime = endTime + point.captureFaction:SumOfUpgradeValues("upgr_longercapture")
	end

	VoidFactions.CapturePoints:StartCapture(point, faction, startTime, endTime)
	point.captureInProgress = true

	point.captureStart = startTime
	point.captureEnd = endTime

	point.capturingBy = faction

	hook.Run("VoidFactions.CapturePoints.PointCaptureStart")

	if (point.captureFaction and point.capturingBy.id != point.captureFaction.id) then
		point.captureFaction:NotifyMembers(L"capturePoint", L"pointCapturedByEnemies", VoidUI.Colors.Orange, 5)

		for k, v in ipairs(point.capturingPlayers) do
			local plyFaction = v:GetVFFaction():GetRootFaction()
			if (plyFaction.id != faction.id) then
				-- Contest!
				VoidFactions.CapturePoints:ChangeContest(point, true)
			end
		end
	end

	
end

function VoidFactions.CapturePoints:ChangePaused(point, isPaused, timerLeft)
	point.isPaused = isPaused

	hook.Run("VoidFactions.CapturePoints.PointPauseChange", isPaused)

	VoidFactions.CapturePoints:NetworkPauseChange(point, timerLeft)
end

function VoidFactions.CapturePoints:ChangeContest(point, isContested)
	point.isContested = isContested

	if (!isContested) then
		point.captureEnd = CurTime() + (point.captureEnd - point.captureStart) - (point.contestStartTime - point.captureStart)
	else
		point.contestStartTime = CurTime()
	end

	hook.Run("VoidFactions.CapturePoints.PointContestChange", isContested)

	-- Network
	VoidFactions.CapturePoints:NetworkContestChange(point, isContested)
end

function VoidFactions.CapturePoints:PlayerEndCapture(ply, point)

	local capturingPlayers = {}
	local defendingPlayers = {}
	for k, v in ipairs(point.capturingPlayers) do
		local faction = v:GetVFFaction():GetRootFaction()

		if (!point.captureFaction or faction.id != point.captureFaction.id) then
			capturingPlayers[#capturingPlayers + 1] = v
		else
			defendingPlayers[#defendingPlayers + 1] = v
		end
	end

	local capturingPlayersNum = #capturingPlayers
	local defendingPlayersNum = #defendingPlayers

	if (point.isContested) then

		if (!point.captureFaction) then
			local totalDiffFactions = 0
			local factionsSort = {}
			for k, v in ipairs(point.capturingPlayers) do
				local faction = v:GetVFFaction():GetRootFaction()
				if (!factionsSort[faction]) then
					totalDiffFactions = totalDiffFactions + 1
				end
				factionsSort[faction] = true
			end


			if (totalDiffFactions < 2) then
				VoidFactions.CapturePoints:ChangeContest(point, false)

				local lastFaction = table.GetKeys(factionsSort)[1]
				if (lastFaction and lastFaction.id != point.capturingBy.id) then
					local startTime = CurTime()
					local endTime = startTime + math.max((VoidFactions.Config.CaptureTime - lastFaction:SumOfUpgradeValues("upgr_capturetime")), 0)
					if (point.captureFaction and point.captureFaction.id != faction.id) then
						endTime = endTime + point.captureFaction:SumOfUpgradeValues("upgr_longercapture")
					end

					point.captureStart = startTime
					point.captureEnd = endTime

					point.capturingBy = lastFaction
					VoidFactions.CapturePoints:NetworkContestFactionChange(point)
				end
			end
		end

		if (capturingPlayersNum == 0) then
			-- End contest
			VoidFactions.CapturePoints:ChangeContest(point, false)

			if (point.captureInProgress) then
				point.captureInProgress = false
				point.capturingBy = nil

				VoidFactions.CapturePoints:EndCapture(point)
			end
		elseif (defendingPlayersNum == 0 and capturingPlayersNum > 0 and point.captureFaction) then
			-- Transfer
			VoidFactions.CapturePoints:ChangeContest(point, false)

			local faction = capturingPlayers[1]:GetVFFaction():GetRootFaction()
			if (point.capturingBy.id == faction.id) then return end

			local startTime = CurTime()
			local endTime = startTime + math.max((VoidFactions.Config.CaptureTime - faction:SumOfUpgradeValues("upgr_capturetime")), 0)
			if (point.captureFaction and point.captureFaction.id != faction.id) then
				endTime = endTime + point.captureFaction:SumOfUpgradeValues("upgr_longercapture")
			end

			point.captureStart = startTime
			point.captureEnd = endTime

			point.capturingBy = faction
			VoidFactions.CapturePoints:NetworkContestFactionChange(point)

		elseif (defendingPlayersNum == 0 and point.captureFaction) then
			VoidFactions.CapturePoints:ChangeContest(point, false)
		end

	elseif (capturingPlayersNum < 1) then

		VoidFactions.CapturePoints:ChangePaused(point, true)
		point.captureEnd = point.captureEnd + 3

		timer.Create("VoidFactions.CapturePoint." .. point.id .. ".Expire", 5, 1, function ()
			point.isPaused = false
			point.captureInProgress = false
			point.capturingBy = nil

			VoidFactions.CapturePoints:EndCapture(point)
		end)
	end

end

function VoidFactions.CapturePoints:CaptureFaction(point, faction)
	point.captureInProgress = false
	point.captureStart = 0
	point.captureEnd = 0

	hook.Run("VoidFactions.CapturePoints.PointCaptured", faction, point)

	point.captureFaction = faction
	point.capturingPlayers = {}
	point.capturingBy = nil

	VoidFactions.CapturePoints:NetworkFactionChange(point, faction)
end


-- Timer

timer.Remove("VoidFactions.CapturePoints.Capturing")
timer.Create("VoidFactions.CapturePoints.Capturing", 0.5, 0, function ()

	for id, point in pairs(VoidFactions.PointsTable) do

		if (point.captureInProgress and point.captureEnd < CurTime()) then
			if (!point.isPaused and !point.isContested) then 
				-- Transfer point to faction
				hook.Run("VoidFactions.CapturePointChanged", point.capturingPlayers)
				VoidFactions.CapturePoints:CaptureFaction(point, point.capturingBy)
			end
		end
	
		local pos = point.pos
		local radius = point.radius

		-- FindInSphere is slower than looping through all the players

		local players = {}
		local tbl = {}
		for k, ply in ipairs(player.GetAll()) do

			local dist = ply:GetPos():DistToSqr(pos)
			if (dist > radius * radius) then continue end

			local plyFaction = ply:GetVFFaction()
			if (!plyFaction) then continue end
			if (!plyFaction.canCaptureTerritory and VoidFactions.Settings:IsStaticFactions()) then continue end
			if (!ply:Alive()) then continue end

			if (!point.previousPlayers[ply]) then
				-- Started capturing
				VoidFactions.CapturePoints:PlayerStartCapture(ply, point)
			end

			players[#players + 1] = ply
			tbl[ply] = ply
		end

		point.capturingPlayers = players

		for _, ply in ipairs(point.previousPlayersSeq or {}) do
			if (!IsValid(ply) or !tbl[ply]) then
				-- Stopped capturing
				VoidFactions.CapturePoints:PlayerEndCapture(ply, point)
			end
		end

		point.previousPlayers = tbl
		point.previousPlayersSeq = players

	end

end)

-- Hooks

hook.Add("VoidFactions.SQL.MemberLoaded", "VoidFactions.CapturePoints.SendPlayerPoints", function (ply)
	VoidFactions.CapturePoints:SyncCapturePoints(ply)
end)
