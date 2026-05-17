if not SERVER then return end
zrush = zrush or {}
zrush.Modules = zrush.Modules or {}

// A function for created module sockets
function zrush.Modules.Setup(ent)
    local count = table.Count(zrush.ModuleSockets[ent.MachineID])
    ent.ModuleSocket = ent.ModuleSocket or {}

    for i = 1, count do
        local aPoint = zrush.ModuleSockets[ent.MachineID][i]
        local attach = ent:GetAttachment(aPoint)
        local ang = attach.Ang
        ang:RotateAroundAxis(attach.Ang:Right(), -90)
        ang:RotateAroundAxis(attach.Ang:Up(), -180)

        local socket = ents.Create("prop_dynamic")
        socket:SetModel("models/zerochain/props_oilrush/zor_module_socket.mdl")
        socket:SetPos(attach.Pos)
        socket:SetAngles(ang)
        socket:Spawn()
        socket:Activate()
        socket:SetParent(ent, aPoint)

        table.insert(ent.ModuleSocket, {ModuleID = -1,AttachID = aPoint})
    end
end

// Generates a list with
function zrush.Modules.Get(ent)
    local modules = {}

    for k, v in pairs(ent.ModuleSocket) do
        if v and IsValid(v.Module) then
            modules[k] = v.ModuleID
        else
            modules[k] = -1
        end
    end

    return modules
end

function zrush.Modules.GetSocket(ent,pos)
    return ent.ModuleSocket[pos]
end

// This returns the first index of a valid module that matches the provided ID
function zrush.Modules.FindByID(ent, id)
    local tModule

    for k, v in pairs(ent.ModuleSocket) do
        if (IsValid(v.Module) and v.ModuleID == id) then
            zclib.Debug("Entity has module with ID: " .. id)
            tModule = k
            break
        end
    end

    return tModule
end

// This searches for a free module spot on out entity
function zrush.Modules.FindFreeSocket(ent)
    local freeSocket

    for k, v in pairs(ent.ModuleSocket) do
        if (not IsValid(v.Module)) then
            zclib.Debug("Found Empty Socket on position " .. k .. " with attachmentPoint " .. tostring(v.AttachID))
            freeSocket = k
            break
        end
    end

    return freeSocket
end

// This checks if we allready have a module of that type installed
function zrush.Modules.HasTypeInstalled(ent, mtype)
    local IsInstalled = false

    for k, v in pairs(ent.ModuleSocket) do
        if IsValid(v.Module) then
            local moduleType = zrush.AbilityModules[v.ModuleID].type

            if (moduleType == mtype) then
                IsInstalled = true
                break
            end
        end
    end

    return IsInstalled
end

local EntityActionClasses = {
    ["zrush_drilltower"] = true,
    ["zrush_burner"] = true,
    ["zrush_pump"] = true,
    ["zrush_refinery"] = true
}

// This creates a Module on a machine
util.AddNetworkString("zrush_machine_PurchaseModule")
net.Receive("zrush_machine_PurchaseModule", function(len, ply)
    if zclib.Player.Timeout(nil, ply) then return end
    local ent = net.ReadEntity()
    local moduleID = net.ReadInt(16)
    if moduleID == nil then return end
    local mData = zrush.Modules.GetData(moduleID)
    if mData == nil then return end
    if not IsValid(ent) then return end
    if zclib.Player.IsOwner(ply, ent) == false and rush.config.EquipmentSharing == false then return end
    if EntityActionClasses[ent:GetClass()] == nil then return end

    // Add checks for disdtance
    if zclib.util.InDistance(ent:GetPos(), ply:GetPos(), 300) == false then
        zrush.Notify(ply, zrush.language["TooFarAway"], 1)

        return
    end

    // Does the player have the correct Rank do buy this module?
    if zclib.Player.RankCheck(ply, mData.ranks) == false then
        zrush.Notify(ply, zrush.language["WrongUserGroup"], 1)

        return
    end

    // Does the player have the correct Job do buy this module?
    if zclib.Player.JobCheck(ply, mData.jobs) == false then
        zrush.Notify(ply, zrush.language["WrongJob"], 1)

        return
    end

    // Check if the player has enough money
    local moduleCost = mData.price

    if (not zclib.Money.Has(ply, moduleCost)) then
        zrush.Notify(ply, zrush.language["Youcannotafford"], 1)

        return
    end

    // Check if module of same type is allready installed
    local mType = mData.type

    if (zrush.Modules.HasTypeInstalled(ent, mType)) then
        zrush.Notify(ply, zrush.language[mType] .. zrush.language["allreadyinstalled"], 1)

        return
    end

    // This checks if there is a freeSocket for the module
    local freeSocket = zrush.Modules.FindFreeSocket(ent)

    if (freeSocket) then
        // Takes some money from the player
        ply:TakeMoney(moduleCost)
        zrush.Modules.Add(moduleID, ent, freeSocket)
        local str = zrush.language["Youbougt"]
        str = string.Replace(str, "$Name", mData.name)
        str = string.Replace(str, "$Price", BaseWars:FormatMoney(mData.price))
        zrush.Notify(ply, str, 0)
        zclib.NetEvent.Create("zrush_npc_cash", {ent})
        zrush.Machine.UpdateUI(ent, true)
    else
        zrush.Notify(ply, zrush.language["NoFreeSocketAvailable"], 1)
    end
end)

