-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

function SH_HADEZ:IsJumpscared(ply)
	return ply:GetNWBool("z_hadez_Jumpscare")
end

function SH_HADEZ:GetJumpscareOption(ply, option)
	return ply:GetNWString("z_hadez_JumpscareOption"..option)
end

local jumpscareModes = {
	"instant",
	"slow"
}

-- Jumpscare starts directly
local instantSoundEffects = {
	"fnaf.mp3",
	"honestly.mp3",
	"insidious.mp3",
	"mazegame.mp3",
	"organ.mp3",
	"redman.mp3",
	"scream.mp3",
	"static.mp3",
	"withered.mp3"
}

function SH_HADEZ:IsInstantSoundEffect(effect)
	return table.HasValue(instantSoundEffects, effect)
end


-- Jumpscare kicks in at 30 second mark
local longSoundEffects = {
	"tiptoe.mp3",
	"thering.mp3",
	"insidious_long.mp3",
	"conjuring.mp3",
}

local visualEffects = {
	"mazegame",
	"jeffkiller",
	"freddy",
	"insidious",
	"nun",
	"thering",
	"thering_victim",
}

function SH_HADEZ:GetJumpscareModes()
	return jumpscareModes
end

function SH_HADEZ:GetJumpscareSounds()
	return table.Copy(instantSoundEffects), table.Copy(longSoundEffects)
end

function SH_HADEZ:GetJumpscareVisuals()
	return table.Copy(visualEffects)
end

if SERVER then

	function SV_HADEZ:SetJumpscareOptions(ply, options)
	
		for name, value in pairs(options) do
			ply:SetNWString("z_hadez_JumpscareOption"..name, value)
		end
		
	end

	util.AddNetworkString("z_hadez_JumpscarePlayers")
	local function JumpscarePlayers(len, ply)
	
		if !SH_HADEZ:HasAccess(ply, "jumpscare") then return end
		
		local targets = SH_HADEZ:NetReadPlayers()
		local jumpscareOptions = {
			mode = net.ReadString(),
			soundEffect = net.ReadString(),
			extraSoundEffect = net.ReadString(),
			visualEffect = net.ReadString()
		}
		
		SV_HADEZ:LogFeature("jumpscareLog", "jumpscare", ply, targets, function(ply)
			if !IsValid(ply) or SH_HADEZ:IsJumpscared(ply) then 
				return nil
			end
			return true
		end)
		
		for i=1, #targets do
			SV_HADEZ:OnJumpscareStart(targets[i], jumpscareOptions)
		end
		
	end
	net.Receive("z_hadez_JumpscarePlayers", JumpscarePlayers)
	
	util.AddNetworkString("z_hadez_PlayJumpscare")
	function SV_HADEZ:OnJumpscareStart(target, options)
	
		if !IsValid(target) or SH_HADEZ:IsJumpscared(target) then return end
		
		SV_HADEZ:SetJumpscareOptions(target, options)
		target:SetNWBool("z_hadez_Jumpscare", true)
		SV_HADEZ:OnPowerToggled(target, "jumpscare", true)
		
		local isInstantSoundEffect = SH_HADEZ:IsInstantSoundEffect(options.soundEffect)
		local canRetargetDelay = isInstantSoundEffect and 5 or 35
		
		timer.Simple(canRetargetDelay, function()
			if IsValid(target) then
				target:SetNWBool("z_hadez_Jumpscare", false)
				SV_HADEZ:OnPowerToggled(target, "jumpscare", false)
			end
		end)
		
		-- Play sound effect
		net.Start("z_hadez_PlayJumpscare")
			net.WriteString(options.soundEffect)
			net.WriteString(options.visualEffect)
		net.Send(target)
	
	end
	
end

if CLIENT then

	local imageOffsetX, imageOffsetY  = ScrW()*0.005, ScrH()*0.005

	local function ShowJumpscareVisual(visualEffect)
	
		local xPos, yPos = -imageOffsetX*2, -imageOffsetY*2
		local image = vgui.Create("DImage")
		image:SetPos(xPos, yPos)
		image:SetSize(ScrW()+(imageOffsetX*4), ScrH()+(imageOffsetY*4))
		image:SetVisible(false)
		image:SetImage("z_hadez/jumpscare/"..visualEffect)
		
		image.Think = function(self)
			
			local randX = math.Rand( -imageOffsetX, imageOffsetX )
			local randY = math.Rand( -imageOffsetY, imageOffsetY )
			
			self:SetPos(xPos+randX, yPos+randY)
			
		end
		
		timer.Simple(0.25, function()
			if IsValid(image) then
				image:SetVisible(true)
			end
		end)
		
		timer.Simple(2.25, function()
			if IsValid(image) then
				image:Remove()
			end
		end)
	
	end
	
	local function PlaySound(soundEffect, boost)
		boost = boost or 10
	
		-- Boost volume
		for i=1, boost do
			surface.PlaySound("z_hadez/jumpscare/"..soundEffect)
		end 
	end
	
	
	local longSoundEffect

	local function PlayJumpscare()
		
		local ply = LocalPlayer()
		local soundEffect = net.ReadString()
		local visualEffect = net.ReadString()
		
		if SH_HADEZ:IsInstantSoundEffect(soundEffect) then
		
			PlaySound(soundEffect)
			ShowJumpscareVisual(visualEffect)
			
		else
		
			PlaySound(soundEffect, 2)
			
			-- Backup for when stopsound is used
			longSoundEffect = CreateSound(game.GetWorld(), "z_hadez/jumpscare/"..soundEffect)
			longSoundEffect:SetSoundLevel(0)
			longSoundEffect:Play()
		
			timer.Simple(30, function()
				if longSoundEffect.Stop ~= nil then
					longSoundEffect:Stop()
				end
				longSoundEffect = nil
				PlaySound(SH_HADEZ:GetJumpscareOption(ply, "extraSoundEffect"))
				ShowJumpscareVisual(visualEffect)
			end)
			
		end
		
	end
	net.Receive("z_hadez_PlayJumpscare", PlayJumpscare)
	
	-- Keep sound alive (blocks stopsound)
	local function Think()
	
		local ply = LocalPlayer()
		
		if !SH_HADEZ:IsJumpscared(ply) then return end
		
		if longSoundEffect and longSoundEffect.ChangeVolume ~= nil then
			longSoundEffect:ChangeVolume(math.Rand(0.99, 1), 0) -- Has to be a new value or it doesnt update
		end
	
	end
	hook.Add("Think", "z_hadez_Jumpscare", Think)

end