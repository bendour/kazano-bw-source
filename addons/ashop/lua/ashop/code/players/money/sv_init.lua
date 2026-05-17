/*
local PLAYER = FindMetaTable("Player")

util.AddNetworkString('ashop_PlayerSyncMoney')

function PLAYER:ashopMoneyChange(amt, is_premium)
    assert(self.ashop_data, "Can't get player money, there is no data")
    is_premium = (is_premium or is_premium == 1) and true or false

    local m = self:ashopMoneyGet(is_premium) + amt
    assert(m >= 0, "Invalid operation, player would be in negative")

    self:ashopMoneySet(m, is_premium)
    ashop.Logs.PushLog(ashop.Logs.IDs.ChangeMoney, self, amt)
end

function PLAYER:ashopMoneySet(amt, is_premium)
    assert(self.ashop_data, "Can't get player money, there is no data")
    assert(amt >= 0, "Money would be negative")
    is_premium = (is_premium == true)
    local attr = (is_premium and "money_premium" or "money_normal")
    self.ashop_data[attr] = amt

    net.Start('ashop_PlayerSyncMoney')
        net.WriteBool(is_premium)
        net.WriteUInt(amt, 32)
    net.Send(self)

    self.PS2_Wallet = self.PS2_Wallet or {}

    if is_premium then
        self.PS2_Wallet.premiumPoints = amt
    else
        self.PS2_Wallet.points = amt
    end

    ashop.SQL.query('UPDATE ashop_players SET ' .. attr .. " = " .. amt .. " WHERE id = " .. self.ashop_data.id)
end

if ashop.Config.PS2Compatibility then
    function PLAYER:PS2_AddPremiumPoints(amt)
        self:ashopMoneyChange(amt, true)
    end

    function PLAYER:PS2_AddStandardPoints(amt)
        self:ashopMoneyChange(amt, false)
    end

    function PLAYER:SH_AddPremiumPoints(amt)
        self:ashopMoneyChange(amt, true)
    end

    function PLAYER:SH_AddStandardPoints(amt)
        self:ashopMoneyChange(amt, false)
    end
end*/

local PLAYER = FindMetaTable("Player")

util.AddNetworkString('ashop_PlayerSyncMoney')

function PLAYER:ashopMoneyChange(amt, is_premium)
    //assert(self.ashop_data, "Can't get player money, there is no data")
    is_premium = (is_premium or is_premium == 1) and true or false

    local m = self:ashopMoneyGet(is_premium) + amt
    assert(m >= 0, "Invalid operation, player would be in negative")

    self:ashopMoneySet(m, is_premium)
    ashop.Logs.PushLog(ashop.Logs.IDs.ChangeMoney, self, amt)
end

function PLAYER:ashopMoneySet(amt, is_premium)
    //assert(self.ashop_data, "Can't get player money, there is no data")
    assert(amt >= 0, "Money would be negative")
    is_premium = (is_premium == true)
    local attr = (is_premium and "money_premium" or "money_normal")
    
    self.ashop_data[attr] = amt // Au cas où
    if is_premium then
        self:SetCredit(amt, true)
    else
        self:SetPointshop(amt, saveToSQL)
    end

    net.Start('ashop_PlayerSyncMoney')
        net.WriteBool(is_premium)
        net.WriteUInt(amt, 32)
    net.Send(self)

    self.PS2_Wallet = self.PS2_Wallet or {}

    if is_premium then
        self.PS2_Wallet.premiumPoints = amt
    else
        self.PS2_Wallet.points = amt
    end

    ashop.SQL.query('UPDATE ashop_players SET ' .. attr .. " = " .. amt .. " WHERE id = " .. self.ashop_data.id)
end

if ashop.Config.PS2Compatibility then
    function PLAYER:PS2_AddPremiumPoints(amt)
        self:ashopMoneyChange(amt, true)
    end

    function PLAYER:PS2_AddStandardPoints(amt)
        self:ashopMoneyChange(amt, false)
    end

    function PLAYER:SH_AddPremiumPoints(amt)
        self:ashopMoneyChange(amt, true)
    end

    function PLAYER:SH_AddStandardPoints(amt)
        self:ashopMoneyChange(amt, false)
    end
end