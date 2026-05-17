local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('TauntsClass')
OBJECT_TYPE.UniqueIdentifier = "Taunts"

function OBJECT_TYPE.OnRemove(ply, plyItem, item)
    if item.metadata[1] then
        // Remove the anim taunt from player, if any
        ply.ashop_anim = nil
    end
end

ashop.SafeNet('selectTaunt', function(ply)
    if net.ReadBool() then
        if IsValid(ply:GetObserverTarget()) then return end

        local e = net.ReadUInt(ashop.Config.BitsPlyItemID)
        if !ply.ashop_data or !ply.ashop_data.items[e] then return end

        local itemID = ply.ashop_data.items[e].item_id
        local item = ashop.items[itemID]
        local ot = ashop.object_types[item.object_types]

        if !ot.UniqueIdentifier or ot.UniqueIdentifier != "Taunts" then
            return
        end

        if !item.metadata[2] then
            print("[AShop] You forgot to add a wOs anim name to the item: " .. item.name)
            return
        end

        ply.ashop_anim = {item.metadata[2], item.metadata[5], item.metadata[3] or false}

        net.Start('ashop_selectTaunt')
            net.WriteEntity(ply)
            net.WriteBool(true)
            net.WriteUInt(itemID, ashop.Config.BitsItemID)
        net.Broadcast()

        ply:SetCycle( 0 )
    elseif ply.ashop_anim then
        net.Start('ashop_selectTaunt')
            net.WriteEntity(ply)
            net.WriteBool(false)
        net.Broadcast()

        ply:SetCycle( 0 )
        ply.ashop_anim = nil
    end
end, 0.15)

local function removeAnim(ply)
    if ply.ashop_anim then
        ply.ashop_anim = nil
        net.Start('ashop_selectTaunt')
            net.WriteEntity(ply)
            net.WriteBool(false)
        net.Broadcast()
    end
end


hook.Add("PlayerEnteredVehicle", "ashop_RemoveAnim", removeAnim)

local rem = {
    [IN_ATTACK] = true,
    [IN_JUMP] = true,
    [IN_DUCK] = true,
    [IN_FORWARD] = true,
    [IN_BACK] = true,
    [IN_MOVELEFT] = true,
    [IN_MOVERIGHT] = true,
    [IN_ATTACK2] = true,
    [IN_ALT1] = true,
    [IN_ALT2] = true,
    [IN_GRENADE1] = true,
    [IN_GRENADE2] = true,
}

hook.Add( "KeyPress", "ashop_RemoveAnim", function( ply, key )
	if rem[key] then
		removeAnim(ply)
	end
end )

hook.Add("Move", "ashop_RemoveAnim", function(ply, mv)
    if mv:GetButtons() != 0 and bit.band(mv:GetButtons(), 8192) != 8192 then
        removeAnim(ply)
    end
end)

ashop.RegisterObjectType(OBJECT_TYPE)