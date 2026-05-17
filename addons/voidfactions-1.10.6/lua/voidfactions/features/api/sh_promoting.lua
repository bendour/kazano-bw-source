local L = VoidFactions.Lang.GetPhrase

local function loadProperties()

	properties.Add("promote", {
		MenuLabel = L"promote", -- Name to display on the context menu
		Order = 1, -- The order to display this property relative to other properties
		MenuIcon = "icon16/arrow_up.png", -- The icon to display next to the property

		Filter = function( self, ent, ply ) -- A function that determines whether an entity is valid for this property
			if ( !IsValid( ent ) ) then return false end
			if ( !ent:IsPlayer() ) then return false end
			
			local selfMember = ply:GetVFMember()
			local playerMember = ent:GetVFMember()

			if (!playerMember or !selfMember) then return false end
			if (!playerMember.rank or !selfMember.rank) then return false end

			return selfMember.rank:CanPromote(playerMember, selfMember)
		end,
		Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )

			self:MsgStart()
				net.WriteEntity( ent )
			self:MsgEnd()

		end,
		Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
			local ent = net.ReadEntity()

			if ( !properties.CanBeTargeted( ent, ply ) ) then return end
			if ( !self:Filter( ent, ply ) ) then return end

			VoidFactions.API:PromoteMember(ent:GetVFMember())
		end 
	})

	properties.Add("demote", {
		MenuLabel = L"demote", -- Name to display on the context menu
		Order = 2, -- The order to display this property relative to other properties
		MenuIcon = "icon16/arrow_down.png", -- The icon to display next to the property

		Filter = function( self, ent, ply ) -- A function that determines whether an entity is valid for this property
			if ( !IsValid( ent ) ) then return false end
			if ( !ent:IsPlayer() ) then return false end
			
			local selfMember = ply:GetVFMember()
			local playerMember = ent:GetVFMember()

			if (!playerMember or !selfMember) then return false end
			if (!playerMember.rank or !selfMember.rank) then return false end

			return selfMember.rank:CanDemote(playerMember, selfMember)
		end,
		Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )

			self:MsgStart()
				net.WriteEntity( ent )
			self:MsgEnd()

		end,
		Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
			local ent = net.ReadEntity()

			if ( !properties.CanBeTargeted( ent, ply ) ) then return end
			if ( !self:Filter( ent, ply ) ) then return end

			VoidFactions.API:DemoteMember(ent:GetVFMember())
		end 
	})

end

if (VoidFactions.Lang.LanguagesLoaded and VoidFactions.Settings.ConfigLoaded) then
	loadProperties()
else
	local bFirstCalled = VoidFactions.Lang.LanguagesLoaded or VoidFactions.Settings.ConfigLoaded

	hook.Add("VoidFactions.Lang.LanguagesLoaded", "VoidFactions.Promoting.LoadLanguages", function ()
		if (bFirstCalled) then
			loadProperties()
		end
		bFirstCalled = true
	end)

	hook.Add("VoidFactions.Settings.Loaded", "VoidFactions.Promoting.LoadSettings", function ()
		if (bFirstCalled) then
			loadProperties()
		end
		bFirstCalled = true
	end)
end