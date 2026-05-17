util.AddNetworkString('ashop_WeaponMaterial_EditBulk')
util.AddNetworkString('ashop_WeaponMaterial_Edit')

local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('WeaponSkinClass')
OBJECT_TYPE.UniqueIdentifier = "WeaponSkins"

function OBJECT_TYPE.OnEquip(ply, plyItem, item)
    ply.ashop_skinwep = plyItem.id

    local wep = ply:GetActiveWeapon()

    if IsValid(wep) then
        ashop.WeaponSkinApply(ply, wep)
    end
end

hook.Add('PlayerSwitchWeapon', 'ashop_weaponskin', function(ply, _, wep)
    ashop.WeaponSkinApply(ply, wep)
end)

function OBJECT_TYPE.OnRemove(ply, plyItem, item)
    ply.ashop_skinwep = nil

    local wep = ply:GetActiveWeapon()

    if IsValid(wep) then
        ashop.WeaponSkinApply(ply, wep)
    end
end

function OBJECT_TYPE.OnLocalFPDraw()
end

// All players
function OBJECT_TYPE.OnMetadataUpdate()
end

ashop.RegisterObjectType(OBJECT_TYPE)

local premades = {
    ["fas2_m16a2"] = {t = "fas2", wm = {0}, vm = {1}},
    ["fas2_m1911"] = {t = "fas2", wm = {0}, vm = {0}},
    ["fas2_m82"] = {t = "fas2", wm = {0}, vm = {0}},
    ["fas2_glock20"] = {t = "fas2", wm = {0}, vm = {0}},
    ["fas2_pp19"] = {t = "fas2", wm = {0}, vm = {1}},
    ["fas2_sterling_mk7a4"] = {t = "fas2", wm = {0}, vm = {1}},
    ["fas2_sterling_l34a1"] = {t = "fas2", wm = {0, 2}, vm = {1, 2}},
    ["fas2_sterling_l2a3"] = {t = "fas2", wm = {0, 2}, vm = {1, 2}},
    ["fas2_sr25"] = {t = "fas2", wm = {0, 1}, vm = {0, 1}},
    ["fas2_sks"] = {t = "fas2", wm = {}, vm = {0}},
    ["fas2_sg552"] = {t = "fas2", wm = {0}, vm = {0}},
    ["fas2_sg551"] = {t = "fas2", wm = {0}, vm = {2}},
    ["fas2_sg550"] = {t = "fas2", wm = {0}, vm = {0}},
    ["fas2_rk95"] = {t = "fas2", wm = {0}, vm = {0}},
    ["fas2_rpk"] = {t = "fas2", wm = {0}, vm = {2}},
    ["fas2_rem870"] = {t = "fas2", wm = {0}, vm = {0}},
    ["fas2_ragingbull"] = {t = "fas2", wm = {0}, vm = {1}},
    ["fas2_p226"] = {t = "fas2", wm = {0}, vm = {0}},
    ["fas2_ots33"] = {t = "fas2", wm = {0}, vm = {0}},
    ["fas2_mp5sd6"] = {t = "fas2", wm = {0, 1}, vm = {0, 1}},
    ["fas2_mp5k"] = {t = "fas2", wm = {0, 1}, vm = {0, 1}},
    ["fas2_mp5a5"] = {t = "fas2", wm = {0, 1}, vm = {0, 1}},
    ["fas2_vollmer"] = {t = "fas2", wm = {0, 1}, vm = {0, 1}},
    ["fas2_m79"] = {t = "fas2", wm = {0, 1}, vm = {0, 1}},
    ["fas2_m60e3"] = {t = "fas2", wm = {0, 1}, vm = {0}},
    ["fas2_m4a1"] = {t = "fas2", wm = {0}, vm = {0}},
    ["fas2_m3s90"] = {t = "fas2", wm = {0}, vm = {1}},
    ["fas2_m249"] = {t = "fas2", wm = {0}, vm = {1}},
    ["fas2_m24"] = {t = "fas2", wm = {3}, vm = {0}},
    ["fas2_m21"] = {t = "fas2", wm = {0}, vm = {3}},
    ["fas2_m14"] = {t = "fas2", wm = {0}, vm = {0}},
    ["fas2_mac11"] = {t = "fas2", wm = {0}, vm = {1}},
    ["fas2_ks23"] = {t = "fas2", wm = {0}, vm = {0}},
    ["fas2_uzi"] = {t = "fas2", wm = {0}, vm = {0}},
    ["fas2_galil"] = {t = "fas2", wm = {0}, vm = {1}},
    ["fas2_deagle"] = {t = "fas2", wm = {0}, vm = {0}},
    ["fas2_g3"] = {t = "fas2", wm = {0}, vm = {0}},
    ["fas2_g36c"] = {t = "fas2", wm = {0}, vm = {0}},
    ["fas2_famas"] = {t = "fas2", wm = {0}, vm = {0}},
    ["fas2_svd"] = {t = "fas2", wm = {0}, vm = {1, 4, 0}},
    ["fas2_an94"] = {t = "fas2", wm = {0}, vm = {0}},
    ["fas2_ak74"] = {t = "fas2", wm = {0}, vm = {1, 2}},
    ["fas2_ak47"] = {t = "fas2", wm = {0}, vm = {1}},
    ["fas2_ak12"] = {t = "fas2", wm = {0}, vm = {0}},
    ["m9k_acr"] = {wm = {0}, vm = {0}},
    ["m9k_winchester73"] = {wm = {0}, vm = {0}},
    ["m9k_ak47"] = {wm = {2}, vm = {1}},
    ["m9k_ak74"] = {wm = {2, 1, 0}, vm = {2, 3, 1}},
    ["m9k_amd65"] = {wm = {0, 1}, vm = {1, 2}},
    ["m9k_an94"] = {wm = {0}, vm = {0}},
    ["m9k_val"] = {wm = {1}, vm = {2}},
    ["m9k_f2000"] = {wm = {1, 3, 4, 2, 0}, vm = {1, 3, 4}},
    ["m9k_famas"] = {wm = {2}, vm = {0}},
    ["m9k_fal"] = {wm = {2, 4, 8, 3}, vm = {2, 3, 4}},
    ["m9k_g36"] = {wm = {1, 3}, vm = {1, 3}},
    ["m9k_m416"] = {wm = {1}, vm = {2}},
    ["m9k_g3a3"] = {wm = {0}, vm = {0}},
    ["m9k_l85"] = {wm = {2, 1, 3, 0, 4}, vm = {2, 1, 3}},
    ["m9k_m14sp"] = {wm = {3}, vm = {3}},
    ["m9k_m16a4_acog"] = {wm = {3, 1}, vm = {2, 4}},
    ["m9k_m4a1"] = {wm = {4, 1}, vm = {2, 4}},
    ["m9k_scar"] = {wm = {7, 8}, vm = {7, 8}},
    ["m9k_vikhr"] = {wm = {1}, vm = {2}},
    ["m9k_auga3"] = {wm = {1}, vm = {2, 1}},
    ["m9k_tar21"] = {wm = {0}, vm = {1}},
    ["unclen8_msr"] = {wm = {0}, vm = {2, 1}},
    ['couteau_uranium'] = {wm = {0}, vm = {0}},
    ['unclen8_deagold'] = {wm = {2}, vm = {3}},
    ['ak47_beast'] = {wm = {0}, vm = {1}},
    ['m4a1_beast'] = {wm = {0}, vm = {0}},

    ['weapon_ttt_m16'] = {wm = {0}, vm = {0}},
    ['weapon_ttt_stungun'] = {wm = {0}, vm = {0}},
    ['weapon_ttt_sipistol'] = {wm = {0}, vm = {0}},
    ['weapon_ttt_phammer'] = {wm = {0}, vm = {0}},
    ['weapon_ttt_push'] = {wm = {0}, vm = {0}},
    ['weapon_ttt_glock'] = {wm = {0}, vm = {0}},
    ['weapon_ttt_knife'] = {wm = {0}, vm = {0}},
    ['weapon_ttt_flaregun'] = {wm = {0}, vm = {0}},
    ['weapon_ttt_defuser'] = {wm = {0}, vm = {}},
    ['weapon_ttt_c4'] = {wm = {0}, vm = {0}},
    ['weapon_ttt_beacon'] = {wm = {0}, vm = {}},

    ['weapon_357'] = {wm = {0}, vm = {0}},
    ['weapon_pistol'] = {wm = {0}, vm = {0}},
    ['weapon_bugbait'] = {wm = {0}, vm = {0}},
    ['weapon_crossbow'] = {wm = {0}, vm = {0}},
    ['weapon_crowbar'] = {wm = {0}, vm = {0}},
    ['weapon_physcannon'] = {wm = {0}, vm = {0}},
    ['weapon_ar2'] = {wm = {0}, vm = {0}},
    ['weapon_rpg'] = {wm = {0}, vm = {0}},
    ['weapon_shotgun'] = {wm = {0}, vm = {0}},
    ['weapon_smg1'] = {wm = {0}, vm = {0}},
    ['weapon_stunstick'] = {wm = {0}, vm = {0}},
}

