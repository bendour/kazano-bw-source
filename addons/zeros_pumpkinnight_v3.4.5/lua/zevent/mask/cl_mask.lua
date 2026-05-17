/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

if SERVER then return end
zpn = zpn or {}
zpn.Mask = zpn.Mask or {}

local LPly = LocalPlayer()

net.Receive("zpn_Mask_Equipt", function()
    local ply = net.ReadEntity()
    local show = net.ReadBool()
    local MaskID = net.ReadInt(6)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    zclib.Debug("zpn_Mask_Equipt: " .. tostring(ply) .. " " .. tostring(show))

    zpn.Mask.Equipt(ply, show,MaskID)
end)

/*
	This function can either be called via net message or via net var
*/
function zpn.Mask.Equipt(ply, show,MaskID)

	ply:EmitSound(show and "zpn_mask_on" or "zpn_mask_off")

	if IsValid(ply.zpn_Mask_model) and ply.zpn_MaskID then

		// Spawn Client Mask model falling of player
		if not zpn.config.Mask.NoDraw then zpn.Mask.PhysicsHandler_Create(ply:GetPos() + Vector(0,0,60),ply.zpn_MaskID) end

		SafeRemoveEntity(ply.zpn_Mask_model)
		zclib.Debug("ClientModel removed")
	end

	ply.zpn_MaskID = MaskID
	ply.zpn_MaskEquipt = show

	if zpn.config.Mask.NoDraw then return end

    if not show then return end
    local cs = ents.CreateClientProp()
    if not IsValid(cs) then return end
	if not cs.SetModel then return end

    local MaskData = zpn.config.Masks[MaskID]

    cs.zpn_OwnerID = zclib.Player.GetOwnerID(ply)
    cs.zpn_Owner = ply
    cs:SetModel(MaskData.mdl)
    cs:SetNoDraw(true)
    cs:SetPredictable(false)
    cs:DrawShadow(false)
    cs:DestroyShadow()
    cs:SetMoveType(MOVETYPE_NONE)
    cs:Spawn()
    ply.zpn_Mask_model = cs
    zclib.Debug("ClientModel created")
end

local MaskColor = Color(0, 0, 0, 230)
zclib.Hook.Add("HUDPaint", "zpn_Mask_HUDPaint", function()
	if not IsValid(LPly) then
		LPly = LocalPlayer()
	else
		if GetViewEntity() == LPly and LPly.zpn_MaskEquipt and zclib.Convar.Get("zpn_cl_mask_enabled") == 1 then
			surface.SetDrawColor(MaskColor)
			surface.SetMaterial(zpn.default_materials[ "zpn_mask" ])
			surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() / 2, 1920 * zclib.wM, 1080 * zclib.hM, 0)
		end
	end
end)


// If we dont draw the models then anything below becomes irelevant
if zpn.config.Mask.NoDraw then return end

function zpn.Mask.Draw(ply)

	local MaskID = ply:GetNWInt("zpn_MaskID",0)
	if not MaskID or MaskID <= 0 then return end

    if not IsValid(ply.zpn_Mask_model) then
		zpn.Mask.Equipt(ply, true,MaskID)
		return
	end

    local pos, ang , scale

    local boneid = ply:LookupBone("ValveBiped.Bip01_Head1")
    local offset = zpn.Mask.ModelOffsets[ply:GetModel()]
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

    if boneid then
        local mat = ply:GetBoneMatrix(boneid)
        if not mat then return end
        pos, ang = mat:GetTranslation(), mat:GetAngles()
        local start_ang = ang
        ang:RotateAroundAxis(start_ang:Forward(), -90)
        ang:RotateAroundAxis(start_ang:Right(), -90)

        if offset == nil then
            offset = zpn.Mask.ModelOffsets["Default"]
        end

        ang:RotateAroundAxis(start_ang:Up(), offset.ang.y)
        ang:RotateAroundAxis(start_ang:Right(), offset.ang.p)
        ang:RotateAroundAxis(start_ang:Forward(), offset.ang.r)
        pos:Set(pos + ang:Forward() * offset.pos.x + ang:Right() * offset.pos.y + ang:Up() * offset.pos.z + ang:Up() * 1.5 + ang:Forward() * 0.19)

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

        if offset.scale then
            scale = offset.scale
        else
            scale = 1
        end
    else
        pos = ply:GetPos()
        ang = Angle(0, 0, 0)
        scale = 1
    end

    ply.zpn_Mask_model:SetPos(pos)
    ply.zpn_Mask_model:SetAngles(ang)
    ply.zpn_Mask_model:SetModelScale(scale)
    ply.zpn_Mask_model:SetRenderOrigin(pos)
    ply.zpn_Mask_model:SetRenderAngles(ang)
    ply.zpn_Mask_model:SetupBones()
    ply.zpn_Mask_model:DrawModel()
