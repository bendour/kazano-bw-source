-- Helper functions

VoidFactions.Currencies = VoidFactions.Currencies or {}
VoidFactions.Currencies.List = {}

-- Class for creating new currencies

local CURRENCY_CLASS = {}
CURRENCY_CLASS.__index = CURRENCY_CLASS

function CURRENCY_CLASS:New()
	local object = setmetatable({}, CURRENCY_CLASS)
		object.name = nil

        object.getMoneyFunc = nil
        object.giveMoneyFunc = nil
        object.takeMoneyFunc = nil
        object.formatMoneyFunc = nil
        object.isInstalledFunc = nil

        object.isInternal = false
	return object
end

function CURRENCY_CLASS:Name(name)
    self.name = name
end

function CURRENCY_CLASS:SetInternal(isInternal)
    self.isInternal = isInternal
end

-- Function setters

function CURRENCY_CLASS:IsInstalledFunc(func)
    self.isInstalledFunc = func
end

function CURRENCY_CLASS:GetMoneyFunc(func)
	self.getMoneyFunc = func
end

function CURRENCY_CLASS:GiveMoneyFunc(func)
    self.giveMoneyFunc = func
end

function CURRENCY_CLASS:TakeMoneyFunc(func)
    self.takeMoneyFunc = func
end

function CURRENCY_CLASS:FormatMoneyFunc(func)
    self.formatMoneyFunc = func
end

-- Functions

function CURRENCY_CLASS:GetMoney(ply)
    return self.getMoneyFunc(ply) or 0
end

function CURRENCY_CLASS:GiveMoney(ply, money)
    if (!SERVER) then return end
    self.giveMoneyFunc(ply, money)
end

function CURRENCY_CLASS:TakeMoney(ply, money)
    if (!SERVER) then return end
    self.takeMoneyFunc(ply, money)
end

function CURRENCY_CLASS:FormatMoney(money)
    return self.formatMoneyFunc(money)
end

function CURRENCY_CLASS:IsInstalled()
    local isInstalled = self.isInstalledFunc and self.isInstalledFunc()
    if (!self.isInstalledFunc) then
        isInstalled = true
    end
    return isInstalled
end

-- Utility functions

function CURRENCY_CLASS:CanAfford(ply, money)
    return self:GetMoney(ply) >= money
end

-- Public functions

function VoidFactions.Currencies:NewCurrency()
	return CURRENCY_CLASS:New()
end

function VoidFactions.Currencies:AddCurrency(currency)
    if (!istable(currency)) then return end

    if (!currency.name) then
        VoidFactions.PrintError("A currency does not have a name! Stack trace:")
        print(debug.traceback())
        return
    end

    if (VoidFactions.Currencies.List[currency.name]) then
        VoidFactions.PrintError("A currency with the name " .. currency.name .. " was already registered!")
        return
    end

	if (!currency.getMoneyFunc) then
        VoidFactions.PrintError("Currency " .. currency.name .. " doesn't have a get money function!")
        return
    end
    if (!currency.giveMoneyFunc) then
        VoidFactions.PrintError("Currency " .. currency.name .. " doesn't have a give money function!")
        return
    end

    if (!currency.takeMoneyFunc) then
        currency.takeMoneyFunc = function (ply, money)
            currency.giveMoneyFunc(ply, -money)
        end
    end

    if (!currency.formatMoneyFunc) then
        currency.formatMoneyFunc = function (money)
            return "$" .. money
        end
    end

    VoidFactions.Currencies.List[currency.name] = currency
    VoidFactions.PrintDebug("Registered currency " .. currency.name .. "!")
end