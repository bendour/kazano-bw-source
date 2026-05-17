-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

CL_HADEZ.menu = CL_HADEZ.menu or nil
CL_HADEZ.menuInitialized = false

CL_HADEZ.menuTabs = CL_HADEZ.menuTabs or {}

function CL_HADEZ:AddMenuTab(name,icon,permKey)
		self.menuTabs[name] = {icon = icon, permKey = permKey, title = SH_HADEZ:GetPermissionName(permKey)}
end

function CL_HADEZ:GetMenuTabs()
	return CL_HADEZ.menuTabs
end

function CL_HADEZ:MenuIsOpen()
	return self.menu ~= nil and self.menu:IsVisible()
end

function CL_HADEZ:ToggleMenu(forceClose)

	if !SH_HADEZ:HasAccess() then return end
	
	if forceClose or self:MenuIsOpen() then

		if self.menu ~= nil then
			
			for _, child in pairs(self.menu:GetChildren()) do
				child:Remove()
			end
		
			self.menu:Remove()
			self.menu = nil
			
		end
		
	else

		if self.menuInitialized then
			self.menu = vgui.Create("p_hadez_menu")
		else
			self.menu = vgui.Create("p_hadez_initializing")
		end
		
		-- show one-time notification if new version is available
		if !SH_HADEZ.VAR.LATESTVERSION then
		
			SH_HADEZ.VAR.LATESTVERSION = true
			
			notification.AddLegacy( SH_HADEZ.VAR.LATESTVERSIONMSG, NOTIFY_GENERIC, 15 )
			
		end
		
	end

end

local function OpenMenuByConCommand( ply, cmd, args )
	CL_HADEZ:ToggleMenu()
end
concommand.Add( "hadez_open", OpenMenuByConCommand)