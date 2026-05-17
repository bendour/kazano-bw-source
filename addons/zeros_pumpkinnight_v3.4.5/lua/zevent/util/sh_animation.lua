/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

zpn = zpn or {}
zpn.Animation = zpn.Animation or {}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

if SERVER then
    util.AddNetworkString("zpn_anim_net")
    function zpn.Animation.Play(ent, anim, speed,force)

        zclib.Animation.Play(ent,anim, speed)

        net.Start("zpn_anim_net")
        net.WriteUInt(ent:LookupSequence(anim),16)
        net.WriteUInt(speed,6)
        net.WriteEntity(ent)
		net.WriteBool(force == true)
        net.Broadcast()
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

if CLIENT then
    net.Receive("zpn_anim_net", function(len, ply)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

        local anim = net.ReadUInt(16)
        local speed = net.ReadUInt(6)
        local ent = net.ReadEntity()
		local force = net.ReadBool()

        if not IsValid(ent) then return end
        if anim == nil then return end
        if speed == nil then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

        // If this animation is currently playing then stop
        local index = ent:GetSequence()
        if not force and index == anim then
            return
        end

        zclib.Animation.Play(ent,ent:GetSequenceName(anim), speed)
    end)
end
