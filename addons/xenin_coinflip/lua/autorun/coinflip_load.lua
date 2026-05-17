Coinflip = Coinflip or {}
Coinflip.Database = {}
Coinflip.Games = Coinflip.Games or {}

function Coinflip:IncludeClient(path)
	if (CLIENT) then
		include("coinflip/" .. path .. ".lua")
	end

	if (SERVER) then
		AddCSLuaFile("coinflip/" .. path .. ".lua")
	end
end

function Coinflip:IncludeServer(path)
	if (SERVER) then
		include("coinflip/" .. path .. ".lua")
	end
end

function Coinflip:IncludeShared(path)
	self:IncludeServer(path)
	self:IncludeClient(path)
end

local function Load()
	Coinflip:IncludeShared("essentials/config_wrapper")
	Coinflip:IncludeShared("essentials/currency")
	Coinflip:IncludeShared("essentials/i18n")

	local currencies = file.Find("coinflip/currencies/*.lua", "LUA") 
	for i, v in pairs(currencies) do
		-- Strips the extension
		Coinflip:IncludeShared("currencies/" .. v:sub(1, v:len() - 4))
	end

	Coinflip:IncludeShared("configuration/config")

	Coinflip:IncludeServer("database/database")

	Coinflip:IncludeClient("networking/client")
	Coinflip:IncludeServer("networking/server")

	Coinflip:IncludeServer("essentials/coinflip")
	Coinflip:IncludeServer("essentials/ratelimiter")
	Coinflip:IncludeServer("essentials/anti_spam")

	-- UI
	Coinflip:IncludeClient("ui/menu")
	Coinflip:IncludeClient("ui/games")
	Coinflip:IncludeClient("ui/games_row")
	Coinflip:IncludeClient("ui/games_create")
	Coinflip:IncludeClient("ui/games_flip")

	-- History
	Coinflip:IncludeClient("ui/history")
	Coinflip:IncludeClient("ui/history_row")

	-- Stats
	Coinflip:IncludeClient("ui/stats")

	MsgC(XeninUI.Theme.Green, "[CF] Loaded Coinflip\n")

	Coinflip.FinishedLoading = true

	--CFMySQLite.initialize(Coinflip.Config.Database)

	hook.Run("Coinflip.FinishedLoading")
end

if (XeninUI) then
	Load()
else
	hook.Add("XeninUI.Loaded", "Coinflip", Load)
end

if (SERVER) then
	resource.AddFile("resource/fonts/Montserrat-Bold.ttf")
	resource.AddFile("resource/fonts/Montserrat-Regular.ttf")

	resource.AddWorkshop("1900562881")
	resource.AddWorkshop("1900579814")
end