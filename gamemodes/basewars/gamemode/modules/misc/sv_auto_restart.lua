--[[BASEWARS_SERVER_RESTARTING = false

local from = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789[](){}!@#$%?&*_+-=/\\.,"
local function getRandomString(num)
	local str = ""

	for i = 1, num do
		str = str .. from[math.random(#from)]
	end

	return str
end

local function createTimer(localTime, interval)
	timer.Create("BASEWARS.AUTO_RESTART", 1, interval - (localTime % interval), function()
		local TIME_LEFT = timer.RepsLeft("BASEWARS.AUTO_RESTART")

		if TIME_LEFT % 3600 == 0 or (TIME_LEFT <= 1800 and TIME_LEFT % 300 == 0) or TIME_LEFT <= 10 then
			BaseWars:NotifyAll("#server_restartIn", NOTIFICATION_SERVER, 5, BaseWars:FormatTime3(TIME_LEFT))
			BaseWars:ChatNotifyAll("#server_restartIn", BaseWars:FormatTime3(TIME_LEFT))
			BaseWars:ServerLog(BaseWars:GetLang("server_restartIn"):format(BaseWars:FormatTime3(TIME_LEFT)))

			if TIME_LEFT > 10 then
				BaseWars:ServerStatus("Redémarrage serveur dans {" .. BaseWars:FormatTime3(TIME_LEFT) .. "}.")
			end
		end

		if TIME_LEFT == 10 then
			BASEWARS_SERVER_RESTARTING = true

			RunConsoleCommand("sv_password", getRandomString(100)) -- to prevent players from joining the server when its literally about to restart

			BaseWars:ServerStatus("Redémarrage serveur. {(Automatique)}")
			BaseWars:RefundAll()
		end

		if TIME_LEFT == 5 then
			for k, v in player.Iterator() do
				v:Kick("Server restarting... (Auto Restart)")
			end
		end

		if TIME_LEFT == 0 then
			RunConsoleCommand("_restart")
		end
	end)
end

hook.Add("InitPostEntity", "BaseWars:AutoRestart", function()
	if BaseWars.Config.AutoRestart.Enable then
		createTimer(os.time() + (BaseWars.Config.AutoRestart.Offset * 3600), BaseWars.Config.AutoRestart.Interval * 3600)
	end
end)

hook.Add("BaseWars:ConfigurationModified", "BaseWars:AutoRestart", function(_, oldConfig, newConfig)
	if oldConfig.AutoRestart.Enable == newConfig.AutoRestart.Enable then
		timer.Remove("BASEWARS.AUTO_RESTART")
		createTimer(os.time() + (newConfig.AutoRestart.Offset * 3600), newConfig.AutoRestart.Interval * 3600)
	else
		if newConfig.AutoRestart.Enable then
			createTimer(os.time() + (newConfig.AutoRestart.Offset * 3600), newConfig.AutoRestart.Interval * 3600)
		else
			timer.Remove("BASEWARS.AUTO_RESTART")
		end
	end
end)

BaseWars:AddConsoleCommand("restartserver", function(ply, args, argStr)
	if BASEWARS_SERVER_RESTARTING then return end

	RunConsoleCommand("sv_password", getRandomString(100)) -- to prevent players from joining the server when its literally about to restart

	BASEWARS_SERVER_RESTARTING = true

	local time = 10

	BaseWars:RefundAll()
	BaseWars:Log("Refunded All (Manual restart by " .. (IsValid(ply) and ply:Name() or "Console") .. ")")
	BaseWars:ServerStatus("Redémarrage serveur. {(Manuel)}")

	local a = time
	timer.Create("BaseWars:ManualRestart", 1, time + 1, function()
		BaseWars:ChatNotifyAll("Server restart in " .. a .. " second" .. (a > 1 and "s" or ""))
		BaseWars:Log("Server restart in " .. a .. " second" .. (a > 1 and "s" or ""))

		if a == 5 then
			for k, v in player.Iterator() do
				if not IsValid(v) then continue end
				v:Kick("Server Restarting")
			end
		end

		if a == 0 then
			RunConsoleCommand("_restart")
		end

		a = a - 1
	end)
end, false, BaseWars:GetSuperAminGroups())]]--