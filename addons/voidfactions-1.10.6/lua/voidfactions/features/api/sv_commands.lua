-- soon™

-- local L = VoidFactions.Lang.GetPhrase

-- VoidFactions.Commands = VoidFactions.Commands or {}

-- local tblValidCommands = {
--     ["promote"] = true,
--     ["demote"] = true,
--     ["invite"] = true,
--     ["kick"] = true
-- }

-- function VoidFactions.Commands:Promote(ply, actionPlayer)
--     local selfMember = ply:GetVFMember()
--     local playerMember = actionPlayer:GetVFMember()

--     if (!playerMember or !selfMember) then return false end
--     if (!playerMember.rank or !selfMember.rank) then return false end

--     if (!selfMember.rank:CanPromote(playerMember, selfMember)) then return end

--     VoidFactions.API:PromoteMember(actionPlayer)
--     VoidLib.Notify(ply, L"success", L("memberPromoted", ))
-- end

-- hook.Add("PlayerSay", "VoidFactions.API.HandlePlayerSayCommands", function (ply, text)
--     local args = string.Split(text, " ")
--     local command = args[1]:lower()
--     if (command:sub(1, 1) != "!" and command:sub(1, 1) != "/") then return end
--     command = command:sub(2)
    
--     table.remove(args, 1)
--     local sid = args[1]
--     if (!sid) then return end

--     if (!tblValidCommands[command]) then return end

--     local actionPlayer = player.GetBySteamID64(sid) or player.GetBySteamID(sid) or getPlayerByName(sid)
--     if (!IsValid(actionPlayer)) then
--         return
--     end

--     if (command == "promote") then
--         VoidFactions.Commands:Promote(ply, actionPlayer)
--     elseif (command == "demote") then
        
--     elseif (command == "invite") then
        
--     elseif (command == "kick") then
        
--     end

--     return ""
-- end)