/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

if CLIENT then return end

zclib.Hook.Add("zclib_PlayerJoined", "zpn_playerjoin", function(ply)

    // Sets up the data for the Candy Points and score
    zpn.data.Init(ply)

                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

    // Lets send the player the current Score
    timer.Simple(1,function()
        if IsValid(ply) and zpn.ScoreList then
            local scoreString = util.TableToJSON(zpn.ScoreList)
            local scoreCompressed = util.Compress(scoreString)
            net.Start("zpn_scoreboard_send")
            net.WriteUInt(#scoreCompressed, 16)
            net.WriteData(scoreCompressed, #scoreCompressed)
            net.Send(ply)
        end
    end)
end)

zclib.Hook.Add("zclib_PlayerDisconnect", "zpn_playerdisconnect", function(steamid)
    timer.Simple(0.25, function()
        // Remove this steam id from the scoreboard
        zpn.PumpkinScore[steamid] = nil
        zpn.Scoreboard.ScoreChanged()
    end)
end)

zclib.Hook.Add("PlayerDeath", "zpn_Main", function(victim, inflictor, attacker)

    // Closes the shop interface
    zpn.Shop.ForceClose(victim)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 6af6efba71e4015ff987fc919ecacbe102ec0873079409ab2a0ed0bf25e3f3cd

    if IsValid(victim) then
        victim.zpn_ImpactHit = false
    end
end)

zclib.Hook.Add( "Move", "zpn_SmashImpact", function(ply,mv)

    if IsValid(ply) and ply:Alive() and ply.zpn_ImpactHit and ply.zpn_ImpactHit == true and ply.zpn_ImpactHit_Dir then
        local vel = mv:GetVelocity()
        mv:SetVelocity( vel + (ply.zpn_ImpactHit_Dir * ply.zpn_ImpactHit_Strenght) )
        ply.zpn_ImpactHit = false
    end
end )

// Used by the Player to tell him his Candy Score / Points
zclib.Hook.Add("PlayerSay", "zpn_Main", function(ply, text)
    if string.sub(string.lower(text), 1, 9) == "!zpn_save" then

        if zclib.Player.IsAdmin(ply) then
            // Saves all of the Shop NPC
            if zclib.STM.Save("zpn_npc") then zclib.Notify(ply, "Shop NPC entities have been saved for the map " .. game.GetMap() .. "!", 0) end


            //Save function for scoreboard
            if zclib.STM.Save("zpn_scoreboard") then zclib.Notify(ply, "Scoreboard entities have been saved for the map " .. game.GetMap() .. "!", 0) end


            // Save function for antighost signs
            if zclib.STM.Save("zpn_AntiGhostSigns") then zclib.Notify(ply, "AntiGhostSign entities have been saved for the map " .. game.GetMap() .. "!", 0) end


            // Save all minion spawn positions
            if zclib.STM.Save("zpn_minionspawns") then zclib.Notify(ply, "Minion spawn positions have been saved for the map " .. game.GetMap() .. "!", 0) end
        end
    elseif string.sub(string.lower(text), 1, 6) == "!candy" then

        zclib.Notify(ply, "Candy Points: " .. zpn.Candy.ReturnPoints(ply), 0)
    elseif string.sub(string.lower(text), 1, 10) == "!dropcandy" then

        local candy = string.sub(string.lower(text), 11, string.len(text))
        candy = tonumber(candy,10)

        if isnumber(candy) and candy > 0 then

            if zpn.Candy.ReturnPoints(ply) >= candy then

                // Drop Candy
        		local tr = ply:GetEyeTrace()
        		if tr.Hit and zclib.util.InDistance(tr.HitPos, ply:GetPos(), 300) then

                    zpn.Candy.TakePoints(ply,candy)
                    zpn.Candy.Notify(ply,-candy)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8

                    local ent = ents.Create("zpn_candy")
                	ent:SetPos(tr.HitPos + Vector(0,0,25))
                    ent:SetModel("models/zerochain/props_pumpkinnight/zpn_candydrop.mdl")
                	ent:Spawn()
                	ent:Activate()
                    ent:SetCandy(candy)
                    ent:SetDisplayCandy(true)
                    ent:SetModel("models/zerochain/props_pumpkinnight/zpn_candydrop.mdl")
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

					ent.CandyDropper = ply
                    ent.CandyWasDropped = true

                    // Give it some random orange color
                    ent:SetColor(HSVToColor(math.random(28,42),0.7,1))
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

                    ent.DeSpawnTime = CurTime() + 900
                else
                    zclib.Notify(ply, zpn.language.General["InvalidDropPosition"], 1)
                end
            else
                zclib.Notify(ply, zpn.language.General["NotEnoughCandy"], 1)
            end
        end
    elseif string.sub(string.lower(text), 1, 10) == "!sellcandy" then

        if zpn.config.Candy.SellValue == nil or zpn.config.Candy.SellValue <= 0 then
            zclib.Notify(ply, zpn.language.General["sellcandy_denied"], 1)
            return
        end

        local candy = string.sub(string.lower(text), 11, string.len(text))
        candy = tonumber(candy,10)

        if isnumber(candy) and candy > 0 then

            if zpn.Candy.ReturnPoints(ply) >= candy then

                zpn.Candy.TakePoints(ply,candy)

                zpn.Candy.Notify(ply,-candy)

                local money = candy * zpn.config.Candy.SellValue
                zclib.Notify(ply, "+" .. zclib.Money.Display(money), 0)
                zclib.Money.Give(ply, money)

            else
                zclib.Notify(ply, zpn.language.General["NotEnoughCandy"], 1)
            end
        end
    end
end)
