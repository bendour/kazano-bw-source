if not SERVER then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

-- Initializeses the Generator
function zwf.f.Generator_Initialize(Generator)
	zwf.f.PowerEntList_Add(Generator)
	zwf.f.EntList_Add(Generator)
	zwf.f.AddGenerator(Generator)
	Generator.NextFuelUse = -1
	Generator.NextStartTrys = math.random(1,zwf.config.Generator.Max_StartTrys)
	Generator.LastStartTry = -1

	Generator.UtraForm = false
end

zwf.Generators = zwf.Generators or {}

-- Adds the Generator to the list
function zwf.f.AddGenerator(Generator)
	table.insert(zwf.Generators, Generator)
end

function zwf.f.Generator_Touch(Generator, other)
	if not IsValid(other) then return end
	if zwf.config.Generator.Fuel_Ents[other:GetClass()] == nil then return end
	if zwf.f.CollisionCooldown(other) then return end
	if Generator:GetIsRefilling() == true then return end
	if Generator:GetMaintance() >= zwf.config.Generator.Maintance_time then return end

	if Generator:GetFuel() < zwf.config.Generator.Fuel_Capacity and (other.GotUsed == false or other.GotUsed == nil) then
		zwf.f.Generator_AddFuel(Generator,other)
	end
end

function zwf.f.Generator_AddFuel(Generator,fuel_ent)

	local fuel_class = fuel_ent:GetClass()

	local FuelAmount = zwf.config.Generator.Fuel_Ents[fuel_class](fuel_ent)

	if FuelAmount <= 0 then return end

	fuel_ent.GotUsed = true

	fuel_ent:PhysicsInit(SOLID_NONE)

	DropEntityIfHeld(fuel_ent)

	Generator:SetIsRefilling(true)

	zwf.f.CreateNetEffect("zwf_fuel_fill",Generator)


	fuel_ent:SetAngles(Generator:GetAngles())

	if fuel_class == "zwf_fuel" then
		fuel_ent:SetPos(Generator:LocalToWorld(Vector(26,0,45)))
		fuel_ent:SetAngles(fuel_ent:LocalToWorldAngles(Angle(-90,0,0)))
	else
		fuel_ent:SetPos(Generator:LocalToWorld(Vector(12,0,45)))
		fuel_ent:SetAngles(fuel_ent:LocalToWorldAngles(Angle(180,90,300)))
	end

	fuel_ent:SetParent(Generator)
	fuel_ent:SetBodygroup(1,1)

	timer.Simple(4,function()
		if IsValid(Generator) then

			Generator:SetFuel(math.Clamp(Generator:GetFuel() + FuelAmount,0,zwf.config.Generator.Fuel_Capacity))
			SafeRemoveEntity(fuel_ent)
			Generator:SetIsRefilling(false)
		end
	end)
end

function zwf.f.Generator_Start(Generator)

	zwf.f.CreateAnimTable(Generator, "start", 2)

	Generator.NextStartTrys = Generator.NextStartTrys - 1

	if  Generator.NextStartTrys <= 0 then

		Generator.LastStartTry = CurTime() + 2

		zwf.f.CreateNetEffect("zwf_generator_start_sucess",Generator)

		timer.Simple(0.9,function()

			if IsValid(Generator) then
				Generator:SetAnimState(1)
				Generator.NextStartTrys = math.random(1,zwf.config.Generator.Max_StartTrys)
			end
		end)


	else

		zwf.f.CreateNetEffect("zwf_generator_start_fail",Generator)

		Generator.LastStartTry = CurTime() + 0.5
	end
end


function zwf.f.Generator_USE(Generator, ply)
	if zwf.f.IsWeedSeller(ply) == false then return end
	if zwf.config.Sharing.Generator == false and zwf.f.IsOwner(ply, Generator) == false then return end

	if zwf.config.Generator.Maintance and Generator:GetMaintance() >= zwf.config.Generator.Maintance_time then
		zwf.f.Generator_Repair(Generator,ply)
	else
		// 167257878
		if Generator:GetIsRefilling() == true then return end

		if Generator:EnableButton(ply) then

			if Generator.LastStartTry > CurTime() then
				return
			end

			if Generator:GetAnimState() == 1 then
				Generator:SetAnimState(0)
			else
				if Generator:GetFuel() > 0 then
					zwf.f.Generator_Start(Generator)
				else
					 zwf.f.Notify(ply, zwf.language.General["generator_nofuel"], 1)
				end
			end
		end
	end
end

function zwf.f.Generator_UseFuel(Generator)
	if Generator.UtraForm then return end
	if (Generator.NextFuelUse or 0) < CurTime() then

		local curFuel = Generator:GetFuel()
		Generator:SetFuel(curFuel - zwf.config.Generator.Fuel_usage)

		Generator.NextFuelUse = CurTime() + 5
	end
end


function zwf.f.Generator_Maintance(Generator)
	if Generator.UtraForm then return end

	local _animstate = Generator:GetAnimState()
	if (_animstate == 1 or _animstate == 2) and Generator:GetFuel() > 0 then
		Generator:SetMaintance(	Generator:GetMaintance() + 1)
	end

	local _maintance = Generator:GetMaintance()
	if _maintance >= zwf.config.Generator.Maintance_time and _animstate ~= 2 then
		Generator:SetAnimState(2)
		hook.Run("zwf_OnGeneratorBroken" ,Generator)
	end

	if _maintance >= zwf.config.Generator.Maintance_time + zwf.config.Generator.Maintance_countdown then

		hook.Run("zwf_OnGeneratorExplode" ,Generator)

		Generator:SetNoDraw(true)
		local _output = Generator:GetOutput()
		if IsValid(_output) then
			_output:SetPowerSource(NULL)
		end

		zwf.f.GenericEffect("Explosion",Generator:GetPos())

		SafeRemoveEntityDelayed(Generator,0.5)
	end
end

function zwf.f.Generator_Repair(Generator,ply)
	zwf.f.CreateNetEffect("zwf_generator_repair",Generator)

	Generator:SetMaintance(	0 )
	Generator:SetAnimState(1)
	hook.Run("zwf_OnGeneratorRepaired" ,Generator,ply)
end


function zwf.f.Generator_MainLogic(Generator)

	if zwf.config.Generator.Maintance and (Generator.NextMaintanceCheck or 0) < CurTime() then
		zwf.f.Generator_Maintance(Generator)
		Generator.NextMaintanceCheck = CurTime() + 1
	end


	if Generator:GetAnimState() == 1 then
		local curFuel = Generator:GetFuel()

		if curFuel > 0 then



			if zwf.config.Generator.Fuel_SpareBenefit == false then

				zwf.f.Generator_UseFuel(Generator)

			elseif zwf.config.Generator.Fuel_SpareBenefit and Generator:GetPower() < zwf.config.Generator.Power_storage then

				zwf.f.Generator_UseFuel(Generator)

			end

			if Generator:GetPower() < zwf.config.Generator.Power_storage  then
				local newPower = math.Clamp(Generator:GetPower() + zwf.config.Generator.Power_production,0,zwf.config.Generator.Power_storage)
				Generator:SetPower(newPower)
			end
		else
			Generator:SetAnimState(0)
		end
	end
end

function zwf.f.Generator_Logic()
	for k, v in pairs(zwf.Generators) do
		if IsValid(v) then
			zwf.f.Generator_MainLogic(v)
		end
	end
end
