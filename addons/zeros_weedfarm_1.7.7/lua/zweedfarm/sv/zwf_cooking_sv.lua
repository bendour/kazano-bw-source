if not SERVER then return end

zwf = zwf or {}
zwf.f = zwf.f or {}

// MixerBowl
function zwf.f.MixerBowl_Initialize(MixerBowl)
	zwf.f.EntList_Add(MixerBowl)

	MixerBowl.EdibleID = nil
	MixerBowl.IsMixed = false
	MixerBowl.WeedName = -1
end

function zwf.f.MixerBowl_OnTouch(MixerBowl,other)

	if not IsValid(MixerBowl) or not IsValid(other) then return end

	if string.sub(other:GetClass(),1,11)  ~= "zwf_backmix" and other:GetClass() ~= "zwf_jar" then return end

	if zwf.f.CollisionCooldown(other) then return end

	if MixerBowl.IsMixed == true then return end

	if string.sub(other:GetClass(),1,11) == "zwf_backmix" and MixerBowl.EdibleID == nil then
		zwf.f.MixerBowl_AddBackMix(MixerBowl,other)
	elseif other:GetClass() == "zwf_jar" and other:GetWeedAmount() > 0 and MixerBowl.EdibleID ~= nil then
		zwf.f.MixerBowl_AddWeed(MixerBowl,other)
	end
end

function zwf.f.MixerBowl_AddBackMix(MixerBowl,BackMix)
	MixerBowl.EdibleID = BackMix.EdibleID
	MixerBowl:SetBodygroup(0,1)
	SafeRemoveEntity(BackMix)

	zwf.f.CreateNetEffect("zwf_cooking_flour",MixerBowl)
end

function zwf.f.MixerBowl_AddWeed(MixerBowl,weedjar)

	local mixerbowl_amount = MixerBowl:GetWeedAmount()

	if mixerbowl_amount >= zwf.config.Cooking.weed_capacity then return end


	// Check if weed ids are matching
	if MixerBowl:GetWeedID() ~= -1 and MixerBowl:GetWeedID() ~= weedjar:GetPlantID() then return end

	// Set WeedID
	local _weedid = weedjar:GetPlantID()
	MixerBowl:SetWeedID(_weedid)
	MixerBowl:SetSkin(zwf.config.Plants[_weedid].skin)

	// Set WeedName
	MixerBowl.WeedName = weedjar:GetWeedName()

	// Set THC
	if MixerBowl:GetTHC() <= 0 then
		MixerBowl:SetTHC(weedjar:GetTHC())
	else
		MixerBowl:SetTHC((MixerBowl:GetTHC() + weedjar:GetTHC()) / 2)
	end


	local moveamount = zwf.config.Cooking.weed_capacity / 3

	// Make sure the moveamount gets clamped to the free space available in the mixerbowl_amount
	moveamount = math.Clamp(moveamount,0,zwf.config.Cooking.weed_capacity - mixerbowl_amount)

	local weedjar_amount = weedjar:GetWeedAmount()

	// If the weedamout in the jar is less then the moveamount then we use the weedjar_amount and remove the jar entity
	if weedjar_amount < moveamount then
		moveamount = weedjar_amount
		SafeRemoveEntity(weedjar)
	else
		weedjar:SetWeedAmount(weedjar_amount - moveamount)
	end

	MixerBowl:SetWeedAmount(mixerbowl_amount + moveamount)

	mixerbowl_amount = MixerBowl:GetWeedAmount()

	if mixerbowl_amount >= zwf.config.Cooking.weed_capacity then
		MixerBowl:SetBodygroup(1,3)
	elseif mixerbowl_amount >= (zwf.config.Cooking.weed_capacity / 2) then
		MixerBowl:SetBodygroup(1,2)
	else
		MixerBowl:SetBodygroup(1,1)
	end

	zwf.f.CreateNetEffect("zwf_grab_weed",MixerBowl)
end

function zwf.f.MixerBowl_Reset(MixerBowl)
	MixerBowl.EdibleID = nil
	MixerBowl.IsMixed = false
	MixerBowl:SetWeedID(-1)
	MixerBowl:SetWeedAmount(0)
	MixerBowl:SetTHC(0)
	MixerBowl:SetBodygroup(0,0)
	MixerBowl:SetBodygroup(1,0)
	MixerBowl:SetColor(Color(255,255,255))
	MixerBowl:SetSkin(0)
	zwf.f.CreateNetEffect("zwf_cooking_dough",MixerBowl)
end






