if CLIENT then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

function zwf.f.NPC_Initialize(npc)
    npc:SetMaxYawSpeed(90)

    if zwf.config.NPC.Capabilities then
        npc:CapabilitiesAdd(CAP_ANIMATEDFACE)
        npc:CapabilitiesAdd(CAP_TURN_HEAD)
    end

    zwf.f.Add_BuyerNPC(npc)
    zwf.f.RefreshBuyRate(npc)
end


function zwf.f.NPC_USE(ply, npc)
    if zwf.f.CanBuyBongs(ply) == false then
        zwf.f.Notify(ply, zwf.language.NPC["interact_fail"], 1)

    	zwf.f.CreateNetEffect("zwf_npc_wrongjob",npc)
        return
    end
    // Open NPC Interface
    zwf.f.NPC_OpenInterface(ply, npc)
end


hook.Add( "EntityTakeDamage", "zwf_EntityTakeDamage_NPCFix", function( target, dmginfo )
	if IsValid(target) and target:GetClass() == "zwf_buyer_npc" then
		return true
	end
end )


util.AddNetworkString("zwf_OpenNPC")
util.AddNetworkString("zwf_CloseNPC")
function zwf.f.NPC_OpenInterface(ply, npc)

    net.Start("zwf_OpenNPC")
    net.WriteEntity(npc)
    net.Send(ply)
end

util.AddNetworkString("zwf_BuyBong")
net.Receive("zwf_BuyBong", function(len,ply)
    if zwf.f.NW_Player_Timeout(ply) then return end

    local pID = net.ReadInt(16)
    local npc = net.ReadEntity()

    if pID == nil then return end
    if not IsValid(npc) then return end
    if npc:GetClass() ~= "zwf_buyer_npc" then return end
    if not IsValid(ply) then return end
    if not ply:IsPlayer() then return end
    if not ply:Alive() then return end
    if not zwf.f.InDistance(ply:GetPos(), npc:GetPos(), 1000) then return end

    zwf.f.BuyBong(ply,pID,npc)
end)
function zwf.f.BuyBong(ply, pID,npc)
    local bongData = zwf.config.Bongs.items[pID]

    if bongData == nil then return end

    if zwf.f.HasMoney(ply, bongData.price) == false then
        zwf.f.Notify(ply, zwf.language.General["not_enough_money"], 1)
        return
    end

    if table.Count(bongData.ranks) > 0 and zwf.f.PlayerRankCheck(ply,bongData.ranks) == false then
        zwf.f.Notify(ply, zwf.language.General["not_correct_rank"], 1)
        return
    end

    if ply:HasWeapon(bongData.w_class) then
        zwf.f.Notify(ply, zwf.language.General["bong_pickup_fail"], 1)
        return
    end

    local HasBongInWorld = false
    for k, v in pairs(zwf.EntList) do
        if IsValid(v) and v:GetClass() == bongData.e_class and zwf.f.IsOwner(ply, v) then
            HasBongInWorld = true
            break
        end
    end

    if HasBongInWorld then
        zwf.f.Notify(ply, zwf.language.General["bong_pickup_fail"], 1)
        return
    end

    local str = zwf.language.General["ItemBought"]
    str = string.Replace(str, "$itemname", bongData.name )
    str = string.Replace(str, "$price", bongData.price )
    str = string.Replace(str, "$currency", zwf.config.Currency )

    zwf.f.Notify(ply, str, 0)

    zwf.f.TakeMoney(ply, bongData.price)

    zwf.f.Debug("Bought Bong: " .. bongData.name)

    npc:EmitSound("zwf_npc_sell")

    zwf.f.CreateNetEffect("zwf_selling",npc)

    ply:Give(bongData.w_class, false)

    ply:SelectWeapon(bongData.w_class)
end




