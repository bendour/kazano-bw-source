-- Modern HTML Admin Menu
-- Client-side DHTML integration

local HTMLLoader = include("darkrp/gamemode/modules/admin_menu/html_loader.lua")

-- Global avatar cache (persists between menu opens)
BaseWars.AdminMenuAvatarCache = BaseWars.AdminMenuAvatarCache or {}

-- Pending avatar requests to avoid duplicates
local pendingAvatarRequests = {}

local PANEL = {}

function PANEL:Init()
    self.localPlayer = LocalPlayer()
    
    self:SetSize(ScrW(), ScrH())
    self:Center()
    self:MakePopup()
    self:SetTitle("")
    self:SetDraggable(false)
    self:ShowCloseButton(false)
    
    -- Use global cache
    self.avatarCache = BaseWars.AdminMenuAvatarCache
    
    -- Create DHTML panel
    self.HTML = self:Add("DHTML")
    self.HTML:SetSize(ScrW() * 0.85, ScrH() * 0.85)
    self.HTML:Center()
    
    -- Add Lua functions for JavaScript (deferred to avoid freeze)
    timer.Simple(0, function()
        if IsValid(self) then
            self:SetupJSFunctions()
        end
    end)
    
    -- Load HTML content
    local html = HTMLLoader.Get()
    self.HTML:SetHTML(html)
    
    -- Set admin info after page loads
    timer.Simple(0.5, function()
        if IsValid(self) and IsValid(self.HTML) then
            self:SetAdminInfo()
        end
    end)
end

