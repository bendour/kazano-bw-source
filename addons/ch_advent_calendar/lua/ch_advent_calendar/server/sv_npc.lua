local map = string.lower( game.GetMap() )

--[[
	Spawn the NPC
--]]
function CH_Advent.SpawnNPC()
	if not CH_Advent.Config.UseNPC then
		return
	end
	
	local PositionFile = file.Read( "craphead_scripts/ch_advent/".. map .."/npc.json", "DATA" )
	
	local Pos = util.JSONToTable( PositionFile )
	local TheVector = Vector( Pos.EntityVector.x, Pos.EntityVector.y, Pos.EntityVector.z )
	local TheAngle = Angle( Pos.EntityAngles.x, Pos.EntityAngles.y, Pos.EntityAngles.z )
	
	local npc = ents.Create( "ch_advent_npc" )
	if not IsValid( npc ) then return end
	npc:SetModel( CH_Advent.Config.NPCModel )
	npc:SetPos( TheVector )
	npc:SetAngles( TheAngle )
	npc:Spawn()
	npc:SetMoveType( MOVETYPE_NONE )
	npc:SetSolid( SOLID_BBOX )
	npc:SetCollisionGroup( COLLISION_GROUP_PLAYER )
	
	CH_Advent.SpawnedNPC = npc
end

--[[
	Console command to set NPC position
--]]
local function CH_Advent_SetNPCPos( ply )
	if not ply:IsSuperAdmin() then
		CH_Advent.Notify( ply, CH_Advent.LangString( "Only administrators can perform this action." ) )
		return
	end
	
	local Entity_Position = {
		EntityVector = {
			x = ply:GetPos().x,
			y = ply:GetPos().y,
			z = ply:GetPos().z,
		},
		EntityAngles = {
			x = ply:GetAngles().x,
			y = ply:GetAngles().y,
			z = ply:GetAngles().z,
		},
	}
	
	file.Write( "craphead_scripts/ch_advent/".. map .."/npc.json", util.TableToJSON( Entity_Position ), "DATA" )

	CH_Advent.Notify( ply, CH_Advent.LangString( "New position for the NPC has been succesfully set." ) )
	CH_Advent.Notify( ply, CH_Advent.LangString( "The NPC will respawn in 5 seconds. Move out the way." ) )
	
	-- Respawn the NPC after 5 seconds
	-- 00000000000000000
	local npc = CH_Advent.SpawnedNPC
	if IsValid( npc ) then
		npc:Remove()
	end
	
	timer.Simple( 5, function()
		CH_Advent.SpawnNPC()
		
		if IsValid( ply ) then
			CH_Advent.Notify( ply, CH_Advent.LangString( "The NPC has been respawned." ) )
		end
	end )
end
concommand.Add( "ch_advent_setnpcpos", CH_Advent_SetNPCPos )

local function CH_Advent_SetupNPC()
	timer.Simple( 1, function()
		CH_Advent.SpawnNPC()
	end )
end
hook.Add( "PostCleanupMap", "CH_Advent_SetupNPC", CH_Advent_SetupNPC )
hook.Add( "InitPostEntity", "CH_Advent_SetupNPC", CH_Advent_SetupNPC )