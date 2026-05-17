if not SERVER then return end
zwf = zwf or {}
zwf.f = zwf.f or {}

function zwf.f.GiveMoney(ply, money)
	ply:AddMoney(money)
end

function zwf.f.TakeMoney(ply, money)
	ply:TakeMoney(money)
end

function zwf.f.HasMoney(ply, money)
	return ply:GetMoney() >= money
end
