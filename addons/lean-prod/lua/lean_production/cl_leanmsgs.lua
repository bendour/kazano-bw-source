if !CLIENT then return end
net.Receive("lean_msg", function()
	local msg = net.ReadString()
	chat.AddText(lean_updated.prefixcol.val,lean_updated.prefix.val .. " ",Color(255,255,255),msg)
end)