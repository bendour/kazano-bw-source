if not CLIENT then return end
local Created = false

CreateConVar("zwf_cl_sfx_volume", "0.5", {FCVAR_ARCHIVE})
CreateConVar("zwf_cl_vfx_lightsprite", "1", {FCVAR_ARCHIVE})
CreateConVar("zwf_cl_vfx_particleeffects", "1", {FCVAR_ARCHIVE})
CreateConVar("zwf_cl_vfx_ventilatorffects", "0", {FCVAR_ARCHIVE})
CreateConVar("zwf_cl_vfx_lightcone", "1", {FCVAR_ARCHIVE})
CreateConVar("zwf_cl_vfx_dynlight", "0", {FCVAR_ARCHIVE})
CreateConVar("zwf_cl_vfx_skankeffect", "1", {FCVAR_ARCHIVE})
CreateConVar("zwf_cl_vfx_exhaleeffect", "1", {FCVAR_ARCHIVE})
CreateConVar("zwf_cl_vfx_epilepsy", "0", {FCVAR_ARCHIVE})
CreateConVar("zwf_cl_vfx_drawui", "1", {FCVAR_ARCHIVE})

cvars.AddChangeCallback( "zwf_cl_sfx_volume", function( convar_name, value_old, value_new )
	zwf.f.VolumeChanged(value_old,value_new)
end )


local function zwf_OptionPanel(name, CPanel, cmds)
	local panel = vgui.Create("DPanel")
	panel:SetSize(250 , 40 + (35 * table.Count(cmds)))
	panel.Paint = function(s, w, h)
		draw.RoundedBox(4, 0, 0, w, h, zwf.default_colors["gray01"])
	end

	local title = vgui.Create("DLabel", panel)
	title:SetPos(10, 2.5)
	title:SetText(name)
	title:SetFont(zwf.f.GetFont("zwf_settings_font01"))
	title:SetSize(panel:GetWide(), 30)
	title:SetTextColor(zwf.default_colors["green09"])

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
					if ((val and 1 or 0) == cvars.Number(v.cmd)) then return end
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
				draw.RoundedBox(5, 0, 0, w, h, zwf.default_colors["gray02"])
				draw.SimpleText(v.name, zwf.f.GetFont("zwf_settings_font02"), w / 2, h / 2, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				if s.Hovered then
					draw.RoundedBox(5, 0, 0, w, h, zwf.default_colors["white02"])
				end
			end
			item.DoClick = function()

				if zwf.f.IsAdmin(LocalPlayer()) == false then return end

				LocalPlayer():EmitSound("zwf_ui_click")

				if v.notify then

					notification.AddLegacy(  v.notify, NOTIFY_GENERIC, 2 )
				end
				LocalPlayer():ConCommand( v.cmd )

			end
		end
	end

	CPanel:AddPanel(panel)
end


local function zweedfarm_settings(CPanel)
	Created = true
	CPanel:AddControl("Header", {
		Text = "Client Settings",
	})

	zwf_OptionPanel("VFX",CPanel,{
		[1] = {name = "ParticleEffects",class = "DCheckBoxLabel", cmd = "zwf_cl_vfx_particleeffects"},
		[2] = {name = "Fan Effects",class = "DCheckBoxLabel", cmd = "zwf_cl_vfx_ventilatorffects"},
		[3] = {name = "Light Sprites",class = "DCheckBoxLabel", cmd = "zwf_cl_vfx_lightsprite"},
		[4] = {name = "Light Cone",class = "DCheckBoxLabel", cmd = "zwf_cl_vfx_lightcone"},
		[5] = {name = "DynamicLight",class = "DCheckBoxLabel", cmd = "zwf_cl_vfx_dynlight"},
		[6] = {name = "Skank Effect",class = "DCheckBoxLabel", cmd = "zwf_cl_vfx_skankeffect"},
		[7] = {name = "Exhale Effect",class = "DCheckBoxLabel", cmd = "zwf_cl_vfx_exhaleeffect"},
		[8] = {name = "Epilepsy SafeMode",class = "DCheckBoxLabel", cmd = "zwf_cl_vfx_epilepsy"},
	})

	zwf_OptionPanel("SFX",CPanel,{
		[1] = {name = "Volume",class = "DNumSlider", cmd = "zwf_cl_sfx_volume",min = 0,max = 1,decimal = 2},
	})

	timer.Simple(0.2, function()
		Created = false
	end)
end

local function zweedfarm_admin_settings(CPanel)

	CPanel:AddControl("Header", {
		Text = "Admin Settings",
	})

	zwf_OptionPanel("NPC",CPanel,{
		[1] = {name = "Save",class = "DButton", cmd = "zwf_save_weedbuyer"},
		[2] = {name = "Remove",class = "DButton", cmd = "zwf_remove_weedbuyer"},
	})

	zwf_OptionPanel("Commands",CPanel,{
		[1] = {name = "Spawn Muffin",class = "DButton", cmd = "zwf_debug_spawn_muffin"},
		[2] = {name = "Spawn Brownie",class = "DButton", cmd = "zwf_debug_spawn_brownie"},
		[3] = {name = "Spawn WeedJar",class = "DButton", cmd = "zwf_debug_spawn_weedjars"},
		[4] = {name = "Spawn WeedBlock",class = "DButton", cmd = "zwf_debug_spawn_weedblock"},
	})
end


hook.Add( "PopulateToolMenu", "zwf_PopulateMenus", function()
	spawnmenu.AddToolMenuOption( "Options", "WeedFarm", "zwf_Settings", "Client Settings", "", "", zweedfarm_settings )
	spawnmenu.AddToolMenuOption("Options", "WeedFarm", "zwf_Admin_Settings", "Admin Settings", "", "", zweedfarm_admin_settings)
end )

hook.Add( "AddToolMenuCategories", "zwf_CreateCategories", function()
	spawnmenu.AddToolCategory( "Options", "WeedFarm", "WeedFarm" );
end )
