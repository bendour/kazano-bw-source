if not SERVER then return end
zrush = zrush or {}
zrush.FuelBuyer = zrush.FuelBuyer or {}
zrush.FuelBuyer.List = zrush.FuelBuyer.List or {}

function zrush.FuelBuyer.Initialize(FuelBuyer)
	FuelBuyer:SetModel(zrush.config.FuelBuyer.Model)
	FuelBuyer:SetSolid(SOLID_BBOX)
	FuelBuyer:SetHullSizeNormal()

	FuelBuyer:SetNPCState(NPC_STATE_SCRIPT)
	FuelBuyer:SetHullType(HULL_HUMAN)
	FuelBuyer:SetUseType(SIMPLE_USE)

	FuelBuyer:CapabilitiesAdd(CAP_ANIMATEDFACE)
	FuelBuyer:CapabilitiesAdd(CAP_TURN_HEAD)

	zrush.FuelBuyer.RefreshBuyRate(FuelBuyer)

	table.insert(zrush.FuelBuyer.List,FuelBuyer)
end


function zrush.FuelBuyer.OnUse(FuelBuyer,ply)

	// Does the player have the correct job?
	if zrush.config.Jobs and table.Count(zrush.config.Jobs) > 0 and zrush.config.Jobs[zclib.Player.GetJob(ply)] == nil then
		zrush.Notify(ply, zrush.language["WrongJob"], 1)
		return
	end

	if zrush.config.FuelBuyer.SellMode == 1 then
		zrush.FuelBuyer.Open(FuelBuyer,ply)
	else
		// 	Direct Sell
		zrush.FuelBuyer.DirectSell(FuelBuyer, ply)
	end
end

// Called when a player presses e on the fuelbuyer
util.AddNetworkString("zrush_npc_open")
function zrush.FuelBuyer.Open(FuelBuyer,ply)
	// Open Sell UI
	net.Start("zrush_npc_open")
	net.WriteEntity(FuelBuyer)
	net.WriteTable(ply:zrush_GetFuelBarrels())
	net.Send(ply)
end

function zrush.FuelBuyer.RefreshBuyRate(FuelBuyer)
	FuelBuyer:SetPrice_Mul(math.random(zrush.config.FuelBuyer.MinBuyRate, zrush.config.FuelBuyer.MaxBuyRate))
end



function zrush.FuelBuyer.ChangeFuelMarkt()
	for k, v in pairs(zrush.FuelBuyer.List) do
		if IsValid(v) then
			zrush.FuelBuyer.RefreshBuyRate(v)
		end
	end
end

function zrush.FuelBuyer.FuelBuyerMarkt_TimerExist()

	local timerid = "zrush_fuelbuyermarkt_id"
	zclib.Timer.Remove(timerid)
	zclib.Timer.Create(timerid, zrush.config.FuelBuyer.RefreshRate, 0,zrush.FuelBuyer.ChangeFuelMarkt)
end

timer.Simple(1,function()
	zrush.FuelBuyer.FuelBuyerMarkt_TimerExist()
end)

util.AddNetworkString("zrush_npc_sell")
net.Receive("zrush_npc_sell", function(len, ply)
	if zclib.Player.Timeout(nil,ply) then return end
	local ent = net.ReadEntity()
	local soldFuelIndex = net.ReadInt(16)

	if (IsValid(ent) and ent:GetClass() == "zrush_npc" and zclib.util.InDistance(ent:GetPos(),ply:GetPos(),200)) then
		zrush.FuelBuyer.SellFuel(ent, ply, soldFuelIndex)
	end
end)

