local PLAYER = FindMetaTable("Player")

/*function PLAYER:ashopMoneyGet(premium)
    assert(self.ashop_data, "Can't get player money, there is no data")
    return self.ashop_data[premium and "money_premium" or "money_normal"]
end

function PLAYER:ashopMoneyAfford(price, premium)
    return self:ashopMoneyGet(premium) >= price
end*/

function PLAYER:ashopMoneyGet(premium)
    assert(self.ashop_data, "Can't get player money, there is no data")
    return premium && self:GetCredit() or self:GetPointshop()
end

function PLAYER:ashopMoneyAfford(price, premium)
    return self:ashopMoneyGet(premium) >= price
end