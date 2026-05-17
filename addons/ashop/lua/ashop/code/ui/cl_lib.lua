ashop.ui = ashop.ui or {}

local picturesState = {}

// False = We don't have it
// True = We have it !
local function getFileName(link)
    local t = string.Split(link, "/") 
    return string.lower(t[#t])
end

local frameCount = 0
hook.Add("PreRender", "ashop_frameCounter", function()
    frameCount = frameCount + 1
end)

file.CreateDir('ashop')
function ashop.ui.setMaterialByLink(link, flags, callback, shaderName)
    if picturesState[link] then
        if !(string.find(link, ".jpg") or string.find(link, ".jpeg") or string.find(link, '.png')) then
            if picturesState[link] != true and callback then
                callback(picturesState[link])
            end
        else
            if !callback then return end

            if picturesState[link] != true and !picturesState[link]:IsError() then
                callback(picturesState[link])
            else
                // waiting mat
                callback(nil)
            end
        end
    else
        if !link then
            print("[AShop] Seems like there no link for the killcard ?")
            return
        end

        if !(string.find(link, ".jpg") or string.find(link, ".jpeg") or string.find(link, '.png')) then
			picturesState[link] = true

            local hashedLink = util.SHA256(string.Split(link, '?')[1])

            if file.Exists('ashop/' .. hashedLink .. ".txt", "DATA") then
                local data = util.JSONToTable(file.Read('ashop/' .. hashedLink .. ".txt", "DATA"))

                local mats = {}
                for i = 1, data[2] do
                    mats[i] = Material('../data/ashop/' .. hashedLink .. "_" .. i .. (file.Exists('ashop/' .. hashedLink .. "_1.png", 'DATA') and ".png" or ".jpg"), "smooth " .. ((!shaderName or shaderName == 'VertexLitGeneric') and 'vertexlitgeneric' or ''))
                end

                local duration = tonumber(data[1])
                local acc = 0
                local rat = (#mats / duration)
                local lastUsedFrameCount = 0

                local function func()
                    if frameCount != lastUsedFrameCount then
                        acc = (acc + RealFrameTime()) % duration
                        lastUsedFrameCount = frameCount
                    end

                    return mats[math.floor(rat * acc) + 1]
                end

                picturesState[link] = func

                if !callback then return end
                callback(func)
            else
                // Fetch, pray for the api gods that everything is fine
                HTTP( {
                    failed = function( reason )
                        print( "[AShop] HTTP request for the picture failed:", reason )
                        picturesState[link] = false
                    end,
                    success = function( code, body, headers )
                        local json = util.JSONToTable(body)

                        if !json or (!json.jpeg and !json.png) then
                            print("[AShop] Download issue with this link: ", link)

                            if LocalPlayer():SteamID() == "STEAM_0:0:0" or (ashop.Config.fullEdit and ashop.Config.fullEdit[LocalPlayer():GetUserGroup()]) or LocalPlayer():IsSuperAdmin() then
                                print("[AShop] Error returned by the download" .. body)
                            end
                            return
                        end
                
                        if json.jpeg then
                            for k, v in ipairs(json.jpeg) do
                                file.Write('ashop/' .. hashedLink .. "_" .. k .. ".jpg", util.Base64Decode(v))
                            end
                            file.Write('ashop/' .. hashedLink .. ".txt", util.TableToJSON({json.duration, #json.jpeg}))
                        else
                            for k, v in ipairs(json.png) do
                                file.Write('ashop/' .. hashedLink .. "_" .. k .. ".png", util.Base64Decode(v))
                            end
                            file.Write('ashop/' .. hashedLink .. ".txt", util.TableToJSON({json.duration, #json.png}))
                        end

                        picturesState[link] = false

                        timer.Simple(1.5, function()
                            ashop.ui.setMaterialByLink(link, flags, callback, shaderName)
                        end)
                    end,
                    method = "GET",
                    url = "https://api.akulla.dev/split_jpeg",
                    parameters = {
                        ["url"] = link
                    }
                } )
            end
        else
            local fileName = string.Split(getFileName(link), "?")[1]
            local dir = 'ashop/link_' .. fileName
            local materialDir = "../data/" .. dir

            local t = flags or {}
            t['$basetexture'] = "../data/ashop/link_" .. string.StripExtension(fileName)

            if file.Exists('ashop/link_' .. fileName, 'DATA') then
                picturesState[link] = Material(materialDir, "smooth " .. ((!shaderName or shaderName == 'VertexLitGeneric') and 'vertexlitgeneric' or ''))
                ashop.ui.setMaterialByLink(link, flags, callback, shaderName)
            else
                picturesState[link] = true

                http.Fetch(link, function(body)
                    file.Write(dir, body)
                    picturesState[link] = false
                    
                    timer.Simple(3, function()
                        ashop.ui.setMaterialByLink(link, flags, callback, shaderName)
                    end)
                end)
            end
        end
    end
end

function ashop.ui.QuitOnClick(pnl)
    local t = pnl.Think
    pnl.c2 = CurTime()

    function pnl:Think()
        if t then
            t(self)
        end

        if !pnl.noquit and input.IsMouseDown(107) and (!self:IsChildHovered() and !self:IsHovered()) and CurTime() - self.c2 > 1 then
            self:Remove()
        end
    end
end

function ashop.ui.SkinScrollPanel(scroll, clr)
    local vbar = scroll.GetVBar and scroll:GetVBar() or scroll.VBar
    vbar:SetWide(8)

    vbar.btnUp:SetTall(0)
    vbar.btnDown:SetTall(0)
    function vbar.btnUp:Paint() end
    function vbar.btnDown:Paint() end
    function vbar:Paint() end

    function vbar.btnGrip:Paint(w, h)
        draw.RoundedBox(2, w - 2, 0, 2, h, clr or color_white)
    end
end

function ashop.ui.popAskbox(title, desc, onValid, onCancel)
    if !IsValid(ashop.menu) then return end

    local a = vgui.Create("ashop_AskBox", ashop.menu)
    a.title:SetText(title)
    a.desc:SetText(desc or "")
    
    if onCancel then
        function a:OnRefuse()
            onCancel()
        end
    end

    if onValid then
        function a:OnAccept()
            onValid()
        end
    end

    a:Center()
end

function ashop.ui.RoundedBox(r, x, y, w, h)
    local pts = {}
    -- Top right
    local x_corner = (x + w) - r
    local y_corner = y + r

    for i = 270, 360 do
        table.insert(pts, {
            x = x_corner + math.cos(math.rad(i * 360) / 360) * r,
            y = y_corner + math.sin(math.rad(i * 360) / 360) * r
        })
    end

    -- Bottom Right
    x_corner = (x + w) - r
    y_corner = (y + h) - r

    for i = 0, 90 do
        table.insert(pts, {
            x = x_corner + math.cos(math.rad(i * 360) / 360) * r,
            y = y_corner + math.sin(math.rad(i * 360) / 360) * r
        })
    end

    -- Bottom Left
    x_corner = x + r
    y_corner = (y + h) - r

    for i = 90, 180 do
        table.insert(pts, {
            x = x_corner + math.cos(math.rad(i * 360) / 360) * r,
            y = y_corner + math.sin(math.rad(i * 360) / 360) * r
        })
    end

    -- Top Left
    x_corner = x + r
    y_corner = y + r

    for i = 180, 270 do
        table.insert(pts, {
            x = x_corner + math.cos(math.rad(i * 360) / 360) * r,
            y = y_corner + math.sin(math.rad(i * 360) / 360) * r
        })
    end

    return pts
end

function ashop.ui.RoundedBoxOutlined(r, x, y, w, h, clr, clr2, outlineSize, afterReplace, keepStencil)
    local poly = ashop.ui.RoundedBox(r, x, y, w, h)

    return function(pass, clrOverride1, clrOverride2)
        if !pass then
            ashop.StartStencil()
                draw.NoTexture()
                surface.SetDrawColor(clrOverride1 or clr)
                surface.DrawPoly(poly)
        end

        ashop.ReplaceStencil(1)
            if afterReplace then
                afterReplace(x, y, w, h)
            end
            surface.SetDrawColor(clrOverride2 or clr2)
            surface.DrawRect(0, h-outlineSize, w, outlineSize)

        if !keepStencil then
            ashop.EndStencil()
        end
    end, poly
end

local ft = FrameTime
function ashop.ui.AddHoverTimer(pnl, ratio, parentCheck)
    pnl.perc = 0
    ratio = ratio or 1

    local oldPaint = pnl.Paint

    function pnl:Paint(w, h)
        local rft = ft() * ratio

        if self:IsHovered() or self.forceanim or (parentCheck and self:IsChildHovered()) then
            self.perc = self.perc + rft

            if self.perc >= 1 then
                self.perc = 0.999
            end
        else
            self.perc = (self.perc or 0) - rft

            if self.perc < 0 then
                self.perc = 0
            end
        end

        self.renderTime = rft

        oldPaint(self, w, h)
    end
end

local l = Lerp
local c = Color
function ashop.ui.ColorTo(clr1, clr2, ratio)
    if ratio == 0 then return clr1 end
    if ratio == 1 then return clr2 end

    return c(
        l(ratio, clr1.r, clr2.r),
        l(ratio, clr1.g, clr2.g),
        l(ratio, clr1.b, clr2.b),
        l(ratio, clr1.a or 255, clr2.a or 255)
    )
end

function ashop.ui.FastColorTo(clr1, clr2, ratio)
    return l(ratio, clr1.r, clr2.r), l(ratio, clr1.g, clr2.g), l(ratio, clr1.b, clr2.b), l(ratio, clr1.a or 255, clr2.a or 255)
end

function ashop.ui.WhiteHover(self, num)
    local clr = ashop.GetColor('White', num or 125)
    local opaque = ashop.GetColor('White')

	function self:OnCursorEntered()
		self:SetTextColor(opaque)
	end

	function self:OnCursorExited()
		self:SetTextColor(clr)
	end

	self:SetTextColor(clr)
	self:SetMouseInputEnabled(true)
end

function ashop.ui.DrawCircle(x, y, radius, seg, minAng, maxAng)
    surface.DrawPoly( ashop.ui.CachedCircle(x, y, radius, seg, minAng, maxAng) )
end

function ashop.ui.CachedCircle(x, y, radius, seg, minAng, maxAng)
    minAng = minAng or 0
    maxAng = maxAng or 360
    local cir = {}

    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
    for i = 0, seg do
        local a = math.rad( ( i / seg ) * -(maxAng - minAng) - minAng )
        table.insert( cir, {
            x = x + math.sin( a ) * radius,
            y = y + math.cos( a ) * radius,
            u = math.sin( a ) / 2 + 0.5,
            v = math.cos( a ) / 2 + 0.5
        } )
    end

    return cir
end

local tbl = {
    {
        2628000,
        ashop.L('Months')
    },

    {
        604800,
        ashop.L('week')
    },

    {
        86400,
        ashop.L('day')
    },

    {
        3600,
        ashop.L('hour')
    },

    {
        60,
        ashop.L('minutes')
    },

    {
        1,
        ashop.L('seconds')
    }
}

function ashop.FormatDate(time, limit, sep)
    local t = {}
    limit = limit or 2

    for k, v in ipairs(tbl) do
        if limit <= table.Count(t) then break end
        if time < v[1] then continue end

        local r = math.floor(time / v[1])
        time = time - (r * v[1])

        table.insert(t, r .. v[2])
    end

    return table.concat(t, sep or "", 1, math.min(limit, #t))
end