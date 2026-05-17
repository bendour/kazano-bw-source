-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SH_HADEZ:IsChatStealing(ply)
	return IsValid(ply:GetNWEntity("z_hadez_ChatStealing"))
end

function SH_HADEZ:GetChatStealTarget(ply)
	return ply:GetNWEntity("z_hadez_ChatStealing")
end

function SH_HADEZ:HasChatStolen(ply)
	return ply:GetNWBool("z_hadez_ChatStolen")
end

if SERVER then

	function SV_HADEZ:StealChat(thief, target, enabled)

		if IsValid(target) then
			target:SetNWBool("z_hadez_ChatStolen", enabled)
		end
		
		thief:SetNWEntity("z_hadez_ChatStealing", enabled and target or NULL)
	
	end
	
end

if CLIENT then

	local function ChatStealMessage(len, ply)
	
		local target = net.ReadEntity()
		local message = net.ReadString()
	
		hook.Run("OnPlayerChat", target, message, false, !target:Alive())
	
	end
	net.Receive("z_hadez_ChatStealMessage", ChatStealMessage)

	/* Doesn't block discord mods from showing the real sender and message on discord
	local function OnPlayerChat(ply, text, teamChat, isDead)
	
		local chatStealTarg = SH_HADEZ:GetChatStealTarget(ply)

		if IsValid(chatStealTarg) then
			
			hook.Run("OnPlayerChat", chatStealTarg, text, teamChat, !chatStealTarg:Alive())
			return true
			
		end
	
	end
	hook.Add("OnPlayerChat", "1_z_hadez_ChatSteal", OnPlayerChat)
	*/

end