// Mixer
function zwf.f.Mixer_Initialize(Mixer)
	zwf.f.EntList_Add(Mixer)

	//Enable Bucket
	Mixer:SetBodygroup(0,1)

	Mixer.WeedName = -1
end

function zwf.f.Mixer_OnTouch(Mixer,other)

	if not IsValid(Mixer) or not IsValid(other) then return end

	if other:GetClass() ~= "zwf_mixer_bowl" then return end

	if zwf.f.CollisionCooldown(other) then return end

	if Mixer:GetHasBowl() == false and other.IsMixed == false then
		zwf.f.Mixer_AddBowl(Mixer,other)
	end
end

function zwf.f.Mixer_USE(Mixer,ply)
	if Mixer:GetHasBowl() == false then return end
	if Mixer:GetWorkState() == 3 then return end

	if Mixer:GetHasDough() == false and Mixer:OnRemoveButton(ply) then
		zwf.f.Mixer_RemoveBowl(Mixer)
	end
end

function zwf.f.Mixer_AddBowl(Mixer,bowl)

	Mixer:SetHasBowl(true)
	Mixer:SetWorkState(2)

	local b_WID = bowl:GetWeedID()
	local b_WAmount = bowl:GetWeedAmount()
	local b_THC = bowl:GetTHC()

	Mixer:SetWeedID(b_WID)
	Mixer:SetWeedAmount(b_WAmount)
	Mixer:SetTHC(b_THC)
	Mixer.WeedName = bowl.WeedName

	Mixer.EdibleID = bowl.EdibleID

	// Enable Bucket
	Mixer:SetBodygroup(0,1)

	if bowl.EdibleID ~= nil then

		// Enable dough
		Mixer:SetBodygroup(1,1)

		Mixer:SetHasDough(true)

		// Enable Weed
		if b_WAmount >= zwf.config.Cooking.weed_capacity then
			Mixer:SetBodygroup(2,3)
		elseif b_WAmount >= (zwf.config.Cooking.weed_capacity / 2) then
			Mixer:SetBodygroup(2,2)
		elseif b_WAmount > 0 then
			Mixer:SetBodygroup(2,1)
		end


		//Change weed Skin here
		if b_WID ~= -1 then
			Mixer:SetSkin(zwf.config.Plants[b_WID].skin)
		end


		timer.Simple(1,function()
			if IsValid(Mixer) then
				zwf.f.Mixer_StartMixing(Mixer)
			end
		end)
	end
	zwf.f.CreateNetEffect("zwf_mixerbowl_add",Mixer)

	SafeRemoveEntity(bowl)
end

function zwf.f.Mixer_RemoveBowl(Mixer)
	Mixer:SetHasBowl(false)
	Mixer:SetHasDough(false)

	Mixer:SetWorkState(1)

	timer.Simple(0.3,function()
		if IsValid(Mixer) then
			// Disable Bucket
			Mixer:SetBodygroup(0,0)

			// Disable Dough
			Mixer:SetBodygroup(1,0)

			// Disable Weed
			Mixer:SetBodygroup(2,0)

			local mOwner = zwf.f.GetOwner(Mixer)

			if mOwner then
				local ent = ents.Create("zwf_mixer_bowl")
				ent:SetPos(Mixer:GetPos() + Mixer:GetUp() * 15 + Mixer:GetRight() * -35)
				ent:Spawn()
				ent:Activate()
				zwf.f.SetOwner(ent, mOwner)

				zwf.f.CreateNetEffect("zwf_mixerbowl_remove",ent)
			end
		end
	end)
end

function zwf.f.Mixer_StartMixing(Mixer)
	Mixer:SetWorkState(3)

	// Switch ON
	Mixer:SetBodygroup(3,1)

	 timer.Simple(zwf.config.Cooking.mix_duration * 0.2,function()
		 if IsValid(Mixer) then
			 // Change Skin from flour to dough
		 	Mixer:SetSkin(7)
		 end
	 end)

	timer.Simple(zwf.config.Cooking.mix_duration,function()
		if IsValid(Mixer) then
			zwf.f.Mixer_FinishMixing(Mixer)
		end
	end)
end

