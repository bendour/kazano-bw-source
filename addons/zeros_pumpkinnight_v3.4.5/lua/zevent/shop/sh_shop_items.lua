/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

/*
    "type_entity" 					= Entity Class
    "type_weapon" 					= Weapon Class
    "type_health" 					= Health
    "type_armor" 					= Armor
    "type_sh_acc" 					= Accessory HatID
    "type_pointshop01" 				= Pointshop01 Points
    "type_pointshop02_standard" 	= Pointshop02 StandardPoints
    "type_pointshop02_premium" 		= Pointshop02 PremiumPoints
    "type_bu3" 						= Blues Unboxing 3
    "type_underdone" 				= Underdone
    "type_easyskins" 				= EasySkins https://www.gmodstore.com/market/view/easy-skins
    "type_mtokens" 					= MTokens https://www.gmodstore.com/market/view/6712
    "type_ass" 						= ASS https://www.gmodstore.com/market/view/advanced-accessory-the-most-advanced-accessory-system
    "type_santosrp_giveitem" 		= SantosRP - GiveItem (.class,.amount)
    "type_wos_item" 				= WOS - Item
    "type_wos_points" 				= WOS - Points
    "type_wos_xp" 					= WOS - XP
    "type_wos_level" 				= WOS - Level
    "type_vrondakis_xp" 			= Vrondakis - XP
    "type_vrondakis_level" 			= Vrondakis - Level
    "type_glorified_xp" 			= Glorified - XP
    "type_glorified_level" 			= Glorified - Level
    "type_essentials_xp" 			= Essentials - XP
    "type_essentials_level" 		= Essentials - Level
    "type_elite_xp" 				= Elite - XP
    "type_sreward_token" 			= sReward - Tokens
	"type_zpc2_coin" 				= ZerosPyrocrafter 2 - PyroCoins
	"type_lua" 						= LUA
	"type_voidcase_item" 		= Voidcases https://www.gmodstore.com/market/view/voidcases-unboxing-system
*/


zpn.PurchaseType = {}
local function AddPrizeType(id,data) zpn.PurchaseType[id] = data end

// Entity
AddPrizeType("type_entity",function(ply, itemData)
	if SERVER then
		local ent = ents.Create(itemData.class)
		ent:SetModel(itemData.model)
		ent:SetPos(ply:GetPos() + (ply:GetUp() * 40))
		ent:Spawn()
		zclib.Player.SetOwner(ent, ply)

		if itemData.class == "zpn_beartrap" then
			ent.TrapOwner = ply
		end

		if zclib.Inventory.Pickup(ply,ent,itemData.class) then
			zclib.Notify(ply, string.Replace(zpn.language.General["inv_itemadd"],"$ItemName",itemData.name), 0)
		end
	end
	return true
end)

// Weapon
AddPrizeType("type_weapon",function(ply, itemData)
    if not ply:HasWeapon(itemData.class) then
        if SERVER then
            ply:Give(itemData.class)
            ply:SelectWeapon(itemData.class)
        end
        return true
    else
        if CLIENT then
            notification.AddLegacy(string.Replace(zpn.language.General["PurchaseFail01"],"$itemname",itemData.name), NOTIFY_ERROR, 3)
            surface.PlaySound( "common/warning.wav" )
        end
        return false
    end
end)

// Health
AddPrizeType("type_health",function(ply, itemData)
    if SERVER then ply:SetHealth( math.Clamp( ply:Health() + (itemData.amount or 100), 0, ply:GetMaxHealth())) end
    return true
end)

// Armor
AddPrizeType("type_armor",function(ply, itemData)
    if SERVER then ply:SetArmor(math.Clamp(ply:Armor() + (itemData.amount or 100),0,100)) end
    return true
end)

