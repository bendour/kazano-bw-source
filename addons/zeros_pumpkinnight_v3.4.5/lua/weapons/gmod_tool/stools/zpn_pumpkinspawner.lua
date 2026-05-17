/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

AddCSLuaFile()
include("sh_zpn_config_main.lua")
AddCSLuaFile("sh_zpn_config_main.lua")
TOOL.Category = "Zeros PumpkinNight"
TOOL.Name = "#PumpkinSpawner"
TOOL.Command = nil
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 69811ac079f3e93f705541d1ed39dfac3a9e2460011697a76c02cf9afa26f9c3

if (CLIENT) then
	language.Add("tool.zpn_pumpkinspawner.name", "Custom Pumpkin SpawnTool")
	language.Add("tool.zpn_pumpkinspawner.desc", "LeftClick: Creates a Pumpkin Spawnpoint. \nRightClick: Removes a Pumpkin Spawnpoint.")
	language.Add("tool.zpn_pumpkinspawner.0", "LeftClick: Creates a Pumpkin Spawnpoint.")
end

function TOOL:LeftClick(trace)
	local trEnt = trace.Entity
	if trEnt:IsPlayer() then return false end
	if (CLIENT) then return end
	if zclib.Player.IsAdmin(self:GetOwner()) == false then return end

	if trEnt:IsWorld() then
		if trace.Hit and trace.HitPos and zclib.util.InDistance(trace.HitPos, self:GetOwner():GetPos(), 1000) then
			zclib.Notify(self:GetOwner(), "Pumpkin Spawn added!", 0)
			zpn.PumpkinSpawner.AddPos(trace.HitPos)
			zpn.PumpkinSpawner.ShowAll(self:GetOwner())
		end

		return true
	else
		return false
	end
end

function TOOL:RightClick(trace)
	if (trace.Entity:IsPlayer()) then return false end
	if (CLIENT) then return end
	if zclib.Player.IsAdmin(self:GetOwner()) == false then return end
	if trace.Hit and trace.HitPos then
		if zclib.util.InDistance(trace.HitPos, self:GetOwner():GetPos(), 1000) then
			zclib.Notify(self:GetOwner(), "Pumpkin Spawn removed!", 0)
			zpn.PumpkinSpawner.RemoveSpawnPos(trace.HitPos, self:GetOwner())
		end

		return true
	else
		return false
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

function TOOL:Deploy()
	if SERVER and zclib.Player.IsAdmin(self:GetOwner()) then
		zpn.PumpkinSpawner.ShowAll(self:GetOwner())
	end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

function TOOL:Holster()
	if SERVER and zclib.Player.IsAdmin(self:GetOwner()) then
		zpn.PumpkinSpawner.HideAll(self:GetOwner())
	end
end

function TOOL.BuildCPanel(CPanel)

	zclib.Settings.OptionPanel("Pumpkin spawns",nil, Color(92, 82, 130, 255), Color(71, 63, 100, 255), CPanel, {
		[1] = {
			name = "Save",
			class = "DButton",
			cmd = "zpn_save_pumpkinspawns"
		},
		[2] = {
			name = "Remove",
			class = "DButton",
			cmd = "zpn_remove_pumpkinspawns"
		}
	})
end
