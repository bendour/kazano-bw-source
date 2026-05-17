local DROP = CarePackage:CreateDrop()
DROP.Options = {}
DROP.InventoryEnabled = false

function DROP:CanLoot(ent, ply, type)
	return !ply:HasWeapon(ent), CarePackage:GetPhrase("Drops.Weapons.Equipped")
end

function DROP:Loot(ent, ply, type)
	ply:Give(ent)
	ply:SelectWeapon(ent)
end

function DROP:GetName(ent)
	return weapons.Get(ent).PrintName or ""
end

function DROP:GetModel(ent)
	return weapons.Get(ent).WorldModel or ".mdl"
end

DROP:Register("Weapon")