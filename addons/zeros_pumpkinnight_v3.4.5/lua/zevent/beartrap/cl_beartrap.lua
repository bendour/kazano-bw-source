/*
    Addon id: 5d8b797b-05d3-45b1-9efb-d4bfab61cce1
    Version: v3.4.5 (stable)
*/

local DebugWindow
local function CreateWindow(title,w,h,content)
	if IsValid(DebugWindow) then DebugWindow:Remove() end
	DebugWindow = vgui.Create("DFrame")
	DebugWindow:SetSize(w,h)
	DebugWindow:MakePopup()
	DebugWindow:Center()
	DebugWindow:SetTitle(title)
	DebugWindow:ShowCloseButton(true)
	pcall(content,DebugWindow)
end

local entryColor = Color(0, 0, 0, 100)
local pnlColor = Color(70, 70, 80)
local function CreateTextEntry(parent,title,default)
	local ct_sub = vgui.Create("DPanel", parent)
	ct_sub:SetTall(70)
	ct_sub:Dock(TOP)
	ct_sub:DockMargin(0, 5, 0, 0)
	ct_sub.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h, pnlColor)
		draw.SimpleText(title, "ChatFont", w/2, 10, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end

	local dentry = vgui.Create("DTextEntry", ct_sub)
	dentry:Dock(FILL)
	dentry:DockMargin(4, 30, 4, 4)
	dentry:SetTall(30)
	dentry:SetWide(300)
	dentry:SetPaintBackground(false)
	dentry:SetAutoDelete(true)
	dentry:SetUpdateOnType(true)
	dentry:SetDrawLanguageID(false)
	dentry:SetValue(default or "")
	dentry:NoClipping(true)
	dentry.Paint = function(s, w, h)
		draw.RoundedBox(0, 0, 0, w, h, entryColor)
		s:DrawTextEntryText(color_white, color_white, Color(10, 10, 10, 155))
	end
	dentry.PerformLayout = function(s, width, height)
		s:SetFontInternal("ChatFont")
	end

	return dentry
end

net.Receive("zpn.Beartrap.Edit", function(len)

	local ent = net.ReadEntity()
	if not IsValid(ent) then return end

	local question = net.ReadString()
	local answer = net.ReadString()

	CreateWindow(zpn.language.General["Edit Puzzle"],600,250,function(pnl)

		local question_entry = CreateTextEntry(pnl,zpn.language.General["Question"],question)

		local answer_entry = CreateTextEntry(pnl,zpn.language.General["Answer"],answer)

		local btn = vgui.Create("DButton",pnl)
		btn:Dock(FILL)
		btn:SetWide(50)
		btn:SetTall(50)
		btn:SetText(zpn.language.General["Save and Activate"])
		btn:SetFont("ChatFont")
		btn:DockMargin(0, 5, 0, 0)
		btn.DoClick = function()

			net.Start("zpn.Beartrap.Edit")
			net.WriteEntity(ent)
			net.WriteString(question_entry:GetValue())
			net.WriteString(answer_entry:GetValue())
			net.SendToServer()

			pnl:Remove()
		end
	end)
end)

net.Receive("zpn.Beartrap.StartGame", function(len)

	local DeathTime = CurTime() + zpn.config.Beartrap.Duration
	local ply = LocalPlayer()
	hook.Add("HUDPaint","zpn.Beartrap.StartGame",function()

		if not ply:Alive() then
			hook.Remove("HUDPaint","zpn.Beartrap.StartGame")
			return
		end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- ddf04c302d8fd9e30f6a5e9cc4e3787dc09a35f0034528f4b4c268245f97715d

		local remain = math.Clamp(DeathTime - CurTime(),0,zpn.config.Beartrap.Duration)

		if remain <= 0 then
			hook.Remove("HUDPaint","zpn.Beartrap.StartGame")
			return
		end

		draw.SimpleText(string.FormattedTime( remain, "%02i:%02i:%02i" ), "DermaLarge", ScrW() / 2, ScrH() / 2, Color(255,0,0,50 + (200 * math.abs(math.sin(CurTime() * 10)))), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end)
end)

net.Receive("zpn.Beartrap.SnapOpen", function(len)

	local ent = net.ReadEntity()
	if not IsValid(ent) then return end
	if not ent:IsValid() then return end

	ent:SetCycle(0)
	ent:SetPlaybackRate(3)
	ent:ResetSequence(ent:LookupSequence("open"))
	ent:SetPlaybackRate(3)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

	sound.Play("weapons/crossbow/bolt_skewer1.wav", ent:GetPos(), 68)
end)

net.Receive("zpn.Beartrap.Reset", function(len)

	local ent = net.ReadEntity()
	if not IsValid(ent) then return end
	if not ent:IsValid() then return end

	ent:SetCycle(0)
	ent:ResetSequence(ent:LookupSequence("idle"))
	ent:SetPlaybackRate(1)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- da71c7e0bf5016ce33a9f318a3747fb53331bb70d9090f016fdcc745ceefa6b8

	sound.Play("weapons/crossbow/reload1.wav",ent:GetPos(), 68)
end)

net.Receive("zpn.Beartrap.StopGame", function(len)

	hook.Remove("HUDPaint","zpn.Beartrap.StartGame")
end)
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

net.Receive("zpn.Beartrap.ScaleHead", function(len)

	local rag = net.ReadEntity()
	if not IsValid(rag) then return end
	if not rag:IsValid() then return end

	local ScaleBones = {
		["ValveBiped.Bip01_Head1"] = true,
		["ValveBiped.Bip01_Neck1"] = true,
	}

	local CallBackID = rag:AddCallback("BuildBonePositions", function(mesh, numbones)
		for i = 0, numbones - 1 do
			local bname = mesh:GetBoneName(i)
			if not bname then continue end
			if not ScaleBones[bname] then continue end
                                                                                                                                                                                                                                                                                                                                                                                                                                                       -- 00000000000000000

			local mat = mesh:GetBoneMatrix(i)
			if not mat then continue end

			mat:SetScale(Vector(0,0,0))
			mesh:SetBoneMatrix(i, mat)
		end
	end)

	rag:CallOnRemove("zpn.Beartrap.ScaleHead", function(a)
		a:RemoveCallback("BuildBonePositions", CallBackID)
	end)
end)
