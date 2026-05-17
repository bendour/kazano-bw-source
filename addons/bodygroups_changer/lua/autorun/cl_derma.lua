net.Receive("ShowBodygroups", function(len, ply)
    local Menu = vgui.Create("DFrame")
    Menu:Center()
    Menu:SetPos(50, 50)
    Menu:SetSize(700, 700)
    Menu:SetTitle("Bodygroups Changer")
    Menu:SetVisible(true)
    Menu:SetDraggable(true)
    Menu:ShowCloseButton(true)
    Menu:SetBackgroundBlur(true)
    Menu:MakePopup()
    Menu.Paint = function(self, w, h) 
        draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255, 25))
    end

    local bodygroups = LocalPlayer():GetBodyGroups()

    local pm = vgui.Create("DModelPanel", Menu)
    pm:SetSize(200, 700)
    pm:SetModel(LocalPlayer():GetModel())
    pm:SetFOV(20)

    local ScrollList = vgui.Create("DScrollPanel", Menu)
    ScrollList:Dock(FILL)
    
    for k, v in pairs(bodygroups) do
        pm.Entity:SetBodygroup(k, LocalPlayer():GetBodygroup(k))

        if (bodygroups[k].id > 0) and (bodygroups[k].num > 0) then
            -- local bodygroupName = vgui.Create("DLabel", Menu)
            local bodygroupName = ScrollList:Add("DLabel")
            bodygroupName:SetFont("CloseCaption_Bold")
            local y = k - 1
            local y = y * 75
            bodygroupName:SetPos(300, y - 60)
            bodygroupName:SetSize(500, 25)
            bodygroupName:SetText(bodygroups[k].name)
            bodygroupName:SetTextColor(Color(255, 255, 255))

            for j, l in pairs(bodygroups[k].submodels) do
                -- local bodygroupButton = vgui.Create("DButton", Menu)
                local bodygroupButton = ScrollList:Add("DButton")
                bodygroupButton:SetFont("ChatFont")
                bodygroupButton:SetText(tostring(j))
                local x = j - 1
                local x = x * 50
                bodygroupButton:SetPos(350 + x, y - 30)
                bodygroupButton:SetSize(35, 35)
                bodygroupButton.Paint = function(self, w, h) 
                    draw.RoundedBox(8, 0, 0, w, h, Color(3, 177, 252, 215))
                end
                bodygroupButton.DoClick = function()
                    local k = k - 1

                    net.Start("ChangeBodygroup")
                        net.WriteString(tostring(k))
                        net.WriteInt(j, 32)
                    net.SendToServer()

                    pm.Entity:SetBodygroup(k, j)
                end
            end
        end
    end
end)