util.AddNetworkString("zwf_SellWeed")
net.Receive("zwf_SellWeed", function(len,ply)
    if zwf.f.NW_Player_Timeout(ply) then return end

    local npc = net.ReadEntity()

    if not IsValid(npc) then return end
    if npc:GetClass() ~= "zwf_buyer_npc" then return end
    if not IsValid(ply) then return end
    if not ply:IsPlayer() then return end
    if not ply:Alive() then return end
    if not zwf.f.InDistance(ply:GetPos(), npc:GetPos(), 1000) then return end

    zwf.f.NPC_SellWeed(ply,npc)
end)

function zwf.f.NPC_GetSellValue(weed_id,weed_amount,weed_thc)
    local wBlockValue = zwf.config.Plants[weed_id].sellvalue

    local amount_mul = (1 / (zwf.config.Jar.Capacity * 4)) * weed_amount
    wBlockValue = wBlockValue * amount_mul

    local finalValue = wBlockValue * (1 + ((zwf.config.THC.sellprice_influence / zwf.config.THC.Max) * weed_thc))

    return finalValue
end

function zwf.f.NPC_SellWeed(ply, npc)

    //Checks if the player has the correct job to sell weed
    if zwf.f.IsWeedSeller(ply) == false then
        return
    end

    local earning = 0
    local WeedBlockCount = 0

    if zwf.config.NPC.SellMode == 2 then
        if ply.zwf_Weed then
            for k, v in pairs(ply.zwf_Weed) do
                if v then
                    earning = earning + zwf.f.NPC_GetSellValue(v.WeedID,v.amount,v.THC)
                    WeedBlockCount = WeedBlockCount + 1
                end
            end
        end
        ply.zwf_Weed = {}
    else

        for k, v in pairs(zwf.EntList) do

            if IsValid(v) and zwf.f.InDistance(ply:GetPos(), v:GetPos(), 250) then

                if v:GetClass() == "zwf_palette"  and v:GetBlockCount() > 0 then
                    WeedBlockCount = WeedBlockCount + v:GetBlockCount()
                    earning = earning + v:GetMoney()
                    zwf.f.CreateNetEffect("zwf_selling_effect",v:GetPos())
                    SafeRemoveEntity(v)
                elseif v:GetClass() == "zwf_weedblock" then
                    earning = earning + zwf.f.NPC_GetSellValue(v:GetWeedID(),v:GetWeedAmount(),v:GetTHC())
                    WeedBlockCount = WeedBlockCount + 1
                    zwf.f.CreateNetEffect("zwf_selling_effect",v:GetPos())
                    SafeRemoveEntity(v)
                end
            end
        end
    end

    local mod_earning,mod_blockcount = hook.Run("zwf_PreWeedSold" ,ply, npc, earning, WeedBlockCount)

    earning = mod_earning
    WeedBlockCount = mod_blockcount

    local profit = (1 / 100) * npc:GetPrice()

    earning = earning * profit

    if earning <= 0 then
        zwf.f.Notify(ply, zwf.language.NPC["interact_noweed"], 1)
    else

        // Custom Hook
        hook.Run("zwf_OnWeedSold" ,ply, npc, earning, WeedBlockCount)

        zwf.f.AlarmPolice(ply)

        zwf.f.Notify(ply, "+" .. zwf.config.Currency .. math.Round(earning), 0)
        zwf.f.GiveMoney(ply, earning)
		local xp = math.floor(BaseWars:CalculatePlayerXP(ply, BaseWars:CalculateXPFromMultiplier(earning) * .01))
		ply:AddXP(xp)
        zwf.f.CreateNetEffect("zwf_npc_sell",npc)
    end
end

// Informs the police that the player just sold weed
function zwf.f.AlarmPolice(ply)
    -- if zwf.config.Police.WantedOnWeedSell == false then return end

    -- local police = {}
    -- for k, v in pairs(player.GetAll()) do
    --     if IsValid(v) and v:IsPlayer() and v:Alive() and zwf.config.Police.Jobs[zwf.f.GetPlayerJob(v)] then
    --         table.insert(police,v)
    --     end
    -- end
    -- if police and table.Count(police) > 0 and IsValid(police[1]) then
    --     hook.Run("zwf_OnWanted", ply)
    --     ply:wanted(police[1], zwf.config.Police.WantedMessage, zwf.config.Police.WantedTime)
    -- end
