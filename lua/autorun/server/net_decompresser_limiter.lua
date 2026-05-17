local MaxDecompressSize = 512

local OriginalDecompress = util.Decompress

function util.Decompress(data)
    if not data or #data > MaxDecompressSize then
        print("[Net-Blocker] Blocked oversized compressed net message (" .. #data .. " bytes)")
        return nil
    end

    return OriginalDecompress(data)
end
