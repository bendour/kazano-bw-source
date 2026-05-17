local sc = VoidUI.Scale

VoidFactions.Invites = VoidFactions.Invites or {}
VoidFactions.Invites.ActivePanel = VoidFactions.Invites.ActivePanel or {}

net.Receive("VoidFactions.Invites.ShowInvite", function (len, ply)
    local name = net.ReadString()
    local id = net.ReadUInt(20)

    if (IsValid(VoidFactions.Invites.ActivePanel)) then
        VoidFactions.Invites.ActivePanel:Remove()
    end

    local popup = vgui.Create("VoidFactions.UI.InvitePopup")
    popup:SetPos(sc(50), sc(50))
    popup:SetInfo(name, id)

    timer.Create("VoidFactions.Invite." .. id, VoidFactions.Config.InviteDuration, 1, function ()
        -- Expired
        popup:Remove()
    end)

    function popup:OnRemove()
        if (timer.Exists("VoidFactions.Invite." .. id)) then
            timer.Remove("VoidFactions.Invite." .. id)
        end
    end

    VoidFactions.Invites.ActivePanel = popup
end)


-- Allow clicking through context (C) menu
local function handleContextOpen()
    if (IsValid(VoidFactions.Invites.ActivePanel)) then
        timer.Simple(0, function ()
            if (IsValid(g_ContextMenu)) then
                VoidFactions.Invites.ActivePanel:SetParent(g_ContextMenu)
            end
        end)
    end
end
local function handleContextClose()
    if (IsValid(VoidFactions.Invites.ActivePanel)) then
        VoidFactions.Invites.ActivePanel:SetParent(NULL)
    end
end
hook.Add("OnContextMenuOpen", "VoidCases.ContextMenuOpen", function ()
    handleContextOpen()
end)
hook.Add("OnContextMenuClose", "VoidCases.ContextMenuClose", function ()
    handleContextClose()
end)