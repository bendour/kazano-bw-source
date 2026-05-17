local DROP = CarePackage:CreateDrop()
DROP.InventoryEnabled = false
DROP.EquipName = function()
	return CarePackage:GetPhrase("Drops.Money.Take")
end

-- Fonction CustomPanel pour afficher l'image personnalisée
function DROP:CustomPanel(pnl, ent, data)
	if IsValid(pnl.Model) then return end
	
	pnl.Model = pnl:Add("DPanel")
	pnl.Model:Dock(FILL)
	pnl.Model:DockMargin(1, 65, 1, 1)
	pnl.Model.Paint = function(s, w, h)
		-- Fond transparent
	end
	
	-- Créer l'image HTML
	local html = pnl.Model:Add("DHTML")
	html:Dock(FILL)
	html:SetHTML([[
		<html>
		<body style="margin:0;padding:0;overflow:hidden;background:transparent;">
			<img src="]] .. self:GetModel(ent) .. [[" style="width:100%;height:100%;object-fit:contain;">
		</body>
		</html>
	]])
end

function DROP:CanLoot(ent, ply, type)
	return true
end

function DROP:Loot(ent, ply, type)
	-- Ajouter des crédits BaseWars si disponible
	if BaseWars and ply.AddCredit then
		-- Vérifier que ent est un nombre valide
		local amount = tonumber(ent) or 0
		if amount > 0 then
			-- Calculer le montant de crédits basé sur l'argent (par exemple, 1 crédit pour chaque 100$)
			local creditsAmount = amount
			if creditsAmount > 0 then
				-- Ajouter les crédits BaseWars
				ply:AddCredit(creditsAmount)
				
				-- Message de notification au joueur
				ply:ChatPrint("Vous avez reçu " .. creditsAmount .. " crédit(s) BaseWars!")
			end
		end
	end
end

function DROP:GetName(ent)
	-- Vérifier que ent est un nombre valide
	local amount = tonumber(ent) or 0
	if BaseWars and BaseWars.FormatCredit then
		return BaseWars:FormatCredit(amount, true)
	end
	-- Fallback si BaseWars n'est pas disponible
	return string.Comma(amount) .. " Credits"
end

function DROP:GetModel(ent)
	-- Retourner l'URL de l'image Imgur
	return "https://i.imgur.com/dFkSJxD.png.png"
end

function DROP:GetPostDisplay(pnl, ent)
	-- Cette fonction est appelée après la création du modèle standard
	-- Pour l'argent, nous utilisons CustomPanel donc cette fonction n'est pas appelée
end

function DROP:GetData(ent)
	return {
		camera = {
			x = 40,
			y = -20
		}
	}
end

function DROP:GetColor(ent)
	if (self.Options.Color) then return self.Options.Color end

	if (XeninInventory) then
		local rarity = XeninInventory.Config.Rarities["spawned_money"] or 1
		
		return XeninInventory.Config.Categories[rarity].color
	end

	return CarePackage.Config.DefaultItemColor
end

DROP:Register("Money")