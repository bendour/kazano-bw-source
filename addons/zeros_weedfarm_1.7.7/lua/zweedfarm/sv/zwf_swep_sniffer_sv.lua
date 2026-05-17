if not SERVER then return end
zwf = zwf or {}
zwf.f = zwf.f or {}


util.AddNetworkString("zwf_sniffer_check")

function zwf.f.SnifferSWEP_Primary(ply)
	net.Start("zwf_sniffer_check" )
	net.Send(ply)

	zwf.f.CreateNetEffect("zwf_sniff",ply)
end
