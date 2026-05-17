local OBJECT_TYPE = {}

OBJECT_TYPE.Name = ashop.L('TrailsClass')
OBJECT_TYPE.UniqueIdentifier = "Trails"

// Refresh Player, check if his trail should be enabled
local b

local function refreshTrail(ply)
    if !IsValid(ply) or ply:IsBot() then return end

    if !b then
        b = ashop.GetObjectTypeIDByUID('Trails')
    end

    local equipped, count = ply:AShop_SlotStateGet(b)

    for k, v in pairs(equipped or {}) do
        local plyItem = ply.ashop_data.items[v]

        if !ply:GetNoDraw() and ply:Alive() and ply:Team() != TEAM_SPECTATOR and ply:GetObserverMode() == 0 then
            plyItem.trail:Fire('Alpha', '255')
            plyItem.trail:Fire("rendermode", "0")
        else
            plyItem.trail:Fire('Alpha', '0')
            plyItem.trail:Fire("rendermode", "1")
        end
    end
end

function OBJECT_TYPE.OnEquip(ply, plyItem, item)
    if item.metadata[1] then
        local attach = 0
        local m = item.metadata
        local startWidth = m[9] or 10
        local endWidth = m[10] or 0
        local textureRes = 1 / ( startWidth + endWidth ) * 0.5
        local clr = m[7] or color_white
        local additive = m[8] or false
        local lifetime = m[11] or 2

        if m[3] then
            local boneID = ply:LookupBone(m[4])
            if boneID then
                local pos, ang = ply:GetBonePosition(boneID)
                local e = ents.Create('prop_dynamic')
                e:SetModel('models/hunter/blocks/cube025x025x025.mdl')
                e:SetMoveType(MOVETYPE_NONE)
                e:SetCollisionGroup(COLLISION_GROUP_NONE)
                e:SetNoDraw(true)
                //e:SetPos(ply:GetPos())
                //e:SetAngles(ang)
                //e:FollowBone(ply, boneID)
                e:Spawn()

                e.trail = util.SpriteTrail( e, 0, clr, additive,
                    startWidth, endWidth, lifetime, textureRes, m[2] )
                plyItem.trail = e.trail

                hook.Add("Think", e, function()
                    if IsValid(ply) then
                        local pos, ang = ply:GetBonePosition(boneID)
                        e:SetPos(pos)
                        e:SetAngles(ang)
                    end
                end)
                
                e.trail:CallOnRemove("ashop_trail", function()
                    if IsValid(e) then
                        e:Remove()
                    end
                end)

                ply.ashop_trails = ply.ashop_trails or {}
                ply.ashop_trails[plyItem.trail] = true

                refreshTrail(ply)
                return
            else
                print("[AShop] Couldn't find the bone ", m[4], " on the model: ", ply:GetModel())
            end

            attach = ply:LookupAttachment(m[4])
        end

        plyItem.trail = util.SpriteTrail( ply, attach, clr, additive,
            startWidth, endWidth, lifetime, textureRes, m[2] )

        ply.ashop_trails = ply.ashop_trails or {}
        ply.ashop_trails[plyItem.trail] = true

        refreshTrail(ply)
    end
end

function OBJECT_TYPE.OnRemove(ply, plyItem, item)
    if plyItem.trail then
        ply.ashop_trails[plyItem.trail] = nil
        if IsValid(plyItem.trail) then
            plyItem.trail:Fire('Disable')
            plyItem.trail:Remove()
        end
    end
end

function OBJECT_TYPE.OnLocalFPDraw()
end

// All players
function OBJECT_TYPE.OnMetadataUpdate(ply, plyItem, item, metadataKey, oldValue, newValue)
    if item.metadata[1] then
        if IsValid(plyItem.trail) then
            plyItem.trail:Fire('Disable')
            plyItem.trail:Remove()
        end

        OBJECT_TYPE.OnEquip(ply, plyItem, item)
    end
end

ashop.RegisterObjectType(OBJECT_TYPE)

local function clearAndRefresh(ply)
    if !b then
        b = ashop.GetObjectTypeIDByUID('Trails')
    end

    local equipped, count = ply:AShop_SlotStateGet(b)

    for k, v in pairs(equipped or {}) do
        local plyItem = ply.ashop_data.items[v]
        OBJECT_TYPE.OnRemove(ply, plyItem, ashop.items[plyItem.item_id])
        OBJECT_TYPE.OnEquip(ply, plyItem, ashop.items[plyItem.item_id])
    end

    refreshTrail(ply)
end

hook.Add( "PlayerChangedTeam", "ashop_unloadTrails", function( ply, oldTeam, newTeam )
    timer.Simple(0, function()
        clearAndRefresh(ply)
    end)
end )

hook.Add("PlayerSpawn", "ashop_unloadTrails", clearAndRefresh)

hook.Add("PlayerDeath", "ashop_unloadTrails", function(ply)
    clearAndRefresh(ply)
end)

local SetNoDrawDefault = ashop.detourNoDraw or FindMetaTable("Entity").SetNoDraw
local ENTITY = FindMetaTable("Entity")

function ENTITY:SetNoDraw(b)
    SetNoDrawDefault(self, b)

    if self:IsPlayer() then
        clearAndRefresh(self)
    end
end

