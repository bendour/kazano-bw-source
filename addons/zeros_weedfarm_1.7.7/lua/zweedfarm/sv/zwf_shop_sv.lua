if CLIENT then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

util.AddNetworkString("zwf_Shop_Open_net")
util.AddNetworkString("zwf_Shop_Close_net")
util.AddNetworkString("zwf_Shop_Buy_net")


net.Receive("zwf_Shop_Buy_net", function(len,ply)
    if zwf.f.NW_Player_Timeout(ply) then return end

    local pID = net.ReadInt(16)
    local pCat = net.ReadUInt(4)

    if IsValid(ply) and pCat and pID then

        zwf.f.BuyItem(ply,pCat,pID)
    end
end)

function zwf.f.Shop_Item_MaxCheck(ply,itemdata,pCat,pID)
    local count = 0
    for k, v in pairs(zwf.EntList) do
        if IsValid(v) and /*v:GetClass() == itemdata.class and*/ zwf.f.IsOwner(ply, v) and v.shop_cat == pCat and v.shop_id == pID then
            count = count + 1
        end
    end

    if count >= itemdata.max then
        return true
    else
        return false
    end
end

local itemRot = {
    ["zwf_splice_lab"] = 180,
    ["zwf_generator"] = 90,
    ["zwf_fuel"] = 0,
    ["zwf_lamp"] = 90,
    ["zwf_ventilator"] = -90,
    ["zwf_outlet"] = 0,
    ["zwf_pot"] = 90,
    ["zwf_pot_hydro"] = 90,
    ["zwf_soil"] = 90,
    ["zwf_watertank"] = 90,
    ["zwf_drystation"] = 90,
    ["zwf_packingstation"] = 0,
    ["zwf_autopacker"] = 0,
    ["zwf_seed_bank"] = 0,
    ["zwf_seed"] = 90,
    ["zwf_nutrition"] = 180,
    ["zwf_palette"] = 0,
}

function zwf.f.BuyItem(ply, pCat, pID)
    local itemData = zwf.config.Shop[pCat]
    if itemData == nil then return end

    itemData = itemData.items[pID]
    if itemData == nil then return end

    if zwf.f.HasMoney(ply, itemData.price) == false then
        zwf.f.Notify(ply, zwf.language.General["not_enough_money"], 1)
        return
    end

    if itemData.ranks and table.Count(itemData.ranks) > 0 and zwf.f.PlayerRankCheck(ply,itemData.ranks) == false then
        zwf.f.Notify(ply, zwf.language.General["not_correct_rank"], 1)
        return
    end

    if itemData.jobs and table.Count(itemData.jobs) > 0 and itemData.jobs[zwf.f.GetPlayerJob(ply)] == nil then
        zwf.f.Notify(ply, zwf.language.General["not_correct_job"], 1)
        return
    end

    local product_name = "nil"
    local product_limit = 1

    if pCat == 2 then

        product_name = zwf.language.Shop["category_Seeds"]
        product_limit = zwf.config.Seeds.ent_limt
    elseif pCat == 3 then

        product_name = zwf.language.Shop["category_Nutritions"]
        product_limit = 7
    elseif pCat == 1 and itemData.class == "zwf_lamp" then

        product_name = zwf.config.Lamps[itemData.lampid].name
        product_limit = itemData.max
    else
        product_name = itemData.name
        product_limit = itemData.max
    end

    itemData.max = product_limit

    if zwf.f.Shop_Item_MaxCheck(ply,itemData,pCat,pID) then
        local str = zwf.language.General["entity_limit"]
        str = string.Replace(str, "$itemname", product_name )

        zwf.f.Notify(ply, str, 1)
        return
    end


    local tr = ply:GetEyeTrace()

    if tr.Hit == false then return end

    if zwf.f.InDistance(ply:GetPos(), tr.HitPos, 1000) == false then return end

    zwf.f.TakeMoney(ply, itemData.price)


    local ent = ents.Create(itemData.class)
    ent:SetPos(tr.HitPos + Vector(0, 0, 25))

    local angle = ply:GetAimVector():Angle()
    angle = Angle(0, angle.yaw, 0)
    angle:RotateAroundAxis(angle:Up(), itemRot[itemData.class])
    ent:SetAngles(angle)
    ent:Spawn()
    ent:SetCurrentValue(itemData.price)
    ent:Activate()

    local ActiveHooks = hook.GetTable()
    if ActiveHooks["playerBoughtCustomEntity"] then
        // Lets call this so other scripts who use this function might run code on the bought entity
        local tblEnt = {
            price = itemData.price,
            name = itemData.name or ""
        }
        hook.Run("playerBoughtCustomEntity", ply, tblEnt, ent, itemData.price)
    end

    // Here we tell the entity its shop category and id so we can resell it later
    ent.shop_cat = pCat
    ent.shop_id = pID

    zwf.f.SetOwner(ent, ply)


    if pCat == 2 then

        ent:SetSeedID(itemData.seedid)

        ent:SetPerf_Time(100)
        ent:SetPerf_Amount(100)
        ent:SetPerf_THC(100)

        ent:SetSeedCount(zwf.config.Seeds.Count)

        local plantData = zwf.config.Plants[itemData.seedid]
        if plantData then
            ent:SetSeedName(plantData.name)
            ent:SetSkin(plantData.skin)
        end
    elseif pCat == 3 then

        ent:SetNutritionID(itemData.nutid)
        ent:SetSkin(zwf.config.Nutrition[itemData.nutid].skin)
    elseif pCat == 1 and itemData.class == "zwf_lamp" then

        ent:SetLampID(itemData.lampid)
        ent:SetModel(itemData.model)
    end

    local str = zwf.language.General["ItemBought"]
    str = string.Replace(str, "$itemname", product_name )
    str = string.Replace(str, "$price", itemData.price )
    str = string.Replace(str, "$currency", zwf.config.Currency )

    zwf.f.Notify(ply, str, 0)