end


// Buy Price
zwf.BuyerList = zwf.BuyerList or {}
function zwf.f.Add_BuyerNPC(npc)
    table.insert(zwf.BuyerList, npc)
end

function zwf.f.Check_BuyerMarkt_TimerExist()

    zwf.f.Timer_Remove("zwf_buyermarkt_id")
    if zwf.config.NPC.RefreshRate > 0 then
        zwf.f.Timer_Create("zwf_buyermarkt_id",zwf.config.NPC.RefreshRate, 0, zwf.f.ChangeMarkt)
    end
end

function zwf.f.RefreshBuyRate(npc)
    npc:SetPrice(math.random(zwf.config.NPC.MinBuyRate, zwf.config.NPC.MaxBuyRate))
end

function zwf.f.ChangeMarkt()
    for k, v in pairs(zwf.BuyerList) do
        if IsValid(v) then
            zwf.f.RefreshBuyRate(v)
        end
    end
end

zwf.f.Check_BuyerMarkt_TimerExist()


// Save functions
concommand.Add( "zwf_save_weedbuyer", function( ply, cmd, args )

    if zwf.f.IsAdmin(ply) then
        zwf.f.Notify(ply, "Weed Buyer entities have been saved for the map " .. game.GetMap() .. "!", 0)
        zwf.f.Save_WeedBuyer()
    end
end )

concommand.Add( "zwf_remove_weedbuyer", function( ply, cmd, args )

    if zwf.f.IsAdmin(ply) then
        zwf.f.Notify(ply, "Weed Buyer entities have been removed for the map " .. game.GetMap() .. "!", 0)
        zwf.f.Remove_WeedBuyer()
    end
end )

function zwf.f.Save_WeedBuyer()
    local data = {}

    for u, j in pairs(ents.FindByClass("zwf_buyer_npc")) do
        if IsValid(j) then
            table.insert(data, {
                pos = j:GetPos(),
                ang = j:GetAngles()
            })
        end
    end

    if not file.Exists("zwf", "DATA") then
        file.CreateDir("zwf")
    end
    if table.Count(data) > 0 then
        file.Write("zwf/" .. string.lower(game.GetMap()) .. "_buyer_npc" .. ".txt", util.TableToJSON(data))
    end
end

function zwf.f.Load_WeedBuyer()
    if file.Exists("zwf/" .. string.lower(game.GetMap()) .. "_buyer_npc" .. ".txt", "DATA") then
        local data = file.Read("zwf/" .. string.lower(game.GetMap()) .. "_buyer_npc" .. ".txt", "DATA")
        data = util.JSONToTable(data)

        if data and table.Count(data) > 0 then
            for k, v in pairs(data) do
                local ent = ents.Create("zwf_buyer_npc")
                ent:SetPos(v.pos)
                ent:SetAngles(v.ang)
                ent:Spawn()
                ent:Activate()

                local phys = ent:GetPhysicsObject()

                if (phys:IsValid()) then
                    phys:Wake()
                    phys:EnableMotion(false)
                end
            end

            print("[Zeros WeedFarm] Finished loading Weed Buyer Entities.")
        end
    else
        print("[Zeros WeedFarm] No map data found for Weed Buyer entities. Please place some and do !savezwf to create the data.")
    end
end

function zwf.f.Remove_WeedBuyer()
    if file.Exists("zwf/" .. string.lower(game.GetMap()) .. "_buyer_npc" .. ".txt", "DATA") then
        file.Delete("zwf/" .. string.lower(game.GetMap()) .. "_buyer_npc" .. ".txt")
    end

    for k, v in pairs(ents.FindByClass("zwf_buyer_npc")) do
        if IsValid(v) then
            v:Remove()
        end
    end
end

timer.Simple(0,function()
    zwf.f.Load_WeedBuyer()
end)

hook.Add("PostCleanupMap", "a_zwf_SpawnWeedBuyerPostCleanUp", zwf.f.Load_WeedBuyer)
