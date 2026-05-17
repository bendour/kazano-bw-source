----------- // SCRIPT BY INJ3 
----------- // SCRIPT BY INJ3 
----------- // SCRIPT BY INJ3 
---- // https://steamcommunity.com/id/Inj3/
----
local Ipr_EnableVgui_EntPost, Ipr_EnableVgui_EntPostChart, Ipr_EnableVgui_EntEsp, Ipr_Class_Count_Search, ipr_cor, Ipr_search_dlt, ipr_sort_cor = 0, 0, 0, 0
local Ipr_system_optimiser_gui, Ipr_system_optimiser_gui_ch, Ipr_model, Ipr_cust, Ipr_conv, Ipr_search, Ipr_system_optimiser_ch_d  = {}, {}, {}, {}, {}, {}, {}
local ipr_data_cl, Ipr_Sys_BlurMat, Ipr_Search_Str, ipr_mat = ipr_data_cl or {}, Material("pp/blurscreen"), "", Material("icon/ipr_sys_map_optimiser_icon.png", "noclamp smooth")

local ipr_table_global = {
    ipr_color_table = {
        ["Bleu"] = Color(44, 62, 80),
        ["Blanc"] = Color(236, 240, 241),
        ["Rouge"] = Color(192, 57, 43),
        ["Vert"] = Color(39, 174, 96),
    },
    ipr_exclude_class = {
        ["class C_Fish"] = true,
        ["class C_BaseFlex"] = true,
        ["class C_PlayerResource"] = true,
        ["viewmodel"] = true,
    },
    ipr_class_convert = {
        [1] = {ipr_n = "prop_physics", ipr_tooltip = "Modèles avec propriétés physiques intégrées. \nSe déplace et entre en collision en utilisant le système physique des corps rigides. \nPeut être contraint à d'autres objets physiques à l'aide de charnières ou d'autres contraintes. \nIl peut également être configuré pour se briser lorsqu'il subit suffisamment de dégâts. \nProjette des ombres dynamiques. \nFonctionne moins bien avec l'ensemble sv_turbophysics. \n Très coûteux en termes de ressource CPU."},
        [2] = {ipr_n = "prop_dynamic", ipr_tooltip = "Des modèles qui peuvent avoir des articulations et jouer des animations. \nPeut également être configuré pour se casser lorsqu'il subit suffisamment de dégâts. \nPeut être rattaché hiérarchiquement à d'autres objets. \nPeut projeter des ombres dynamiques. \nMoins couteux en ressource CPU que prop_physics."},
        [3] = {ipr_n = "prop_physics_multiplayer", ipr_tooltip = "Accessoires physiques utilisant un système de collision physique simplifié conçu pour les jeux multijoueurs. \nAvoir moins de surcharge réseau que les accessoires physiques standard, nécessaires pour l'environnement à bande passante limitée des jeux multijoueurs. \nFonctionne mieux avec l'ensemble sv_turbophysics."},
        [4] = {ipr_n = "prop_physics_override", ipr_tooltip = "Type d'accessoire spécial utilisé pour remplacer les propriétés intégrées au modèle. \nCoût en ressource CPU identique à un prop_physics."},
        [5] = {ipr_n = "prop_dynamic_override", ipr_tooltip = "Type de prop spécial utilisé pour convertir un modèle conçu pour être utilisé comme prop_static, et lui donnant les propriétés d'un prop_dynamic. \nCoût en ressource CPU identique à un prop_dynamic."},
    }
}

local function Ipr_returnIndex(Ipr_ent)
    if (ipr_data_cl) then
         for i = 1, #ipr_data_cl do
              if (Ipr_ent:EntIndex() == ipr_data_cl[i]["ipr_index"] and Ipr_ent:GetClass() == string.Replace(ipr_data_cl[i]["ipr_ent"], "_override", "")) then
                   return true
              end
         end
    end

    return false
end

local function Ipr_AlongRay(Ipr_Ent, Ipr_Player)
    local Ipr_EyeEnt = Ipr_Ent.Entity
    if not IsValid(Ipr_EyeEnt) then
         local Ipr_AlongRay = ents.FindAlongRay(Ipr_Ent.StartPos, Ipr_Ent.HitPos)

         if (Ipr_AlongRay) then
              for i = 1, #Ipr_AlongRay do
                   if not IsValid(Ipr_AlongRay[i]) then
                        continue
                   end
                   if ipr_table_global.ipr_exclude_class[Ipr_AlongRay[i]:GetClass()] or (Ipr_AlongRay[i] == Ipr_Player) or Ipr_AlongRay[i]:IsWeapon() then
                        continue
                   end
                   return Ipr_AlongRay[i]
              end
         end
    end

    return Ipr_EyeEnt
end

local function Ipr_Update_Line(Ipr_gui)
    for a, v in pairs(Ipr_gui:GetLines()) do
         for b, l in pairs(v.Columns) do
              if (l:GetName() == "DListView_Line") then
                   continue
              end
              
              l:SetTextColor(Color(236, 240, 241))
              l:SetFont("Ipr_System_Map_Optmiser_Font")
         end
    end
end

local function Ipr_Coroutine_Func_Search()
    while true do
        local Ipr_Entity = ents.FindByClass("*")
        for i=1, #Ipr_Entity do
            if timer.Exists("IprLoadSearchClass" ..i) then
                timer.Remove("IprLoadSearchClass" ..i)
            end
        end
        if not next(Ipr_Entity) then
            coroutine.yield()
            return
        end

        for k, v in ipairs(Ipr_Entity) do
            if not IsValid(v) or v:IsPlayer() or v:IsNPC() or (v:GetParent() and (v:GetParent():IsPlayer()) or v:ViewModelIndex()) or ipr_table_global.ipr_exclude_class[v:GetClass()] or (v.PrintName) then
               continue
            end
            local ipr_indexcall_cor = Ipr_returnIndex(v)
            if (ipr_indexcall_cor) then
               continue
            end
            if istable(CPPI) and (IsValid(v:CPPIGetOwner()) and v:CPPIGetOwner():IsPlayer()) then
               continue
            end
            if (ipr_sort_cor ~= nil) then
                local ipr_sort_cor_ = tonumber(ipr_sort_cor)
                if not (ipr_sort_cor_) then
                    if not string.find(v:GetClass():lower(), ipr_sort_cor:lower())  then
                        continue
                    end
                else
                    if not (v:EntIndex() == ipr_sort_cor_) then
                        continue
                    end
                end
            end
            local Ipr_Class, Ipr_Pos, Ipr_Dist, Ipr_Index = v:GetClass(), v:GetPos(), math.Round(LocalPlayer():GetPos():Distance(v:GetPos()), 0), v:EntIndex()
            timer.Create("IprLoadSearchClass" ..k, 0.001, 1, function()
                if not IsValid(Ipr_search) and not IsValid(v) or not IsValid(Ipr_search_dlt) then
                    return
                end
                Ipr_search_dlt:AddLine(Ipr_Class, Ipr_Pos, Ipr_Dist, Ipr_Index, v)
                Ipr_Update_Line(Ipr_search_dlt)

                Ipr_Class_Count_Search = Ipr_Class_Count_Search + 1
                coroutine.resume(ipr_cor)
            end)

            local ipr_fps_iter = math.Round(1 / RealFrameTime(), 0)
            if (ipr_fps_iter <= 10) then
                timer.Create("IprOptiWaitCoroutine" ..k, 0.2, 1, function()
                    if not ipr_cor then
                        return
                    end
                    coroutine.resume(ipr_cor)
                end)
                coroutine.yield()
            end
            coroutine.yield()
        end
        coroutine.yield()
    end
end