function zrush.FuelBuyer.SellFuel(fuelnpc, ply, id)
	local playerFuelTable = {}
	table.CopyFromTo(ply:zrush_GetFuelBarrels(), playerFuelTable)

	local sellAmount = playerFuelTable[id]
	if sellAmount == nil then return end
	if sellAmount <= 0 then return end

	ply:zrush_SoldFuelBarrel(id, sellAmount)
	ply:zrush_RemoveFuelBarrel(id, sellAmount)

	local sellProfit = fuelnpc:GetPrice_Mul() / 100
	local Earning = (zrush.FuelTypes[id].price * sellAmount) * sellProfit

	// Give the player the Cash
	zclib.Money.Give(ply, Earning)
	local str = zrush.language["YouSoldFuel"]
	str = string.Replace(str, "$Amount", tostring(math.Round(sellAmount)))
	str = string.Replace(str, "$UoM", zrush.config.UoM)
	str = string.Replace(str, "$Fuelname", zrush.FuelTypes[id].name)
	str = string.Replace(str, "$Earning", BaseWars:FormatMoney(Earning))
	zrush.Notify(ply, str, 0)
	zclib.NetEvent.Create("zrush_npc_cash", {ply})

	// Give the player the xp (BaseWars)
	local xp = math.floor(BaseWars:CalculatePlayerXP(ply, BaseWars:CalculateXPFromMultiplier(Earning) * .01))
	ply:AddXP(xp)
	// Custom Hook
	hook.Run("zrush_OnFuelSold", ply,sellAmount,id,Earning,fuelnpc)

	// Play the Sell Animation
	zclib.NetEvent.Create("zrush_npc_anim", {fuelnpc, zrush.config.FuelBuyer.anim_sell[math.random(#zrush.config.FuelBuyer.anim_sell)], zrush.config.FuelBuyer.anim_idle[math.random(#zrush.config.FuelBuyer.anim_idle)]})

	zrush.FuelBuyer.Open(fuelnpc,ply)
end

function zrush.FuelBuyer.DirectSell(fuelnpc, ply)
	local FuelInDistance = {}
	for k, v in pairs(zclib.EntityTracker.GetList()) do
		if IsValid(v) and zclib.util.InDistance(ply:GetPos(), v:GetPos(), 250) then
			if v:GetClass() == "zrush_palette" and v.BarrelCount > 0 then

				for f_id,f_amount in pairs(v.FuelList) do
					FuelInDistance[f_id] = (FuelInDistance[f_id] or 0) + f_amount
				end

				zclib.NetEvent.Create("zclib_sell", {v:GetPos()})

				SafeRemoveEntity(v)


			elseif v:GetClass() == "zrush_barrel" and v:GetFuelTypeID() > 0 and v:GetFuel() > 0 then

				FuelInDistance[v:GetFuelTypeID()] = (FuelInDistance[v:GetFuelTypeID()] or 0) + v:GetFuel()
				zclib.NetEvent.Create("zclib_sell", {v:GetPos()})
				SafeRemoveEntity(v)

			end
		end
	end

	if table.Count(FuelInDistance) <= 0 then

		zrush.Notify(ply, zrush.language["NoFuel"], 1)
		return
	end

	local sellProfit = fuelnpc:GetPrice_Mul() / 100

	for k, v in pairs(FuelInDistance) do
		if k and v then
			local fuel_id = k
			local fuelAmount = v

			if zrush.FuelTypes[fuel_id] == nil then continue end

			ply:zrush_SoldFuelBarrel(fuel_id, fuelAmount)

			local Earning = (zrush.FuelTypes[fuel_id].price * fuelAmount) * sellProfit

			// Give the player the Cash
			zclib.Money.Give(ply, Earning)
			local str = zrush.language["YouSoldFuel"]
			str = string.Replace(str, "$Amount", tostring(math.Round(fuelAmount)))
			str = string.Replace(str, "$UoM", zrush.config.UoM)
			str = string.Replace(str, "$Fuelname", zrush.FuelTypes[fuel_id].name)
			str = string.Replace(str, "$Earning", BaseWars:FormatMoney(Earning))
			zrush.Notify(ply, str, 0)

			// Custom Hook
			hook.Run("zrush_OnFuelSold", ply,fuelAmount,fuel_id,Earning,fuelnpc)
		end
	end

	zclib.NetEvent.Create("zrush_npc_cash", {ply})

	// Play the Sell Animation
	zclib.NetEvent.Create("zrush_npc_anim", {fuelnpc, zrush.config.FuelBuyer.anim_sell[math.random(#zrush.config.FuelBuyer.anim_sell)], zrush.config.FuelBuyer.anim_idle[math.random(#zrush.config.FuelBuyer.anim_idle)]})
end


// Save NPC
file.CreateDir("zrush")
zclib.STM.Setup("zrush_npc", "zrush/" .. string.lower(game.GetMap()) .. "_fuelbuyernpc" .. ".txt", function()
    local data = {}
    for u, j in pairs(ents.FindByClass("zrush_npc")) do
        table.insert(data, {
            class = j:GetClass(),
            pos = j:GetPos(),
            ang = j:GetAngles()
        })
    end
    return data
end, function(data)
    for k, v in pairs(data) do
        local ent = ents.Create(v.class)
        ent:SetPos(v.pos)
        ent:SetAngles(v.ang)
        ent:Spawn()
    end
    zrush.Print("Finished loading FuelBuyer entities.")
end, function()
    for k, v in pairs(ents.FindByClass("zrush_npc")) do
        if IsValid(v) then
            SafeRemoveEntity(v)
        end
    end
end)

concommand.Add("zrush_npc_save", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		zclib.STM.Save("zrush_npc")
		zrush.Notify(ply, "The NPC entities have been saved for the map " .. string.lower(game.GetMap()) .. "!", 0)
	end
end)

zclib.Hook.Add("PlayerSay", "zrush_save", function(ply, text)
	if string.sub(string.lower(text), 1, 10) == "!savezrush" and zclib.Player.IsAdmin(ply) then
		zclib.STM.Save("zrush_npc")
		zrush.Notify(ply, "The NPC entities have been saved for the map " .. string.lower(game.GetMap()) .. "!", 0)
	end
end)

concommand.Add("zrush_npc_remove", function(ply, cmd, args)
	if zclib.Player.IsAdmin(ply) then
		zclib.STM.Remove("zrush_npc")
		zrush.Notify(ply, "The NPC have been removed for the map " .. string.lower(game.GetMap()) .. "!", 0)
	end
end)