concommand.Add("ashop_scanMissingWeapons", function(ply)
    if IsValid(ply) and !ply:IsSuperAdmin() then return end

    net.Start('ashop_WeaponMaterial_EditBulk')
    for k, v in pairs(premades) do
        if !ashop.weaponmaterials[k] and (weapons.Get(k) or ashop.DefaultWeaponsHL2[k]) then
            print('[AShop] Loaded weapon preset: ', k)

            local vmFormat, wmFormat = {}, {}
            for k, v in ipairs(v.vm) do
                vmFormat[v] = true
            end

            for k, v in ipairs(v.wm) do
                wmFormat[v] = true
            end

            ashop.weaponmaterials[k] = {
                vm = vmFormat,
                wm = wmFormat
            }

            net.WriteBool(true)
            net.WriteString(k)
            
            net.WriteUInt(#v.vm, 8)
            for i = 1, #v.vm do
                net.WriteUInt(v.vm[i], 8)
            end

            net.WriteUInt(#v.wm, 8)
            for i = 1, #v.wm do
                net.WriteUInt(v.wm[i], 8)
            end

            ashop.SQL.query("INSERT INTO ashop_weaponmaterials(weaponname, wm, vm) VALUES('" .. k .. "', '" .. util.TableToJSON(wmFormat) .. "', '" .. util.TableToJSON(vmFormat) .. "')")
        end
    end

        net.WriteBool(false)
    net.Broadcast()
end)

ashop.SafeNet('WeaponMaterial_Delete', function(ply)
    local wep = net.ReadString()
    if !ashop.weaponmaterials[wep] then return end

    net.Start('ashop_WeaponMaterial_Delete')
        net.WriteString(wep)
    net.Broadcast()

    ashop.SQL.query('DELETE FROM ashop_weaponmaterials WHERE weaponname = "' .. ashop.SQL.escape(wep) .. '"')
    ashop.Logs.PushLog(ashop.Logs.IDs.WeaponMaterial_Delete, ply, wep)
end, 1, true)

ashop.SafeNet('WeaponMaterial_EditBulk', function(ply)
    local wep = net.ReadString()
    local b = net.ReadBool()
    local wm = net.ReadBool()
    local id = net.ReadUInt(8)
    local key2 = wm and "wm" or "vm"
    if !ashop.weaponmaterials[wep] then return end

    ashop.weaponmaterials[wep][key2] = ashop.weaponmaterials[wep][key2] or {}
    ashop.weaponmaterials[wep][key2][id] = b and true or nil

    // This is only number, they can't sql injection that
    ashop.SQL.query("UPDATE ashop_weaponmaterials SET " .. key2 .. " = '" .. util.TableToJSON(ashop.weaponmaterials[wep][key2]) .. "' WHERE weaponname = " .. ashop.SQL.escape(wep))
    net.Start('ashop_WeaponMaterial_Edit')
        net.WriteString(wep)
        net.WriteBool(b)
        net.WriteBool(wm)
        net.WriteUInt(id, 8)
    net.Broadcast()

    ashop.Logs.PushLog(ashop.Logs.IDs.WeaponMaterial_Update, ply, wep)
end, 0.15, true)

ashop.SafeNet('WeaponMaterial_Create', function(ply)
    local wep = net.ReadString()
    if ashop.weaponmaterials[wep] then return end
    if !weapons.Get(wep) and !ashop.DefaultWeaponsHL2[wep] then return end

    ashop.weaponmaterials[wep] = {
        vm = {},
        wm = {}
    }

    net.Start('ashop_WeaponMaterial_Create')
        net.WriteString(wep)
        ashop.Network.W_WeaponMaterials(ashop.weaponmaterials[wep])
    net.Broadcast()

    ashop.SQL.query("INSERT INTO ashop_weaponmaterials(weaponname, wm, vm) VALUES(" .. ashop.SQL.escape(wep) .. ", '[]', '[]')")
    ashop.Logs.PushLog(ashop.Logs.IDs.WeaponMaterial_Create, ply, wep)
end, 0.5, true)