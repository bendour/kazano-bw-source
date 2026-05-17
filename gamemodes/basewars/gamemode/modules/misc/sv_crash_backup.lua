local BACKUP_FILE_PATH = "basewars/crash_backup.json"

local function crashBackupExists()
	return file.Exists(BACKUP_FILE_PATH, "DATA")
end

local function deleteCrashBackupFile()
	file.Delete(BACKUP_FILE_PATH, "DATA")
end

local function writeCrashBackupFile()
	local players = {}

	for k, v in ents.Iterator() do
		if not IsValid(v) then continue end

		local owner = v:CPPIGetOwner()
		if not IsValid(owner) or not owner:IsPlayer() then continue end
		if owner.basewarsProfileID == nil then continue end

		local entValue = v:GetCurrentValue()
		if entValue <= 0 then
			continue
		end

		local ownerID64 = owner:SteamID64()
		if not players[ownerID64] then
			players[ownerID64] = {money = 0, xp = 0}
		end

		if v.IsBank or v.IsPrinter then
			local entMoney = v:GetMoney()
			entValue = entValue + entMoney

			local xp = math.floor(BaseWars:CalculatePlayerXP(owner, BaseWars:CalculateXPFromMultiplier(entMoney) * BaseWars.Config.XPMult))
			if BaseWars.Config.Prestige.Enable then
				xp = xp * hook.Run("BaseWars:PlayerGainXP", owner) or 1
			end

			players[ownerID64].xp = players[ownerID64].xp + xp
		end

		players[ownerID64].money = players[ownerID64].money + entValue
	end

	for k, v in pairs(players) do
		players[k].money = math.floor(v.money)
		players[k].xp = math.floor(v.xp)
		players[k].profileID = BaseWars:FindPlayer(k).basewarsProfileID
		players[k].name = BaseWars:FindPlayer(k):Name()
	end

	if table.Count(players) <= 0 then
		if crashBackupExists() then
			deleteCrashBackupFile()
		end

		return
	end

	file.Write(BACKUP_FILE_PATH, util.TableToJSON(players, true))
end

local function createTimer(interval)
	timer.Create("Basewars.MoneyXPBackup", interval, 0, function()
		local start = SysTime()
		writeCrashBackupFile()

		if BaseWars.Config.Debug.Gamemode then
			BaseWars:ServerLog(Format("Crash backup file created (Took %.5f secs)", SysTime() - start))
		end
	end)
end

local giveMoneyAndXPBack = false
hook.Add("OnGamemodeLoaded", "BaseWars:MoneyXPBackup", function()
	giveMoneyAndXPBack = true -- For Lua refresh
end)

local tellPlayer = {}
hook.Add("PostDatabaseInitialized", "BaseWars:MoneyXPBackup", function()
	if file.Exists(BACKUP_FILE_PATH, "DATA") and giveMoneyAndXPBack then
		local data = util.JSONToTable(file.Read(BACKUP_FILE_PATH, "DATA") or "[]", false, true) or {}

		local log = ""

		tellPlayer = data
		for k, v in pairs(data) do
			MySQLite.query(Format("UPDATE basewars_player SET money = CAST(money AS DECIMAL) + %s, xp = CAST(xp AS DECIMAL) + %s WHERE player_id64 = %s AND profile_id = %s", v.money, v.xp, k, v.profileID))

			BaseWars:ServerLog("Restored crash backup for " .. v.name)
			log = log .. v.name .. " » {" .. BaseWars:FormatMoney(v.money) .. "} & {" .. BaseWars:FormatNumber(v.xp) .. " XP}\n"
		end

		--BaseWars:ServerStatus("Remboursement de crash.\n" .. string.TrimRight(log, "\n"))

		deleteCrashBackupFile()
	end

	if BaseWars.Config.CrashBackup.Enable then
		createTimer(BaseWars.Config.CrashBackup.Interval)
	end
end)

hook.Add("BaseWars:ConfigurationModified", "BaseWars:MoneyXPBackup", function(_, oldConfig, newConfig)
	if oldConfig.CrashBackup.Enable == newConfig.CrashBackup.Enable then
		timer.Adjust("Basewars.MoneyXPBackup", newConfig.CrashBackup.Interval)
	else
		if newConfig.CrashBackup.Enable then
			createTimer(newConfig.CrashBackup.Interval)
		else
			timer.Remove("Basewars.MoneyXPBackup")
		end
	end
end)

hook.Add("ShutDown", "BaseWars:MoneyXPBackup", function()
	deleteCrashBackupFile()
end)

hook.Add("BaseWars:SendNetToClient", "BaseWars:MoneyXPBackup", function(ply)
	local player_id64 = ply:SteamID64()
	local crashData = tellPlayer[player_id64]

	if crashData then
		BaseWars:ChatNotify(ply, "#crash_refund", BaseWars:FormatMoney(crashData.money), BaseWars:FormatNumber(crashData.xp))
		tellPlayer[player_id64] = nil
	end
end)

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "BaseWars:MoneyXPBackup", function()
	timer.Simple(0, function()
		local start = SysTime()
		writeCrashBackupFile()

		if BaseWars.Config.Debug.Gamemode then
			BaseWars:ServerLog(Format("Crash backup file created (Took %.5f secs)", SysTime() - start))
		end
	end)
end)

BaseWars:AddConsoleCommand("bw_backup_time", function(ply, args, argStr)
	local msg = "Backup in: " .. math.ceil(timer.TimeLeft("Basewars.MoneyXPBackup")) .. " seconds"

	if ply:IsPlayer() then
		BaseWars:ChatNotify(ply, msg)
	else
		BaseWars:Log(msg)
	end
end, false, BaseWars:GetSuperAminGroups())