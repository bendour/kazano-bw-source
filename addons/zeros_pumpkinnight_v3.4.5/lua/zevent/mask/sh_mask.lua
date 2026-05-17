/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

zpn = zpn or {}
zpn.Mask = zpn.Mask or {}

/*
	Returns if the player is in friendlymode with monsters
*/
function zpn.Mask.GetMonsterFriend(ply)
	if not IsValid(ply) then return end
    if not zpn.Mask.Has(ply) then return end

	local MaskData = zpn.config.Masks[ply:GetNWInt("zpn_MaskID",0)]
    if MaskData and MaskData.monster_friend then
        return MaskData.monster_friend
	else
		return
    end
end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

/*
	Returns the candy multiplicator for the player
*/
function zpn.Mask.GetCandyMul(ply)
	if not IsValid(ply) then return 1 end
    if not zpn.Mask.Has(ply) then return 1 end

	local MaskData = zpn.config.Masks[ply:GetNWInt("zpn_MaskID",0)]
    if MaskData and MaskData.candy_mul then
        return MaskData.candy_mul
	else
		return 1
    end
end

/*
	Returns the attack multiplicator for the player
*/
function zpn.Mask.GetAttackMul(ply)
	if not IsValid(ply) then return end
    if not zpn.Mask.Has(ply) then return end

	local MaskData = zpn.config.Masks[ply:GetNWInt("zpn_MaskID",0)]
    if MaskData and MaskData.attack_mul then
        return MaskData.attack_mul
	else
		return
    end
end

/*
	Returns the protection multiplicator for the player
*/
function zpn.Mask.GetReflectMul(ply)
	if not IsValid(ply) then return end
    if not zpn.Mask.Has(ply) then return end

	local MaskData = zpn.config.Masks[ply:GetNWInt("zpn_MaskID",0)]
    if MaskData and MaskData.reflect_mul then
        return MaskData.reflect_mul
	else
		return
    end
end


function zpn.Mask.GetUses(ply)
    return ply.zpn_MaskUses or 1
end

function zpn.Mask.Has(ply)
    local MaskID = ply:GetNWInt("zpn_MaskID",0)
    return MaskID and MaskID > 0 and zpn.Mask.GetUses(ply) > 0
end

