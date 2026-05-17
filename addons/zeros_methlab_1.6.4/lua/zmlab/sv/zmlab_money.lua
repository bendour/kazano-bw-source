if not SERVER then return end
zmlab = zmlab or {}
zmlab.f = zmlab.f or {}

function zmlab.f.GiveMoney(ply, money)
	ply:AddMoney(money)
end

function zmlab.f.TakeMoney(ply, money)
	ply:TakeMoney(money)
end

function zmlab.f.HasMoney(ply, money)
	return ply:GetMoney() >= moneys
end
