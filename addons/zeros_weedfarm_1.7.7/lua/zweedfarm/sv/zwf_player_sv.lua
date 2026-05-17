if (not SERVER) then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

////////////////////////////////////////////
//////////////// NW Timeout ////////////////
////////////////////////////////////////////
// How often are clients allowed to send net messages to the server
ZWF_NW_TIMEOUT = 0.25

function zwf.f.NW_Player_Timeout(ply)
    local Timeout = false

    if ply.ZWF_NWTimeout and ply.ZWF_NWTimeout > CurTime() then
        Timeout = true
    end

    ply.ZWF_NWTimeout = CurTime() + ZWF_NW_TIMEOUT

    return Timeout
end
////////////////////////////////////////////
////////////////////////////////////////////





////////////////////////////////////////////
///////////// Player Initialize ////////////
////////////////////////////////////////////
if zwf_PlayerList == nil then
    zwf_PlayerList = {}
end

function zwf.f.Add_Player(ply)
    table.insert(zwf_PlayerList, ply)
end


util.AddNetworkString("zwf_Player_Initialize")
net.Receive("zwf_Player_Initialize", function(len, ply)

    if ply.zwf_HasInitialized then
        return
    else
        ply.zwf_HasInitialized = true
    end

    zwf.f.Debug("zwf_Player_Initialize Netlen: " .. len)

    if IsValid(ply) then
        zwf.f.Add_Player(ply)

        zwf.data.PlayerSpawn(ply)
    end
end)
////////////////////////////////////////////
////////////////////////////////////////////






function zwf.f.DropWeedBlock(weeddata, pos)
    local ent = ents.Create("zwf_weedblock")
    ent:SetAngles(Angle(0, 0, 0))
    ent:SetPos(pos)
    ent:Spawn()
    ent:Activate()
    ent:SetWeedID(weeddata.WeedID)
    ent:SetTHC(weeddata.THC)
    ent:SetWeedName(weeddata.name)
    ent:SetWeedAmount(weeddata.amount)
end

function zwf.f.DropAllWeedBlocks(ply)
    if ply.zwf_Weed == nil or istable(ply.zwf_Weed) == false or table.Count(ply.zwf_Weed) <= 0 then return end
    local _count = 1

    for k, v in pairs(ply.zwf_Weed) do
        if v then
            zwf.f.DropWeedBlock(v, ply:GetPos() + ply:GetUp() * (25 * _count))
            _count = _count + 1
        end
    end
end

hook.Add("PlayerDeath", "a_zwf_PlayerDeath", function(victim, inflictor, attacker)
    // Stops the screeneffect
    zwf.f.RemoveHighEffect(victim)

    // Close Shop interface
    net.Start("zwf_Shop_Close_net")
    net.Send(victim)

    // Close Seedbank interface
    net.Start("zwf_CloseSeedBank")
    net.Send(victim)

    // Close SpliceLab interface
    net.Start("zwf_CloseSpliceLab")
    net.Send(victim)

    // NPC SpliceLab interface
    net.Start("zwf_CloseNPC")
    net.Send(victim)

    if zwf.config.NPC.SellMode == 2 and zwf.config.Player.DropWeedOnDeath then
        // Drop Weed
        zwf.f.DropAllWeedBlocks(victim)
    end

    // Resets the weed the player has in his inventory
    victim.zwf_Weed = {}
end)

local zwf_DeleteEnts = {
    ["zwf_drystation"] = true,
    ["zwf_autopacker"] = true,
    ["zwf_fuel"] = true,
    ["zwf_generator"] = true,
    ["zwf_lamp"] = true,
    ["zwf_nutrition"] = true,
    ["zwf_outlet"] = true,
    ["zwf_packingstation"] = true,
    ["zwf_palette"] = true,
    ["zwf_plant"] = true,
    ["zwf_pot"] = true,
    ["zwf_seed"] = true,
    ["zwf_seed_bank"] = true,
    ["zwf_soil"] = true,
    ["zwf_splice_lab"] = true,
    ["zwf_ventilator"] = true,
    ["zwf_watertank"] = true,
    ["zwf_weedblock"] = true,
    ["zwf_weedstick"] = true,
    ["zwf_pot_hydro"] = true,
    ["zwf_doobytable"] = true,
    ["zwf_mixer"] = true,
    ["zwf_mixer_bowl"] = true,
    ["zwf_backmix_muffin"] = true,
    ["zwf_backmix_brownie"] = true,
}

