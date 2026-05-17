include("shared.lua")

function ENT:Initialize()
	zwf.f.EntList_Add(self)

	self.DoobyProgress = false
	self.LastWeedAmount = -1
end

function ENT:Draw()
	self:DrawModel()

	if GetConVar("zwf_cl_vfx_drawui"):GetInt() == 1 and zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 200) then
		self:DrawScreenUI()
	end
end

function ENT:Draw_GrinderButton()
	if self:OnGrinder(LocalPlayer()) then
		draw.SimpleText("[E]", zwf.f.GetFont("zwf_watertank_font01"), 170, 40, zwf.default_colors["orange01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	else
		draw.SimpleText("[E]", zwf.f.GetFont("zwf_watertank_font01"), 170, 40, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
end

function ENT:Draw_StartButton()
	if self:OnStartButton(LocalPlayer()) then
		draw.SimpleText(zwf.language.General["generator_start"], zwf.f.GetFont("zwf_splicelab_font02"), -170, 55, zwf.default_colors["orange01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	else
		draw.SimpleText(zwf.language.General["generator_start"], zwf.f.GetFont("zwf_splicelab_font02"), -170, 55, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
end

function ENT:Draw_RemoveWeedButton()
	if self:OnRemoveButton(LocalPlayer()) then
		draw.SimpleText(zwf.language.General["Remove"], zwf.f.GetFont("zwf_splicelab_font02"), -170, 25, zwf.default_colors["orange01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	else
		draw.SimpleText(zwf.language.General["Remove"], zwf.f.GetFont("zwf_splicelab_font02"), -170, 25, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
end

function ENT:Draw_PaperButton()
	if self:OnPaper(LocalPlayer()) then
		draw.SimpleText("[E]", zwf.f.GetFont("zwf_watertank_font01"), 0, -30, zwf.default_colors["orange01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	else
		draw.SimpleText("[E]", zwf.f.GetFont("zwf_watertank_font01"), 0, -30, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
end

function ENT:DrawScreenUI()


	//debugoverlay.Sphere( self:LocalToWorld(Vector(-7, math.random(-12,12), 5)), 1,  0.1,Color( 255, 255, 255 ), false )
	if self.LastWeedAmount > 0 then
		cam.Start3D2D(self:LocalToWorld(Vector(2, 17, 17)), Angle(0, EyeAngles().y - 90, -EyeAngles().x + 90), 0.1)
			draw.SimpleText(self:GetWeedName(), zwf.f.GetFont("zwf_splicelab_font02"), 0, 0, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			draw.SimpleText(math.Round(self.LastWeedAmount) .. zwf.config.UoW, zwf.f.GetFont("zwf_splicelab_font02"), 0, 25, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		cam.End3D2D()
	end

	cam.Start3D2D(self:LocalToWorld(Vector(0, 0, 6)), self:LocalToWorldAngles(Angle(0, -90, 0)), 0.1)

		if self.DoobyProgress == 0 and self:GetWeedAmount() >= zwf.config.DoobyTable.WeedPerJoint then

			self:Draw_StartButton()

			self:Draw_RemoveWeedButton()

		elseif self.DoobyProgress >= 1 and self.DoobyProgress < 5 then

			self:Draw_GrinderButton()

		elseif self.DoobyProgress == 5 then

			self:Draw_PaperButton()

		elseif self.DoobyProgress == 6 then

			self:Draw_GrinderButton()
		end
	cam.End3D2D()

	if self.DoobyProgress >= 7 and self.DoobyProgress < 11 then

		local pos = self:GetGamePos()

		cam.Start3D2D(self:LocalToWorld(Vector(pos.x, pos.y, 6)), self:LocalToWorldAngles(Angle(0, -90, 0)), 0.1)

			//debugoverlay.Sphere( self:LocalToWorld(pos), 1,  0.1,Color( 255, 255, 255 ), false )

			if self:OnHitButton(LocalPlayer()) then
				draw.SimpleText("[E]", zwf.f.GetFont("zwf_watertank_font01"), 0, -10, zwf.default_colors["orange01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			else
				draw.SimpleText("[E]", zwf.f.GetFont("zwf_watertank_font01"), 0, -10, zwf.default_colors["white01"], TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end

		cam.End3D2D()
	end
end


function ENT:Think()

	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then

		// Update Weed Amount and Skin
		local _weedamount = self:GetWeedAmount()
		if self.LastWeedAmount ~= _weedamount then
			self.LastWeedAmount = _weedamount

			local _weedID = self:GetWeedID()
			if _weedID ~= -1 then

				local plantData = zwf.config.Plants[_weedID]
				self:SetSkin(plantData.skin)
			end

			local fraction = zwf.config.DoobyTable.Capacity / 3

			if _weedamount <= 0 then

				// No Weed
				self:SetBodygroup(5,0)
			elseif _weedamount < fraction then

				// Less Weed
				self:SetBodygroup(5,1)
			elseif _weedamount < fraction * 2 then

				// Half Weed
				self:SetBodygroup(5,2)
			elseif _weedamount > fraction * 2 then

				// Full Weed
				self:SetBodygroup(5,3)
			end
		end

		local _progress = self:GetDoobyProgress()
		if self.DoobyProgress ~= _progress then
			self.DoobyProgress = _progress



			if self.DoobyProgress == 0 then

				// Disable Dooby
				self:SetBodygroup(3,0)

				// Paper Close
				self:SetBodygroup(2,0)
				zwf.f.EmitSoundENT("zwf_paper_close", self)

				// Grinder Close
				self:SetBodygroup(1,0)
				zwf.f.EmitSoundENT("zwf_grinder_close", self)

			elseif self.DoobyProgress == 1 then

				// Grinder Open
				self:SetBodygroup(1,1)
				zwf.f.EmitSoundENT("zwf_grinder_open", self)

				// WeedJunk On
				self:SetBodygroup(6,1)
				zwf.f.EmitSoundENT("zwf_grab_weed", self)

			elseif self.DoobyProgress >= 1 and  self.DoobyProgress < 5 then

				// Play Grind Animation
				zwf.f.ClientAnim(self, "grind", 2)

				// Grinder Close
				if self:GetBodygroup(1) == 1 then
					self:SetBodygroup(1,0)
					zwf.f.EmitSoundENT("zwf_grinder_close", self)
				end

				// WeedJunk Off
				self:SetBodygroup(6,0)
				zwf.f.EmitSoundENT("zwf_grinder_grind", self)

			elseif self.DoobyProgress == 5 then

				// Grinded Weed On
				self:SetBodygroup(6,2)

				// Grinder Open
				self:SetBodygroup(1,1)
				zwf.f.EmitSoundENT("zwf_grinder_open", self)

			elseif self.DoobyProgress == 6 then

				// Paper Open
				self:SetBodygroup(2,1)
				zwf.f.EmitSoundENT("zwf_paper_open", self)

				// Paper Placed
				self:SetBodygroup(0,1)
				zwf.f.EmitSoundENT("zwf_grab_paper", self)

			elseif self.DoobyProgress == 7 then

				// Grinded Weed Off
				self:SetBodygroup(6,0)

				// Added Weed On Paper
				self:SetBodygroup(0,2)
				zwf.f.EmitSoundENT("zwf_grab_weed", self)

			elseif self.DoobyProgress == 8 then

				// Roll Stage 01
				self:SetBodygroup(0,3)
				zwf.f.EmitSoundENT("zwf_joint_foldstage", self)

			elseif self.DoobyProgress == 9 then

				// Roll Stage 02
				self:SetBodygroup(0,4)
				zwf.f.EmitSoundENT("zwf_joint_foldstage", self)

			elseif self.DoobyProgress == 10 then

				// Roll Stage 03
				self:SetBodygroup(0,5)
				zwf.f.EmitSoundENT("zwf_joint_foldstage", self)

			elseif self.DoobyProgress == 11 then

				// Remove Roll Stage
				self:SetBodygroup(0,0)

				// Enable Finished Dooby
				self:SetBodygroup(3,1)

				// Play Grind Animation
				zwf.f.ClientAnim(self, "roll", 2)
				zwf.f.EmitSoundENT("zwf_joint_fold_finish", self)
			end
		end

	else
		self.DoobyProgress = -1
	end

	self:SetNextClientThink(CurTime())
	return true
end



function ENT:OnRemove()
end
