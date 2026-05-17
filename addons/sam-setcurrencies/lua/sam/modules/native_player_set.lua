if SAM_LOADED then return end

local sam, command = sam, sam.command

command.set_category("BaseWars")

command.new("addcredits")
	:SetPermission("addcredits", "superadmin")

	:AddArg("player", {single_target = true})
	:AddArg("number", {hint = "credit(s)", default = 1, min = 1})

	:Help("Ajoute des crédits a un joueur.")

	:OnExecute(function(ply, targets, credits)
		local target = targets[1]
        
        target:AddCredit(credits)

		//DarkRP.notify(target, 0, 4, ply:Nick() .. " vous a donné " .. credits .. " crédit(s).")
        BaseWars:Notify(target, ply:Nick() .. " vous a donné " .. credits .. " crédit(s).", 0, 4)

		if sam.is_command_silent then return end
		sam.player.send_message(nil, "{A} a donné {V} crédit(s) à {T}.", {
			A = ply, T = targets, V = credits
		})
	end)
:End()

command.new("setcredits")
	:SetPermission("setcredits", "superadmin")

	:AddArg("player", {single_target = true})
	:AddArg("number", {hint = "credit(s)", default = 1, min = 1})

	:Help("Définit les crédits d'un joueur.")

	:OnExecute(function(ply, targets, credits)
		local target = targets[1]
        
        target:SetCredit(credits)

		//DarkRP.notify(target, 0, 4, ply:Nick() .. " a définit vos crédits à " .. credits .. " crédit(s).")
        BaseWars:Notify(target, ply:Nick() .. " a définit vos crédits à " .. credits .. " crédit(s).", 0, 4)

		if sam.is_command_silent then return end
		sam.player.send_message(nil, "{A} a définit les crédits de {T} à {V}.", {
			A = ply, T = targets, V = credits
		})
	end)
:End()

-- POINT SHOP

command.new("addpointshop")
	:SetPermission("addpointshop", "superadmin")

	:AddArg("player", {single_target = true})
	:AddArg("number", {hint = "point(s)", default = 1, min = 1})

	:Help("Ajoute des points shop a un joueur.")

	:OnExecute(function(ply, targets, points)
		local target = targets[1]
        
        target:AddPointshop(points)

		//DarkRP.notify(target, 0, 4, ply:Nick() .. " vous a donné " .. points .. " point(s) shop.")
        BaseWars:Notify(target, ply:Nick() .. " vous a donné " .. points .. " point(s) shop.", 0, 4)

		if sam.is_command_silent then return end
		sam.player.send_message(nil, "{A} a donné {V} point(s) shop à {T}.", {
			A = ply, T = targets, V = points 
		})
	end)
:End()

command.new("setpointshop")
	:SetPermission("setpointshop", "superadmin")

	:AddArg("player", {single_target = true})
	:AddArg("number", {hint = "point(s)", default = 1, min = 1})

	:Help("Définit les points shop d'un joueur.")

	:OnExecute(function(ply, targets, points)
		local target = targets[1]
        
        target:SetPointshop(points)

		//DarkRP.notify(target, 0, 4, ply:Nick() .. " a définit vos points shop à " .. points .. " shop.")
        BaseWars:Notify(target, ply:Nick() .. " a définit vos points shop à " .. points .. " shop.", 0, 4)

		if sam.is_command_silent then return end
		sam.player.send_message(nil, "{A} a définit les points shop de {T} à {V}", {
			A = ply, T = targets, V = points
		})
	end)
:End()

-- DARKRP MONEY

command.new("addmoney")
	:SetPermission("addmoney", "superadmin")

	:AddArg("player", {single_target = true})
	:AddArg("number", {hint = "dollar(s)", default = 1, min = 1})

	:Help("Ajoute de l'argent a un joueur.")

	:OnExecute(function(ply, targets, argent)
		local target = targets[1]
        
        target:AddMoney(argent)

        BaseWars:Notify(target, ply:Nick() .. " vous a donné " .. argent .. "$.", 0, 4)

		if sam.is_command_silent then return end
		sam.player.send_message(nil, "{A} a donné {V}$ à {T}.", {
			A = ply, T = targets, V = argent 
		})
	end)
:End()

command.new("setmoney")
	:SetPermission("setmoney", "superadmin")

	:AddArg("player", {single_target = true})
	:AddArg("number", {hint = "dollar(s)", default = 1, min = 1})

	:Help("Définit l'argent d'un joueur.")

	:OnExecute(function(ply, targets, argent)
		local target = targets[1]
        
        target:SetMoney(argent)

		//DarkRP.notify(target, 0, 4, ply:Nick() .. " a définit vos points shop à " .. points .. " shop.")
        BaseWars:Notify(target, ply:Nick() .. " a définit votre argent à " .. argent .. "$.", 0, 4)

		if sam.is_command_silent then return end
		sam.player.send_message(nil, "{A} a définit l'argent de {T} à {V}$", {
			A = ply, T = targets, V = argent
		})
	end)
:End()

-- Refund

command.new("refund")
	:SetPermission("refund", "superadmin")

	:AddArg("player", {single_target = true})

	:Help("Refund un joueur.")

	:OnExecute(function(ply, targets)
		local target = targets[1]
        
        BaseWars:Refund(target)

        BaseWars:Notify(target, ply:Nick() .. " vien de vous refund.", 0, 4)

		if sam.is_command_silent then return end
		sam.player.send_message(nil, "{A} a refund {T}", {
			A = ply, T = targets
		})
	end)
:End()