local function Ipr_Coroutine_Func_Chart()
    while true do
        for i=1, #ipr_data_cl do
            if timer.Exists("IprLoadSearchClass" ..i) then
                timer.Remove("IprLoadSearchClass" ..i)
            end
        end
        if (#ipr_data_cl <= 0) then
            coroutine.yield()
            return
        end

        for i = 1, #ipr_data_cl do
            timer.Create("IprLoadSearchClass" ..i, 0.001, 1, function()
                if not IsValid(Ipr_system_optimiser_ch_d) or timer.Exists("ipr_load_addline_corout") then
                    return
                end
                Ipr_system_optimiser_ch_d:AddLine(ipr_data_cl[i]["ipr_customname"], "- #"..i, ipr_data_cl[i]["ipr_ent"], ipr_data_cl[i]["ipr_pos"], ipr_data_cl[i]["ipr_admin"], ipr_data_cl[i]["ipr_model"], ipr_data_cl[i]["ipr_index"])
                Ipr_Update_Line(Ipr_system_optimiser_ch_d)
                coroutine.resume(ipr_cor)
            end)
            local ipr_fps_iter = math.Round(1 / RealFrameTime(), 0)
            if (ipr_fps_iter <= 10) then
                timer.Create("IprOptiWaitCoroutine" ..i, 0.2, 1, function()
                    if not ipr_cor then
                        return
                    end
                    coroutine.resume(ipr_cor)
                end)
                coroutine.yield()
            end
            coroutine.yield()
        end
        coroutine.yield()
    end
end

local function Ipr_Gui_Blur(Ipr_Sys_Frame, Ipr_Sys_Float, Ipr_Sys_Col, Ipr_Sys_Bord)
    local x, y = Ipr_Sys_Frame:LocalToScreen(0, 0)

    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(Ipr_Sys_BlurMat)
    for i = 1, 3 do
        Ipr_Sys_BlurMat:SetFloat("$blur", (i / 3) * Ipr_Sys_Float)
        Ipr_Sys_BlurMat:Recompute()
        render.UpdateScreenEffectTexture()
        surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
    end

    draw.RoundedBoxEx( Ipr_Sys_Bord, 0, 0, Ipr_Sys_Frame:GetWide(), Ipr_Sys_Frame:GetTall(), Ipr_Sys_Col, true, true, true, true )
end

local function Ipr_Search_Load(Ipr_sort, Ipr_gui)
     if IsValid(Ipr_gui) then
          ipr_sort_cor = Ipr_sort
          Ipr_Class_Count_Search = 0
          Ipr_gui:Clear()

          ipr_cor = coroutine.create(Ipr_Coroutine_Func_Search)
          coroutine.resume(ipr_cor)
     end
end

local function Ipr_opti_namecustom_order(Ipr_ent)
    if (ipr_data_cl and IsValid(Ipr_ent)) then
        for i = 1, #ipr_data_cl do
             if (Ipr_ent:EntIndex() == ipr_data_cl[i]["ipr_index"]) then
                  return ipr_data_cl[i]["ipr_customname"], i
             end
        end
   end

   return false
end

hook.Add("PostDrawHUD", "Ipr_opti_map:PostDraw", function()
    if (Ipr_EnableVgui_EntPost == 0) then
        return
    end
    local Ipr_Cur, Ipr_Player = CurTime(), LocalPlayer()
    if input.IsKeyDown(Improved_System_Map_Optimiser.InputKeySwitch) and (Ipr_Cur > (Ipr_Player.IprRemoveProps_DelayInput or 0)) then
        if (Ipr_EnableVgui_EntPost == 1) then
            Ipr_EnableVgui_EntPost = 2
        else
            Ipr_EnableVgui_EntPost = 1
        end
        Ipr_Player.IprRemoveProps_DelayInput = CurTime() + 0.3
    end

    local Ipr_Ent = Ipr_AlongRay(Ipr_Player:GetEyeTrace(), Ipr_Player)
    draw.DrawText("[" ..(Ipr_EnableVgui_EntPost == 1 and "Removed Props Optimiser" or "Perma Props Optimiser").. "] " .." est activé, pour le désactiver, commande dans le chat : " ..Improved_System_Map_Optimiser.Command_OpenPanel, "Ipr_System_Map_Optmiser_Font", ScrW() / 2- 300, ScrH() -50, color_white)
    if not IsValid(Ipr_Ent) then
        return
    end
    if (Ipr_Player:GetPos():DistToSqr(Ipr_Ent:GetPos() ) > 400000) then
        return
    end
    local ipr_indexcall = Ipr_returnIndex(Ipr_Ent)
    if (Ipr_EnableVgui_EntPost == 1 and (ipr_indexcall or (Ipr_Ent:IsPlayer() or (istable(CPPI) and (IsValid(Ipr_Ent:CPPIGetOwner()) and Ipr_Ent:CPPIGetOwner():IsPlayer()))))) then
        return
    end
    if (Ipr_EnableVgui_EntPost == 2 and not ipr_indexcall and (istable(CPPI) and not IsValid(Ipr_Ent:CPPIGetOwner()))) then
        return
    end

    if input.IsKeyDown(Improved_System_Map_Optimiser.InputKey) and not IsValid(Ipr_cust) and (Ipr_Cur > (Ipr_Player.IprRemoveProps_DelayInput or 0))  then
            if (Ipr_EnableVgui_EntPost == 1) then
                net.Start("ipr_optimiser_rmv")
                net.WriteUInt(1, 2)
                net.WriteEntity(Ipr_Ent)
                net.SendToServer()
            else
                if not ipr_indexcall then
                    net.Start("ipr_optimiser_rmv")
                    net.WriteUInt(2, 2)
                    net.WriteEntity(Ipr_Ent)
                    net.SendToServer()
                else
                    net.Start("ipr_optimiser_prm")
                    net.WriteUInt(3, 2)
                    net.WriteString(tostring(0,0,0))
                    net.WriteEntity(Ipr_Ent)
                    net.SendToServer()
                end
            end
            Ipr_Player.IprRemoveProps_DelayInput = CurTime() + 0.5
    end

    halo.Add({Ipr_Ent}, Improved_System_Map_Optimiser.ColorHalo_effect, 5, 5, 2 )
    draw.DrawText("[" ..(Ipr_EnableVgui_EntPost == 1 and "Removed Props" or "Perma Props").. "] : " ..Ipr_Ent:GetClass(), "Ipr_System_Map_Optmiser_Font", ScrW() / 2, ScrH() / 2, (ipr_indexcall and ipr_table_global.ipr_color_table["Rouge"] or ipr_table_global.ipr_color_table["Blanc"]), TEXT_ALIGN_CENTER)
    draw.DrawText(string.upper(input.GetKeyName(Improved_System_Map_Optimiser.InputKey)).. " pour " ..(Ipr_EnableVgui_EntPost == 1 and "Supprimer" or (ipr_indexcall and "Supprimer" or "sauvegarder")), "Ipr_System_Map_Optmiser_Font", ScrW() / 2, ScrH() / 2 + 20, (ipr_indexcall and ipr_table_global.ipr_color_table["Rouge"] or ipr_table_global.ipr_color_table["Blanc"]), TEXT_ALIGN_CENTER)
    if (Ipr_EnableVgui_EntEsp ~=  0) then
        return
    end
    local ipr_custname, ipr_order = Ipr_opti_namecustom_order(Ipr_Ent)
    if (ipr_custname) then
        draw.DrawText("Custom Name : " ..ipr_custname, "Ipr_System_Map_Optmiser_Font", ScrW() / 2, ScrH() / 2 + 40, ipr_table_global.ipr_color_table["Rouge"], TEXT_ALIGN_CENTER)
    end
    if (ipr_order) then
        draw.DrawText("Ordre : #" ..ipr_order, "Ipr_System_Map_Optmiser_Font", ScrW() / 2, ScrH() / 2 + 55, ipr_table_global.ipr_color_table["Rouge"], TEXT_ALIGN_CENTER)
    end
end)

hook.Add("HUDPaint", "Ipr_opti_map:HUDPaint", function()
    if (Ipr_EnableVgui_EntEsp ==  0) then
         return
    end
    local ipr_findbyclass = ents.FindByClass("*")
    for _,v in ipairs(ipr_findbyclass) do
         if not IsValid(v) or v:IsPlayer() or (v:GetParent() and (v:GetParent():IsPlayer() or v:GetParent():IsNPC()) or v:ViewModelIndex()) or ipr_table_global.ipr_exclude_class[v:GetClass()] then
              continue
         end
         local ipr_pos_p = v:GetPos()
         local ipr_pos = ipr_pos_p:ToScreen()
         if not ipr_pos.visible then
              continue
         end
         if (ipr_pos_p:DistToSqr(LocalPlayer():GetPos()) > Improved_System_Map_Optimiser.HUD_Class_Distance * 10000) then
            continue
         end

         local ipr_getclass, ipr_getclass_index =  v:GetClass(), v:EntIndex()
         local ipr_custname, ipr_order = Ipr_opti_namecustom_order(v)
         draw.SimpleTextOutlined("♦", "Ipr_System_Map_Optmiser_Font", ipr_pos.x, ipr_pos.y-35, ipr_table_global.ipr_color_table["Blanc"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ipr_table_global.ipr_color_table["Bleu"])
         draw.SimpleTextOutlined("Class : " ..ipr_getclass, "Ipr_System_Map_Optmiser_Font", ipr_pos.x, ipr_pos.y, ipr_table_global.ipr_color_table["Blanc"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ipr_table_global.ipr_color_table["Bleu"])
         draw.SimpleTextOutlined("ID : " ..ipr_getclass_index, "Ipr_System_Map_Optmiser_Font", ipr_pos.x, ipr_pos.y -15, ipr_table_global.ipr_color_table["Blanc"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ipr_table_global.ipr_color_table["Bleu"])
    
         if (ipr_pos_p:DistToSqr(LocalPlayer():GetPos()) < Improved_System_Map_Optimiser.HUD_Class_Distance * 5000) then
              if (ipr_custname) then
                   draw.SimpleTextOutlined("Custom Name : " ..ipr_custname, "Ipr_System_Map_Optmiser_Font", ipr_pos.x, ipr_pos.y +45, ipr_table_global.ipr_color_table["Blanc"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ipr_table_global.ipr_color_table["Bleu"])
              end
              if (ipr_order) then
                   draw.SimpleTextOutlined("Ordre : #" ..ipr_order, "Ipr_System_Map_Optmiser_Font", ipr_pos.x, ipr_pos.y +30, ipr_table_global.ipr_color_table["Blanc"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, ipr_table_global.ipr_color_table["Bleu"])
              end
         end
         if (ipr_pos_p:DistToSqr(LocalPlayer():GetPos()) < Improved_System_Map_Optimiser.HUD_Class_Distance * 2000) then
              if (v:GetParent() and v:GetParent():IsPlayer()) or v:ViewModelIndex() or istable(CPPI) and (IsValid(v:CPPIGetOwner()) and v:CPPIGetOwner():IsPlayer()) then
                   draw.DrawText("[N'appartient pas à la carte ou \n n'a pas été sauvegardé par le système.]", "Ipr_System_Map_Optmiser_Font", ipr_pos.x, ipr_pos.y + 15, ipr_table_global.ipr_color_table["Blanc"], TEXT_ALIGN_CENTER)
                   continue
              end
         end
         if (ipr_custname) then
              draw.SimpleTextOutlined("Entité sauvegardé", "Ipr_System_Map_Optmiser_Font", ipr_pos.x, ipr_pos.y +15, ipr_table_global.ipr_color_table["Blanc"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 0.5, ipr_table_global.ipr_color_table["Rouge"])
         end
    end
end)

local function Ipr_Convert(tbl_)
    if IsValid(Ipr_search) then
        Ipr_search:Remove()
    end
    if IsValid(Ipr_system_optimiser_gui_ch) then
        Ipr_system_optimiser_gui_ch:Remove()
    end
    if IsValid(Ipr_model) then
        Ipr_model:Remove()
    end
    if IsValid(Ipr_cust) then
        Ipr_cust:Remove()
    end
    if IsValid(Ipr_conv) then
        Ipr_conv:Remove()
    end

    Ipr_conv = vgui.Create( "DFrame" )
    local Ipr_conv_ds = vgui.Create( "DScrollPanel", Ipr_conv)
    local Ipr_conv_a = vgui.Create( "DCheckBoxLabel", Ipr_conv)
    local Ipr_conv_b = vgui.Create( "DCheckBoxLabel", Ipr_conv)
    local Ipr_conv_c = vgui.Create("DButton", Ipr_conv)
    local Ipr_conv_cls = vgui.Create("DImageButton", Ipr_conv)
    if IsValid(Ipr_system_optimiser_gui) then
        Ipr_system_optimiser_gui:SetPos(ScrW()/2-275, ScrH()/2-180 )
    end

    Ipr_conv:SetTitle( "" )
    Ipr_conv:SetSize(260, 260)
    Ipr_conv:Center()
    Ipr_conv:MakePopup()
    Ipr_conv:ShowCloseButton(false)
    Ipr_conv:SetDraggable(true)
    Ipr_conv:AlphaTo(5, 0, 0)
    Ipr_conv:AlphaTo(255, 1, 0)
    Ipr_conv.Paint = function( self, w, h )
        Ipr_Gui_Blur(self, 2, Color( 0, 0, 0, 170 ), 8)

        draw.RoundedBox( 6, 0, 0, w, 20, Color(52, 73, 94))
        draw.SimpleText("Options de conversion Perma Props","Ipr_System_Map_Optmiser_Font",w/2,1, color_white, TEXT_ALIGN_CENTER)
        draw.SimpleText("Convertir la classe d'entité : ","Ipr_System_Map_Optmiser_Font",w/2,30, color_white, TEXT_ALIGN_CENTER)
    end
    Ipr_conv.Think = function()
        if IsValid(Ipr_system_optimiser_gui) then
            local x, y = Ipr_system_optimiser_gui:GetPos()
            if IsValid(Ipr_conv) then
                Ipr_conv:SetPos(x + 295, y + 105)
            end
        end
    end

    Ipr_conv_ds:Dock(FILL)
    Ipr_conv_ds:DockMargin(-8, 25, 0, 100)
    local Ipr_map_convert_Vbar = Ipr_conv_ds:GetVBar()
    function Ipr_map_convert_Vbar:Paint(w, h)
    end
    function Ipr_map_convert_Vbar.btnUp:Paint(w, h)
        draw.RoundedBox(3, 0, 0, w, h, Color(52, 73, 94))
    end
    function Ipr_map_convert_Vbar.btnDown:Paint(w, h)
        draw.RoundedBox(3, 0, 0, w, h, Color(52, 73, 94))
    end
    function Ipr_map_convert_Vbar.btnGrip:Paint(w, h)
        draw.RoundedBox(3, 0, 0, w, h, Color(52, 73, 94))
    end

    local Ipr_System_Map_CheckboxTbl = {}
do
    local function ipr_override(gui)
        for _, v in ipairs(gui:GetChildren()) do
            if (v:GetName() == "DCheckBox") then
                v.Paint = function(self, w, h)
                    draw.RoundedBox( 6, 0, 0, w, h, self:GetChecked() and ipr_table_global.ipr_color_table["Vert"] or ipr_table_global.ipr_color_table["Rouge"] )
                    draw.RoundedBox( 12, 7, 7, 2, 2, self:GetChecked() and ipr_table_global.ipr_color_table["Blanc"] or color_black )
                end
            end
        end
    end

    for i = 1, #ipr_table_global.ipr_class_convert do
        local Ipr_map_convert_dhcb = vgui.Create( "DCheckBoxLabel", Ipr_conv_ds)
        Ipr_map_convert_dhcb:SetPos( 10, i * (1+ 22) -22)
        Ipr_map_convert_dhcb:SetFont("Ipr_System_Map_Optmiser_Font")
        Ipr_map_convert_dhcb:SetText(ipr_table_global.ipr_class_convert[i].ipr_n)
        Ipr_map_convert_dhcb:SetValue( (tbl_.ipr_ent == ipr_table_global.ipr_class_convert[i].ipr_n) and true or false)
        Ipr_map_convert_dhcb:SetTooltip(ipr_table_global.ipr_class_convert[i].ipr_tooltip)
        Ipr_map_convert_dhcb:SetTextColor(color_white)
        Ipr_map_convert_dhcb:SizeToContents()
        Ipr_map_convert_dhcb.OnChange = function(self, val)
            if not self:GetChecked() then
                self:SetChecked(true)
            end
            for _, v in pairs(Ipr_System_Map_CheckboxTbl) do
                if (self == v) then
                   continue
                end
                if (v:GetChecked()) then
                    v:SetChecked(false)
                end
            end
        end
        table.insert(Ipr_System_Map_CheckboxTbl,  Ipr_map_convert_dhcb)
        ipr_override(Ipr_map_convert_dhcb)
        end


    Ipr_conv_a:SetPos( 32, 174)
    Ipr_conv_a:SetText("")
    Ipr_conv_a:SetValue(tbl_.ipr_freeze)
    Ipr_conv_a:SetTextColor(color_white)
    Ipr_conv_a:SetWide(200)
    function Ipr_conv_a:Paint(w, h)
        draw.SimpleText("Geler l'entité à l'apparition", "Ipr_System_Map_Optmiser_Font", w / 2 - 2, -1, color_white, TEXT_ALIGN_CENTER)
    end
    ipr_override(Ipr_conv_a)

    Ipr_conv_b:SetPos( 32, 200)
    Ipr_conv_b:SetText("")
    Ipr_conv_b:SetValue(tbl_.ipr_shadow)
    Ipr_conv_b:SetTextColor(color_white)
    Ipr_conv_b:SetWide(200)
    function Ipr_conv_b:Paint(w, h)
        draw.SimpleText("Dessiner l'ombre de l'entité", "Ipr_System_Map_Optmiser_Font", w / 2 - 1, -1, color_white, TEXT_ALIGN_CENTER)
    end
    ipr_override(Ipr_conv_b)
end

    Ipr_conv_cls:SetPos(241, 2)
    Ipr_conv_cls:SetSize(17, 17)
    Ipr_conv_cls:SetImage("icon16/cross.png")
    function Ipr_conv_cls:Paint(w, h) end
    Ipr_conv_cls.DoClick = function()
        if IsValid(Ipr_system_optimiser_gui) then
            Ipr_system_optimiser_gui:SetPos(ScrW()/2-160, ScrH()/2-180  )
        end

        Ipr_conv:Remove()
    end

    Ipr_conv_c:SetPos(30, 230)
    Ipr_conv_c:SetSize(190, 18)
    Ipr_conv_c:SetText("")
    Ipr_conv_c:SetImage( "icon16/table_relationship.png" )
    function Ipr_conv_c:Paint(w, h)
        if self:IsHovered() then
            draw.RoundedBox( 6, 0, 0, w, h, Color(102, 73, 94))
        else
            draw.RoundedBox( 6, 0, 0, w, h, Color(52, 73, 94))
        end
        draw.SimpleText("Sauvegarder la conversion", "Ipr_System_Map_Optmiser_Font", w / 2 + 9, 0, color_white, TEXT_ALIGN_CENTER)
    end
    Ipr_conv_c.DoClick = function()
        local p, u, l = "", Ipr_conv_a:GetChecked(), Ipr_conv_b:GetChecked()
        for _, v in pairs(Ipr_System_Map_CheckboxTbl) do
            if v:GetChecked() then
                p = v:GetText()
            end
        end

        net.Start("ipr_optimiser_convert")
        net.WriteString(p)
        net.WriteBool(u)
        net.WriteBool(l)
        net.SendToServer()

        if IsValid(Ipr_system_optimiser_gui) then
            Ipr_system_optimiser_gui:SetPos(ScrW()/2-160, ScrH()/2-180  )
        end
        Ipr_conv:Remove()
    end
end
    
local function Ipr_SearchClass()
    if IsValid(Ipr_search) then
        Ipr_search:Remove()
    end
    if IsValid(Ipr_system_optimiser_gui_ch) then
        Ipr_system_optimiser_gui_ch:Remove()
    end
    if IsValid(Ipr_model) then
        Ipr_model:Remove()
    end
    if IsValid(Ipr_cust) then
        Ipr_cust:Remove()
    end
    if IsValid(Ipr_conv) then
        Ipr_conv:Remove()
    end

    Ipr_search = vgui.Create("DFrame")
    local Ipr_search_dlt_a = vgui.Create("DImageButton", Ipr_search)
    local Ipr_search_dlt_b = vgui.Create("DTextEntry", Ipr_search)
    local Ipr_search_dlt_cls = vgui.Create("DImageButton", Ipr_search)
    local Ipr_search_dlt_r = vgui.Create("DImageButton", Ipr_search)
    local Ipr_search_dlt_s = vgui.Create("DImageButton", Ipr_search)
    Ipr_search_dlt = vgui.Create( "DListView", Ipr_search)
    if IsValid(Ipr_system_optimiser_gui) then
        Ipr_system_optimiser_gui:SetPos(ScrW()/2-275, ScrH()/2-180 )
    end

    local Ipr_Entity = ents.FindByClass("*")
    Ipr_search:SetTitle("")
    Ipr_search:SetSize(340, 300)
    Ipr_search:SetPos(0, 0)
    Ipr_search:MakePopup()
    Ipr_search:ShowCloseButton(false)
    Ipr_search:SetDraggable(true)
    Ipr_search.Paint = function(self, w, h)
        Ipr_Gui_Blur(self, 1, Color(0, 0, 0, 170), 8)
        draw.RoundedBox(6, 0, 0, w, 26, Color(52, 73, 94))
        draw.SimpleText("Rechercher une classe objet dans votre carte", "Ipr_System_Map_Optmiser_Font", w / 2, 5, color_white, TEXT_ALIGN_CENTER)
        draw.SimpleText("Classes détectées : "..Ipr_Class_Count_Search, "Ipr_System_Map_Optmiser_Font", w / 2, h-20, color_white, TEXT_ALIGN_CENTER)
        local Ipr_Status = "Arrêt"
        for i=1, #Ipr_Entity do
            if timer.Exists("IprLoadSearchClass" ..i) then
                Ipr_Status = "Recherche en cours.."
            end
        end
        draw.SimpleText("Status : " ..Ipr_Status, "Ipr_System_Map_Optmiser_Font", w/2-55, 50, color_white, TEXT_ALIGN_LEFT)
    end
    Ipr_search.Think = function()
        if IsValid(Ipr_system_optimiser_gui) then
            local x, y = Ipr_system_optimiser_gui:GetPos()
            if IsValid(Ipr_search) then
                Ipr_search:SetPos(x + 295, y + 75)
            end
        end
    end

    Ipr_search_dlt_b:SetPos(25, 35)
    Ipr_search_dlt_b:SetSize(75, 20)
    Ipr_search_dlt_b.Ipr_MaxChar = 50
    Ipr_search_dlt_b:SetFont("Ipr_System_Map_Optmiser_Font")
    Ipr_search_dlt_b:SetPlaceholderText("Entité/ID..")
    Ipr_search_dlt_b.OnGetFocus = function(self)
        if (Ipr_search_dlt_b:GetText() == "Entité/ID..") then
            self:SetTextColor(Color(0, 0, 0, 255))
            self:SetFont("Ipr_System_Map_Optmiser_Font")
            self:SetPlaceholderText("")
        end
    end
    Ipr_search_dlt_b.OnTextChanged = function(self)
        local ipr_texte = self:GetValue()
        local ipr_nombre = utf8.len(ipr_texte)

        if (ipr_nombre > self.Ipr_MaxChar) then
            self.Ipr_OldTextVal = self.Ipr_OldTextVal or self:GetValue() or ""

            self:SetText(self.Ipr_OldTextVal)
            self:SetValue(self.Ipr_OldTextVal)
        else
            self.Ipr_OldTextVal = ipr_texte
        end
    end
    Ipr_search_dlt_b.OnEnter = function()
        Ipr_Search_Str = Ipr_search_dlt_b:GetValue()
        if (Ipr_Search_Str == "") then
            chat.AddText(color_white, "Veuillez spécifier un ID/entité dans la case de recherche !")
            return 
        end
        Ipr_Search_Load(Ipr_Search_Str, Ipr_search_dlt)
    end

    Ipr_search_dlt:SetPos(20, 70)
    Ipr_search_dlt:SetSize(300, 205)
    Ipr_search_dlt:AddColumn("Entités"):SetWidth(20)
    Ipr_search_dlt:AddColumn("Position"):SetWidth(20)
    Ipr_search_dlt:AddColumn("Distance"):SetWidth(20)
    Ipr_search_dlt:AddColumn("ID"):SetWidth(15)
    Ipr_search_dlt:SetMultiSelect(false)
    function Ipr_search_dlt:Paint(w, h)
        draw.RoundedBox( 6, 0, 3, w, h, Color( 255, 255, 255, 100 ) )
    end
    Ipr_search_dlt.OnRowSelected = function( panel, rowIndex, row )
        local Ipr_Derma = DermaMenu()
        if not IsValid(Ipr_Derma) then
            return
        end
        local Ipr_Sys_Derma_Sub, Ipr_Sys_Derma_Parent = Ipr_Derma:AddSubMenu("Supprimer de la carte")
        Ipr_Sys_Derma_Parent:SetIcon("icon16/cut_red.png")

        local Ipr_Sys_Derma_Option_1 = Ipr_Sys_Derma_Sub:AddOption( "Supprimer " ..row:GetValue(1), function()
            net.Start("ipr_optimiser_data")
            net.WriteUInt(0, 3)
            net.WriteEntity(row:GetValue(5))
            net.SendToServer()
          timer.Simple(0.1, function()
            Ipr_Search_Load(Ipr_Search_Str, Ipr_search_dlt)
          end)
        end)
        Ipr_Sys_Derma_Option_1:SetIcon("icon16/cut_red.png")
        Ipr_Derma:AddSpacer()

        local Ipr_Sys_Derma_Sub_, Ipr_Sys_Derma_Parent_ = Ipr_Derma:AddSubMenu("Téléporter vers l'object")
        Ipr_Sys_Derma_Parent_:SetIcon("icon16/cut.png")

        local Ipr_Sys_Derma_Option_1 = Ipr_Sys_Derma_Sub_:AddOption( "Téléporter vers " ..row:GetValue(1), function()
            net.Start("ipr_optimiser_custcmd")
            net.WriteUInt(3, 4)
            net.WriteString(tostring(row:GetValue(2)))
            net.WriteString("")
            net.SendToServer()
        end)
        Ipr_Sys_Derma_Option_1:SetIcon("icon16/cut.png")
        Ipr_Derma:Open()
    end

    for k in pairs(Ipr_search_dlt.Columns) do
        Ipr_search_dlt.Columns[k].Header:SetTextColor(Color(255, 255, 255))
        Ipr_search_dlt.Columns[k].Header:SetFont("Ipr_System_Map_Optmiser_Font")
        Ipr_search_dlt.Columns[k].Header.Paint = function(self, w, h) draw.RoundedBox( 6, 0, 0, w, h, Color(52,73,94)) end
    end
    Ipr_search_dlt:GetChildren()[6].btnGrip.Paint = function(self, w, h) draw.RoundedBox( 3, 0, 0, w, h, Color(52,73,94)) end
    Ipr_search_dlt:GetChildren()[6].btnUp.Paint = function(self, w, h) draw.RoundedBox( 5, 0, 0, w, h, Color(52,73,94)) end
    Ipr_search_dlt:GetChildren()[6].btnDown.Paint = function(self, w, h) draw.RoundedBox( 5, 0, 0, w, h, Color(52,73,94)) end
    Ipr_search_dlt:GetChildren()[6].Paint = function() end
    Ipr_search_dlt:GetChildren()[6]:SetHideButtons( true )
    Ipr_search_dlt.Paint = function() end

    timer.Create("ipr_load_searchclss", 0.1, 1, function()
    Ipr_Search_Load(nil, Ipr_search_dlt)
    end)

    Ipr_search_dlt_a:SetPos(107, 30)
    Ipr_search_dlt_a:SetSize(60, 17)
    Ipr_search_dlt_a:SetText("")
    function Ipr_search_dlt_a:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(52, 73, 94))
        draw.SimpleText("Valider ", "Ipr_System_Map_Optmiser_Font", w / 2 + 1, 1, color_white, TEXT_ALIGN_CENTER)
    end
    Ipr_search_dlt_a.DoClick = function()
        Ipr_Search_Str = Ipr_search_dlt_b:GetValue()
        if (Ipr_Search_Str == "") then
            chat.AddText(color_white, "Veuillez spécifier un ID/entité dans la case de recherche !")
            return 
        end
        Ipr_Search_Load(Ipr_Search_Str, Ipr_search_dlt)
    end

    Ipr_search_dlt_r:SetPos(172, 30)
    Ipr_search_dlt_r:SetSize(60, 17)
    Ipr_search_dlt_r:SetText("")
    function Ipr_search_dlt_r:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(52, 73, 94))
        draw.SimpleText("Reset", "Ipr_System_Map_Optmiser_Font", w / 2 + 1, 1, color_white, TEXT_ALIGN_CENTER)
    end
    Ipr_search_dlt_r.DoClick = function()
        if IsValid(Ipr_search_dlt_b) then
        Ipr_search_dlt_b:SetText("")
        Ipr_search_dlt_b:SetPlaceholderText("Entité/ID..")
        end
        Ipr_Search_Load(nil, Ipr_search_dlt)
    end

    Ipr_search_dlt_s:SetPos(237, 30)
    Ipr_search_dlt_s:SetSize(60, 17)
    Ipr_search_dlt_s:SetText("")
    function Ipr_search_dlt_s:Paint(w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(52, 73, 94))
        draw.SimpleText("Stop", "Ipr_System_Map_Optmiser_Font", w / 2 + 1, 1, color_white, TEXT_ALIGN_CENTER)
    end
    Ipr_search_dlt_s.DoClick = function()
        local Ipr_Entity = ents.FindByClass("*")
        for k, v in ipairs(Ipr_Entity) do
            if timer.Exists("IprLoadSearchClass" ..k) then
                timer.Remove("IprLoadSearchClass" ..k)
            end
        end
    end

    Ipr_search_dlt_cls:SetPos(320, 5)
    Ipr_search_dlt_cls:SetSize(17, 17)
    Ipr_search_dlt_cls:SetImage("icon16/cross.png")
    function Ipr_search_dlt_cls:Paint(w, h) end
    Ipr_search_dlt_cls.DoClick = function()
        if IsValid(Ipr_system_optimiser_gui) then
            Ipr_system_optimiser_gui:SetPos(ScrW()/2-160, ScrH()/2-180  )
        end
        Ipr_search:Remove()
    end
end

local function Ipr_DText(ent_vector, row, row_)
    if IsValid(Ipr_cust) then
        Ipr_cust:Remove()
    end
    Ipr_cust = vgui.Create("DFrame")
    local Ipr_cust_a = vgui.Create("DTextEntry", Ipr_cust)
    local Ipr_cust_b = vgui.Create("DButton", Ipr_cust)
    local Ipr_cust_cls = vgui.Create("DImageButton", Ipr_cust)

    Ipr_cust:SetTitle("")
    Ipr_cust:SetSize(250, 95)
    Ipr_cust:SetPos(0, 0)
    Ipr_cust:MakePopup()
    Ipr_cust:ShowCloseButton(false)
    Ipr_cust:SetDraggable(true)
    Ipr_cust.Paint = function(self, w, h)
        Ipr_Gui_Blur(self, 1, Color(0, 0, 0, 170), 8)
        draw.RoundedBox(6, 0, 0, w, 26, Color(52, 73, 94))
        draw.SimpleText("Nom Custom " ..row_, "Ipr_System_Map_Optmiser_Font", w / 2, 4, color_white, TEXT_ALIGN_CENTER)
    end

    Ipr_cust_a:SetPos(25, 35)
    Ipr_cust_a:SetSize(205, 25)
    Ipr_cust_a.Ipr_MaxChar = 20
    Ipr_cust_a:SetFont("Ipr_System_Map_Optmiser_Font")
    Ipr_cust_a:SetPlaceholderText("Inscrire le nom custom")
    Ipr_cust_a.OnGetFocus = function(self)
        if (Ipr_cust_a:GetText() == "Inscrire le nom custom") then
            self:SetTextColor(Color(0, 0, 0, 255))
            self:SetFont("Ipr_System_Map_Optmiser_Font")
            self:SetPlaceholderText("")
        end
    end
    Ipr_cust_a.OnTextChanged = function(self)
        local ipr_texte = self:GetValue()
        local ipr_nombre = utf8.len(ipr_texte)

        if (ipr_nombre >= self.Ipr_MaxChar) then
            self.ipr_OldTextValue = self.ipr_OldTextValue or self:GetValue() or ""

            self:SetText(self.ipr_OldTextValue)
            self:SetValue(self.ipr_OldTextValue)
        else
            self.ipr_OldTextValue = ipr_texte
        end
    end

    Ipr_cust_cls:SetPos(230, 5)
    Ipr_cust_cls:SetSize(17, 17)
    Ipr_cust_cls:SetImage("icon16/cross.png")
    function Ipr_cust_cls:Paint(w, h)
    end
    Ipr_cust_cls.DoClick = function()
        Ipr_cust:Remove()
    end

    Ipr_cust_b:SetPos(95, 70)
    Ipr_cust_b:SetSize(60, 17)
    Ipr_cust_b:SetText("")
    function Ipr_cust_b:Paint(w, h)
        draw.RoundedBox(2, 0, 0, w, 26, Color(52, 73, 94))
        draw.SimpleText("Valider ", "Ipr_System_Map_Optmiser_Font", w / 2 + 1, 1, color_white, TEXT_ALIGN_CENTER)
    end
    Ipr_cust_b.DoClick = function()
        local ipr_valsend = Ipr_cust_a:GetValue()
        Ipr_cust:Remove()

        if (ipr_valsend ~= "") then
            if IsValid(Ipr_cust_a) and IsValid(row) then
                net.Start("ipr_optimiser_custcmd")
                net.WriteUInt(Ipr_EnableVgui_EntPostChart, 4)
                net.WriteString(tostring(ent_vector))
                net.WriteString(ipr_valsend)
                net.SendToServer()

                row:SetColumnText(1, ipr_valsend)
            end
        end
    end
end

local function Ipr_Dmodel(ipr_model, ipr_ent, ipr_odr)
    if IsValid(Ipr_model) then
        Ipr_model:Remove()
    end
    Ipr_model = vgui.Create("DFrame")
    local Ipr_model_cls = vgui.Create("DImageButton", Ipr_model)
    local Ipr_model_a = vgui.Create("DAdjustableModelPanel", Ipr_model)

    Ipr_model:SetTitle("")
    Ipr_model:SetSize(150, 150)
    Ipr_model:SetPos(0, 0)
    Ipr_model:MakePopup()
    Ipr_model:ShowCloseButton(false)
    Ipr_model:SetDraggable(true)
    Ipr_model.Paint = function(self, w, h)
        Ipr_Gui_Blur(self, 1, Color(0, 0, 0, 170), 8)
        draw.RoundedBox(6, 0, 0, w, 26, Color(52, 73, 94))
        draw.SimpleText("3d Model " .. ipr_odr,"Ipr_System_Map_Optmiser_Font",w / 2,4,color_white,TEXT_ALIGN_CENTER)
        draw.SimpleText(ipr_ent, "Ipr_System_Map_Optmiser_Font", w / 2, h - 20, color_white, TEXT_ALIGN_CENTER)
        if (ipr_model == "") then
            draw.DrawText("[Ce model ne peut \n pas être affiché]", "Ipr_System_Map_Optmiser_Font", w/2, h/2 - 10, ipr_table_global.ipr_color_table["Rouge"], TEXT_ALIGN_CENTER)
        end
    end

    if (ipr_model ~= "") then
        Ipr_model_a:SetPos(0, 27)
        Ipr_model_a:SetSize(175, 97)
        Ipr_model_a:SetModel(ipr_model)
        Ipr_model_a.LoadIcon_Show = function(self)
            self.aLookAngle = Angle(-25, 2, 0)
            self.vCamPos = Vector(-73, -3, -4) * 2
        end
        function Ipr_model_a:LayoutEntity(Entity)
            return
        end
        Ipr_model_a:LoadIcon_Show()
    end

    Ipr_model_cls:SetPos(130, 5)
    Ipr_model_cls:SetSize(17, 17)
    Ipr_model_cls:SetImage("icon16/cross.png")
    function Ipr_model_cls:Paint(w, h)
    end
    Ipr_model_cls.DoClick = function()
        Ipr_model:Remove()
    end
end
 
local function Ipr_Chart(Ipr_tbl)
    if IsValid(Ipr_search) then
        Ipr_search:Remove()
    end
    if IsValid(Ipr_conv) then
        Ipr_conv:Remove()
    end
    Ipr_system_optimiser_gui_ch = vgui.Create( "DFrame" )
    Ipr_system_optimiser_ch_d = vgui.Create( "DListView", Ipr_system_optimiser_gui_ch)
    local Ipr_system_optimiser_ch_a = vgui.Create("DButton", Ipr_system_optimiser_gui_ch)
    local Ipr_system_optimiser_ch_cls = vgui.Create("DImageButton", Ipr_system_optimiser_gui_ch)

    Ipr_system_optimiser_ch_d:Clear()

    Ipr_system_optimiser_gui_ch:SetTitle( "" )
    Ipr_system_optimiser_gui_ch:SetSize( 400, 300)
    Ipr_system_optimiser_gui_ch:SetPos(0, 0)
    Ipr_system_optimiser_gui_ch:MakePopup()
    Ipr_system_optimiser_gui_ch:ShowCloseButton(false)
    Ipr_system_optimiser_gui_ch:SetDraggable(true)
    Ipr_system_optimiser_gui_ch.Paint = function( self, w, h )
        Ipr_Gui_Blur(self, 1, Color( 0, 0, 0, 170 ), 8)
        draw.RoundedBox( 6, 0, 0, w, 26, Color(52,73,94))
        draw.SimpleText("Improved System Map Optimiser","Ipr_System_Map_Optmiser_Font",w/2,4, color_white, TEXT_ALIGN_CENTER)
        draw.SimpleText( (Ipr_EnableVgui_EntPostChart == 2 and "Removed Props Optimiser" or "Perma Props Optimiser") ,"Ipr_System_Map_Optmiser_Font",w/2,35, Color(255,0,0), TEXT_ALIGN_CENTER)
        draw.SimpleText( "Entités permanentes " ..(Ipr_EnableVgui_EntPostChart == 2 and "supprimées" or "sauvegardés").. " : " ..#Ipr_tbl,"Ipr_System_Map_Optmiser_Font",w/2,h-23, color_white, TEXT_ALIGN_CENTER)

        if timer.Exists("ipr_load_addline_corout") then
            draw.SimpleText("Veuillez patientez...", "Ipr_System_Map_Optmiser_Font", w / 2, h/2+20, color_white, TEXT_ALIGN_CENTER)
            return
        end
        if (#Ipr_tbl <= 0) then
            draw.SimpleText("Aucune entité sauvegardée", "Ipr_System_Map_Optmiser_Font", w / 2, h/2+20, color_white, TEXT_ALIGN_CENTER)
        end
    end
    Ipr_system_optimiser_gui_ch.Think = function()
        if IsValid(Ipr_system_optimiser_gui) then
            local x, y = Ipr_system_optimiser_gui:GetPos()
            if IsValid(Ipr_model) then
                Ipr_model:SetPos(x + 295, y - 10)
                Ipr_system_optimiser_gui_ch:SetPos(x + 295, y + 160)
                if IsValid(Ipr_cust) then
                    Ipr_cust:SetPos(x + 460, y + 45)
                end
            else
                Ipr_system_optimiser_gui_ch:SetPos(x + 295, y + 75)
            end
            if IsValid(Ipr_cust) and not IsValid(Ipr_model) then
                Ipr_cust:SetPos(x + 295, y + 10)
                Ipr_system_optimiser_gui_ch:SetPos(x + 295, y + 130)
            end
        end
    end

    Ipr_system_optimiser_ch_d:SetPos(20, 60)
    Ipr_system_optimiser_ch_d:SetSize(363, 205)
    Ipr_system_optimiser_ch_d:AddColumn("Nom Custom"):SetWidth(70)
    Ipr_system_optimiser_ch_d:AddColumn("Ordre"):SetWidth(15)
    Ipr_system_optimiser_ch_d:AddColumn("Entités"):SetWidth(50)
    Ipr_system_optimiser_ch_d:AddColumn("Position"):SetWidth(40)
    Ipr_system_optimiser_ch_d:AddColumn("Admin"):SetWidth(35)
    Ipr_system_optimiser_ch_d:SetMultiSelect(false)
    function Ipr_system_optimiser_ch_d:Paint(w, h)
        draw.RoundedBox( 6, 0, 3, w, h, Color( 255, 255, 255, 100 ) )
    end
    Ipr_system_optimiser_ch_d.OnRowSelected = function( panel, rowIndex, row )
        local Ipr_Derma = DermaMenu()
        if not IsValid(Ipr_Derma) then
            return
        end
        local ipr_vector, ipr_entrow = row:GetValue(4), row:GetValue(3)
        local index = (Ipr_EnableVgui_EntPostChart == 1) and " - ID:" ..row:GetValue(7) or ""

        local Ipr_Sys_Derma_Sub, Ipr_Sys_Derma_Parent = Ipr_Derma:AddSubMenu("Supprimer de la liste")
        Ipr_Sys_Derma_Parent:SetIcon("icon16/cut_red.png")

        local Ipr_Sys_Derma_Option_1 = Ipr_Sys_Derma_Sub:AddOption( "Supprimer" ..row:GetValue(2), function()
            net.Start("ipr_optimiser_prm")
            net.WriteUInt(Ipr_EnableVgui_EntPostChart, 2)
            net.WriteString(tostring(ipr_vector))
            net.WriteString(ipr_entrow)
            net.SendToServer()
        if IsValid(panel) then
            panel:RemoveLine(rowIndex)
            for k, v in pairs(panel:GetChildren()) do
                if (v:GetName() == "DVScrollBar") then
                   v:AnimateTo(v:GetScroll(), 0, 0.5, -1)
                end
            end
        end
        if IsValid(Ipr_cust) then
         Ipr_cust:Remove()
        end
        if IsValid(Ipr_model) then
         Ipr_model:Remove()
        end
            if (Ipr_EnableVgui_EntPostChart == 2) then
                chat.AddText(color_white, "[", "Improved System Map Optimiser", "] : ", color_white, "Veuillez Clean UP, ou redémarrer pour faire apparaitre de nouveau les entités du remove props")
            end
        end)
        Ipr_Sys_Derma_Option_1:SetIcon("icon16/cut_red.png")
        Ipr_Derma:AddSpacer()

        local Ipr_SysPos_Optiond = Ipr_Derma:AddOption("Visualiser l'object" ..index, function()
            Ipr_Dmodel(row:GetValue(6), ipr_entrow, row:GetValue(2))
        end)
        Ipr_SysPos_Optiond:SetIcon("icon16/eye.png")
        Ipr_Derma:AddSpacer()

        local Ipr_Sys_Derma_Sub_, Ipr_Sys_Derma_Parent_ = Ipr_Derma:AddSubMenu("Téléporter vers l'object")
        Ipr_Sys_Derma_Parent_:SetIcon("icon16/cut.png")

        local Ipr_Sys_Derma_Option_1 = Ipr_Sys_Derma_Sub_:AddOption( "Téléporter vers" ..row:GetValue(2).. " - " ..ipr_entrow, function()
            net.Start("ipr_optimiser_custcmd")
            net.WriteUInt(3, 4)
            net.WriteString(tostring(ipr_vector))
            net.WriteString("")
            net.SendToServer()
        end)
        Ipr_Sys_Derma_Option_1:SetIcon("icon16/cut.png")
        Ipr_Derma:AddSpacer()

        local Ipr_SysPos_Optionc = Ipr_Derma:AddOption("Renommer le Nom Custom", function()
            Ipr_DText(ipr_vector, row, row:GetValue(2))
        end)
        Ipr_SysPos_Optionc:SetIcon("icon16/pencil.png")

        if (Ipr_EnableVgui_EntPostChart == 1) then

         if not ipr_table_global.ipr_exclude_class[ipr_entrow] then
            Ipr_Derma:AddSpacer()
            local Ipr_Sys_Derma_Sub_y, Ipr_Sys_Derma_Parent_o = Ipr_Derma:AddSubMenu("Convertir la classe")
            Ipr_Sys_Derma_Parent_o:SetIcon("icon16/textfield_rename.png")

            for i=1, #ipr_table_global.ipr_class_convert do
                if (ipr_table_global.ipr_class_convert[i].ipr_n == ipr_entrow) then 
                    continue
                end
                local Ipr_Sys_Derma_Option_4 = Ipr_Sys_Derma_Sub_y:AddOption( "Convertir en " ..ipr_table_global.ipr_class_convert[i].ipr_n, function()
                    row:SetColumnText(3, ipr_table_global.ipr_class_convert[i].ipr_n)

                    net.Start("ipr_optimiser_custcmd")
                    net.WriteUInt(5, 4)
                    net.WriteString(tostring(ipr_vector))
                    net.WriteString(ipr_table_global.ipr_class_convert[i].ipr_n)
                    net.WriteBool(nil)
                    net.SendToServer()
                end)
                Ipr_Sys_Derma_Option_4:SetIcon("icon16/textfield_rename.png")
                Ipr_Sys_Derma_Sub_y:AddSpacer()
            end
          end
            Ipr_Derma:AddSpacer()

            local Ipr_Sys_Derma_Sub_1, Ipr_Sys_Derma_Parent_1 = Ipr_Derma:AddSubMenu("Ombre de l'entité".. " " ..((Ipr_tbl[rowIndex]["ipr_v_shadow"] and "(Actif)") or "(Inactif)") or "".. ")")
            Ipr_Sys_Derma_Parent_1:SetIcon("icon16/shape_group.png")
            local Ipr_Sys_Derma_Option_3 = Ipr_Sys_Derma_Sub_1:AddOption( "Afficher l'ombre", function()
                net.Start("ipr_optimiser_custcmd")
                net.WriteUInt(6, 4)
                net.WriteString(tostring(ipr_vector))
                net.WriteString("")
                net.WriteBool(true)
                net.SendToServer()

                Ipr_tbl[rowIndex]["ipr_v_shadow"] = true
            end)
            Ipr_Sys_Derma_Option_3:SetIcon("icon16/shape_group.png")
            Ipr_Sys_Derma_Sub_1:AddSpacer()
            Ipr_Derma:AddSpacer()

            local Ipr_Sys_Derma_Option_4 = Ipr_Sys_Derma_Sub_1:AddOption( "Ne pas afficher l'ombre", function()
                net.Start("ipr_optimiser_custcmd")
                net.WriteUInt(6, 4)
                net.WriteString(tostring(ipr_vector))
                net.WriteString("")
                net.WriteBool(false)
                net.SendToServer()

                Ipr_tbl[rowIndex]["ipr_v_shadow"] = false
            end)
            Ipr_Sys_Derma_Option_4:SetIcon("icon16/shape_group.png")
            Ipr_Sys_Derma_Sub_1:AddSpacer()

            local Ipr_Sys_Derma_Sub_x, Ipr_Sys_Derma_Parent_x = Ipr_Derma:AddSubMenu("Freeze Enitité".. " " ..((Ipr_tbl[rowIndex]["ipr_v_freeze"] and "(Actif)") or "(Inactif)") or "".. ")")
            Ipr_Sys_Derma_Parent_x:SetIcon("icon16/package.png")
            local Ipr_Sys_Derma_Option_u = Ipr_Sys_Derma_Sub_x:AddOption( "Geler l'entité à l'apparition", function()
                net.Start("ipr_optimiser_custcmd")
                net.WriteUInt(7, 4)
                net.WriteString(tostring(ipr_vector))
                net.WriteString("")
                net.WriteBool(true)
                net.SendToServer()

                Ipr_tbl[rowIndex]["ipr_v_freeze"] = true
            end)
            Ipr_Sys_Derma_Option_u:SetIcon("icon16/package.png")
            Ipr_Sys_Derma_Sub_x:AddSpacer()
            Ipr_Derma:AddSpacer()

            local Ipr_Sys_Derma_Option_m = Ipr_Sys_Derma_Sub_x:AddOption( "Dé-geler l'entité à l'apparition", function()
                net.Start("ipr_optimiser_custcmd")
                net.WriteUInt(7, 4)
                net.WriteString(tostring(ipr_vector))
                net.WriteString("")
                net.WriteBool(false)
                net.SendToServer()

                Ipr_tbl[rowIndex]["ipr_v_freeze"] = false
            end)
            Ipr_Sys_Derma_Option_m:SetIcon("icon16/package.png")
            Ipr_Sys_Derma_Sub_x:AddSpacer()

            local Ipr_Sys_Derma_Sub_2, Ipr_Sys_Derma_Parent_2 = Ipr_Derma:AddSubMenu(Ipr_tbl[rowIndex]["ipr_collide"] and ((Ipr_tbl[rowIndex]["ipr_collide"] == "0" and "Collision activé - Global") or (Ipr_tbl[rowIndex]["ipr_collide"] == "12" and "Sans collsion - Joueur") or (Ipr_tbl[rowIndex]["ipr_collide"] == "15" and "Sans collsion - Véhicule") or (Ipr_tbl[rowIndex]["ipr_collide"] == "11" and "Sans collsion - Joueur/Véhicule") or (Ipr_tbl[rowIndex]["ipr_collide"] == "20" and "Collision Désactivé - Global")) or "Collision Entité")
            Ipr_Sys_Derma_Parent_2:SetIcon("icon16/vector.png")
            local Ipr_Sys_Derma_Option_5 = Ipr_Sys_Derma_Sub_2:AddOption( "Activer Collision - Global", function()
                net.Start("ipr_optimiser_custcmd")
                net.WriteUInt(9, 4)
                net.WriteString(tostring(ipr_vector))
                net.WriteString("0")
                net.SendToServer()

                Ipr_tbl[rowIndex]["ipr_collide"] = "0" 
            end)
            Ipr_Sys_Derma_Option_5:SetIcon("icon16/bullet_green.png")
            Ipr_Sys_Derma_Sub_2:AddSpacer()
            Ipr_Derma:AddSpacer()

            local Ipr_Sys_Derma_Option_3 = Ipr_Sys_Derma_Sub_2:AddOption( "Sans collision - Joueur/Entité", function()
                net.Start("ipr_optimiser_custcmd")
                net.WriteUInt(9, 4)
                net.WriteString(tostring(ipr_vector))
                net.WriteString("12")
                net.SendToServer()

                Ipr_tbl[rowIndex]["ipr_collide"] = "12" 
            end)
            Ipr_Sys_Derma_Option_3:SetIcon("icon16/user.png")
            Ipr_Sys_Derma_Sub_2:AddSpacer()

            local Ipr_Sys_Derma_Option_7 = Ipr_Sys_Derma_Sub_2:AddOption( "Sans collision - Joueur/Véhicule", function()
                net.Start("ipr_optimiser_custcmd")
                net.WriteUInt(9, 4)
                net.WriteString(tostring(ipr_vector))
                net.WriteString("11")
                net.SendToServer()

                Ipr_tbl[rowIndex]["ipr_collide"] = "11" 
            end)
            Ipr_Sys_Derma_Option_7:SetIcon("icon16/connect.png")
            Ipr_Sys_Derma_Sub_2:AddSpacer()

            local Ipr_Sys_Derma_Option_6 = Ipr_Sys_Derma_Sub_2:AddOption( "Désactiver collision - Global", function()
                net.Start("ipr_optimiser_custcmd")
                net.WriteUInt(9, 4)
                net.WriteString(tostring(ipr_vector))
                net.WriteString("20")
                net.SendToServer()

                Ipr_tbl[rowIndex]["ipr_collide"] = "20" 
            end)
            Ipr_Sys_Derma_Option_6:SetIcon("icon16/bullet_red.png")

            local Ipr_Sys_Derma_Sub_3, Ipr_Sys_Derma_Parent_3 = Ipr_Derma:AddSubMenu("Visibilité Entité" ..(((Ipr_tbl[rowIndex]["ipr_visible"]) and " (visible)") or " (non visible)"))
            Ipr_Sys_Derma_Parent_3:SetIcon("icon16/wrench.png")
            local Ipr_Sys_Derma_Option_5 = Ipr_Sys_Derma_Sub_3:AddOption( "Enitité visible", function()
                net.Start("ipr_optimiser_custcmd")
                net.WriteUInt(10, 4)
                net.WriteString(tostring(ipr_vector))
                net.WriteString("")
                net.WriteBool(true)
                net.SendToServer()

                Ipr_tbl[rowIndex]["ipr_visible"] = true
            end)
            Ipr_Sys_Derma_Option_5:SetIcon("icon16/lightbulb.png")
            Ipr_Sys_Derma_Sub_3:AddSpacer()
            Ipr_Derma:AddSpacer()

            local Ipr_Sys_Derma_Option_3 = Ipr_Sys_Derma_Sub_3:AddOption( "Enitité invisible", function()
                net.Start("ipr_optimiser_custcmd")
                net.WriteUInt(10, 4)
                net.WriteString(tostring(ipr_vector))
                net.WriteString("")
                net.WriteBool(false)
                net.SendToServer()

                Ipr_tbl[rowIndex]["ipr_visible"] = false
            end)
            Ipr_Sys_Derma_Option_3:SetIcon("icon16/lightbulb_off.png")
            Ipr_Sys_Derma_Sub_3:AddSpacer()

           local Ipr_SysPos_Optionj = Ipr_Derma:AddOption("Respawn Entités", function()
                net.Start("ipr_optimiser_custcmd")
                net.WriteUInt(8, 4)
                net.WriteString(tostring(ipr_vector))
                net.WriteString("")
                net.WriteBool(false)
                net.SendToServer()
            end)
             Ipr_SysPos_Optionj:SetIcon("icon16/arrow_rotate_anticlockwise.png")
         end

        Ipr_Derma:Open()
    end

    timer.Create("ipr_load_addline_corout", 0.5, 1, function()
    ipr_cor = coroutine.create(Ipr_Coroutine_Func_Chart)
    coroutine.resume(ipr_cor)
    end)
    for k, v in pairs(Ipr_system_optimiser_ch_d.Columns) do
        Ipr_system_optimiser_ch_d.Columns[k].Header:SetTextColor(Color(255, 255, 255))
        Ipr_system_optimiser_ch_d.Columns[k].Header:SetFont("Ipr_System_Map_Optmiser_Font")
        Ipr_system_optimiser_ch_d.Columns[k].Header.Paint = function(self, w, h) draw.RoundedBox( 6, 0, 0, w, h, Color(52,73,94)) end
    end

    Ipr_system_optimiser_ch_d:GetChildren()[7].btnGrip.Paint = function(self, w, h) draw.RoundedBox( 3, 0, 0, w, h, Color(52,73,94)) end
    Ipr_system_optimiser_ch_d:GetChildren()[7].btnUp.Paint = function(self, w, h) draw.RoundedBox( 5, 0, 0, w, h, Color(52,73,94)) end
    Ipr_system_optimiser_ch_d:GetChildren()[7].btnDown.Paint = function(self, w, h) draw.RoundedBox( 5, 0, 0, w, h, Color(52,73,94)) end
    Ipr_system_optimiser_ch_d:GetChildren()[7].Paint = function() end
    Ipr_system_optimiser_ch_d:GetChildren()[7]:SetHideButtons( true )
    Ipr_system_optimiser_ch_d.Paint = function() end
    for a, v in pairs(Ipr_system_optimiser_ch_d:GetLines()) do
        for b, l in pairs(v.Columns) do
             if (l:GetName() == "DListView_Line") then
              continue
             end
            l:SetTextColor(Color(236, 240, 241))
            l:SetFont("Ipr_System_Map_Optmiser_Font")
        end
    end

    Ipr_system_optimiser_ch_a:SetPos(20, 30)
    Ipr_system_optimiser_ch_a:SetSize(105, 20)
    Ipr_system_optimiser_ch_a:SetText("")
    function Ipr_system_optimiser_ch_a:Paint(w, h)
        draw.RoundedBox( 6, 0, 0, w, h, Color(52,73,94))
        draw.SimpleText("Supprimer tout", "Ipr_System_Map_Optmiser_Font", w/2, 2, color_white, TEXT_ALIGN_CENTER)
    end
    Ipr_system_optimiser_ch_a.DoClick = function()
        local Ipr_Derma = DermaMenu()
        if not IsValid(Ipr_Derma) then
            return
        end

        local Ipr_Sys_Derma_Sub, Ipr_Sys_Derma_Parent = Ipr_Derma:AddSubMenu("Supprimer les données (irréversible)")
        Ipr_Sys_Derma_Parent:SetIcon("icon16/database_error.png")

        local Ipr_Sys_Derma_Option_1 = Ipr_Sys_Derma_Sub:AddOption( "Supprimer tout !", function()

                net.Start("ipr_optimiser_data")
                net.WriteUInt(Ipr_EnableVgui_EntPostChart, 3)
                net.SendToServer()

                if IsValid(Ipr_system_optimiser_ch_d) then
                Ipr_system_optimiser_ch_d:Clear()
                end
                if (Ipr_EnableVgui_EntPostChart == 2) then
                    chat.AddText(color_white, "[", "Improved System Map Optimiser", "] : ", color_white, "Veuillez Clean UP, ou redémarrer pour faire apparaitre de nouveau les entités du remove props")
                end
        end)
        Ipr_Sys_Derma_Option_1:SetIcon("icon16/disconnect.png")

        Ipr_Derma:Open()
    end

    Ipr_system_optimiser_ch_cls:SetPos(380, 5)
    Ipr_system_optimiser_ch_cls:SetSize(17, 17)
    Ipr_system_optimiser_ch_cls:SetImage("icon16/cross.png")
    function Ipr_system_optimiser_ch_cls:Paint(w, h) end
    Ipr_system_optimiser_ch_cls.DoClick = function()
        Ipr_system_optimiser_gui_ch:Remove()

        if IsValid(Ipr_system_optimiser_gui) then
            Ipr_system_optimiser_gui:SetPos(ScrW()/2-160, ScrH()/2-180  )
        end
        if IsValid(Ipr_model) then
            Ipr_model:Remove()
        end
        if IsValid(Ipr_cust) then
            Ipr_cust:Remove()
        end
    end
end

do
    local ipr_vguigb_w, ipr_vguigb_h = 280, 440
    local function ipr_centerpos(ipr_size)
        return (ipr_vguigb_w - ipr_size) / 2
    end
    local function Ipr_Vgui()
        if IsValid(Ipr_system_optimiser_gui) then
            Ipr_system_optimiser_gui:Remove()
        end
        Ipr_system_optimiser_gui = vgui.Create( "DFrame" )
        local Ipr_system_optimiser_a = vgui.Create("DButton", Ipr_system_optimiser_gui)
        local Ipr_system_optimiser_b = vgui.Create("DButton", Ipr_system_optimiser_gui)
        local Ipr_system_optimiser_c = vgui.Create("DButton", Ipr_system_optimiser_gui)
        local Ipr_system_optimiser_d = vgui.Create("DButton", Ipr_system_optimiser_gui)
        local Ipr_system_optimiser_e = vgui.Create("DButton", Ipr_system_optimiser_gui)
        local Ipr_system_optimiser_f = vgui.Create("DButton", Ipr_system_optimiser_gui)
        local Ipr_system_optimiser_g = vgui.Create("DButton", Ipr_system_optimiser_gui)
        local Ipr_system_optimiser_cls = vgui.Create("DImageButton", Ipr_system_optimiser_gui)
        
        Ipr_system_optimiser_gui:SetTitle( "" )
        Ipr_system_optimiser_gui:SetSize(0, 0)
        Ipr_system_optimiser_gui:SetPos(ScrW()/2-160, ScrH()/2-180 )
        Ipr_system_optimiser_gui:MakePopup()
        Ipr_system_optimiser_gui:ShowCloseButton(false)
        Ipr_system_optimiser_gui:SetDraggable(true)
        Ipr_system_optimiser_gui:SizeTo(ipr_vguigb_w, ipr_vguigb_h, .5, 0, 10)
        Ipr_system_optimiser_gui.Paint = function( self, w, h )
            Ipr_Gui_Blur(self, 1, Color( 0, 0, 0, 170 ), 8)
            local Ior_Sys_Abs = math.abs(math.sin(CurTime() * 1.5) * 170)
            draw.RoundedBox(6, 0, 0, w, 26, Color(52,73,94))
            draw.RoundedBox(8, 10, 122, w - 20, 60, Color(52,73,94))

            draw.SimpleText("Improved System Map Optimiser","Ipr_System_Map_Optmiser_Font",w/2,4, color_white, TEXT_ALIGN_CENTER)
            draw.SimpleText("Removed Props Optimiser : " ..(Ipr_EnableVgui_EntPost == 0 and "Inactif" or (Ipr_EnableVgui_EntPost == 1) and "Actif" or "Inactif"),"Ipr_System_Map_Optmiser_Font", w/2,125, (Ipr_EnableVgui_EntPost == 0 and Color(255,0,0) or (Ipr_EnableVgui_EntPost == 1) and Color(0,175,0) or Color(255,0,0)), TEXT_ALIGN_CENTER)
            draw.SimpleText("Perma Props Optimiser : "..(Ipr_EnableVgui_EntPost == 0 and "Inactif" or (Ipr_EnableVgui_EntPost == 2) and  "Actif" or "Inactif"),"Ipr_System_Map_Optmiser_Font", w/2,143, (Ipr_EnableVgui_EntPost == 0 and Color(255,0,0) or (Ipr_EnableVgui_EntPost == 2) and Color(0,175,0) or Color(255,0,0)), TEXT_ALIGN_CENTER)
            draw.SimpleText("ESP Class Object : " ..(Ipr_EnableVgui_EntEsp == 0 and "Inactif" or "Actif"), "Ipr_System_Map_Optmiser_Font", w/2, 161, (Ipr_EnableVgui_EntEsp == 0 and Color(255,0,0) or Color(0,175,0)), TEXT_ALIGN_CENTER)
            draw.SimpleText("v" ..Improved_System_Map_Optimiser.Version.. " by Inj3","Ipr_System_Map_Optmiser_Font", w-40,h-20, Color(Ior_Sys_Abs, Ior_Sys_Abs, Ior_Sys_Abs), TEXT_ALIGN_CENTER)
            
            surface.SetMaterial(ipr_mat)
            surface.SetDrawColor(color_white)
            surface.DrawTexturedRect(75, 30, 140, 88)
        end

        Ipr_system_optimiser_a:SetSize(250, 25)
        Ipr_system_optimiser_a:SetPos(14, 235)
        Ipr_system_optimiser_a:SetText("")
        Ipr_system_optimiser_a:SetImage( "icon16/wrench.png" )
        Ipr_system_optimiser_a.Paint = function( self, w, h)
            if self:IsHovered() then
                draw.RoundedBox( 6, 0, 0, w, h, Color(30, 73, 109) )
            else
                draw.RoundedBox( 6, 0, 0, w, h, Color(52,73,94) )
            end
            draw.DrawText("Activer/Désactiver le Removed Props","Ipr_System_Map_Optmiser_Font",w/2 + 7, 4, Color(255, 255, 250), TEXT_ALIGN_CENTER)
        end
        Ipr_system_optimiser_a.DoClick = function(self)
            Ipr_EnableVgui_EntPost = (Ipr_EnableVgui_EntPost ~= 1) and 1 or 0
        end

        Ipr_system_optimiser_b:SetSize(195, 25)
        Ipr_system_optimiser_b:SetPos(ipr_centerpos(195), 267)
        Ipr_system_optimiser_b:SetText("")
        Ipr_system_optimiser_b:SetImage( "icon16/cog_add.png" )
        Ipr_system_optimiser_b.Paint = function( self, w, h)
            if self:IsHovered() then
                draw.RoundedBox( 6, 0, 0, w, h, Color(30, 73, 109) )
            else
                draw.RoundedBox( 6, 0, 0, w, h, Color(52,73,94) )
            end
            draw.DrawText("Options Removed Props","Ipr_System_Map_Optmiser_Font",w/2 + 7, 4, Color(255, 255, 250), TEXT_ALIGN_CENTER)
        end
        Ipr_system_optimiser_b.DoClick = function(self)
            if IsValid(Ipr_system_optimiser_gui_ch) then
                Ipr_system_optimiser_gui_ch:Remove()
            end
            if (Ipr_EnableVgui_EntPost ~= 1) then
                Ipr_EnableVgui_EntPost = 0
            end
            Ipr_EnableVgui_EntPostChart = 2
            Ipr_EnableVgui_EntEsp = 0

            net.Start("ipr_optimiser_upchart")
            net.WriteUInt(1, 2)
            net.SendToServer()
        end

        Ipr_system_optimiser_c:SetSize(255, 25)
        Ipr_system_optimiser_c:SetPos(ipr_centerpos(255), 310)
        Ipr_system_optimiser_c:SetText("")
        Ipr_system_optimiser_c:SetImage( "icon16/wrench_orange.png" )
        Ipr_system_optimiser_c.Paint = function( self, w, h)
            if self:IsHovered() then
                draw.RoundedBox( 6, 0, 0, w, h, Color(30, 73, 109) )
            else
                draw.RoundedBox( 6, 0, 0, w, h, Color(52,73,94) )
            end
            draw.DrawText("Activer/Désactiver le Perma Props","Ipr_System_Map_Optmiser_Font",w/2 + 7, 4, Color(255, 255, 250), TEXT_ALIGN_CENTER)
        end
        Ipr_system_optimiser_c.DoClick = function(self)
            Ipr_EnableVgui_EntPost = (Ipr_EnableVgui_EntPost ~= 2) and 2 or 0

            net.Start("ipr_optimiser_data")
            net.WriteUInt(3, 3)
            net.SendToServer()
        end

        Ipr_system_optimiser_d:SetSize(195, 25)
        Ipr_system_optimiser_d:SetPos(ipr_centerpos(195), 342)
        Ipr_system_optimiser_d:SetText("")
        Ipr_system_optimiser_d:SetImage( "icon16/cog_add.png" )
        Ipr_system_optimiser_d.Paint = function( self, w, h)
            if self:IsHovered() then
                draw.RoundedBox( 6, 0, 0, w, h, Color(30, 73, 109) )
            else
                draw.RoundedBox( 6, 0, 0, w, h, Color(52,73,94) )
            end
            draw.DrawText("Options Perma Props","Ipr_System_Map_Optmiser_Font",w/2 + 7, 4, Color(255, 255, 250), TEXT_ALIGN_CENTER)
        end
        Ipr_system_optimiser_d.DoClick = function(self)
            local Ipr_Derma = DermaMenu()
            if not IsValid(Ipr_Derma) then
                return
            end

            local Ipr_Sys_Derma_Option_1 = Ipr_Derma:AddOption( "Options Perma props", function()
                if IsValid(Ipr_system_optimiser_gui_ch) then
                    Ipr_system_optimiser_gui_ch:Remove()
                end
                if (Ipr_EnableVgui_EntPost ~= 2) then
                    Ipr_EnableVgui_EntPost = 0
                end

                Ipr_EnableVgui_EntPostChart = 1

                net.Start("ipr_optimiser_upchart")
                net.WriteUInt(2, 2)
                net.SendToServer()
            end)
            Ipr_Sys_Derma_Option_1:SetIcon("icon16/cog_add.png")

            Ipr_Derma:AddSpacer()
            local Ipr_Sys_Derma_Option_2 = Ipr_Derma:AddOption( "Options de conversion général", function()
                net.Start("ipr_optimiser_custcmd")
                net.WriteUInt(4, 4)
                net.SendToServer()
            end)
            Ipr_Sys_Derma_Option_2:SetIcon("icon16/table_relationship.png")

            Ipr_Derma:Open()
        end

        Ipr_system_optimiser_e:SetSize(260, 25)
        Ipr_system_optimiser_e:SetPos(ipr_centerpos(260), 381)
        Ipr_system_optimiser_e:SetText("")
        Ipr_system_optimiser_e:SetImage( "icon16/chart_line.png" )
        Ipr_system_optimiser_e.Paint = function( self, w, h)
            if self:IsHovered() then
                draw.RoundedBox( 6, 0, 0, w, h, Color(30, 73, 109) )
            else
                draw.RoundedBox( 6, 0, 0, w, h, Color(52,73,94) )
            end
            draw.DrawText("Recherche/supprimer Class Objects","Ipr_System_Map_Optmiser_Font",w/2 + 5, 4, Color(255, 255, 250), TEXT_ALIGN_CENTER)
        end
        Ipr_system_optimiser_e.DoClick = function(self)
            if IsValid(Ipr_search) then
                return
            end

            net.Start("ipr_optimiser_data")
            net.WriteUInt(3, 3)
            net.SendToServer()

            Ipr_SearchClass()
        end

        Ipr_system_optimiser_g:SetSize(87, 21)
        Ipr_system_optimiser_g:SetPos(5, 31)
        Ipr_system_optimiser_g:SetText("")
        Ipr_system_optimiser_g:SetImage( "icon16/brick_link.png" )
        Ipr_system_optimiser_g.Paint = function( self, w, h)
            if self:IsHovered() then
                draw.RoundedBox( 6, 0, 0, w, h, Color(30, 73, 109) )
            else
                draw.RoundedBox( 6, 0, 0, w, h, Color(52,73,94) )
            end
            draw.DrawText("Clean UP","Ipr_System_Map_Optmiser_Font",w/2 + 8, 2, Color(255, 255, 250), TEXT_ALIGN_CENTER)
        end
        Ipr_system_optimiser_g.DoClick = function(self)
            local Ipr_Derma = DermaMenu()
            if not IsValid(Ipr_Derma) then
                return
            end
            Ipr_Derma:AddSpacer()

            local Ipr_Sys_Derma_Sub, Ipr_Sys_Derma_Parent = Ipr_Derma:AddSubMenu("Clean la map [suppression et respawn de toutes les entités]")
            Ipr_Sys_Derma_Parent:SetIcon("icon16//database_refresh.png")

            local Ipr_Sys_Derma_Option_1 = Ipr_Sys_Derma_Sub:AddOption( "Clean Up", function()
                net.Start("ipr_optimiser_data")
                net.WriteUInt(4, 3)
                net.SendToServer()
            end)
            Ipr_Sys_Derma_Option_1:SetIcon("icon16/brick_link.png")

            Ipr_Derma:AddSpacer()
            Ipr_Derma:Open()
        end

        Ipr_system_optimiser_f:SetSize(260, 25)
        Ipr_system_optimiser_f:SetPos(ipr_centerpos(260), 195)
        Ipr_system_optimiser_f:SetText("")
        Ipr_system_optimiser_f:SetImage( "icon16/bricks.png" )
        Ipr_system_optimiser_f.Paint = function( self, w, h)
            if self:IsHovered() then
                draw.RoundedBox( 6, 0, 0, w, h, Color(30, 73, 109) )
            else
                draw.RoundedBox( 6, 0, 0, w, h, Color(52,73,94) )
            end
            draw.DrawText("Activer/Desactiver ESP Class Objects","Ipr_System_Map_Optmiser_Font",w/2 + 7, 4, Color(255, 255, 250), TEXT_ALIGN_CENTER)
        end
        Ipr_system_optimiser_f.DoClick = function(self)
            Ipr_EnableVgui_EntEsp = (Ipr_EnableVgui_EntEsp ~= 1) and 1 or 0

            net.Start("ipr_optimiser_data")
            net.WriteUInt(3, 3)
            net.SendToServer()
        end

        Ipr_system_optimiser_cls:SetPos(260, 5)
        Ipr_system_optimiser_cls:SetSize(17, 17)
        Ipr_system_optimiser_cls:SetImage("icon16/cross.png")
        function Ipr_system_optimiser_cls:Paint(w, h) end
        Ipr_system_optimiser_cls.DoClick = function()
            Ipr_system_optimiser_gui:Remove()
            if IsValid(Ipr_system_optimiser_gui_ch) then
                Ipr_system_optimiser_gui_ch:Remove()
            end
            if IsValid(Ipr_model) then
                Ipr_model:Remove()
            end
            if IsValid(Ipr_cust) then
                Ipr_cust:Remove()
            end

            if IsValid(Ipr_search) then
                Ipr_search:Remove()
            end

            if IsValid(Ipr_conv) then
                Ipr_conv:Remove()
            end

            if IsValid(Ipr_system_optimiser_gui_ch) then
                Ipr_system_optimiser_gui_ch:SetPos(ScrW()/2-160, ScrH()/2-180  )
            end
        end
    end
    net.Receive("ipr_optimiser_data", Ipr_Vgui)
end

local function ipr_up_ch()
    local ipr_uireadint = net.ReadUInt(32)
    local ipr_uireaddata = net.ReadData(ipr_uireadint)
    local ipr_uireadnb = net.ReadUInt(2)
    local ipr_uireadbool = net.ReadBool()

    ipr_data_cl = util.JSONToTable(util.Decompress(ipr_uireaddata))
    if (ipr_uireadbool) then
         return
    end
    if (ipr_uireadnb ~= 3) then
         if IsValid(Ipr_system_optimiser_gui_ch) then
              Ipr_system_optimiser_gui_ch:Remove()
         end
         Ipr_Chart(ipr_data_cl)
    end
    if IsValid(Ipr_system_optimiser_gui) then
         Ipr_system_optimiser_gui:SetPos(ScrW()/2-300, ScrH()/2-180 )
    end
end

local function ipr_conv_class()
    local ipr_r = net.ReadTable()
    Ipr_Convert(ipr_r)
end
net.Receive("ipr_optimiser_convert", ipr_conv_class)
net.Receive("ipr_optimiser_upchart", ipr_up_ch)