// SH Accessory
AddPrizeType("type_sh_acc",function(ply, itemData)
    if ply:SH_HasAccessory(itemData.class) == false then
        if SERVER then ply:SH_AddAccessory(itemData.class) end
        return true
    else
        if CLIENT then
            notification.AddLegacy(string.Replace(zpn.language.General["PurchaseFail01"],"$itemname",itemData.name), NOTIFY_ERROR, 3)
            surface.PlaySound( "common/warning.wav" )
        end
        return false
    end
end)
// We dont allow players to sell hats which are given from the candy shop
local HatIDsList = {}
timer.Simple(2,function() for k,v in pairs(zpn.config.Shop) do if v and v.type == "type_sh_acc" then HatIDsList[v.class] = true end end end)
hook.Add("SH_ACC.CanSell","SH_ACC.CanSell.ZerosPumpkinNight",function(ply,acc)
	if HatIDsList[acc.id] then

		// Check if the hat exist in the owned items thing
		local OwnsHat = false
		for k,v in pairs(ply.zpn_OwnedItems) do
			local ItemData = zpn.config.Shop[k]
			if not ItemData then continue end
			if not ItemData.class then continue end
			if HatIDsList[ItemData.class] then
				OwnsHat = true
				break
			end
		end
		if OwnsHat then
			return false
		end
	end
end)

// Pointshop 1 - Points
AddPrizeType("type_pointshop01",function(ply, itemData)
    if SERVER then ply:PS_GivePoints(itemData.amount) end
    return true
end)

// Pointshop 2 - StandardPoints
AddPrizeType("type_pointshop02_standard",function(ply, itemData)
    if SERVER then ply:PS2_AddStandardPoints(itemData.amount) end
    return true
end)

// Pointshop 2 - PremiumPoints
AddPrizeType("type_pointshop02_premium",function(ply, itemData)
    if SERVER then ply:PS2_AddPremiumPoints(itemData.amount) end
    return true
end)

// Blues Unboxing 3
AddPrizeType("type_bu3",function(ply, itemData)
    if SERVER then ply:UB3AddItem(itemData.class, itemData.amount) end
    return true
end)

// Underdone
AddPrizeType("type_underdone",function(ply, itemData)
    if SERVER then ply:AddItem(itemData.class, itemData.amount) end
    return true
end)