end

zclib.Hook.Add("PostPlayerDraw", "zpn_Mask_PostPlayerDraw", function(ply)

	if not IsValid(LPly) then LPly = LocalPlayer() end

	if IsValid(LPly) and IsValid(ply) and ply:Alive() and zclib.util.InDistance(LPly:GetPos(), ply:GetPos(), 1000) then
		zpn.Mask.Draw(ply)
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

gameevent.Listen("player_disconnect")
zclib.Hook.Add("player_disconnect", "zpn_Mask_player_disconnect", function(data)
    for k, v in pairs(ents.GetAll()) do
        if IsValid(v) and v.zpn_OwnerID and v.zpn_OwnerID == data.networkid then
            SafeRemoveEntity(v)
        end
    end
end)

local zpn_MaskObjects = {}
function zpn.Mask.PhysicsHandler_Create(pos,MaskID)
    zclib.Debug("zpn.Mask.PhysicsHandler_Create " .. tostring(pos))

	local MaskData = zpn.config.Masks[MaskID]
	if not MaskData then return end

    local ent = ents.CreateClientProp()
	if not IsValid(ent) then return end
	if not ent.SetModel then return end

    ent:SetModel(MaskData.mdl)
    ent:SetPos(pos)
    ent:SetAngles(Angle(0, 0, 0))
    ent:Spawn()
    ent:PhysicsInit(SOLID_VPHYSICS)
    ent:SetSolid(SOLID_NONE)
    ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    ent:SetMoveType(MOVETYPE_VPHYSICS)
    ent:SetRenderMode(RENDERMODE_NORMAL)

    local phys = ent:GetPhysicsObject()

    if IsValid(phys) then
        phys:SetMass(25)
        phys:Wake()
        phys:EnableMotion(true)
        phys:SetDragCoefficient(100)

        local tickrate = 66.6 * engine.TickInterval()
        tickrate = tickrate * 64
        tickrate = math.Clamp(tickrate, 15, 64)


        local f_force = tickrate * 2
        local f_dir = Vector(math.Rand(-1,1), math.Rand(-1,1), 1) * f_force
        phys:ApplyForceCenter(phys:GetMass() * f_dir)

        local val = 0.9
        local angVel = (Vector(0, 0, 1) * math.Rand(-val, val)) * phys:GetMass() * tickrate
        phys:AddAngleVelocity(angVel)
    else
        SafeRemoveEntity(ent)
    end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    table.insert(zpn_MaskObjects, {
        ent = ent,
        remove_time = CurTime() + 5,
    })
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

	if zclib.Hook.Exist("Think", "zpn_mask") then return end

	zclib.Hook.Add("Think", "zpn_mask", zpn.Mask.PhysicsHandler)
end

function zpn.Mask.PhysicsHandler()
    if IsValid(LPly) and #zpn_MaskObjects > 0 then

        local ply = LPly
        local distance = 1000

        for k, v in pairs(zpn_MaskObjects) do
            if IsValid(v.ent) and not zclib.util.InDistance(ply:GetPos(), v.ent:GetPos(), distance) or CurTime() >= v.remove_time then
                SafeRemoveEntity(v.ent)
                table.remove(zpn_MaskObjects, k)
            end
        end

		if not zpn_MaskObjects or table.Count(zpn_MaskObjects) <= 0 then
			zclib.Hook.Remove("Think", "zpn_mask")
		end
    end
end
