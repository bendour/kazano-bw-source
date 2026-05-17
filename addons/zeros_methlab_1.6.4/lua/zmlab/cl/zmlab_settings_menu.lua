if not CLIENT then return end
local Created = false

CreateConVar("zmlab_cl_vfx_particleeffects", "1", {FCVAR_ARCHIVE})
CreateConVar("zmlab_cl_vfx_dynamiclight", "0", {FCVAR_ARCHIVE})

local function zmlab_OptionPanel(name, CPanel, cmds)
	local panel = vgui.Create("DPanel")
	panel:SetSize(250 , 40 + (35 * table.Count(cmds)))
	panel.Paint = function(s, w, h)
		draw.RoundedBox(4, 0, 0, w, h, zmlab.default_colors["grey01"])
	end

	local title = vgui.Create("DLabel", panel)
	title:SetPos(10, 2.5)
	title:SetText(name)
	title:SetFont("zmlab_settings_font01")
	title:SetSize(panel:GetWide(), 30)
	title:SetTextColor(zmlab.default_colors["blue01"])

	for k, v in pairs(cmds) do
		if v.class == "DNumSlider" then

			local item = vgui.Create("DNumSlider", panel)
			item:SetPos(10, 35 * k)
			item:SetSize(panel:GetWide(), 30)
			item:SetText(v.name)
			item:SetMin(v.min)
			item:SetMax(v.max)
			item:SetDecimals(v.decimal)
			item:SetDefaultValue(math.Clamp(math.Round(GetConVar(v.cmd):GetFloat(),v.decimal),v.min,v.max))
			item:ResetToDefaultValue()

			item.OnValueChanged = function(self, val)

				if (not Created) then
					RunConsoleCommand(v.cmd, tostring(val))
				end
			end

			timer.Simple(0.1, function()
				if (item) then
					item:SetValue(math.Clamp(math.Round(GetConVar(v.cmd):GetFloat(),v.decimal),v.min,v.max))
				end
			end)
		elseif v.class == "DCheckBoxLabel" then

			local item = vgui.Create("DCheckBoxLabel", panel)
			item:SetPos(10, 35 * k)
			item:SetSize(panel:GetWide(), 30)
			item:SetText( v.name )
			item:SetConVar( v.cmd )
			item:SetValue(0)
			item.OnChange = function(self, val)

				if (not Created) then
					if ((bVal and 1 or 0) == cvars.Number(v.cmd)) then return end
					RunConsoleCommand(v.cmd, tostring(val))
				end
			end

			timer.Simple(0.1, function()
				if (item) then
					item:SetValue(GetConVar(v.cmd):GetInt())
				end
			end)
		elseif v.class == "DButton" then
			local item = vgui.Create("DButton", panel)
			item:SetPos(10, 35 * k)
			item:SetSize(panel:GetWide(), 30)
			item:SetText( "" )
			//item:SetConsoleCommand( v.cmd )
			item.Paint = function(s, w, h)
				draw.RoundedBox(5, 0, 0, w, h, zmlab.default_colors["blue01"])
				draw.SimpleText(v.name, "zmlab_settings_font02", w / 2, h / 2, zmlab.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				if s.Hovered then
					draw.RoundedBox(5, 0, 0, w, h, zmlab.default_colors["white03"])
				end
			end
			item.DoClick = function()

				if zmlab.f.IsAdmin(LocalPlayer()) == false then return end

				LocalPlayer():EmitSound("zmlab_ui_click")

				if v.notify then

					notification.AddLegacy(  v.notify, NOTIFY_GENERIC, 2 )
				end
				LocalPlayer():ConCommand( v.cmd )

			end
		end
	end

	CPanel:AddPanel(panel)
end


local function zmlab_settings(CPanel)
	Created = true
	CPanel:AddControl("Header", {
		Text = "Client Settings",
		Description = ""
	})

	zmlab_OptionPanel("VFX",CPanel,{
		[1] = {name = "ParticleEffects",class = "DCheckBoxLabel", cmd = "zmlab_cl_vfx_particleeffects"},
		[2] = {name = "DynamicLight",class = "DCheckBoxLabel", cmd = "zmlab_cl_vfx_dynamiclight"},
	})

	timer.Simple(0.1, function()
		Created = false
	end)
end

local function zmlab_admin_settings(CPanel)

	CPanel:AddControl("Header", {
		Text = "Admin Settings",
		Description = ""
	})

	zmlab_OptionPanel("NPC",CPanel,{
		[1] = {name = "Save",class = "DButton", cmd = "zmlab_npc_save"},
		[2] = {name = "Remove",class = "DButton", cmd = "zmlab_npc_remove"},
	})

	zmlab_OptionPanel("DropOffPoints",CPanel,{
		[1] = {name = "Save",class = "DButton", cmd = "zmlab_dropoff_save"},
		[2] = {name = "Remove",class = "DButton", cmd = "zmlab_dropoff_remove"},
	})

	zmlab_OptionPanel("Commands",CPanel,{
		[1] = {name = "Spawn Methcrates",class = "DButton", cmd = "zmlab_debug_spawn_methcrates"},
	})
end



hook.Add( "PopulateToolMenu", "a_zmlab_PopulateMenus", function()
	spawnmenu.AddToolMenuOption( "Options", "Zeros Methlab", "zmlab_Settings", "Client Settings", "", "", zmlab_settings )
	spawnmenu.AddToolMenuOption("Options", "Zeros Methlab", "zmlab_Admin_Settings", "Admin Settings", "", "", zmlab_admin_settings)
end )

hook.Add( "AddToolMenuCategories", "a_zmlab_CreateCategories", function()
	spawnmenu.AddToolCategory( "Options", "Zeros Methlab", "Zeros Methlab" );
end )
