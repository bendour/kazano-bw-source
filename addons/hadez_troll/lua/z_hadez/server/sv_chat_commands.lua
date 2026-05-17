-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

/* 
	A compact chat command system
*/

local CHATCMDS = {}

-- Open menu
CHATCMDS["hadez"] = function(ply)
	ply:SendLua("CL_HADEZ:ToggleMenu()")
end
CHATCMDS["had3z"] = CHATCMDS["hadez"]
CHATCMDS["hades"] = CHATCMDS["hadez"]
CHATCMDS["had3s"] = CHATCMDS["hadez"]

local function TextHasCommand( txt, cmd )

	local targetTxt = string.sub(txt:lower(), 1, string.len(cmd)+1)
	
	return targetTxt == '!'..cmd or targetTxt == '/'..cmd
	
end

local function PlayerSay( ply , txt )

	for cmd, func in pairs(CHATCMDS) do
		
		if TextHasCommand(txt,cmd) then
		
			func(ply)
			
			return ""
			
		end
		
	end

end
hook.Add("PlayerSay","z_hadez_ChatCommands",PlayerSay)