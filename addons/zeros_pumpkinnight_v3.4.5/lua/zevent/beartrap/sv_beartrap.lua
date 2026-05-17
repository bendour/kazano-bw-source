/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

zpn = zpn or {}
zpn.Beartrap = zpn.Beartrap or {}

hook.Add("CanSit", "beartrap",function(ply, tr, ent)
	if not IsValid(ent) then return end
	if not IsValid(ply) then return end
	if not IsValid(ply.zpn_beartrap_ent) then return end
	return false, zpn.language.General["dsit_info"]
end)

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

util.AddNetworkString("zpn.Beartrap.Edit")
function zpn.Beartrap.Edit(ent,ply)
	net.Start("zpn.Beartrap.Edit")
	net.WriteEntity(ent)
	net.WriteString(ent.Question)
	net.WriteString(ent.Answer)
	net.Send(ply)
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

util.AddNetworkString("zpn.Beartrap.StartGame")
function zpn.Beartrap.Attach(ent,ply)

	if IsValid(ply.zpn_beartrap_ent) then ply.zpn_beartrap_ent:Remove() end

	ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local attachid = ply:LookupAttachment("eyes")

	local attachData = ply:GetAttachment(attachid)

	local ang = attachData.Ang
	ang:RotateAroundAxis(ang:Up(),-90)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

	local pos = attachData.Pos
	pos = pos + ang:Right() * 3
	pos = pos - ang:Up() * 2.8

	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetParent(ply,attachid)

	ply.zpn_beartrap_ent = ent

	ply:ChatPrint(" ")
	ply:ChatPrint(zpn.language.General["[Beartrap] Question > "] .. ent.Question)
	ply:ChatPrint(zpn.language.General["[Beartrap] Type your answer in the chat."])
	ply:ChatPrint(string.Replace(zpn.language.General["info_seconds"],"$Seconds",zpn.config.Beartrap.Duration))
	ply:ChatPrint(" ")

	local timerid = "zpn.Beartrap_trap_" .. ply:SteamID64()
	timer.Remove(timerid)
	timer.Create(timerid,zpn.config.Beartrap.Duration,1,function()
		if IsValid(ent) and IsValid(ply) then
			zpn.Beartrap.Loose(ent,ply)
		end
	end)

	net.Start("zpn.Beartrap.StartGame")
	net.Send(ply)
end

util.AddNetworkString("zpn.Beartrap.StopGame")
function zpn.Beartrap.Detach(ent,ply)

	ent:SetParent(nil)

	local attachid = ply:LookupAttachment("eyes")
	local attachData = ply:GetAttachment(attachid)

	ent:SetPos(attachData.Pos)
	ent:SetAngles(attachData.Ang)

	ent:PhysicsInit(SOLID_VPHYSICS)
	ent:SetSolid(SOLID_VPHYSICS)
	ent:SetMoveType(MOVETYPE_VPHYSICS)
	ent:SetCollisionGroup(COLLISION_GROUP_NONE)

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(true)
	end

	net.Start("zpn.Beartrap.StopGame")
	net.Send(ply)

	ply.zpn_beartrap_ent = nil
end

util.AddNetworkString("zpn.Beartrap.SnapOpen")
function zpn.Beartrap.Solve(ent,ply)
	timer.Remove("zpn.Beartrap_trap_" .. ply:SteamID64())

	zpn.Beartrap.Reset(ent,ply)
end

util.AddNetworkString("zpn.Beartrap.ScaleHead")
function zpn.Beartrap.Loose(ent,ply)

	local ef = EffectData()
	ef:SetOrigin(ent:GetPos())
	util.Effect("BloodImpact", ef, true, true)

	ply:Kill()

	timer.Simple(0,function()
		if not IsValid(ply) then return end
		local rag = ply:GetRagdollEntity()
		if not IsValid(rag) then return end

		net.Start("zpn.Beartrap.ScaleHead")
		net.WriteEntity(rag)
		net.Broadcast()
	end)

	zpn.Beartrap.Reset(ent,ply)
end

util.AddNetworkString("zpn.Beartrap.Reset")
function zpn.Beartrap.Reset(ent,ply)

	net.Start("zpn.Beartrap.SnapOpen")
	net.WriteEntity(ent)
	net.Broadcast()

	zpn.Beartrap.Detach(ent,ply)

	ent.TrapCooldown = CurTime() + zpn.config.Beartrap.TrapCooldown

	SafeRemoveEntityDelayed(ent,5)

	timer.Simple(zpn.config.Beartrap.TrapCooldown,function()
		if not IsValid(ent) then return end
		net.Start("zpn.Beartrap.Reset")
		net.WriteEntity(ent)
		net.Broadcast()
	end)
end

net.Receive("zpn.Beartrap.Edit", function(len,ply)

	local ent = net.ReadEntity()
	if not IsValid(ent) then return end

	if ply ~= ent.TrapOwner then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8

	local question = net.ReadString()
	local answer = net.ReadString()

	ent.Question = question
	ent.Answer = answer

	ent.TrapActivated = true

	net.Start("zpn.Beartrap.Reset")
	net.WriteEntity(ent)
	net.Broadcast()
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8


hook.Add("PlayerSay","ZerosModernBeartrap",function(ply,text)
	if not IsValid(ply) then return end
	if not IsValid(ply.zpn_beartrap_ent) then return end

	local answer = string.Replace(string.lower(ply.zpn_beartrap_ent.Answer)," ","")
	local guess = string.Replace(string.lower(text)," ","")

	if answer == guess then
		ply:ChatPrint(zpn.language.General["[Beartrap] Your answer was correct!"])

		zpn.Beartrap.Solve(ply.zpn_beartrap_ent,ply)
		return
	else
		ply:ChatPrint(zpn.language.General["[Beartrap] Wrong answer!"])
	end
end)