end

// Tells use if the entity can be sold and what action to call before it gets removed
function zwf.f.SellItem_Check(ent)

    local entClass = ent:GetClass()

    if entClass == "zwf_fuel" then

        if ent.GotUsed then
            return true
        else
            return false
        end
    elseif entClass == "zwf_generator" then

        if (ent:GetIsRefilling() or ent:GetAnimState() == 2) then
            return true
        else
            zwf.f.CableSWEP_Deconnect(ent)
            return false
        end
    elseif entClass == "zwf_lamp" then

        if IsValid(ent:GetPowerSource()) then
            zwf.f.CableSWEP_Deconnect(ent:GetPowerSource())
        end
        zwf.f.CableSWEP_Deconnect(ent)

        return false
    elseif entClass == "zwf_ventilator" then

        if IsValid(ent:GetPowerSource()) then
            zwf.f.CableSWEP_Deconnect(ent:GetPowerSource())
        end
        zwf.f.CableSWEP_Deconnect(ent)

        return false
    elseif entClass == "zwf_drystation" then

        if zwf.f.DryStation_HasWeed(ent) then
            return true
        else
            return false
        end
    elseif entClass == "zwf_nutrition" then
        return false
    elseif entClass == "zwf_autopacker" then
        return false
    elseif entClass == "zwf_outlet" then
        if IsValid(ent:GetPowerSource()) then
            zwf.f.CableSWEP_Deconnect(ent:GetPowerSource())
        end
        zwf.f.CableSWEP_Deconnect(ent)
        return false
    elseif entClass == "zwf_packingstation" then
        if ent:GetJarCount() <= 0 then
            return false
        else
            return true
        end
    elseif entClass == "zwf_palette" then
        if ent:GetMoney() <= 0 then
            return false
        else
            return true
        end
    elseif entClass == "zwf_pot" then

        if ent:GetSeed() == -1 then
            return false
        else
            return true
        end
    elseif entClass == "zwf_pot_hydro" then

        if ent:GetSeed() == -1 then
            return false
        else
            return true
        end
    elseif entClass == "zwf_watertank" then
        return false
    elseif entClass == "zwf_seed_bank" then
        return false
    elseif entClass == "zwf_splice_lab" then
        if IsValid(ent:GetWeedA()) or IsValid(ent:GetWeedB()) then
            return true
        else
            return false
        end
    end
end

function zwf.f.SellItem(ply)

    if zwf.config.ShopTablet.refund == 0 then return end

    local tr = ply:GetEyeTrace()

    if tr.Hit == false then return end

    if zwf.f.InDistance(ply:GetPos(), tr.HitPos, 1000) == false then return end

    local ent = tr.Entity

    if not IsValid(ent) then return end

    if ent.shop_cat == nil or ent.shop_id == nil then return end

    if zwf.f.IsOwner(ply, ent) == false then return end


    // Tells use if the entity can be sold and what actions to call before it gets removed
    if zwf.f.SellItem_Check(ent) then return end




    local itemdata = zwf.config.Shop[ent.shop_cat].items[ent.shop_id]

    SafeRemoveEntityDelayed(ent,0)

    local money = itemdata.price * zwf.config.ShopTablet.refund

    zwf.f.GiveMoney(ply, money)

    zwf.f.Notify(ply, "+" .. money .. zwf.config.Currency, 0)
end
