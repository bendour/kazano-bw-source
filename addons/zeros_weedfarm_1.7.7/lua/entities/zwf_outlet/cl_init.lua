include("shared.lua")

function ENT:Initialize()
	self.Cached_Rope = false
	self.RopeRefresh = true
	self.LastPowerLevel = -1

	self.Output01 = nil
	self.Output02 = nil
	self.Output03 = nil

	zwf.f.EntList_Add(self)
end

function ENT:Draw()
	self:DrawModel()


	zwf.f.UpdateEntityVisuals(self)
end

function ENT:Think()
	if zwf.f.InDistance(LocalPlayer():GetPos(), self:GetPos(), 1000) then

		local _Output01 = self:GetOutput01()
		local _Output02 = self:GetOutput02()
		local _Output03 = self:GetOutput03()

		if self.Output01 ~= _Output01 then
			self.Output01 = _Output01

			if IsValid(self.Output01) then
				self:SetBodygroup(1,1)
			else
				self:SetBodygroup(1,0)
			end
		end

		if self.Output02 ~= _Output02 then
			self.Output02 = _Output02

			if IsValid(self.Output02) then
				self:SetBodygroup(2,1)
			else
				self:SetBodygroup(2,0)
			end
		end

		if self.Output03 ~= _Output03 then
			self.Output03 = _Output03

			if IsValid(self.Output03) then
				self:SetBodygroup(3,1)
			else
				self:SetBodygroup(3,0)
			end
		end
	else

		self.Output01 = nil
		self.Output02 = nil
		self.Output03 = nil
	end
end


function ENT:UpdateVisuals()

	if IsValid(self.Output01) then
		self:SetBodygroup(1,1)
	else
		self:SetBodygroup(1,0)
	end

	if IsValid(self.Output02) then
		self:SetBodygroup(2,1)
	else
		self:SetBodygroup(2,0)
	end

	if IsValid(self.Output03) then
		self:SetBodygroup(3,1)
	else
		self:SetBodygroup(3,0)
	end
end
