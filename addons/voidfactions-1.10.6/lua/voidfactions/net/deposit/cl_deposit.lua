
function VoidFactions.Deposit:DepositItem(itemClass, printName)
    net.Start("VoidFactions.Deposit.DepositItem")
        net.WriteString(itemClass)
        net.WriteString(printName) -- We have to send the printName because the SERVER does not know the printname
    net.SendToServer()
end

function VoidFactions.Deposit:WithdrawItem(id, name)
    net.Start("VoidFactions.Deposit.WithdrawItem")
        net.WriteUInt(id, 20)
        net.WriteString(name)
    net.SendToServer()
end

function VoidFactions.Deposit:DepositMoney(money)
    net.Start("VoidFactions.Deposit.DepositMoney")
        net.WriteUInt(money, 32)
    net.SendToServer()
end

function VoidFactions.Deposit:WithdrawMoney(money)
    net.Start("VoidFactions.Deposit.WithdrawMoney")
        net.WriteUInt(money, 32)
    net.SendToServer()
end