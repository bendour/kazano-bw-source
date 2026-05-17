if not SERVER then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

-- Initializeses the DoobyTable
function zwf.f.DoobyTable_Initialize(DoobyTable)
	zwf.f.EntList_Add(DoobyTable)

	DoobyTable.Wait = false
end

function zwf.f.DoobyTable_Touch(DoobyTable, other)
	if not IsValid(other) then return end
	if other:GetClass() ~= "zwf_jar" then return end
	if zwf.f.CollisionCooldown(other) then return end
	if DoobyTable:GetDoobyProgress() ~= 0 then return end
	if other:GetWeedAmount() <= 0 then return end
	if DoobyTable:GetWeedID() ~= -1 and other:GetPlantID() ~= DoobyTable:GetWeedID() then return end

	zwf.f.DoobyTable_AddWeed(DoobyTable, other)
end

function zwf.f.DoobyTable_USE(DoobyTable, ply)
	if DoobyTable.Wait then return end

	local progress = DoobyTable:GetDoobyProgress()

	if progress == 0 and DoobyTable:GetWeedAmount() >= zwf.config.DoobyTable.WeedPerJoint then

		if DoobyTable:OnStartButton(ply) then
			zwf.f.DoobyTable_PlaceWeed(DoobyTable)
		elseif DoobyTable:OnRemoveButton(ply) then
			zwf.f.DoobyTable_RemoveWeed(DoobyTable)
		end

	elseif progress >= 1 and progress < 5 and DoobyTable:OnGrinder(ply) then
		zwf.f.DoobyTable_GrindWeed(DoobyTable)
	elseif progress == 5 and DoobyTable:OnPaper(ply) then
		zwf.f.DoobyTable_TakePaper(DoobyTable)
	elseif progress == 6 and DoobyTable:OnGrinder(ply) then
		zwf.f.DoobyTable_PlaceWeedOnPaper(DoobyTable)
	elseif progress >= 7 and progress < 11 and DoobyTable:OnHitButton(ply) then
		zwf.f.DoobyTable_MakeJoint(DoobyTable)
	end
end


function zwf.f.DoobyTable_AddWeed(DoobyTable, weedjar)

	DoobyTable:SetWeedID(weedjar:GetPlantID())
	DoobyTable:SetTHC(weedjar:GetTHC())
	DoobyTable:SetWeedName(weedjar:GetWeedName())

	local WeedInJar = weedjar:GetWeedAmount()
	local m_Amount = zwf.config.DoobyTable.Capacity - DoobyTable:GetWeedAmount()

	m_Amount = math.Clamp(m_Amount,0,WeedInJar)

	if m_Amount < WeedInJar then
		DoobyTable:SetWeedAmount(DoobyTable:GetWeedAmount() + m_Amount)
		weedjar:SetWeedAmount(WeedInJar - m_Amount)
	else
		DoobyTable:SetWeedAmount(DoobyTable:GetWeedAmount() + m_Amount)
		SafeRemoveEntity( weedjar )
	end
end

function zwf.f.DoobyTable_RemoveWeed(DoobyTable)

	DoobyTable:SetWeedID(-1)
	DoobyTable:SetWeedName("NIL")
	DoobyTable:SetWeedAmount(0)
	DoobyTable:SetTHC(0)
end



function zwf.f.DoobyTable_PlaceWeed(DoobyTable)

	DoobyTable:SetWeedAmount(DoobyTable:GetWeedAmount() - zwf.config.DoobyTable.WeedPerJoint)
	// 167257878
	DoobyTable:SetDoobyProgress(1)
end

function zwf.f.DoobyTable_GrindWeed(DoobyTable)
	DoobyTable.Wait = true

	timer.Simple(0.25,function()
		if IsValid(DoobyTable) then
			DoobyTable.Wait = false
		end
	end)

	DoobyTable:SetDoobyProgress(DoobyTable:GetDoobyProgress() + 1)
end

function zwf.f.DoobyTable_TakePaper(DoobyTable)
	DoobyTable.Wait = true

	timer.Simple(0.55,function()
		if IsValid(DoobyTable) then
			DoobyTable.Wait = false
		end
	end)
	DoobyTable:SetDoobyProgress(6)
end

function zwf.f.DoobyTable_PlaceWeedOnPaper(DoobyTable)
	DoobyTable.Wait = true

	timer.Simple(0.55,function()
		if IsValid(DoobyTable) then
			DoobyTable.Wait = false
		end
	end)

	DoobyTable:SetDoobyProgress(7)
	DoobyTable:SetGamePos(Vector(-8, 10, 5))
end

function zwf.f.DoobyTable_MakeJoint(DoobyTable)
	DoobyTable.Wait = true



	DoobyTable:SetGamePos(Vector(-8, DoobyTable:GetGamePos().y - 5, 5))
	DoobyTable:SetDoobyProgress(DoobyTable:GetDoobyProgress() + 1)

	if DoobyTable:GetDoobyProgress() == 11 then

		timer.Simple(1.25, function()

			if IsValid(DoobyTable) then

				DoobyTable.Wait = false

				// Spawn Joint
				zwf.f.DoobyTable_SpawnJoint(DoobyTable)
			end
		end)
	else

		timer.Simple(0.25, function()
			if IsValid(DoobyTable) then
				DoobyTable.Wait = false
			end
		end)
	end
end

function zwf.f.DoobyTable_SpawnJoint(DoobyTable)
	local ent = ents.Create("zwf_joint_ent")
	if not IsValid(ent) then return end
	ent:SetPos(DoobyTable:GetPos() + DoobyTable:GetUp() * 15)
	ent:Spawn()
	ent:Activate()

	ent:SetWeedID(DoobyTable:GetWeedID())
	ent:SetWeed_Name(DoobyTable:GetWeedName())
	ent:SetWeed_THC(DoobyTable:GetTHC())
	ent:SetWeed_Amount(zwf.config.DoobyTable.WeedPerJoint)

	DoobyTable:SetDoobyProgress(0)

	if DoobyTable:GetWeedAmount() <= 0 then
		DoobyTable:SetWeedID(-1)
		DoobyTable:SetWeedName("NIL")
		DoobyTable:SetWeedAmount(0)
		DoobyTable:SetTHC(0)
	end

	DoobyTable:SetGamePos(Vector(0,0,0))
end
