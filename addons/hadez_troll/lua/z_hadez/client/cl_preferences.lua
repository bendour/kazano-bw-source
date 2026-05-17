-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

CL_HADEZ.preferences = CL_HADEZ.preferences or {}

local saveDataPath = "z_hadez/preferences.txt"

function CL_HADEZ:LoadPreferences()

	if file.Exists( saveDataPath, "DATA" ) then
	
		local saveData = file.Read( saveDataPath, "DATA" )
	
		self.preferences = util.JSONToTable( saveData )
	
	end

end
hook.Add("Initialize", "z_hadez_LoadPreferences", function() CL_HADEZ:LoadPreferences() end)

function CL_HADEZ:SavePreferences()

	local saveData = util.TableToJSON( self.preferences )
	
	if !file.Exists( "z_hadez", "DATA" ) then
		file.CreateDir("z_hadez")
	end
	
	file.Write( saveDataPath, saveData )

end

function CL_HADEZ:HasPreference(key)
	return self.preferences[key] ~= nil
end

function CL_HADEZ:GetPreference(key, default)

	if default ~= nil and !CL_HADEZ:HasPreference(key) then
		CL_HADEZ:SetPreference(key, default)
	end

	return self.preferences[key]
end

function CL_HADEZ:SetPreference(key, value)
	self.preferences[key] = value
	self:SavePreferences()
end