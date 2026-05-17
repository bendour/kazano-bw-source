-- [[ CREATED BY ZOMBIE EXTINGUISHER ]]

local textSizes = {
	10,
	20,
	30,
	40,
	50,
	60,
	70,
	80,
	90,
	100,
	125,
	150
}

local fonts = {
	"hades",
	"Classic Console",
	"Roboto",
	"Coolvetica",
	"Akbar",
	"Courier New",
	"Verdana",
	"Tahoma",
	"Trebuchet MS",
	"HalfLife2",
}

local colorInfos = {
	["White"] = {f = color_white, b = color_black},
	["Black"] = {f = color_black, b = color_white},
	["Red"] = {f = SH_HADEZ.VAR.COLOR.RED, b = color_black},
	["Blue"] = {f = SH_HADEZ.VAR.COLOR.LIGHTBLUE, b = color_black},
	["Green"] = {f = SH_HADEZ.VAR.COLOR.GREEN, b = color_black},
	["Orange"] = {f = SH_HADEZ.VAR.COLOR.ORANGE, b = color_black},
	["Yellow"] = {f = SH_HADEZ.VAR.COLOR.YELLOW, b = color_black},
	["Purple"] = {f = SH_HADEZ.VAR.COLOR.PURPLE, b = color_black},
	["Fuchsia"] = {f = SH_HADEZ.VAR.COLOR.FUCHSIA, b = color_black},
	["HAD3Z Blue"] = {f = SH_HADEZ.VAR.COLOR.LIGHTBLUE, b = SH_HADEZ.VAR.COLOR.DARKBLUE},
}

local prevRandCol = 0
colorInfos["Random"] = {Think = function()
	
	if prevRandCol < CurTime() then
	
		local colorInfo = colorInfos["Random"]
		colorInfo.f = ColorRand()
		
		prevRandCol = CurTime() + 0.35
		
	end
	
end}

colorInfos["Random (letter)"] = {Think = function(rowLbl)
	
	if (rowLbl.nextRandCol or 0) < CurTime() then
	
		local colorInfo = colorInfos["Random (letter)"]
		
		for i=1, #rowLbl.charTbl do
			rowLbl.charTbl[i].col = ColorRand()
		end
		
		rowLbl.nextRandCol = CurTime() + 0.35
		
	end
		
end}

local colors = table.GetKeys(colorInfos)
table.sort(colors, function(a, b) return a:lower() < b:lower() end)

function SH_HADEZ:GetTextSizes()
	return table.Copy(textSizes)
end

function SH_HADEZ:GetTextFonts()
	return table.Copy(fonts)
end

function SH_HADEZ:GetTextColors()
	return table.Copy(colors)
end

function SH_HADEZ:GetHackyTextFont(font, size)
	
	size = size or ""

	return "z_hadez_hackytext_"..font..size
	
end

