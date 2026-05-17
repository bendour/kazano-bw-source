ashop.lang.StrToID = {}
ashop.lang.IDToStr = {}

for k, v in pairs(ashop.lang.l) do
	local place = #ashop.lang.IDToStr + 1
	ashop.lang.IDToStr[place] = k
	ashop.lang.StrToID[k] = place
end

function ashop.L(info, ...)
    local str = ashop.lang.IDToStr[info] or info

    if !ashop.lang.l[str] then
        print("[ashop] Not found: " .. str)
        return "[ashop] Not found: " .. str
    else
        return string.format(ashop.lang.l[str], ...)
    end
end