function PANEL:SetupJSFunctions()
    -- Close menu
    self.HTML:AddFunction("adminmenu", "close", function()
        BaseWars:CloseAdminMenu()
    end)
    
    -- Search player
    self.HTML:AddFunction("adminmenu", "searchPlayer", function(query)
        net.Start("BaseWars:AdminMenu:SearchPlayer")
        net.WriteString(query)
        net.SendToServer()
    end)
    
    -- Request online players
    self.HTML:AddFunction("adminmenu", "requestPlayers", function()
        net.Start("BaseWars:AdminMenu:RequestPlayers")
        net.SendToServer()
    end)
    
    self.HTML:AddFunction("adminmenu", "requestOnlinePlayers", function()
        net.Start("BaseWars:AdminMenu:RequestOnlinePlayers")
        net.SendToServer()
    end)
    
    -- Request player details
    self.HTML:AddFunction("adminmenu", "requestPlayerDetails", function(steamid64)
        net.Start("BaseWars:AdminMenu:RequestPlayerDetails")
        net.WriteString(steamid64)
        net.SendToServer()
    end)
    
    -- Warnings functions
    self.HTML:AddFunction("adminmenu", "requestWarnings", function(steamid64)
        net.Start("BaseWars:AdminMenu:RequestWarnings")
        net.WriteString(steamid64)
        net.SendToServer()
    end)
    
    self.HTML:AddFunction("adminmenu", "addWarning", function(steamid64, reason)
        net.Start("BaseWars:AdminMenu:AddWarning")
        net.WriteString(steamid64)
        net.WriteString(reason)
        net.SendToServer()
    end)
    
    self.HTML:AddFunction("adminmenu", "deleteWarning", function(warningId)
        net.Start("BaseWars:AdminMenu:DeleteWarning")
        net.WriteUInt(warningId, 32)
        net.SendToServer()
    end)
    
    -- Factions functions (use local client data)
    self.HTML:AddFunction("adminmenu", "requestFactions", function()
        self:SendFactionData()
    end)
    
    self.HTML:AddFunction("adminmenu", "disbandFaction", function(factionName)
        net.Start("BaseWars:Factions:Admin:Disband")
        net.WriteString(factionName)
        net.SendToServer()
        -- Refresh after action
        timer.Simple(0.5, function()
            if IsValid(self) then self:SendFactionData() end
        end)
    end)
    
    self.HTML:AddFunction("adminmenu", "changeLeader", function(factionName, oldLeaderSteamID, newLeaderSteamID)
        local oldLeader = BaseWars:FindPlayer(oldLeaderSteamID)
        local newLeader = BaseWars:FindPlayer(newLeaderSteamID)
        if not IsValid(oldLeader) or not IsValid(newLeader) then return end
        
        net.Start("BaseWars:Factions:Admin:ChangeLeader")
        net.WriteString(factionName)
        net.WriteEntity(oldLeader)
        net.WriteEntity(newLeader)
        net.SendToServer()
        -- Refresh after action
        timer.Simple(0.5, function()
            if IsValid(self) then self:SendFactionData() end
        end)
    end)
    
    self.HTML:AddFunction("adminmenu", "kickFromFaction", function(factionName, steamid64)
        local target = BaseWars:FindPlayer(steamid64)
        if not IsValid(target) then return end
        
        net.Start("BaseWars:Factions:Admin:KickMember")
        net.WriteString(factionName)
        net.WriteEntity(target)
        net.SendToServer()
        -- Refresh after action
        timer.Simple(0.5, function()
            if IsValid(self) then self:SendFactionData() end
        end)
    end)
    
    -- Immunities functions
    self.HTML:AddFunction("adminmenu", "requestImmunities", function()
        self:SendImmunitiesData()
    end)
    
    self.HTML:AddFunction("adminmenu", "resetGlobalImmunity", function()
        net.Start("BaseWars:ResetGlobalImmunity")
        net.SendToServer()
    end)
    
    self.HTML:AddFunction("adminmenu", "resetFactionImmunity", function(factionName)
        net.Start("BaseWars:Factions:Admin:ResetImmunity")
        net.WriteString(factionName)
        net.SendToServer()
    end)
    
    self.HTML:AddFunction("adminmenu", "resetPlayerImmunity", function(steamid64)
        net.Start("BaseWars:ResetPlayerImmunity")
        net.WriteString(steamid64)
        net.SendToServer()
    end)
    
    -- Logs functions
    self.HTML:AddFunction("adminmenu", "requestLogCategories", function()
        net.Start("BaseWars:AdminMenu:RequestLogCategories")
        net.SendToServer()
    end)
    
    self.HTML:AddFunction("adminmenu", "requestLogs", function(module, page)
        net.Start("BaseWars:AdminMenu:RequestLogs")
        net.WriteString(module or "all")
        net.WriteUInt(page or 1, 16)
        net.SendToServer()
    end)
    
    -- Player actions
    self.HTML:AddFunction("adminmenu", "gotoPlayer", function(steamid64)
        net.Start("BaseWars:AdminMenu:GotoPlayer")
        net.WriteString(steamid64)
        net.SendToServer()
    end)
    
    self.HTML:AddFunction("adminmenu", "bringPlayer", function(steamid64)
        net.Start("BaseWars:AdminMenu:BringPlayer")
        net.WriteString(steamid64)
        net.SendToServer()
    end)
    
    self.HTML:AddFunction("adminmenu", "kickPlayer", function(steamid64)
        net.Start("BaseWars:AdminMenu:KickPlayer")
        net.WriteString(steamid64)
        net.SendToServer()
    end)
    
    -- Request avatar from Steam profile
    self.HTML:AddFunction("adminmenu", "requestAvatar", function(steamid64)
        self:FetchSteamAvatar(steamid64)
    end)
    
    -- Copy to clipboard
    self.HTML:AddFunction("adminmenu", "copyToClipboard", function(text)
        SetClipboardText(text)
    end)
end

-- Rate limiting for avatar fetches
local avatarFetchQueue = {}
local isProcessingQueue = false
local AVATAR_FETCH_DELAY = 0.1 -- 100ms between requests

local function ProcessAvatarQueue()
    if isProcessingQueue or #avatarFetchQueue == 0 then return end
    
    isProcessingQueue = true
    local item = table.remove(avatarFetchQueue, 1)
    
    if item and item.panel and IsValid(item.panel) then
        item.panel:DoFetchSteamAvatar(item.steamid64)
    end
    
    timer.Simple(AVATAR_FETCH_DELAY, function()
        isProcessingQueue = false
        ProcessAvatarQueue()
    end)
end

-- Fetch Steam avatar and send URL to JavaScript
function PANEL:FetchSteamAvatar(steamid64)
    if not steamid64 or steamid64 == "" then return end
    if not IsValid(self) then return end
    
    -- Check if already cached (global cache)
    if BaseWars.AdminMenuAvatarCache[steamid64] then
        self:SendAvatarToJS(steamid64, BaseWars.AdminMenuAvatarCache[steamid64])
        return
    end
    
    -- Check if already in queue
    if pendingAvatarRequests[steamid64] then return end
    pendingAvatarRequests[steamid64] = true
    
    -- Add to queue for rate-limited processing
    table.insert(avatarFetchQueue, {
        panel = self,
        steamid64 = steamid64
    })
    
    ProcessAvatarQueue()
