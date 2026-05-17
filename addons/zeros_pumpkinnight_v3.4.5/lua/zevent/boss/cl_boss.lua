/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

if SERVER then return end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8

// Called when the PumpkinBoss smashes on the ground
net.Receive("zpn_Boss_SmashImpact_net", function(len, ply)
	zclib.Debug("zpn_Boss_SmashImpact_net Len: " .. len)

	local PumpkinBoss = net.ReadEntity()
	local pos = net.ReadVector()
	local scale = net.ReadFloat()

	if IsValid(PumpkinBoss) and pos and scale then
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

		// Effect
		local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetScale(500 * scale)
		effectdata:SetRadius( 100 )
		util.Effect("ThumperDust", effectdata, false, true)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8

		// Sound
		PumpkinBoss:EmitSound("coast.thumper_dust")
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

// Called when the PumpkinBoss starts healing
net.Receive("zpn_Boss_StartHeal_net", function(len, ply)
	zclib.Debug("zpn_Boss_StartHeal_net Len: " .. len)

	local PumpkinBoss = net.ReadEntity()

	if IsValid(PumpkinBoss) then
		zclib.Animation.PlayTransition(PumpkinBoss,zpn.Theme.Boss.anim["action_heal_start"], 1,zpn.Theme.Boss.anim["action_heal_loop"],1)
	end
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

// Called when the PumpkinBoss stops healing
net.Receive("zpn_Boss_StopHeal_net", function(len, ply)
	zclib.Debug("zpn_Boss_StopHeal_net Len: " .. len)

	local PumpkinBoss = net.ReadEntity()

	if IsValid(PumpkinBoss) then

		zclib.Animation.Play(PumpkinBoss,zpn.Theme.Boss.anim["action_heal_end"], 1)
	end
end)