if CLIENT then

	for i=1, #fonts do
		
		local font = fonts[i]
		
		surface.CreateFont( "z_hadez_hackytext_"..font, {
			font = font,
			size = 14,
			weight = 500,
			antialias = true
		} )
	
		for ii=1, #textSizes do
		
			local size = textSizes[ii]
			
			surface.CreateFont( "z_hadez_hackytext_"..font..size, {
				font = font,
				size = size,
				weight = 500,
				antialias = true
			} )
		
		end
	
	end
	
	-- Performance
	local surf =  {}
	surf.SetFont =	surface.SetFont
	surf.SetTextColor =	surface.SetTextColor
	surf.SetTextPos =	surface.SetTextPos
	surf.DrawText =	surface.DrawText
	surf.GetTextSize =	surface.GetTextSize
	local Rand = math.Rand
	
	-- Bugs out with new lines, etc
	local function SanitiseHackyText(str)
		return string.gsub(str, "[%c%s]", " ")
	end
	
	local alphabet = "abcdefghijklmnopqrstuvwxyz"
	local activeTextLabels = {}
	
	local function CalculateTextLabels(text, font, size, color, time)
	
		local scrW, scrH = ScrW(), ScrH()
		local timePerLetter = math.Round(time/3)/#text
		local bgOffset = size*0.05
		local colorInfo = colorInfos[color]
		
		-- Divide text over several rows
		local textRows = {}
		local curText = ""
		local prevSpaceText = "" 
		
		surface.SetFont(font)
		
		for i=1, #text do
			
			local char = text[i]
			char = SanitiseHackyText(char)
		
			curText = curText..char
			
			if char == " " then
				prevSpaceText = curText
			end
			
			local textW = surface.GetTextSize(curText)
			
			if textW > scrW*0.95 then
				
				if char ~= " " and #prevSpaceText > 0 then
					-- print("no space", curText, prevSpaceText, string.Trim(string.sub( curText, #prevSpaceText )))
					table.insert(textRows, prevSpaceText)
					curText = string.sub( curText, #prevSpaceText )
					
				else
					-- print("space devide", curText)
					table.insert(textRows, curText)
					curText = ""
				
				end
				
				prevSpaceText = ""
				
			end
		
		end
		
		if #curText > 0 then
			table.insert(textRows, curText)
		end
	
		-- Create text labels for each row
		local nextY = scrH*0.05
		local nextStartLetterShow = CurTime()
	
		for i=1, #textRows do
			
			local textRow = textRows[i]
			
			local rowLbl = vgui.Create("DLabel")
			rowLbl:SetPos(0, nextY)
			rowLbl:SetFont(font)
			rowLbl:SetContentAlignment(7)
			rowLbl:SetText(textRow)
			rowLbl:SetColor(color_white)
			rowLbl:SizeToContents()
			rowLbl:CenterHorizontal()

			-- Performance
			rowLbl.PerformLayout = nil 
			rowLbl.InvalidateLayout = nil
			
			rowLbl:SetText("")
			
			rowLbl.charTbl = {}

			for i=1, #textRow do
				rowLbl.charTbl[i] = {
					symbol = textRow[i]
				}
			end
			
			function rowLbl:GetChar(index)
				return rowLbl.charTbl[index]
			end
			
			function rowLbl:SetChar(index, char)
				rowLbl.charTbl[index].symbol = char
			end
			
			local rowLblInitialized = false
			rowLbl.Paint = function(self, w, h)
				
				for i=1, #self.charTbl do
					
					local char = self.charTbl[i]
					local prevChar = self.charTbl[i-1]
					
					if !char.x then
						
						surf.SetFont(font)
						local charW, charH = surf.GetTextSize(char.symbol)
						
						char.x = 0
						
						if prevChar then
							char.x = prevChar.x + prevChar.w
						end
						
						char.y = h/2 - charH/2
						char.w = charW
						char.h = charH
						char.isSpace = string.match( char.symbol, "[%c%s]") ~= nil
						
						if i == #self.charTbl then
							rowLblInitialized = true
						end
			
					end
					
					if rowLblInitialized then

						surf.SetFont(font)
					
						-- BG
						surf.SetTextColor( colorInfo.b or color_black )
						surf.SetTextPos( char.x+bgOffset, char.y+bgOffset )
						surf.DrawText( char.symbol )
						
						-- FG
						surf.SetTextColor( colorInfo.f or char.col or color_white )
						surf.SetTextPos( char.x, char.y )
						surf.DrawText( char.symbol )
					
					end
					
				end
				
			end
			
			local realTextIndex = 0
			local nextLetter = nextStartLetterShow
			
			rowLbl.Think = function(self)
			
				-- Color think
				if colorInfo.Think then
					colorInfo.Think(self)
				end
			
				if !rowLblInitialized or realTextIndex == #textRow then return end
				
				-- Real letters
				if nextLetter < CurTime() then
				
					realTextIndex = realTextIndex + 1
					self:SetChar(realTextIndex, textRow[realTextIndex])
				
					nextLetter = CurTime()+timePerLetter
					
				end
				
				-- Random letters
				for i=1+realTextIndex, #textRow do
					
					if textRow[i] ~= " " then
						self:SetChar(i, alphabet[Rand(1,string.len(alphabet))])
					end
					
				end
				
			end
				
			timer.Simple(time, function()
			
				if IsValid(rowLbl) then
					table.RemoveByValue(activeTextLabels, rowLbl)
					rowLbl:Remove()
				end
				
			end)
			
			nextY = rowLbl:GetBottomY()+scrH*0.01
			nextStartLetterShow = nextStartLetterShow + (timePerLetter*#textRow)
			activeTextLabels[i] = rowLbl
			
		end
		
	end
	
	local function ShowHackyText()
	
		local scrW, scrH = ScrW(), ScrH()
		local text = net.ReadString()
		local size = net.ReadUInt(8)
		local font = net.ReadString()
		local color = net.ReadString()
		local time = net.ReadUInt(4)
		
		-- Hide any active text labels
		for i=1, #activeTextLabels do
		
			if IsValid(activeTextLabels[i]) then
				activeTextLabels[i]:Hide()
			end
			
		end
		
		CalculateTextLabels(text, SH_HADEZ:GetHackyTextFont(font, size), size, color, time)
		
	end
	net.Receive("z_hadez_ShowHackyText", ShowHackyText)

end

function SH_HADEZ:HasHackyText(ply)
	return ply:GetNWBool("z_hadez_HackyText")
end

if SERVER then

	function SV_HADEZ:SetHackyText(ply, bool)
		ply:SetNWBool("z_hadez_HackyText", bool)
	end
	
end
