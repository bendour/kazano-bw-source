if not SERVER then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

// This disables the collision betweent he smaller entities
local zwf_Ents = {
	["zwf_backmix"] = true,
	["zwf_edibles"] = true,
	["zwf_weedstick"] = true,
	["zwf_seed"] = true,
}
hook.Add("ShouldCollide", "a.zwf.hooks.ShouldCollide", function(ent1, ent2)
	if (IsValid(ent1) and IsValid(ent2) and zwf_Ents[ent1:GetClass()] and zwf_Ents[ent2:GetClass()]) then return false end
end)
