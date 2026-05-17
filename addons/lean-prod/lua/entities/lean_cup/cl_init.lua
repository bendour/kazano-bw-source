include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

--[[-------------------------------------------------------------------------
Make the screen fade in-out with black
---------------------------------------------------------------------------]]
local box = (box or nil)
net.Receive("lean_sendeffects", function()
	local onlean = net.ReadBool()
	if onlean then
		box = vgui.Create("DPanel")
		box:SetSize(ScrW(),ScrH())
		box.Paint = function(self,w,h)
			draw.RoundedBox(0,0,0,w,h,Color( 0, 0, 0, math.abs(math.sin(CurTime()*2)*225) ))
		end
	else
		box:Remove()
	end
end)