function zwf.f.Cleanup_PlayerEnts(pl)
    local _steamid = pl:SteamID()
    for k, v in pairs(zwf.EntList) do
        if IsValid(v) and zwf_DeleteEnts[v:GetClass()] and zwf.f.GetOwnerID(v) == _steamid then
            v:Remove()
        end
    end
end

hook.Add("PlayerDisconnected", "a_zwf_PlayerDisconnected", function(ply)
    zwf.f.Cleanup_PlayerEnts(ply)
end)


local zwf_LastBongDrop = -1

// Drop / Share Bong Function
hook.Add("PlayerButtonDown", "a_zwf_PlayerButtonDown_BongDrop", function(ply, key)
    if key == MOUSE_MIDDLE and IsValid(ply) and IsValid(ply:GetActiveWeapon()) then

        if string.sub( ply:GetActiveWeapon():GetClass(),1,8 ) == "zwf_bong" then

            if zwf_LastBongDrop > CurTime() then return end
            zwf_LastBongDrop = CurTime() + 1

            zwf.f.DropBong(ply)

        elseif ply:GetActiveWeapon():GetClass() == "zwf_joint" then

            if zwf_LastBongDrop > CurTime() then return end
            zwf_LastBongDrop = CurTime() + 1

            zwf.f.DropJoint(ply)
        end

    end
end)

function zwf.f.DropBong(ply)
    local tr = ply:GetEyeTrace()
    local ply_Bong = ply:GetActiveWeapon()

    if ply_Bong:GetIsBusy() or ply_Bong:GetIsSmoking() then return end

    if tr.Hit and tr.HitSky == false and zwf.f.InDistance(ply:GetPos(), tr.HitPos, 500) then

        local SWEPData = zwf.config.Bongs.items[ply_Bong.BongID]


        if tr.HitWorld then

            local ent = ents.Create(SWEPData.e_class)
            ent:SetPos(tr.HitPos)
            ent:SetModel(SWEPData.model)
            ent:Spawn()
            ent:Activate()

            ent:SetWeedID(ply_Bong:GetWeedID())
            ent:SetWeed_Name(ply_Bong:GetWeed_Name())
            ent:SetWeed_THC(ply_Bong:GetWeed_THC())
            ent:SetWeed_Amount(ply_Bong:GetWeed_Amount())
            ent:SetIsBurning(ply_Bong:GetIsBurning())

            zwf.f.SetOwner(ent, ply)

            ply:StripWeapon( SWEPData.w_class )


        elseif IsValid(tr.Entity) then

            if tr.Entity:IsPlayer() and tr.Entity:Alive() then

                if tr.Entity:HasWeapon(SWEPData.w_class) == true then

                    local str = zwf.language.General["BongSharingFail"]
                    str = string.Replace(str, "$PlayerName", tr.Entity:Nick() )
                    zwf.f.Notify(ply,str, 1)
                else
                    tr.Entity:Give(SWEPData.w_class, false)

                    local bong = tr.Entity:GetWeapon(SWEPData.w_class)

                    bong:SetWeedID(ply_Bong:GetWeedID())
                    bong:SetWeed_Name(ply_Bong:GetWeed_Name())
                    bong:SetWeed_THC(ply_Bong:GetWeed_THC())
                    bong:SetWeed_Amount(ply_Bong:GetWeed_Amount())
                    bong:SetIsBurning(ply_Bong:GetIsBurning())

                    tr.Entity:SelectWeapon(SWEPData.w_class)

                    ply:StripWeapon( SWEPData.w_class )
                end
            else

                local ent = ents.Create(SWEPData.e_class)
                ent:SetPos(tr.HitPos)
                ent:SetModel(SWEPData.model)
                ent:Spawn()
                ent:Activate()

                ent:SetWeedID(ply_Bong:GetWeedID())
                ent:SetWeed_Name(ply_Bong:GetWeed_Name())
                ent:SetWeed_THC(ply_Bong:GetWeed_THC())
                ent:SetWeed_Amount(ply_Bong:GetWeed_Amount())
                ent:SetIsBurning(ply_Bong:GetIsBurning())

                zwf.f.SetOwner(ent, ply)

                ply:StripWeapon( SWEPData.w_class )
            end
        end
    end
end

