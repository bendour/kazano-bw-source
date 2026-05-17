function BaseWars:OpenF3Menu()
    if IsValid(BaseWars:GetF3MenuPanel()) then
        return
    end

	local F4 = BaseWars:GetF4MenuPanel()
	if IsValid(F4) then
		F4:Remove()
		BaseWars:CloseF4Menu()
	end

	local AM = BaseWars:GetAdminMenuPanel()
	if IsValid(AM) then
		AM:CloseAdminMenu()
	end

    F3Menu = vgui.Create("BaseWars.F3Menu", nil, "Kazano Menu")
    if F3Menu and F3Menu.AnimateOpen then
        F3Menu:AnimateOpen()
    end
end

function BaseWars:CloseF3Menu()
    if IsValid(F3Menu) then
        if F3Menu.AnimateClose then
            F3Menu:AnimateClose()
        else
            F3Menu:Remove()
        end
    end
end

function BaseWars:GetF3MenuPanel()
	return F3Menu
end

local NavigationButtons = {}
function BaseWars:AddBaseWarsMenuTab(name, icon, panel, order)
	if not name or not icon or not panel then return end

	table.insert(NavigationButtons, {
		name = name,
		translate = translate,
		icon = Material(icon, "smooth"),
		panel = panel,
		order = order or 50
	})

	table.SortByMember(NavigationButtons, "order", true)
end

function BaseWars:GetBaseWarsMenuTabs()
	return table.Copy(NavigationButtons)
end
