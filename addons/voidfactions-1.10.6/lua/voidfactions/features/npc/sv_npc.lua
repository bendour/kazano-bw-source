VoidFactions.NPC = VoidFactions.NPC or {}

function VoidFactions.NPC.LoadAll()
    if not VoidFactions.Config.NPCModel then
        VoidFactions.PrintDebug("VoidFactions NPCs were not able to load!")
        return
    end

    local npcFile = file.Read("voidfactions_npc.json", "DATA")
    if not npcFile then return end

    local npcData = util.JSONToTable(npcFile)
    local npcList = npcData[game.GetMap()]

    if not npcList then return end

    for _, data in ipairs(npcList) do
        local npc = ents.Create("voidfactions_npc")
        npc:SetPos(data.pos)
        npc:SetAngles(data.angles)
        npc:Spawn()
    end

    VoidFactions.PrintDebug("VoidFactions NPCs loaded successfully!")
end

function VoidFactions.NPC.Save()
    local npcFile = file.Read("voidfactions_npc.json", "DATA")
    local map = game.GetMap()
    local npcList = {}
    npcList[map] = {}

    if npcFile then
        local existingNPCList = util.JSONToTable(npcFile)

        for _, data in ipairs(existingNPCList) do
            table.insert(npcList[map], data)
        end
    end

    local localNPCs = ents.FindByClass("voidfactions_npc")

    for _, npc in ipairs(localNPCs) do
        table.insert(npcList[map], {pos = npc:GetPos(), angles = npc:GetAngles()})
    end

    local npcData = util.TableToJSON(npcList)
    file.Write("voidfactions_npc.json", npcData)

    VoidFactions.PrintDebug("VoidFactions NPCs saved successfully!")
end

concommand.Add("voidfactions_savenpc", function(ply)
    if not CAMI.PlayerHasAccess(ply, "VoidFactions_SaveNPCs") then
        VoidLib.Notify(ply, "NO PERMISSION", "You need the permission VoidFactions_SaveNPCs to save NPCs!", VoidUI.Colors.Red, 4)
        return
    end

    VoidFactions.NPC.Save()
    VoidLib.Notify(ply, "SUCCESS", "You successfully saved all VoidFaction NPCs!", VoidUI.Colors.Green, 3)
end)

hook.Add("VoidFactions.Settings.Loaded", "VoidFactions.LoadNpcOnConfigLoad", VoidFactions.NPC.LoadAll)