function zwf.f.DropJoint(ply)
    local tr = ply:GetEyeTrace()
    local ply_Joint = ply:GetActiveWeapon()

    if ply_Joint:GetIsBusy() or ply_Joint:GetIsSmoking() then return end

    if tr.Hit and tr.HitSky == false and zwf.f.InDistance(ply:GetPos(), tr.HitPos, 500) then

        if tr.HitWorld then

            local ent = ents.Create("zwf_joint_ent")
            ent:SetPos(tr.HitPos)
            ent:Spawn()
            ent:Activate()

            ent:SetWeedID(ply_Joint:GetWeedID())
            ent:SetWeed_Name(ply_Joint:GetWeed_Name())
            ent:SetWeed_THC(ply_Joint:GetWeed_THC())
            ent:SetWeed_Amount(ply_Joint:GetWeed_Amount())
            ent:SetIsBurning(ply_Joint:GetIsBurning())

            zwf.f.SetOwner(ent, ply)

            ply:StripWeapon( "zwf_joint" )
        elseif IsValid(tr.Entity) then

            if tr.Entity:IsPlayer() and tr.Entity:Alive() then

                if tr.Entity:HasWeapon("zwf_joint") == true then

                    local str = zwf.language.General["JointSharingFail"]
                    str = string.Replace(str, "$PlayerName", tr.Entity:Nick() )
                    zwf.f.Notify(ply,str, 1)
                else
                    tr.Entity:Give("zwf_joint", false)

                    local joint = tr.Entity:GetWeapon("zwf_joint")

                    joint:SetWeedID(ply_Joint:GetWeedID())
                    joint:SetWeed_Name(ply_Joint:GetWeed_Name())
                    joint:SetWeed_THC(ply_Joint:GetWeed_THC())
                    joint:SetWeed_Amount(ply_Joint:GetWeed_Amount())
                    joint:SetIsBurning(ply_Joint:GetIsBurning())

                    tr.Entity:SelectWeapon("zwf_joint")

                    ply:StripWeapon( "zwf_joint" )
                end
            else

                local ent = ents.Create("zwf_joint_ent")
                ent:SetPos(tr.HitPos)
                ent:Spawn()
                ent:Activate()

                ent:SetWeedID(ply_Joint:GetWeedID())
                ent:SetWeed_Name(ply_Joint:GetWeed_Name())
                ent:SetWeed_THC(ply_Joint:GetWeed_THC())
                ent:SetWeed_Amount(ply_Joint:GetWeed_Amount())
                ent:SetIsBurning(ply_Joint:GetIsBurning())

                zwf.f.SetOwner(ent, ply)

                ply:StripWeapon( "zwf_joint" )
            end
        end
    end
end


hook.Add("PlayerSay", "a_zwf_PlayerSay_Save", function(ply, text)
    if string.sub(string.lower(text), 1, 8) == "!savezwf" then
        if zwf.f.IsAdmin(ply) then
            zwf.f.Save_WeedBuyer()
            zwf.f.Notify(ply, "Weed Buyer NPC´s have been saved for the map " .. game.GetMap() .. "!", 0)
        else
            zwf.f.Notify(ply, "You do not have permission to perform this action, please contact an admin.", 1)
        end
    end
end)


hook.Add("canDropWeapon", "a_zwf_canDropWeapon", function(ply,swep)
    if IsValid(swep) and (string.sub( swep:GetClass(),1,8 ) == "zwf_bong" or swep:GetClass() == "zwf_joint" /*or swep:GetClass() == "zwf_cable" or swep:GetClass() == "zwf_shoptablet" or swep:GetClass() == "zwf_sniffer" or swep:GetClass() == "zwf_wateringcan"*/) then
        return false
    end
end)


// Called when the players picks up a weedblock
function zwf.f.CollectWeed(weedblock,ply)
    if zwf.f.IsWeedSeller(ply) == false then return end


    if ply.zwf_Weed == nil then
        ply.zwf_Weed = {}
    end


    local weedID = weedblock:GetWeedID()
    local weedTHC = weedblock:GetTHC()
    local WeedAmount = weedblock:GetWeedAmount()
    local weedName = weedblock:GetWeedName()

    zwf.f.Notify(ply, "+ " .. zwf.language.General["WeedBlock"] .. " [" .. weedblock:GetWeedName() .. "]", 0)
    table.insert(ply.zwf_Weed, {
        WeedID = weedID,
        THC = weedTHC,
        amount = WeedAmount,
        name = weedName
    })

    weedblock:Remove()
end
