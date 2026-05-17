-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

util.AddNetworkString("z_hadez_ChatSteal")
local function ChatSteal(len, ply)

	if !SH_HADEZ:HasAccess(ply, "chatSteal") then return end
	
	local target = net.ReadEntity()
	local enabled = !SH_HADEZ:IsChatStealing(ply)
	
	target.z_hadez_chatStealOptions = {
		canChat = net.ReadBool()
	}
	
	-- target disconnected
	if enabled and !IsValid(target) then return end
	
	SV_HADEZ:StealChat(ply, target, enabled)
	SV_HADEZ:OnPowerToggled(target, "chatSteal", enabled)
	
	SV_HADEZ:LogFeature("chatStealLog", "chatSteal", ply, target, function(ply)
		return SH_HADEZ:HasChatStolen(ply)
	end)

end
net.Receive("z_hadez_ChatSteal",ChatSteal)

util.AddNetworkString("z_hadez_ChatStealMessage")
local function PlayerSay(ply, text, teamChat, isRedirect)

	if isRedirect then return end

	-- Chat thief
	local chatStealTarg = SH_HADEZ:GetChatStealTarget(ply)

	if IsValid(chatStealTarg) then
		
		-- Fool server
		local hookRes = hook.Run("PlayerSay", chatStealTarg, text, teamChat, true)
		
		-- Fool clients	   DarkRP always returns nil in the PlayerSay hook
		if !SH_HADEZ.VAR.ISDARKRP and isstring(hookRes) and #hookRes > 0 then
			
			net.Start("z_hadez_ChatStealMessage")
				net.WriteEntity(chatStealTarg)
				net.WriteString(text)
			net.Broadcast()
			
		end
		
		-- Fool DarkRP clients {https://github.com/FPtje/DarkRP/blob/master/gamemode/modules/chat/sv_chat.lua}
        if SH_HADEZ.VAR.ISDARKRP then
			local name = chatStealTarg:Nick()
			local players = player.GetAll()

			local col = team.GetColor(chatStealTarg:Team())
			local col2 = Color(255, 255, 255, 255)
			if not chatStealTarg:Alive() then
				col2 = Color(255, 200, 200, 255)
				col = col2
			end

			for i=1, #players do
				DarkRP.talkToPerson(players[i], col, name, col2, text, chatStealTarg)
			end
		end
		
		return ""
		
	end
	
	-- Chat steal target
	if SH_HADEZ:HasChatStolen(ply) then
		
		if ply.z_hadez_chatStealOptions and !ply.z_hadez_chatStealOptions.canChat then
			return ""
		end
		
	end

end
SH_HADEZ:PrioritizedAddHook("PlayerSay", "z_hadez_ChatSteal", PlayerSay)