end

-- Actual fetch function (called from queue)
function PANEL:DoFetchSteamAvatar(steamid64)
    if not IsValid(self) then
        pendingAvatarRequests[steamid64] = nil
        return
    end
    
    -- Store reference to self for callback
    local panelRef = self
    
    -- Fetch from Steam XML profile
    http.Fetch("https://steamcommunity.com/profiles/" .. steamid64 .. "?xml=1",
        function(body, size, headers, code)
            pendingAvatarRequests[steamid64] = nil
            
            -- Check if panel still exists
            if not IsValid(panelRef) then return end
            
            if size == 0 or code < 200 or code > 299 then
                return
            end
            
            -- Extract avatarFull URL from XML
            local avatarUrl = body:match("<avatarFull><!%[CDATA%[(.-)%]%]></avatarFull>")
            if not avatarUrl then
                avatarUrl = body:match("<avatarFull>(.-)</avatarFull>")
            end
            
            if avatarUrl then
                -- Save to global cache
                BaseWars.AdminMenuAvatarCache[steamid64] = avatarUrl
                panelRef:SendAvatarToJS(steamid64, avatarUrl)
            end
        end,
        function(err)
            pendingAvatarRequests[steamid64] = nil
        end
    )
end

function PANEL:SendAvatarToJS(steamid64, avatarUrl)
    if not IsValid(self) or not IsValid(self.HTML) then return end
    
    if avatarUrl then
        self.HTML:RunJavascript(string.format(
            "receiveAvatar(%q, %q);",
            steamid64, avatarUrl
        ))
    end
end

-- Send faction data from client-side cache to JavaScript
function PANEL:SendFactionData()
    if not IsValid(self) or not IsValid(self.HTML) then return end
    
    local factions = {}
    local allFactions = BaseWars:GetFactions()
    
    if allFactions then
        for factionName, factionData in pairs(allFactions) do
            local leader = factionData.leader
            local members = {}
            
            -- Get members
            if factionData.members then
                for _, memberPly in ipairs(factionData.members) do
                    if IsValid(memberPly) then
                        table.insert(members, {
                            steamid64 = memberPly:SteamID64(),
                            name = memberPly:Nick()
                        })
                    end
                end
            end
            
            -- Build faction data
            local colorHex = "#ffffff"
            if factionData.color then
                colorHex = string.format("#%02x%02x%02x", factionData.color.r, factionData.color.g, factionData.color.b)
            end
            
            table.insert(factions, {
                name = factionName,
                id = factionData.id or 0,
                color = colorHex,
                leader = {
                    steamid64 = IsValid(leader) and leader:SteamID64() or "",
                    name = IsValid(leader) and leader:Nick() or "Inconnu"
                },
                members = members,
                ff = factionData.ff or false,
                immunity = factionData.immunity or 0
            })
        end
    end
    
    local json = util.TableToJSON(factions)
    self.HTML:RunJavascript(string.format("receiveFactions(%q);", json))
end

-- Send immunities data to JavaScript
function PANEL:SendImmunitiesData()
    if not IsValid(self) or not IsValid(self.HTML) then return end
    
    local data = {
        global = BaseWars.GetGlobalImmunity and BaseWars:GetGlobalImmunity() or 0,
        factions = {},
        players = {}
    }
    
    -- Get faction immunities
    local allFactions = BaseWars:GetFactions()
    if allFactions then
        for factionName, factionData in pairs(allFactions) do
            local colorHex = "#ffffff"
            if factionData.color then
                colorHex = string.format("#%02x%02x%02x", factionData.color.r, factionData.color.g, factionData.color.b)
            end
            
            -- Calculate remaining immunity time
            local immunityTime = 0
            if factionData.immunity and factionData.immunity > CurTime() then
                immunityTime = math.floor(factionData.immunity - CurTime())
            end
            
            table.insert(data.factions, {
                name = factionName,
                color = colorHex,
                immunity = immunityTime
            })
        end
    end
    
    -- Get player immunities
    for _, ply in player.Iterator() do
        local immunityTime = 0
        if ply.GetRaidImmunity then
            local immunity = ply:GetRaidImmunity()
            if immunity and immunity > 0 then
                immunityTime = math.floor(immunity)
            end
        end
        
        table.insert(data.players, {
            name = ply:Nick(),
            steamid64 = ply:SteamID64(),
            immunity = immunityTime
        })
    end
    
    local json = util.TableToJSON(data)
    self.HTML:RunJavascript(string.format("receiveImmunities(%q);", json))
