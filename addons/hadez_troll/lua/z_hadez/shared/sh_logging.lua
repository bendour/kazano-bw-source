-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local function GetLogReceivers(permission, targets)

	local logReceivers = {}
	
	-- Everyone
	if SH_HADEZ.SETTINGS.LOGMODE == 3 then
		return player.GetAll()
	end
	
	-- Permission havers
	if SH_HADEZ.SETTINGS.LOGMODE >= 1 then
	
		local players = player.GetAll()
				
		for i=1, #players do
		
			local ply = players[i]
			
			if !IsValid(ply) then continue end
			
			if SH_HADEZ:HasAccess(ply,permission) then
				table.insert(logReceivers, ply)
			end
			
		end
		
	end
	
	-- Targets
	if SH_HADEZ.SETTINGS.LOGMODE >= 2 then
		table.Add(logReceivers, targets)
	end
	
	return logReceivers

end

local function GetPlayerFormat(ply)
	
	if IsValid(ply) then
	
		local steamID = ply:SteamID() or "STEAM_0:0:0"
		local nick = ply:Nick() or "ERROR"
	
		return "<"..steamID.."> ", nick
	
	end
	
	return "", "Disconnected" -- Console
	
end

local msgHeading = {
	[1] = SH_HADEZ.VAR.COLOR.RED,
	[2] = "[HAD3Z] ",
}

function SH_HADEZ:Log(tranlationKey, permission, ...)

	local str = SH_HADEZ:Translate(tranlationKey)
	local args = {...}
	local logMsgFormat = {}
	local chatMsgFormat = {}
	local strTbl = string.Explode( "[p]", str )
	local shouldLog = SERVER or SH_HADEZ:HasAccess(permission)
	
	local activator, targets
	
	for i=1, #strTbl do
	
		local str = strTbl[i]
		
		-- Players
		if #str == 0 then
			
			local arg = args[1]
			local players = {}
			local targetAll = false
			
			if istable(arg) then
			
				players = arg
				targets = arg
				
				-- Can be inconsistent when client receives targets from server
				local activePlayerCount = SH_HADEZ:HasLSACBot() and #player.GetAll() - 1 or #player.GetAll()
				if #players > 1 and #players >= activePlayerCount then 
					targetAll = true
				end
				
			else
			
				players[1] = arg
				
			end
			
			if targetAll then
			
				local everyone = SH_HADEZ:Translate("everyone")
				
				if CLIENT then
					table.insert(chatMsgFormat, SH_HADEZ.VAR.COLOR.LIGHTBLUE)
					table.insert(chatMsgFormat, everyone)
				end
				
				if shouldLog then
					table.insert(logMsgFormat, SH_HADEZ.VAR.COLOR.LIGHTBLUE)
					table.insert(logMsgFormat, everyone)
				end
			
				continue
				
			end
			
			for i=1, #players do
				
				local ply = players[i]
				local steamID, nick = GetPlayerFormat(ply)
				
				if ply == activator then
					steamID = ""
					nick = SH_HADEZ:Translate("themself")
				end
				
				if i > 10 then
				
					if CLIENT then
						table.insert(chatMsgFormat, color_white)
						table.insert(chatMsgFormat, ',... ')
					end
					
					if shouldLog then
						table.insert(logMsgFormat, color_white)
						table.insert(logMsgFormat, ',... ')
					end
					
					break
					
				end
				
				if i > 1 then
				
					if CLIENT then
						table.insert(chatMsgFormat, color_white)
						table.insert(chatMsgFormat, ', ')
					end
					
					if shouldLog then
						table.insert(logMsgFormat, color_white)
						table.insert(logMsgFormat, ', ')
					end
					
				end
			
				if CLIENT then
					table.insert(chatMsgFormat, SH_HADEZ.VAR.COLOR.LIGHTBLUE)
					table.insert(chatMsgFormat, nick)
				end
				
				if shouldLog then
					table.insert(logMsgFormat, SH_HADEZ.VAR.COLOR.LIGHTGREY)
					table.insert(logMsgFormat, steamID)
					table.insert(logMsgFormat, SH_HADEZ.VAR.COLOR.LIGHTBLUE)
					table.insert(logMsgFormat, nick)
				end
				
			end
			
			table.remove(args, 1)
			
			if !activator and #players == 1 then
				activator = players[1]
			end
			
		else
			
			if CLIENT then
				table.insert(chatMsgFormat, color_white)
				table.insert(chatMsgFormat, str)
			end
			
			if shouldLog then
				table.insert(logMsgFormat, color_white)
				table.insert(logMsgFormat, str)
			end
			
		end
	
	end
	
	local chatFormat
	if CLIENT then
		table.insert(chatMsgFormat, color_white)
		table.insert(chatMsgFormat, ".")
		chatFormat = table.Add( table.Copy(msgHeading), chatMsgFormat )
	end
	
	local logFormat
	if shouldLog then
		table.insert(logMsgFormat, color_white)
		table.insert(logMsgFormat, ".\n")
		logFormat = table.Add( table.Copy(msgHeading), logMsgFormat )
	end
	
	if SERVER then
	
		-- Server
		if SH_HADEZ.VAR.DEDICATED then
			MsgC(unpack(logFormat))
		end
		
		if SH_HADEZ.SETTINGS.LOGMODE == 0 then return end
		
		-- Client
		local logReceivers = GetLogReceivers(permission, targets)
		
		net.Start("z_hadez_Log")
			net.WriteString(tranlationKey)
			net.WriteString(permission)
			net.WriteTable({...})
		net.Send(logReceivers)
		
	end
	
	if CLIENT then 
	
		if shouldLog then
			MsgC(unpack(logFormat))
		end
		
		chat.AddText(unpack(chatFormat))
	
	end

end

if SERVER then

	util.AddNetworkString("z_hadez_Log")
	function SV_HADEZ:LogFeature(baseLogTransKey, permission, activator, targets, IsEnabled)
	
		local enabledPlayers = {}
		local disabledPlayers = {}
		
		if !istable(targets) then
			targets = {targets}
		end
		
		for i=1, #targets do
			
			local target = targets[i]
			local isEnabled = IsEnabled(target)
			
			if isEnabled then
				table.insert(enabledPlayers, target)
			elseif isEnabled == false then
				table.insert(disabledPlayers, target)
			end
			
		end
		
		if #enabledPlayers > 0 then
			SH_HADEZ:Log(baseLogTransKey.."Enabled", permission, activator, enabledPlayers)
		end
		
		if #disabledPlayers > 0 then
			SH_HADEZ:Log(baseLogTransKey.."Disabled", permission, activator, disabledPlayers)
		end

	end
 
end

if CLIENT then
	
	net.Receive("z_hadez_Log", function() 
		
		local tranlationKey = net.ReadString()
		local permission = net.ReadString()
		local args = net.ReadTable()
			
		SH_HADEZ:Log(tranlationKey, permission, unpack(args)) 
		
	end)

end
