include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

net.Receive("ShowTeslaRadius", function()
    local ent = net.ReadEntity()
    
    if IsValid(ent) then
        local radius = ent.Radius
        
        hook.Add("PostDrawOpaqueRenderables", "DrawTeslaRadius", function()
            if not IsValid(ent) then
                hook.Remove("PostDrawOpaqueRenderables", "DrawTeslaRadius")
                return
            end
            
            local pos = ent:GetPos()
            local color = Color(255, 255, 255)

            render.SetMaterial(Material("models/wireframe"))
            render.DrawWireframeSphere(pos, radius, 30, 30, color, true)
        end)
        
        timer.Simple(20, function()
            hook.Remove("PostDrawOpaqueRenderables", "DrawTeslaRadius")
        end)
    end
end)
