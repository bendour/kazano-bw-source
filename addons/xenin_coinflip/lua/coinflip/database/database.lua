function Coinflip.Database:GetConnection()
	return XeninDB
end

function Coinflip.Database:Tables()
	local conn = self:GetConnection()
	local mySQL = conn.isMySQL()

	-- Can SQLite not be so shit
	conn.query([[
		CREATE TABLE IF NOT EXISTS coinflip_games (
			id ]] .. (mySQL and "INT(11) AUTO_INCREMENT" or "INTEGER PRIMARY KEY AUTOINCREMENT") .. [[,
			flip_id INT(11),
			sid64 VARCHAR(22) NOT NULL,
			money INT NOT NULL]] .. (mySQL and ", PRIMARY KEY (id) )" or ")")
			.. [[
				;

				ALTER TABLE coinflip_games
				ADD currency VARCHAR(64)
			]]
	)

	conn.query([[
		CREATE TABLE IF NOT EXISTS coinflip_history (
			id ]] .. (mySQL and "INT(11) AUTO_INCREMENT" or "INTEGER PRIMARY KEY AUTOINCREMENT") .. [[,
			creator_sid64 VARCHAR(22) NOT NULL,
			challenger_sid64 VARCHAR(22) NOT NULL,
			money INT NOT NULL,
			time INT NOT NULL,
			winner VARCHAR(22) NOT NULL]] .. (mySQL and ", PRIMARY KEY (id) )" or ")")
			.. [[
				;

				ALTER TABLE coinflip_history
				ADD currency VARCHAR(64)
			]]
	)
end

hook.Add("Xenin.ConfigLoaded", "XeninCoinflip", function()
	Coinflip.Database:Tables()
end)

function Coinflip.Database:SaveGame(id, sid64, money, currency)
	local conn = self:GetConnection()
	local sql = [[
		INSERT INTO coinflip_games (flip_id, sid64, money, currency)
		VALUES (:id, ':sid64', :money, ':currency')
	]]
	sql = sql:Replace(":id", id)
	sql = sql:Replace(":sid64", sid64)
	sql = sql:Replace(":money", money)
	sql = sql:Replace(":currency", currency)

	conn.query(sql)
end

function Coinflip.Database:DeleteGame(id, sid64)
	local conn = self:GetConnection()
	local sql = [[
		DELETE FROM coinflip_games 
		WHERE flip_id = :id
			AND sid64 = ':sid64'
	]]
	sql = sql:Replace(":id", id)
	sql = sql:Replace(":sid64", sid64)

	conn.query(sql)
end

function Coinflip.Database:AddToHistory(creator, challenger, money, winner, currency)
	local conn = self:GetConnection()
	local sql = [[
		INSERT INTO coinflip_history (creator_sid64, challenger_sid64, money, time, winner, currency)
		VALUES (':creator', ':challenger', :money, :time, ':winner', ':currency')
	]]
	sql = sql:Replace(":creator", creator)
	sql = sql:Replace(":challenger", challenger)
	sql = sql:Replace(":money", money)
	sql = sql:Replace(":time", os.time())
	sql = sql:Replace(":winner", winner)
	sql = sql:Replace(":currency", currency)

	conn.query(sql)
end

function Coinflip.Database:GetHistory(sid64, limit, offset, callback)
	callback = callback or function() end

	local conn = self:GetConnection()
	local sql = [[
		SELECT time, money, winner, creator_sid64, challenger_sid64, currency
		FROM coinflip_history
		WHERE creator_sid64 = ':sid64'
			OR challenger_sid64 = ':sid64'
		ORDER BY time DESC
		LIMIT :limit
		OFFSET :offset
	]]
	sql = sql:Replace(":sid64", sid64)
	sql = sql:Replace(":limit", limit)
	sql = sql:Replace(":offset", offset)

	conn.query(sql, function(result)
		local newTbl = {}

		for i, v in ipairs(result or {}) do
			local opponent = v.creator_sid64 == sid64 and v.challenger_sid64 or v.creator_sid64

			table.insert(newTbl, {
				time = v.time,
				money = tonumber(v.money),
				winner = v.winner,
				opponent = opponent,
				currency = v.currency
			})
		end

		callback(newTbl)
	end)
end

function Coinflip.Database:GetStats(sid64, callback)
	local conn = self:GetConnection()
	local sql = [[
    SELECT
        SUM(money) AS server_money,
        COUNT(id) AS server_flips,
        (SELECT SUM(money) FROM coinflip_history WHERE creator_sid64 = ':sid64' OR challenger_sid64 = ':sid64') AS user_money,
        (SELECT COUNT(id) FROM coinflip_history WHERE creator_sid64 = ':sid64' OR challenger_sid64 = ':sid64') AS user_flips
    FROM
        coinflip_history
	]]
	sql = sql:Replace(":sid64", sid64)

	conn.query(sql, function(result)
		callback(result or {})
	end)
end

function Coinflip.Database:RefundMoney(ply)
	local conn = self:GetConnection()
	local sid64 = ply:SteamID64()
	local sql = [[
		SELECT money, flip_id, currency
		FROM coinflip_games 
		WHERE sid64 = ':sid64'
	]]
	sql = sql:Replace(":sid64", sid64)

	conn.query(sql, function(result)
		local currencies = {}
		for i, v in pairs(result or {}) do
			local curr = v.currency or Coinflip:GetCurrencyIfNil()
			currencies[curr] = currencies[curr] or 0
			currencies[curr] = currencies[curr] + tonumber(v.money)

			self:DeleteGame(v.flip_id, sid64)
		end

		for i, v in pairs(currencies) do
			if (v <= 0) then continue end

			local currency = Coinflip:GetCurrency(i)
			XeninUI:Notify(ply, "You have been refunded " .. currency:Format(v) .. " because you didn't finish your coinflips before you disconnected")
			currency:Add(ply, money)
		end
	end)
end

-- If they reconnect
hook.Add("PlayerInitialSpawn", "Coinflip.RefundMoney", function(ply)
	timer.Simple(15, function()
		-- Give them a bit of time to initialise everything
		if (!IsValid(ply)) then return end
		
		Coinflip.Database:RefundMoney(ply)
	end)
end)

--Coinflip.Database:RefundMoney(Entity(1))