// This defines a offsets for diffrent models so the mask allways fits perfect
zpn.Mask.ModelOffsets = {}
/*
zpn.Mask.ModelOffsets["Path/To/The/Model.mdl"] = {
    pos = Offset Position from ValveBiped.Bip01_Head1,
    ang = Offset Angle from ValveBiped.Bip01_Head1,
    scale = Size of the Model (can be removed if not needed)
}
*/
zpn.Mask.ModelOffsets["Default"] = {pos = Vector(2.9, 0, 0.6),ang = Angle(-5, 0, 0)}
zpn.Mask.ModelOffsets["models/player/kleiner.mdl"] = {pos = Vector(3.1, 0, 1),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/monk.mdl"] = {pos = Vector(3.6, 0, 0.85),ang = Angle(10, 0, 0)}
zpn.Mask.ModelOffsets["models/player/corpse1.mdl"] = {pos = Vector(3.6, 0, 0),ang = Angle(10, 0, 0)}
zpn.Mask.ModelOffsets["models/player/police.mdl"] = {pos = Vector(6, 0, 0),ang = Angle(10, 0, 0)}
zpn.Mask.ModelOffsets["models/player/breen.mdl"] = {pos = Vector(3.3, 0, 0),ang = Angle(10, 0, 0)}
zpn.Mask.ModelOffsets["models/player/alyx.mdl"] = {pos = Vector(2.6, 0, 0.6),ang = Angle(-5, 0, 0)}
zpn.Mask.ModelOffsets["models/player/p2_chell.mdl"] = {pos = Vector(2.8, 0, 0.8),ang = Angle(-5, 0, 0)}
zpn.Mask.ModelOffsets["models/player/barney.mdl"] = {pos = Vector(3.6, 0, 0.9),ang = Angle(-5, 0, 0)}
zpn.Mask.ModelOffsets["models/player/gman_high.mdl"] = {pos = Vector(3, 0, 1.9),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/odessa.mdl"] = {pos = Vector(3.7, 0, 1),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/mossman.mdl"] = {pos = Vector(3, 0.1, 0.7),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/eli.mdl"] = {pos = Vector(3, 0.1, 0.7),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/charple.mdl"] = {pos = Vector(1, 0, 0),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/soldier_stripped.mdl"] = {pos = Vector(2, 0, 0),ang = Angle(0, 0, 0)}


zpn.Mask.ModelOffsets["models/player/group02/male_02.mdl"] = {pos = Vector(3.5, 0, 0.6),ang = Angle(5, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group02/male_04.mdl"] = {pos = Vector(3.5, 0, 1),ang = Angle(5, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group02/male_06.mdl"] = {pos = Vector(4, 0, 0.9),ang = Angle(5, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group02/male_08.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}


zpn.Mask.ModelOffsets["models/player/group01/male_01.mdl"] = {pos = Vector(3.9, 0, 1),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group01/male_02.mdl"] = {pos = Vector(3.5, 0, 1),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group01/male_03.mdl"] = {pos = Vector(3.7, 0, 0.7),ang = Angle(10, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group01/male_04.mdl"] = {pos = Vector(3.2, 0, 1),ang = Angle(5, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group01/male_05.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(10, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group01/male_06.mdl"] = {pos = Vector(4, 0, 1),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group01/male_07.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group01/male_08.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group01/male_09.mdl"] = {pos = Vector(3.7, 0, 0.7),ang = Angle(10, 0, 0)}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

zpn.Mask.ModelOffsets["models/player/group03/male_01.mdl"] = {pos = Vector(3.9, 0, 1),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03/male_02.mdl"] = {pos = Vector(3.5, 0, 1),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03/male_03.mdl"] = {pos = Vector(3.7, 0, 0.7),ang = Angle(10, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03/male_04.mdl"] = {pos = Vector(3.2, 0, 1),ang = Angle(5, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03/male_05.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(10, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03/male_06.mdl"] = {pos = Vector(4, 0, 1),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03/male_07.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03/male_08.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03/male_09.mdl"] = {pos = Vector(3.7, 0, 0.7),ang = Angle(10, 0, 0)}

zpn.Mask.ModelOffsets["models/player/group03/female_01.mdl"] = {pos = Vector(3, 0, 0.3),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03/female_02.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03/female_03.mdl"] = {pos = Vector(3.1, 0, 0.3),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03/female_04.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03/female_05.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03/female_06.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}


zpn.Mask.ModelOffsets["models/player/group03m/male_01.mdl"] = {pos = Vector(3.9, 0, 1),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03m/male_02.mdl"] = {pos = Vector(3.5, 0, 1),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03m/male_03.mdl"] = {pos = Vector(3.7, 0, 0.7),ang = Angle(10, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03m/male_04.mdl"] = {pos = Vector(3.2, 0, 1),ang = Angle(5, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03m/male_05.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(10, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03m/male_06.mdl"] = {pos = Vector(4, 0, 1),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03m/male_07.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03m/male_08.mdl"] = {pos = Vector(3, 0, 0.5),ang = Angle(5, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03m/male_09.mdl"] = {pos = Vector(3.7, 0, 0.7),ang = Angle(10, 0, 0)}

zpn.Mask.ModelOffsets["models/player/group03m/female_01.mdl"] = {pos = Vector(3, 0, 0.3),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03m/female_02.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03m/female_03.mdl"] = {pos = Vector(3.1, 0, 0.3),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03m/female_04.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03m/female_05.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group03m/female_06.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}


zpn.Mask.ModelOffsets["models/player/group01/female_01.mdl"] = {pos = Vector(3, 0, 0.1),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group01/female_02.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group01/female_03.mdl"] = {pos = Vector(3.1, 0, 0.3),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group01/female_04.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group01/female_05.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/group01/female_06.mdl"] = {pos = Vector(3.2, 0, 0.3),ang = Angle(0, 0, 0)}

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- a2b46fa362cff6519809e40cc8d153299c414b52d9b8c3759ca38e67d8a7d851

zpn.Mask.ModelOffsets["models/player/hostage/hostage_01.mdl"] = {pos = Vector(3, 0, 1),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/hostage/hostage_02.mdl"] = {pos = Vector(3.9, 0, 1),ang = Angle(0, 0, 0)}
zpn.Mask.ModelOffsets["models/player/hostage/hostage_03.mdl"] = {pos = Vector(3, 0, 0.2),ang = Angle(10, 0, 0)}
zpn.Mask.ModelOffsets["models/player/hostage/hostage_04.mdl"] = {pos = Vector(3, 0, 1),ang = Angle(0, 0, 0)}
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000
