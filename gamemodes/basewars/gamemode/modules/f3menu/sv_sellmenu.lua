util.AddNetworkString("BaseWars:SellEntities")
util.AddNetworkString("BaseWars:SellAll")


local SellCooldown = {}


local function CanPlayerSell(ply)
    local steamID = ply:SteamID()
    local currentTime = CurTime()

    if SellCooldown[steamID] and SellCooldown[steamID] > currentTime then
        local remainingTime = math.ceil(SellCooldown[steamID] - currentTime)
        BaseWars:Notify(ply, "#sellmenu_cooldown", NOTIFICATION_ERROR, 3, remainingTime)
        return false
    end
    
    return true
end

local function RecordSale(ply, entityCount, totalValue)
    local steamID = ply:SteamID()
    local currentTime = CurTime()
    
    SellCooldown[steamID] = currentTime + (BaseWars.Config.SellCooldown or 5)
end

net.Receive("BaseWars:SellEntities", function(len, ply)
	if ply:InRaid() then
		BaseWars:Notify(ply, "#sellmenu_sellDuringRaid", NOTIFICATION_ERROR, 5)
		return
	end

	if not CanPlayerSell(ply) then
		return
	end

	local totalEntities = 0
	local totalValue = 0
	local entitiesToSell = net.ReadTable()

	for k, v in pairs(entitiesToSell) do
		if not IsValid(v) or not v:ValidToSell(ply) then 
			continue 
		end

		local entValue = v:GetCurrentValue()
		totalEntities = totalEntities + 1
		totalValue = totalValue + entValue

		hook.Run("BaseWars:PreSellEntity", ply, v, entValue)

		SafeRemoveEntity(v)
	end

	if totalEntities == 0 then
		return
	end

	totalValue = totalValue * BaseWars.Config.BackMoney

	ply:AddMoney(totalValue)
	BaseWars:Notify(ply, "#sellmenu_sell", NOTIFICATION_SELL, 5, totalEntities, BaseWars:FormatMoney(totalValue))
	
	RecordSale(ply, totalEntities, totalValue)
end)

net.Receive("BaseWars:SellAll", function(len, ply)
	if ply:InRaid() then
		BaseWars:Notify(ply, "#sellmenu_sellDuringRaid", NOTIFICATION_ERROR, 5)
		return
	end

	if not CanPlayerSell(ply) then
		return
	end

	local totalEntities = 0
	local totalValue = 0
	local entitiesToRemove = {} 

	for k, v in ents.Iterator() do
		if not IsValid(v) or not v:ValidToSell(ply) then 
			continue 
		end

		local entValue = v:GetCurrentValue()

		if v.IsBank then
			entValue = entValue + (v.GetMoney and v:GetMoney() or 0)
		end

		if v.IsPrinter then
			entValue = entValue + (v.GetMoney and v:GetMoney() or 0)
		end

		totalEntities = totalEntities + 1
		totalValue = totalValue + entValue
		table.insert(entitiesToRemove, v)
	end

	if totalEntities == 0 then
		return
	end

	for _, v in ipairs(entitiesToRemove) do
		if IsValid(v) then
			hook.Run("BaseWars:PreSellEntity", ply, v, v:GetCurrentValue())
			SafeRemoveEntity(v)
		end
	end

	totalValue = totalValue * BaseWars.Config.BackMoney

	ply:AddMoney(totalValue)
	BaseWars:Notify(ply, "#sellmenu_sell", NOTIFICATION_SELL, 5, totalEntities, BaseWars:FormatMoney(totalValue))
	RecordSale(ply, totalEntities, totalValue)
end)
