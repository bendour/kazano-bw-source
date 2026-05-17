/*
    Addon id: a36a6eee-6041-4541-9849-360baff995a2
    Version: v1.4.1 (stable)
*/

if CLIENT then return end

// Adds those classes to the Entity Cleanup once he leaves the server or changes his job
zclib.Player.CleanUp_Add("zmlab2_equipment")
zclib.Player.CleanUp_Add("zmlab2_storage")
zclib.Player.CleanUp_Add("zmlab2_table")
zclib.Player.CleanUp_Add("zmlab2_tent")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- e3b23fe5de9dfb761758a006a7271ce1817b0b3d31fddc5f22fc8264734156bf

zclib.Player.CleanUp_Add("zmlab2_item_acid")
zclib.Player.CleanUp_Add("zmlab2_item_aluminium")
zclib.Player.CleanUp_Add("zmlab2_item_crate")
zclib.Player.CleanUp_Add("zmlab2_item_frezzertray")
zclib.Player.CleanUp_Add("zmlab2_item_lox")
zclib.Player.CleanUp_Add("zmlab2_item_methylamine")
zclib.Player.CleanUp_Add("zmlab2_item_palette")
zclib.Player.CleanUp_Add("zmlab2_item_autobreaker")

zclib.Player.CleanUp_Add("zmlab2_machine_mixer")
zclib.Player.CleanUp_Add("zmlab2_machine_filler")
zclib.Player.CleanUp_Add("zmlab2_machine_filter")
zclib.Player.CleanUp_Add("zmlab2_machine_frezzer")
zclib.Player.CleanUp_Add("zmlab2_machine_furnace")
zclib.Player.CleanUp_Add("zmlab2_machine_ventilation")


zmlab2 = zmlab2 or {}
zmlab2.Player = zmlab2.Player or {}

function zmlab2.Player.DropMeth(ply,SuppressNotify)

    if ply.zmlab2_MethList == nil or table.Count(ply.zmlab2_MethList) <= 0 then
        if not SuppressNotify then zclib.Notify(ply, zmlab2.language["NPC_InteractionFail02"], 1) end
        return
    end

    local x,y,z = 0,0,0
    for k,v in pairs(ply.zmlab2_MethList) do

        if x >= 60 then
            y = y + 25
            x = 0
        end

        if y >= 60 then
            z = z + 25
            y = 0
        end

        x = x + 30

        local ent = ents.Create("zmlab2_item_crate")
        if not IsValid(ent) then continue end
        ent:SetPos(ply:GetPos() + Vector(40 - x,40 - y,z))
        ent:Spawn()
        ent:Activate()

        zmlab2.Crate.AddMeth(ent,v.t,v.a,v.q,false)

        zclib.Player.SetOwner(ent, ply)
    end
    ply.zmlab2_MethList = {}
end

zclib.Hook.Add("PlayerSay", "zmlab2_ChatCommands", function(ply, text)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 7e845693ad2a490ead94c2e1f6c2eaff90beaf41e1d134566247921805d9f29b

    if string.sub(string.lower(text), 1, 12) == "!zmlab2_save" and zclib.Player.IsAdmin(ply) then
        zmlab2.SellSetup.Save(ply)
    end

    // Drop all the collected meth of the player you are looking
    if zmlab2.config.Police.Jobs[zclib.Player.GetJob(ply)] and string.sub(string.lower(text), 1, string.len(zmlab2.config.Police.cmd_strip)) == zmlab2.config.Police.cmd_strip then
        local tr = ply:GetEyeTrace()
        if tr.Hit and IsValid(tr.Entity) and tr.Entity:IsPlayer() and tr.Entity:Alive() then
            zmlab2.Player.DropMeth(tr.Entity)
        end
    end

    // Drop all the collected meth
    if string.sub(string.lower(text), 1, string.len(zmlab2.config.DropMeth)) == zmlab2.config.DropMeth then
        zmlab2.Player.DropMeth(ply)
    end

    // Extract meth out of a crate
    if string.sub(string.lower(text), 1, string.len(zmlab2.config.BagMeth)) == zmlab2.config.BagMeth then
        local tr = ply:GetEyeTrace()
        if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "zmlab2_item_crate" then
            local crate = tr.Entity
            local m_amount = crate:GetMethAmount()
            if m_amount <= 0 then return end

            local function SpawnMeth(id,amount,quality,position)
                local ent = ents.Create("zmlab2_item_meth")
                if not IsValid(ent) then return end
                ent:SetPos(position)
                ent:Spawn()
                ent:Activate()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

                ent:SetMethType(id)
                ent:SetMethAmount(amount)
                ent:SetMethQuality(quality)

                zclib.Player.SetOwner(ent, ply)
            end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 99958388d5b8bc21e4d7af1df39fd75077f0660617b3c526ce40ea9691a5fd3b

            local i_amount,i_type,i_quality = 100,1,1

            i_type = crate:GetMethType()
            i_quality = crate:GetMethQuality()
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 20505de7028925e794a03b5d1a113ab09db033ae5f8a5a69bfd7d0ab6982aaae

            local i_pos = tr.Entity:GetPos() + Vector(35,0,5)

            if m_amount > 100 then
                crate:SetMethAmount(crate:GetMethAmount() - 100)
            else
                i_amount = crate:GetMethAmount()

                SafeRemoveEntity(crate)
            end

            SpawnMeth(i_type,i_amount,i_quality,i_pos)
        end
    end
end)


////////////////////////////////////////////
////////////// Player Death ////////////////
////////////////////////////////////////////
zclib.Hook.Add("PostPlayerDeath", "zmlab2.DropMethOnDeath", function(ply, text)
	if zmlab2.config.DropMethOnDeath then
		zmlab2.Player.DropMeth(ply, true)
	end
end)

zclib.Hook.Add("PlayerSilentDeath", "zmlab2.DropMethOnDeath", function(ply, text)
	if zmlab2.config.DropMethOnDeath then
		zmlab2.Player.DropMeth(ply, true)
	end
end)

zclib.Hook.Add("PlayerDeath", "zmlab2.DropMethOnDeath", function(victim, inflictor, attacker)
	if zmlab2.config.DropMethOnDeath then
		zmlab2.Player.DropMeth(victim, true)
	end
end)
////////////////////////////////////////////
////////////////////////////////////////////
