-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SH_HADEZ:HasBarrier(ply)
	return ply:GetNWBool("z_hadez_Barrier")
end 

function SV_HADEZ:GetBarrierOwner(ply)
	return ply:GetNWEntity("z_hadez_BarrierOwner")
end

function SH_HADEZ:GetBarrierOption(ply, option, optionType)

	if isnumber(value) then
		return ply:GetNWInt("z_hadez_Barrier"..option)
	else
		return ply:GetNWBool("z_hadez_Barrier"..option)
	end
	
end

if SERVER then

	function SV_HADEZ:SetBarrier(ply, enabled)
		ply:SetNWBool("z_hadez_Barrier", enabled)
	end
	
	function SV_HADEZ:SetInBarrier(ply, barrierOwner)
		ply:SetNWEntity("z_hadez_BarrierOwner", barrierOwner)
	end

	function SV_HADEZ:SetBarrierOptions(ply, options)
	
		for name, value in pairs(options) do
		
			if isnumber(value) then
				ply:SetNWInt("z_hadez_Barrier"..name, value)
			else
				ply:SetNWBool("z_hadez_Barrier"..name, value)
			end
			
		end
		
	end
	
end

if CLIENT then

	local barrierMat = Material("z_hadez/barrier/barrier_sheet")
	
	local function Barrier3DContext(ply)
	
		if !ply:Alive() then return end
		
		local origin = ply:GetPos()+Vector(0,0,40)
		local range = SH_HADEZ:GetBarrierOption(ply, "range", 1)
		local radius = range/2

		render.SetMaterial(barrierMat)
		render.DrawSphere( origin, range, radius, radius, color_black )
		
	end
	
	local function PostDrawTranslucentRenderables()
		
		local plys = player.GetAll()
		
		for i=1, #plys do
		
			local ply = plys[i]

			if SH_HADEZ:HasBarrier(ply) then
				Barrier3DContext(ply)
			end
			
		end
		
	end
	hook.Add( "PostDrawTranslucentRenderables", "z_hadez_Barrier", PostDrawTranslucentRenderables )

end