// EasySkins
AddPrizeType("type_easyskins",function(ply, itemData)
    local _, skin_id = SH_EASYSKINS.GetSkinByName(itemData.skin_name)
    local skin = SH_EASYSKINS.GetSkin(skin_id)

    if not IsValid(ply:GetActiveWeapon()) or table.HasValue(skin.weaponTbl, ply:GetActiveWeapon():GetClass()) == false then
        if CLIENT then
            notification.AddLegacy(table.concat(skin.weaponTbl, ",", 1, #skin.weaponTbl), NOTIFY_HINT, 3)
            notification.AddLegacy(zpn.language.General["easyskin_invalidgun"], NOTIFY_ERROR, 3)
            CL_EASYSKINS.PlaySound("deny")
        end

        return false
    end

    local _weaponclass = ply:GetActiveWeapon():GetClass()
    local _canbuy, _reason = SH_EASYSKINS.CanBuySkin(ply, skin_id, _weaponclass)

    if _canbuy == false then
        if CLIENT then
            notification.AddLegacy(_reason, NOTIFY_ERROR, 3)
            CL_EASYSKINS.PlaySound("deny")
        end

        return false
    end

    if SERVER then
        SV_EASYSKINS.GiveSkinToPlayer(ply:SteamID64(), skin_id, {_weaponclass})
    end

    return true
end)

// Mtokens
AddPrizeType("type_mtokens",function(ply, itemData)
    if SERVER then mTokens.AddPlayerTokens(ply, itemData.amount) end
    return true
end)

// ASS
AddPrizeType("type_ass",function(ply, itemData)
    if SERVER then
        if ply:AASIsBought(itemData.class) == false then
            AAS.GiveItem(ply:SteamID64(),itemData.class, 0)
            return true
        else
            zclib.Notify(ply, string.Replace(zpn.language.General["PurchaseFail01"],"$itemname",itemData.name), 1)
            return false
        end
    else
        return true
    end
end)

// SantosRP - GiveItem
AddPrizeType("type_santosrp_giveitem",function(ply, itemData)
    if SERVER then
        if not GAMEMODE.Inv:ValidItem(itemData.class) then return end
        GAMEMODE.Inv:GivePlayerItem(ply, itemData.class,itemData.amount)
    end
    return true
end)

// WOS - Item
AddPrizeType("type_wos_item",function(ply, itemData)
    if SERVER and wOS and wOS.HandleItemPickup then
        wOS:HandleItemPickup( ply, itemData.class)
    end
    return true
end)

// WOS - Points
AddPrizeType("type_wos_points",function(ply, itemData)
    if SERVER then
        if not isfunction(ply.SetSkillPoints) then return end
        local oldPoints = ply:GetSkillPoints()
        ply:SetSkillPoints(oldPoints + itemData.amount)
    end

    return true
end)

// WOS - XP
AddPrizeType("type_wos_xp",function(ply, itemData)
    if SERVER then
        if not isfunction(ply.SetSkillXP) then return end
        local oldXP = ply:GetSkillXP()
        ply:SetSkillXP(oldXP + itemData.amount)
    end
    return true
end)

// WOS - Level
AddPrizeType("type_wos_level",function(ply, itemData)
    if SERVER then
        if not isfunction(ply.SetSkillLevel) then return end
        local oldLevel = ply:GetSkillLevel()
        ply:SetSkillLevel(oldLevel + itemData.amount)
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    return true
end)

// Vrondakis - XP
AddPrizeType("type_vrondakis_xp",function(ply, itemData)
    if SERVER then
        ply:addXP(itemData.amount)
    end

    return true
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

// Vrondakis - Level
AddPrizeType("type_vrondakis_level",function(ply, itemData)
    if SERVER then
        ply:addLevels(itemData.amount)
    end

    return true
end)

// Glorified - XP
AddPrizeType("type_glorified_xp",function(ply, itemData)
    if SERVER then
        GlorifiedLeveling.AddPlayerXP(ply, itemData.amount)
    end

    return true
end)

// Glorified - Level
AddPrizeType("type_glorified_level",function(ply, itemData)
    if SERVER then
        GlorifiedLeveling.AddPlayerLevels(ply, itemData.amount)
    end

    return true
end)

// Essentials - XP
AddPrizeType("type_essentials_xp",function(ply, itemData)
    if SERVER then
        ply:AddExperience(itemData.amount,"")
    end

    return true
end)

// Essentials - Level
AddPrizeType("type_essentials_level",function(ply, itemData)
    if SERVER then
        ply:AddLevel(itemData.amount,"")
    end

    return true
end)

// Elite - XP
AddPrizeType("type_elite_xp",function(ply, itemData)
    if SERVER then
        EliteXP.CheckXP(ply, itemData.amount)
    end

    return true
end)

// sReward - Tokens
AddPrizeType("type_sreward_token",function(ply, itemData)
    if SERVER then
        sReward.GiveTokens(ply,itemData.amount)
    end

    return true
end)

// ZerosPyrocrafter 2 - PyroCoins
AddPrizeType("type_zpc2_coin",function(ply, itemData)
    if SERVER then
		zpc2.data.Give_PyroCoins(ply,itemData.amount)
    end

    return true
end)

// LUA
AddPrizeType("type_lua",function(ply, itemData)
	if SERVER and itemData and itemData.lua then
		itemData.lua(ply)
	end

    return true
end)

// Voidcases https://www.gmodstore.com/market/view/voidcases-unboxing-system
AddPrizeType("type_voidcase_item",function(ply, itemData)
	if SERVER and itemData and itemData.item_id then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

		local sid = ply:SteamID64()
		local id = itemData.item_id
		local amount = itemData.amount or 1
		local item = VoidCases.Config.Items[id]
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

	    if not item then
			zclib.Notify(ply, "Cant find Voidcase Item with ID > " .. id, 1)
			print("Cant find Voidcase Item with ID > " .. id)
			return
		end

	    VoidCases.AddItem(sid, id, amount)

	    VoidCases.NetworkItem(ply, id, amount)
	end

    return true
end)
