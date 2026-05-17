// Flux shenanigans once again

local ScrH = ScrH
local ScrW = ScrW
local surface = surface
local createfonts = createfonts
local hook = hook

local w, h = ScrW(), ScrH()
local ratio_h = h / 1080
local ratio_w = w / 1920
local ratio = ratio_h < ratio_w and ratio_h or ratio_w

function ashop.GetSize(n)
    return n * ratio
end

function ashop.GetMargin(rat)
    return ashop.GetSize(h*0.0333 * (rat or 1))
end

// I searched 1h to debug this,
// https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/modules/draw.lua#L33-L49
// The cache doesn't reset when you change screen size ...
local CachedFontHeights = {}
function ashop.GetFontHeight(font)
	if ( CachedFontHeights[ font ] != nil ) then
		return CachedFontHeights[ font ]
	end

	surface.SetFont( font )
	local w, h = surface.GetTextSize( "W" )
	CachedFontHeights[ font ] = h

	return h
end

local fontList = {
    {
        font = "Inter",
        prefix = "ashop_",
        size = {
            [-1] = {16, 18, 12, 14, 24},
            [700] = {16, 14, 24}
        },
    },

    {
        font = "Inter SemiBold",
        prefix = "ashop_",
        size = {
            [600] = {24, 12, 14, 20, 30, 60, 16, 32, 100},
        },
    },

    {
        font = "Inter",
        prefix = "ashop_3D2D_",
        size = {
            [-1] = {18, ashop.Config.FontSizeTitle, 40},
        }
    },

    {
        font = "After Miles Swash",
        prefix = "ashop_logo_bottom",
        size = {
            [-1] = {54},
        },
    },

    {
        font = "Pacifico",
        prefix = "ashop_logo_top",
        size = {
            [-1] = {48}
        }
    },

    {
        font = "ashop-",
        prefix = "ashop_icon_",
        size = {
            [-1] = {20, 25, 16, 50, 18}
        }
    }
}

// antialias
function createfonts()
    for _, fontInfo in pairs(fontList) do
        for weight, sizeTable in pairs(fontInfo.size) do
            for _, size in ipairs(sizeTable) do
                local name = fontInfo.prefix .. size

                if weight != -1 then
                    name = name .. "_" .. weight
                end

                local _, err = pcall(function()
                    surface.CreateFont(name, {
                        antialias = true,
                        size = fontInfo["3D2D"] and size or ashop.GetSize(size),
                        font = fontInfo.font,
                        underline = fontInfo.underline
                    })
                end)

                if err then
                    print("[AShop] Couldn't load the font " .. name .. " composed of : " .. fontInfo.font)
                    skip = true
                    break
                end
            end
        end
    end
end

createfonts()

function ashop.GetScreen()
    return w, h
end

hook.Add("OnScreenSizeChanged", "ashop_RefreshFont", function()
    w, h = ScrW(), ScrH()
    ratio_h = h / 1080
    ratio_w = w / 1920
    ratio = (ratio_h < ratio_w and ratio_h or ratio_w)
    createfonts()
    CachedFontHeights = {}
end)