function zrush.Modules.Add(moduleID, ent, freeSocketPos)
    local socket = zrush.Modules.GetSocket(ent, freeSocketPos)

    local mData = zrush.Modules.GetData(moduleID)

    local attach = ent:GetAttachment(socket.AttachID)

    local aModule = ents.Create("zrush_module")
    aModule:SetPos(attach.Pos + attach.Ang:Up() * 3)

    local ang = attach.Ang
    ang:RotateAroundAxis(attach.Ang:Right(), 180)
    ang:RotateAroundAxis(attach.Ang:Up(), -180)
    aModule:SetAngles(ang)

    aModule:Spawn()
    aModule:Activate()
    aModule:SetNoDraw(true)
    aModule:SetParent(ent, socket.AttachID)
    aModule:SetAbilityID(moduleID)

    socket.ModuleID = moduleID
    socket.Module = aModule

    zrush.ModuleDefinitions[mData.type].setvalue(ent, mData.amount)

    timer.Simple(0.1, function()
        if IsValid(aModule) then
            aModule:SetNoDraw(false)
            zclib.NetEvent.Create("zrush_module_attached", {aModule})
        end
    end)

    ent:ModulesChanged()
end

// This removes a Module from a machine
util.AddNetworkString("zrush_machine_SellModule")
net.Receive("zrush_machine_SellModule", function(len, ply)
    if zclib.Player.Timeout(nil, ply) then return end
    local ent = net.ReadEntity()
    local modulePos = net.ReadInt(16)

    if not IsValid(ent) then return end
    if modulePos == nil then return end
    if zclib.Player.IsOwner(ply, ent) == false and rush.config.EquipmentSharing == false then return end
    if EntityActionClasses[ent:GetClass()] == nil then return end

    // Add checks for disdtance
    if zclib.util.InDistance(ent:GetPos(), ply:GetPos(), 300) == false then
        zrush.Notify(ply, zrush.language["TooFarAway"], 1)

        return
    end

    local socket = zrush.Modules.GetSocket(ent,modulePos)
    if socket == nil then return end
    if socket.ModuleID == nil then return end

    local mData = zrush.Modules.GetData(socket.ModuleID)
    local earning = mData.price * zrush.config.MachineBuilder.SellValue

    // Give the player the Cash
    zclib.Money.Give(ply, earning)

    local str = zrush.language["YouSold"]
    str = string.Replace(str, "$Name", mData.name)
    str = string.Replace(str, "$Price", BaseWars:FormatMoney(earning))
    zrush.Notify(ply, str, 0)

    zrush.Modules.Remove(ent, modulePos)

    zclib.NetEvent.Create("zrush_npc_cash", {ply})
    zrush.Machine.UpdateUI(ent, true)
end)
function zrush.Modules.Remove(ent, modulePos)

    local socket = zrush.Modules.GetSocket(ent,modulePos)

    local mData = zrush.Modules.GetData(socket.ModuleID)

    zrush.ModuleDefinitions[mData.type].setvalue(ent, 0)

    socket.ModuleID = -1

    SafeRemoveEntity(socket.Module)

    socket.Module = nil

    zclib.NetEvent.Create("zrush_module_detached", {ent})

    ent:ModulesChanged()
end
