if not SERVER then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

function zwf.f.Jar_AddWeed(jar, weedamount)
	jar:SetWeedAmount(weedamount)
end

function zwf.f.Jar_Touch(JarA, JarB)

	// We can only merge weed jars of the same sort
	if JarA:GetPlantID() ~= JarB:GetPlantID() then return end

	local weedA = JarA:GetWeedAmount()
	local weedB = JarB:GetWeedAmount()

	if weedA >= zwf.config.Jar.Capacity then return end

	// The amount of space we have in JarA
	local sAmount = zwf.config.Jar.Capacity - weedA

	// The Amount we can transfer
	local tAmount

	if sAmount >= weedB then
		tAmount = weedB
	else
		tAmount = sAmount
	end

	// Here we average out the THC level of both jars
	local avg_thc = JarA:GetTHC() + JarB:GetTHC()
	avg_thc = math.floor(avg_thc / 2)
	JarA:SetTHC(avg_thc)
	JarB:SetTHC(avg_thc)

	// If the transfer amount is more then the weed amount from JarB then we remove JarB
	if tAmount >= weedB then
		JarB:Remove()
	else
		zwf.f.Jar_AddWeed(JarB, weedB - tAmount)
	end

	zwf.f.Jar_AddWeed(JarA, weedA + tAmount)
end

function zwf.f.Jar_ItemStore(jar)

end
