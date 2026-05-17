/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

if CLIENT then return end
zpn = zpn or {}
zpn.Shop = zpn.Shop or {}

/*
	Allows the player to open the shop interface with a chat command
*/
if zpn.config.ShopCommand then
	zclib.Hook.Add("PlayerSay", "zpn_ShopCommand", function(ply, text)
	    if string.sub(string.lower(text), 1, string.len(zpn.config.ShopCommand)) == string.lower(zpn.config.ShopCommand) then
			zpn.Shop.Open(ply, ply)
	    end
	end)
end

/*
	Closes the players shop interface
*/
util.AddNetworkString("zpn_Shop_ForceClose_net")
function zpn.Shop.ForceClose(ply)

    if ply.zpn_InShop == false then return end
    net.Start("zpn_Shop_ForceClose_net")
    net.Send(ply)

    ply.zpn_InShop = false
end

/*
	Opens the shop interface
*/
util.AddNetworkString("zpn_Shop_Open_net")
function zpn.Shop.Open(ply, npc)
    // Tells the server player is using the shop now
    ply.zpn_InShop = true

    // Open Shop interface
    net.Start("zpn_Shop_Open_net")
    net.WriteEntity(npc)
    net.WriteInt(zpn.CandyPoints[zclib.Player.GetID(ply)] or 0,16)
    net.WriteTable(ply.zpn_OwnedItems or {})
    net.Send(ply)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

/*
	Gets called when the player closes the shop interface
*/
util.AddNetworkString("zpn_Shop_ClosedShop_net")
net.Receive("zpn_Shop_ClosedShop_net", function(len, ply)
    if zclib.Player.Timeout(nil,ply) then return end
    zclib.Debug("zpn_Shop_ClosedShop_net Len: " .. len)

	if not IsValid(ply) then return end

    ply.zpn_InShop = false
end)

/*
	Called from CLIENT to purchase a item
*/
util.AddNetworkString("zpn_Shop_BuyItem_net")
net.Receive("zpn_Shop_BuyItem_net", function(len, ply)
    if zclib.Player.Timeout(nil,ply) then return end
    zclib.Debug("zpn_Shop_BuyItem_net Len: " .. len)
    local npc = net.ReadEntity()
    local itemid = net.ReadInt(16)
	if not itemid then return end

	if not IsValid(npc) then return end
	if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
	if not zclib.util.InDistance(npc:GetPos(), ply:GetPos(), 300) then return end

    // Tells the server that the player is not using the shop anymore
    ply.zpn_InShop = false
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

    zpn.Shop.BuyItem(ply, npc, itemid)
end)

local function PerformPurchase(ply,itemData,itemid,npc,OnSuccess)

	// Does he have enough money
	if not zpn.Candy.HasPoints(ply,itemData.price) then
		zclib.Notify(ply, zpn.language.General["NotEnoughCandy"], 1)
		return
	end

	// Give the Player the item he purchased
	if zpn.PurchaseType[itemData.type](ply, itemData) then

		// Take money
		zpn.Candy.TakePoints(ply,itemData.price)

		zclib.Notify(ply, zpn.Shop.NotifyReplace(zpn.language.General["PurchaseSucess"],itemid), 0)

		if OnSuccess then pcall(OnSuccess) end

		hook.Run("zpn_OnShopItemBought", ply, npc, itemid,itemData)

		zpn.Shop.Open(ply, npc)
	else
		zclib.Notify(ply, zpn.Shop.NotifyReplace(zpn.language.General["PurchaseFail01"],itemid), 1)
	end
end

function zpn.Shop.NotifyReplace(text,itemid)
	local itemData = zpn.config.Shop[itemid]

    local str = text
    str = string.Replace(str,"$itemname",zpn.Shop.GetItemName(itemid))
    str = string.Replace(str,"$itemamount",itemData.amount)

    return str
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

function zpn.Shop.BuyItem(ply, npc, itemid)
    zclib.Debug("zpn.Shop.BuyItem")
    local itemData = zpn.config.Shop[itemid]

	// CustomCheck
	if itemData.check and not itemData.check(ply) then
		return
	end

    // Rank Check
    if itemData.ranks and not zclib.Player.RankCheck(ply, itemData.ranks) then
        return
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

	// If the Owned Items table doesent exist for some reason then lets create it
	if ply.zpn_OwnedItems == nil then ply.zpn_OwnedItems = {} end

	// Is the item permanent?
	if itemData.permanent then

		if ply.zpn_OwnedItems[itemid] then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

			// Give the Player the item he purchased previously
			if not zpn.PurchaseType[itemData.type](ply, itemData) then
				zclib.Notify(ply, zpn.Shop.NotifyReplace(zpn.language.General["PurchaseFail01"],itemid), 1)
			end
		else

			PerformPurchase(ply,itemData,itemid,npc,function()
				ply.zpn_OwnedItems[itemid] = true
				zpn.data.Save(ply)
			end)
		end

		return
	end

	// Is this a one time purchase only item?
	if itemData.ontime then

		// If he already owns it then stop
		if ply.zpn_OwnedItems[itemid] then return end

		PerformPurchase(ply,itemData,itemid,npc,function()
			ply.zpn_OwnedItems[itemid] = true
			zpn.data.Save(ply)
		end)

		return
	end

	// Perform a normal purchase
	PerformPurchase(ply,itemData,itemid,npc)
end
