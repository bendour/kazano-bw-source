if not SERVER then return end

zwf = zwf or {}
zwf.f = zwf.f or {}

// Initializeses the edible
function zwf.f.Edible_Initialize(Edible)
	zwf.f.EntList_Add(Edible)
	Edible.EdibleID = -1
	Edible.WeedID = -1
	Edible.WeedAmount = -1
	Edible.WeedTHC = -1
	Edible.WeedName = -1
end

function zwf.f.Edible_USE(Edible,ply)
	if not IsValid(Edible) then return end
	if not IsValid(ply) then return end

	if Edible.WeedID ~= -1 then

		local effect_duration =  math.Round(Edible.WeedAmount / zwf.config.Bongs.Use_Amount) * zwf.config.HighEffect.DefaultEffect_Duration

		zwf.f.CreateHighEffect(Edible.WeedID,Edible.WeedTHC,effect_duration,ply)
	end

	local edible_data = zwf.config.Cooking.edibles[Edible.EdibleID]

	if edible_data == nil then return end

	local _health = edible_data.health

	local _NewHealth = math.Clamp(ply:Health() + _health, 0, edible_data.healthcap)
	ply:SetHealth(_NewHealth)

	zwf.f.CreateNetEffect("zwf_muffin_eat",ply)

	SafeRemoveEntity(Edible)
end
