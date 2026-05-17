--[[---------------------------------------------------------
   Spraymesh module,
   Calculates a mesh of vertices to prevent textures clipping into the world
   
   Original code by: Bletotum
   Link: https://steamcommunity.com/sharedfiles/filedetails/?id=394091909
   
   Modulefied & updated by: Zombie Extinguisher
-----------------------------------------------------------]]

module( "spraymesh", package.seeall )

local res = 20 -- CPU expensive
local resM1 = res-1
local resM2 = res-2
local nextCalculateMeshVertices = 0

local function CopyVertice(vertice,u,v,norm,bNorm,tang)

	local newVertice = {
		u = u or 0,
		v = v or 0,
		normal = norm or 1,
		bitnormal = bNorm or Vector(0,0,0),
		tangent = tang or 1,
		color = vertice.color,
		pos = vertice.pos,
	}
	
	return newVertice
	
end

local function AddSquareTovertices(x,y,vertices,coords)

	local __a = coords[x+0][y+0]
	local __b = coords[x+1][y+0]
	local __c = coords[x+1][y+1]
	local __d = coords[x+0][y+1]
	
	if __a.bad then __a = coords[math.Clamp(x+1,0,resM1)][math.Clamp(y+1,0,resM1)] end
	if __b.bad then __b = coords[math.Clamp(x+0,0,resM1)][math.Clamp(y+1,0,resM1)] end
	if __c.bad then __c = coords[math.Clamp(x+0,0,resM1)][math.Clamp(y+0,0,resM1)] end
	if __d.bad then __d = coords[math.Clamp(x+1,0,resM1)][math.Clamp(y+0,0,resM1)] end
		
	local _a = CopyVertice(__a,(x+0)/resM1,1-((y+0)/resM1))
	local _b = CopyVertice(__b,(x+1)/resM1,1-((y+0)/resM1))
	local _c = CopyVertice(__c,(x+1)/resM1,1-((y+1)/resM1))
	local _d = CopyVertice(__d,(x+0)/resM1,1-((y+1)/resM1))
	
	table.insert(vertices,_a)
	table.insert(vertices,_d)
	table.insert(vertices,_c)
	table.insert(vertices,_c)
	table.insert(vertices,_b)
	table.insert(vertices,_a)
	
end
 
function CalculateMeshVertices(pos, posNormal, size, CallBack)

	-- To prevent frame stuttering
	if nextCalculateMeshVertices > CurTime() then
		
		timer.Simple(0.001, function()
			CalculateMeshVertices(pos, posNormal, size, CallBack)
		end)
		
		return
		
	end
	
	local startTime = os.clock()
	local pos = pos+posNormal
	local vertices = {}
	local coords = {}
	
	for iX = 0, resM1 do
	
		coords[iX] = {}
		
		for iY = 0, resM1 do
		
			coords[iX][iY] = {}
			
			local coord = coords[iX][iY]
			local tangang = posNormal:Angle()
			
			coord.pos = pos + (-(tangang:Right()*iX) + (tangang:Up()*iY)) * size
			coord.pos = coord.pos + (tangang:Right()*size*res/2) - (tangang:Up()*size*res/2)
			
			if !(iX == 0 && iY == 0) then
			
				local trace = util.TraceLine({
					start = coord.pos+posNormal*15,
					endpos = coord.pos-posNormal*15,
					filter = function(ent) return ent:IsWorld() end
				})
				
				if !trace.Hit or !trace.HitWorld then
				
					if iX == 0 then
						coord.pos = coords[iX][iY-1].pos
					else
						coord.pos = coords[iX-1][iY].pos
					end
					
					coord.bad = true
					
				else
					coord.pos = trace.HitPos+posNormal
				end
				
			end
			
			coord.u = 0
			coord.v = 0
			coord.bitnormal = 1
			coord.tangent = 1
			coord.normal = posNormal
			local lcol = render.GetLightColor(coord.pos)*638
			local basec = 20
			coord.color = Color(lcol.x+basec,lcol.y+basec,lcol.z+basec,255)
			
		end
		
	end
	
	for iX = 0, resM2 do
		for iY = 0, resM2 do
			AddSquareTovertices(iX,iY,vertices,coords)
		end
	end

	local calcTime = math.Round(os.clock()-startTime,3)

	nextCalculateMeshVertices = CurTime() + calcTime + 0.01

	-- DEBUG
	-- print(#vertices.." vertices created in: "..calcTime.."s")
	
	CallBack(vertices)

end