ashop.currencies = ashop.currencies or {
    list = {}
}

function ashop.currencies.RegisterCurrency(name, addMoney, getMoney, format)
    assert(name, "Currency must have a name")
    ashop.currencies.list[name] = {
        addMoney = addMoney,
        getMoney = getMoney,
        format = format
    }
end