end

function PANEL:SetAdminInfo()
    local name = self.localPlayer:Name()
    local rank = self.localPlayer:GetUserGroup()
    local steamid64 = self.localPlayer:SteamID64()
    
    -- Set admin info with default avatar first
    local defaultAvatar = "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_full.jpg"
    
    self.HTML:RunJavascript(string.format(
        "setAdminInfo(%q, %q, %q);",
        name, rank, defaultAvatar
    ))
    
    -- Fetch real avatar
    self:FetchSteamAvatar(steamid64)
    
    -- Update admin avatar when fetched
    timer.Simple(1, function()
        if IsValid(self) and self.avatarCache and self.avatarCache[steamid64] then
            self.HTML:RunJavascript(string.format(
                "document.querySelector('.admin-avatar img').src = %q;",
                self.avatarCache[steamid64]
            ))
        end
    end)
end

function PANEL:RunJS(code)
    if IsValid(self.HTML) then
        self.HTML:RunJavascript(code)
    end
end

function PANEL:OnKeyCodePressed(key)
    if input.LookupKeyBinding(key) == "bw_adminmenu" then
        BaseWars:CloseAdminMenu()
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 230))
    
    if LocalPlayer():GetBaseWarsConfig("bluredBackground") then
        BaseWars:DrawBlur(self, 4)
    end
end

function PANEL:Think()
    if not BaseWars:IsAdmin(self.localPlayer, true) then
        self:Remove()
    end
end

vgui.Register("BaseWars.AdminMenuHTML", PANEL, "DFrame")

-- Net receivers for data
net.Receive("BaseWars:AdminMenu:ReceivePlayers", function()
    local data = net.ReadString()
    local panel = BaseWars:GetAdminMenuPanel()
    if IsValid(panel) and IsValid(panel.HTML) then
        panel:RunJS(string.format("receivePlayers(%q);", data))
    end
end)

net.Receive("BaseWars:AdminMenu:ReceivePlayerDetails", function()
    local data = net.ReadString()
    local panel = BaseWars:GetAdminMenuPanel()
    if IsValid(panel) and IsValid(panel.HTML) then
        panel:RunJS(string.format("receivePlayerDetails(%q);", data))
    end
end)

net.Receive("BaseWars:AdminMenu:ReceiveOnlinePlayers", function()
    local data = net.ReadString()
    local panel = BaseWars:GetAdminMenuPanel()
    if IsValid(panel) and IsValid(panel.HTML) then
        panel:RunJS(string.format("receiveOnlinePlayers(%q);", data))
    end
end)

net.Receive("BaseWars:AdminMenu:ReceiveWarnings", function()
    local data = net.ReadString()
    local panel = BaseWars:GetAdminMenuPanel()
    if IsValid(panel) and IsValid(panel.HTML) then
        panel:RunJS(string.format("receiveWarnings(%q);", data))
    end
end)

net.Receive("BaseWars:AdminMenu:ReceiveFactions", function()
    local data = net.ReadString()
    local panel = BaseWars:GetAdminMenuPanel()
    if IsValid(panel) and IsValid(panel.HTML) then
        panel:RunJS(string.format("receiveFactions(%q);", data))
    end
end)

net.Receive("BaseWars:AdminMenu:ReceiveLogCategories", function()
    local data = net.ReadString()
    local panel = BaseWars:GetAdminMenuPanel()
    if IsValid(panel) and IsValid(panel.HTML) then
        panel:RunJS(string.format("receiveLogCategories(%q);", data))
    end
end)

net.Receive("BaseWars:AdminMenu:ReceiveLogs", function()
    local data = net.ReadString()
    local panel = BaseWars:GetAdminMenuPanel()
    if IsValid(panel) and IsValid(panel.HTML) then
        panel:RunJS(string.format("receiveLogs(%q);", data))
    end
end)

-- Override UpdateAdminMenuFactions to also update HTML menu
local oldUpdateAdminMenuFactions = BaseWars.UpdateAdminMenuFactions
function BaseWars:UpdateAdminMenuFactions()
    if oldUpdateAdminMenuFactions then
        oldUpdateAdminMenuFactions(self)
    end
    
    -- Also update HTML admin menu if open
    local panel = BaseWars:GetAdminMenuPanel()
    if IsValid(panel) and panel.SendFactionData then
        panel:SendFactionData()
    end
end
