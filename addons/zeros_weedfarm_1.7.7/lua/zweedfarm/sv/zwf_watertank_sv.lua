if CLIENT then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

function zwf.f.WaterTank_Refill(WaterTank, ply)
	if zwf.f.IsWeedSeller(ply) == false then return end
    if zwf.config.Sharing.WaterTank == false and zwf.f.IsOwner(ply, WaterTank) == false then return end

    if WaterTank:GetWater() >= zwf.config.WaterTank.Capacity then return end

    if WaterTank:RefillButton(ply) then
        local refillAmount = zwf.config.WaterTank.Capacity - WaterTank:GetWater()
        local cost = refillAmount * zwf.config.WaterTank.RefillCostPerUnit

        if zwf.f.HasMoney(ply, cost) then
            zwf.f.TakeMoney(ply, cost)

            local str = zwf.language.General["ItemBought"]
            str = string.Replace(str, "$itemname", zwf.language.General["Water"] )
            str = string.Replace(str, "$price", cost )
            str = string.Replace(str, "$currency", zwf.config.Currency )

            zwf.f.Notify(ply, str, 0)

            WaterTank:SetWater(zwf.config.WaterTank.Capacity)

			zwf.f.CreateNetEffect("zwf_water_refill",WaterTank)
        end
    end
end
