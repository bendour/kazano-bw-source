-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local function findFiles(searchQuota,searchPath,foundTbl)
	
	foundTbl = foundTbl or {}
	searchPath = searchPath or "z_hadez"
	
	local files, dirs = file.Find( searchPath.."/*", "LUA" )
	
	for i=1,#dirs do
		findFiles(searchQuota,searchPath..'/'..dirs[i],foundTbl)
	end
	
	for i=1,#files do
		
		local f = files[i]
		
		for ii=1,#searchQuota do
			
			local quota = searchQuota[ii]
			
			if string.StartWith( f, quota ) then
				table.insert(foundTbl, (quota == "sh_" and 1 or #foundTbl+1),searchPath..'/'..f)
				break
			end
		
		end
		
	end
	
	return foundTbl
	
end

local searchQuota = {}
searchQuota.priority = {"settings","vars"}
searchQuota.cl = {"sh_","cl_","p_"}
searchQuota.sv = {"sh_","sv_"}

local priorityFiles = findFiles(searchQuota.priority)
local clFiles = findFiles(searchQuota.cl)
local svFiles = findFiles(searchQuota.sv)
 
CL_HADEZ = {}
SH_HADEZ = {}
SV_HADEZ = {}
	
-- Load shared priority files first
for _,priorityFile in pairs( priorityFiles ) do
	include( priorityFile )
end

if CLIENT then

	for _,clFile in pairs( clFiles ) do
		include( clFile )
	end

end

if SERVER then 

	for _,priorityFile in pairs( priorityFiles ) do
		AddCSLuaFile( priorityFile )
	end
	
	for _,clFile in pairs( clFiles ) do
		AddCSLuaFile( clFile )
	end

	for _,svFile in pairs( svFiles ) do 
		include( svFile )
	end
	
end