function zwf.f.Mixer_FinishMixing(Mixer)
	Mixer:SetWorkState(1)
	Mixer:SetHasBowl(false)
	Mixer:SetHasDough(false)

	// Switch OFF
	Mixer:SetBodygroup(3,0)

	// Disable Bucket
	Mixer:SetBodygroup(0,0)

	// Disable Dough
	Mixer:SetBodygroup(1,0)

	// Disable Weed
	Mixer:SetBodygroup(2,0)

	// Reset skin
	Mixer:SetSkin(0)

	local mOwner = zwf.f.GetOwner(Mixer)

	if mOwner then
		local ent = ents.Create("zwf_mixer_bowl")
		ent:SetPos(Mixer:GetPos() + Mixer:GetUp() * 15 + Mixer:GetRight() * -35)
		ent:Spawn()
		ent:Activate()

		ent.EdibleID = Mixer.EdibleID

		zwf.f.SetOwner(ent, mOwner)

		// Enable dough mesh
		ent:SetBodygroup(0,1)

		// Change to dough skin
		ent:SetSkin(7)

		ent.IsMixed = true

		local _weedid = Mixer:GetWeedID()
		if _weedid ~= -1 then
			ent:SetWeedID(_weedid)
			ent:SetWeedAmount(Mixer:GetWeedAmount())
			ent:SetTHC(Mixer:GetTHC())
			ent.WeedName = Mixer.WeedName

			//Set Color of dough depending on weed id
			ent:SetColor(zwf.config.Plants[_weedid].color)
		end
	end

	zwf.f.Mixer_Reset(Mixer)
end

function zwf.f.Mixer_Reset(Mixer)
	Mixer.EdibleID = nil
	Mixer:SetWeedID(-1)
	Mixer:SetWeedAmount(0)
	Mixer:SetTHC(0)
end







// Oven
function zwf.f.Oven_Initialize(Oven)
	zwf.f.EntList_Add(Oven)

	Oven.EdibleID = nil
	Oven.WeedID = -1
	Oven.WeedAmount = -1
	Oven.WeedTHC = -1
	Oven.WeedName = -1
end

function zwf.f.Oven_OnTouch(Oven,other)

	if not IsValid(Oven) or not IsValid(other) then return end

	if other:GetClass() ~= "zwf_mixer_bowl" then return end

	if zwf.f.CollisionCooldown(other) then return end

	if Oven:GetIsBaking() == false and other.IsMixed == true then
		// Add dough to oven and empty bowl
		zwf.f.Oven_AddDough(Oven,other)
	end
end

function zwf.f.Oven_AddDough(Oven,bowl)

	Oven:SetIsBaking(true)
	Oven:SetWorkState(2)

	local _weedid = bowl:GetWeedID()
	if _weedid ~= -1 then
		Oven.WeedID = _weedid
		Oven.WeedAmount = bowl:GetWeedAmount()
		Oven.WeedTHC = bowl:GetTHC()
		Oven.WeedName = bowl.WeedName
	end

	Oven.EdibleID = bowl.EdibleID

	if Oven.EdibleID then
		Oven:SetBodygroup(0, zwf.config.Cooking.edibles[Oven.EdibleID].oven_bg)
	end

	zwf.f.MixerBowl_Reset(bowl)

	timer.Simple(zwf.config.Cooking.bake_duration,function()
		if IsValid(Oven) then
			zwf.f.Oven_FinishedBaking(Oven)
		end
	end)
end

function zwf.f.Oven_FinishedBaking(Oven)
	Oven:SetIsBaking(false)
	Oven:SetWorkState(1)

	local edible_data = zwf.config.Cooking.edibles[Oven.EdibleID]

	local mOwner = zwf.f.GetOwner(Oven)

	if mOwner then
		local ent = ents.Create("zwf_edibles")
		ent:SetPos(Oven:GetPos() + Oven:GetUp() * 15 + Oven:GetRight() * -35)
		ent:Spawn()
		ent:SetModel(edible_data.edible_model)
		ent:Activate()
		zwf.f.SetOwner(ent, mOwner)

		ent.EdibleID = Oven.EdibleID

		if Oven.WeedID ~= -1 then

			ent.WeedID = Oven.WeedID
			ent.WeedAmount = math.Round(Oven.WeedAmount)
			ent.WeedTHC = math.Round(Oven.WeedTHC,2)
			ent.WeedName = Oven.WeedName
			ent:SetColor(zwf.config.Plants[ent.WeedID].color)

			ent:SetSkin(1)
		else
			ent:SetSkin(0)

			ent:SetColor(HSVToColor( math.random(0,360), 0.5, 0.85 ) )
		end
	end

	Oven:SetBodygroup(0, 0)
	Oven.EdibleID = -1
	Oven.WeedID = -1
	Oven.WeedAmount = -1
	Oven.WeedTHC = -1
end
