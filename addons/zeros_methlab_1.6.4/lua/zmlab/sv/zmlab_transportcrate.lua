if (not SERVER) then return end
zmlab = zmlab or {}
zmlab.f = zmlab.f or {}

function zmlab.f.TransportCrate_Initialize(TransportCrate)
    zmlab.f.Debug("zmlab.f.TransportCrate_Initialize")
    zmlab.f.EntList_Add(TransportCrate)

    if zmlab.config.TransportCrate.FullCollide then
        TransportCrate:SetCollisionGroup(COLLISION_GROUP_NONE)
    else
        TransportCrate:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    end

    TransportCrate.IsClosed = false
    TransportCrate.PhysgunDisable = true
end

function zmlab.f.TransportCrate_USE(TransportCrate, ply)
    if ply != TransportCrate:CPPIGetOwner() then
		BaseWars:Notify(ply, "#notYours", NOTIFICATION_ERROR, 5)
		return
	end

    zmlab.f.Debug("zmlab.f.TransportCrate_Initialize")

    if zmlab.config.TransportCrate.NoWait then
        if TransportCrate:GetMethAmount() <= 0 then return end
    else
        if TransportCrate:GetMethAmount() < zmlab.config.TransportCrate.Capacity then return end
    end

    local sellmode = zmlab.f.GetSellMode(ply)

    if sellmode == 1 or sellmode == 3 then

        zmlab.f.CreateNetEffect("zmlab_crate_collect",TransportCrate)

        ply.zmlab_meth = ply.zmlab_meth or 0
        ply.zmlab_meth = ply.zmlab_meth + TransportCrate:GetMethAmount()

        local str = string.Replace(zmlab.language.transportcrate_collect, "$methAmount", BaseWars:FormatNumber(TransportCrate:GetMethAmount()))
        zmlab.f.Notify(ply, str, 0)

        TransportCrate:Remove()
    else
        if TransportCrate:GetMethAmount() >= zmlab.config.TransportCrate.Capacity and TransportCrate.IsClosed == false then
            TransportCrate.IsClosed = true
            zmlab.f.CreateNetEffect("zmlab_crate_close",TransportCrate)
        end
    end
end


function zmlab.f.TransportCrate_StartTouch(TransportCrate, other)
    if not IsValid(TransportCrate) then return end
    if not IsValid(other) then return end
    if other:GetClass() != "zmlab_meth" and other:GetClass() != "zmlab_meth_baggy" then return end
    if other:GetClass() == "zmlab_meth_baggy" and other.Enabled == false then return end
    if zmlab.f.CollisionCooldown(other) then return end
    if  TransportCrate:GetMethAmount() >= zmlab.config.TransportCrate.Capacity then return end

    local crateOwner = other:CPPIGetOwner()
    if TransportCrate:CPPIGetOwner() != crateOwner then
        if IsValid(crateOwner) then
            BaseWars:Notify(crateOwner, "#notYours", NOTIFICATION_ERROR, 8)
        end

        return
    end

    zmlab.f.TransportCrate_AddMeth(TransportCrate,other)
end

function zmlab.f.TransportCrate_AddMeth(TransportCrate, meth)
    TransportCrate:SetMethAmount(TransportCrate:GetMethAmount() + meth:GetMethAmount())

    zmlab.f.CreateNetEffect("zmlab_crate_fill",TransportCrate)

    SafeRemoveEntity(meth)
    zmlab.f.TransportCrate_UpdateVisuals(TransportCrate)
end


function zmlab.f.TransportCrate_UpdateVisuals(TransportCrate)
    local methAmount = TransportCrate:GetMethAmount()

    if methAmount >= zmlab.config.TransportCrate.Capacity then
        TransportCrate.IsClosed = true
        zmlab.f.CreateNetEffect("zmlab_crate_close",TransportCrate)
        TransportCrate:SetBodygroup(0, 3)
    elseif methAmount > zmlab.config.TransportCrate.Capacity * 0.7 then
        TransportCrate:SetBodygroup(0, 3)
    elseif methAmount > zmlab.config.TransportCrate.Capacity * 0.5 then
        TransportCrate:SetBodygroup(0, 2)
    elseif methAmount <= 0 then
        TransportCrate:SetBodygroup(0, 0)
    else
        TransportCrate:SetBodygroup(0, 1)
    end
end

function zmlab.f.TransportCrate_Delayed_UpdateVisuals(TransportCrate)
    timer.Simple(0.1, function()
        if IsValid(TransportCrate) then
            TransportCrate.IsClosed = true
            zmlab.f.CreateNetEffect("zmlab_crate_close",TransportCrate)
            TransportCrate:SetBodygroup(0, 3)
        end
    end)
end

function zmlab.f.TransportCrate_XeninDrop(TransportCrate)
    timer.Simple(0.1, function()
        if IsValid(TransportCrate) then
            zmlab.f.TransportCrate_UpdateVisuals(TransportCrate)
        end
    end)
end
