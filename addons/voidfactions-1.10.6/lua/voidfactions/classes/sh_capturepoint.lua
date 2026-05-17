VoidFactions.CapturePoints = VoidFactions.CapturePoints or {}

-- Class

local CAPTUREPOINT_CLASS = {}
CAPTUREPOINT_CLASS.__index = CAPTUREPOINT_CLASS

function CAPTUREPOINT_CLASS:New(id, pos, radius)
	local newObject = setmetatable({}, CAPTUREPOINT_CLASS)
		newObject.id = id
        newObject.pos = pos
        newObject.radius = radius
    
        newObject.isSelected = false
        newObject.captureInProgress = false

        newObject.isPaused = false
        newObject.pauseTime = 0

        newObject.capturingBy = nil

        newObject.capturingPlayers = {}
        newObject.isContested = false

        newObject.captureFaction = nil 
        newObject.captureStart = 0 -- curtime
        newObject.captureEnd = 0

        newObject.previousPlayers = {}
        newObject.previousPlayersSeq = {}

	return newObject
end

-- Setter functions

function CAPTUREPOINT_CLASS:SetPos(pos)
    self.pos = pos
end

function CAPTUREPOINT_CLASS:SetRadius(radius)
    self.radius = radius
end

function CAPTUREPOINT_CLASS:SetCapturingPlayers(plys)
    self.capturingPlayers = plys
end

function CAPTUREPOINT_CLASS:SetFaction(faction)
    self.captureFaction = faction
end

function CAPTUREPOINT_CLASS:SetCaptureStart(start)
    self.captureStart = start
end

-- Functions

function VoidFactions.CapturePoints:InitCapturePoint(...)
    return CAPTUREPOINT_CLASS:New(...)
end