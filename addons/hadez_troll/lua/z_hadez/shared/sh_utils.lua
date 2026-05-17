-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SH_HADEZ:ParseVersionStr(verStr)
	return tonumber(string.Replace(verStr, '.', ''))
end

function SH_HADEZ:IsSteamID(str)
	return string.StartWith(str, "STEAM_")
end

-- Cheecky way to make our hook the first
function SH_HADEZ:PrioritizedAddHook(hookName, identifier, prioritizedFunc)

	hook.Add( "PostGamemodeLoaded", "z_hadez_prioritizeHook_"..hookName, function()
	
		-- Shitty workaround to avoid conflicts
		timer.Simple(10, function()
			
			local prioritizedHookName = "z_hadez_prioritized_"..hookName
			local hooks = hook.GetTable()[hookName] or {}
			
			-- Remove all hooks & add to alternate hook
			for name, func in pairs(hooks) do
				hook.Add(prioritizedHookName, name, func)
				hook.Remove(hookName, name)
			end
			
			-- Create delegator that calls prioritized func first
			local function DelegateFunc(...)
				
				local funcRes = prioritizedFunc(...)
				
				if !funcRes then
					
					-- Fix for those shitty mods that return values for no reason
					if hookName == "PlayerSay" then
					
						local args = {...}
						local text = args[2]
						local hooks = hook.GetTable()[prioritizedHookName]
						
						for name, func in pairs(hooks or {}) do
							
							local hookRes = func(...)
							-- print("checking", name, func, "res -->>"..(hookRes or "nil"), text)
							
							if hookRes ~= nil and hookRes ~= text then
								-- print("break!")
								funcRes = hookRes
								break
							end
							
						end
						
					else
						funcRes = hook.Run(prioritizedHookName, ...)
					end
					
				end
				
				return funcRes
				
			end

			-- Hook delegator
			hook.Add(hookName, identifier, DelegateFunc)
			
			-- Make sure future hooks run under the delegator
			local __oldHookAdd = hook.Add
			
			function hook.Add(name, id, func)
			
				if name == hookName then
					__oldHookAdd(prioritizedHookName, id, func)
				else
					__oldHookAdd(name, id, func)
				end
			
			end
		
		end)
	
	end)

end

function SH_HADEZ:FormatTime(time,format)
	
	local ms = string.match(tostring(time), "%d%.(%d+)")
	
	-- Taking only the first 2 digits for milliseconds
	ms = string.sub( ms || "00", 1, 2 )
	
	return os.date(format,math.max(time,0))..""..(ms || "00")

end

function SH_HADEZ:CanDrawPlayer(ply)
	return !ply:IsEffectActive(EF_NODRAW) and !ply:IsEffectActive(EF_BONEMERGE)
end

function SH_HADEZ:HookEntityFireBullets(id, func)
	
	self.entityFireBulletsHooks = self.entityFireBulletsHooks or {}
	self.entityFireBulletsHooks[id] = func
	
	local function EntityFireBullets(ent, data)
	
		local showBullet, shouldSupress
		
		for k, hookFunc in pairs(self.entityFireBulletsHooks) do
		
			showBullet, newData = hookFunc(ent, data)
			
			if newData then
				data = newData
			end
			
			if showBullet then
				shouldSupress = true
			end
		
		end
		
		if shouldSupress or showBullet then
			return shouldSupress or showBullet
		end
		
	end
	hook.Add("EntityFireBullets", "z_hadez_EntityFireBullets", EntityFireBullets)

end

function SH_HADEZ:NetWritePlayers(players)
	
	net.WriteUInt(#players,7)
	for i=1, #players do
		net.WriteEntity(players[i])
	end

end

function SH_HADEZ:NetReadPlayers()
	
	local players = {}
	local plyNum = net.ReadUInt(7)
	
	for i=1, plyNum do
		players[i] = net.ReadEntity()
	end

	return players

end

function SH_HADEZ:GetLowestPlayer()

	local plys = player.GetAll()
	local lowestData = {}
	
	
	for i=1, #plys do
	
		local ply = plys[i]
		local plyPos = ply:GetPos()
			
		if !lowestData.z or plyPos.z < lowestData.z then
			lowestData.ply = ply
			lowestData.z = plyPos.z
		end
	
	end
	
	return lowestData.ply, lowestData.z
	
end