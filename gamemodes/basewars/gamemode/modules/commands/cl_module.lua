net.Receive("BaseWars:Msg", function()
    local message = net.ReadTable()

    chat.AddText(unpack(message))
end)

net.Receive("BaseWars:ChatCommand:AdminChat", function()
    local message = net.ReadString()
    local admin = net.ReadString()

    chat.AddText(GetBaseWarsTheme("adminChat_prefix"), "<clr:white>:admin_chat0::admin_chat1::admin_chat2::admin_chat3::admin_chat4::admin_chat5::admin_chat7:<clr:white>" .. admin, GetBaseWarsTheme("adminChat_text"), " » ", message)
end)

net.Receive("BaseWars:Broadcast", function()
    local message = net.ReadString()

    chat.AddText(GetBaseWarsTheme("broadcast_prefix"), "[BaseWars Broadcast]", GetBaseWarsTheme("broadcast_text"), " » ", message)
    surface.PlaySound("bw_annoncement.mp3")
end)

net.Receive("BaseWars:Commands:Announcement", function()
    local text = net.ReadString()

    if IsValid(AnnouncementPanel) then
        AnnouncementPanel:Remove()
    end

    AnnouncementPanel = vgui.Create("BaseWars.AnnouncementPanel")
    AnnouncementPanel:SetText(text)
end)

local HIGHLIGHT_COLOR = Color(255, 184, 0)
net.Receive("BaseWars:Commands:FindEntities", function()
    local ply = net.ReadEntity()
    if not IsValid(ply) then return end

    local time = CurTime() + 10
    local id = tostring(time) .. "_" .. math.random(1, 100)
    hook.Add("PreDrawHalos", id, function()
        if not IsValid(ply) or CurTime() > time then
            hook.Remove("PreDrawHalos", id)
        end

        local entities = {}
        for k, v in ents.Iterator() do
            if not IsValid(v) then continue end
            if v:CPPIGetOwner() != ply then continue end

            table.insert(entities, v)
        end

        halo.Add(entities, HIGHLIGHT_COLOR, 2, 2, 5, true, true)
    end)
end)