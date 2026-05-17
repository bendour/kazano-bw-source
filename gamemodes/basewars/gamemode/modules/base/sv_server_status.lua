--[[local pendingStatusMessages = {}
local function sendServerStatusToDiscord()
    if #pendingStatusMessages > 0 then
        local data = pendingStatusMessages[1]
        data.message = string.Replace(data.message, "{", "[2;36m")
        data.message = string.Replace(data.message, "}", "[0m")

        http.Post(BaseWars.ServerName == "DEV" and "https://discord.com/api/webhooks/1249817329462939668/bG5c6pD_w-iu3bw_2Anq1cxL8XfwrjKc9apQmABsUK_dYYn6zgszw90nBS-7Xkmbd3TL" or "https://discord.com/api/webhooks/1249817329462939668/bG5c6pD_w-iu3bw_2Anq1cxL8XfwrjKc9apQmABsUK_dYYn6zgszw90nBS-7Xkmbd3TL", {
            ["payload_json"] = util.TableToJSON({
                ["username"] = "Kazano Status",
                ["avatar_url"] = "https://tip4serv.com/pages/dashboard/admin/store_img/logos/f19796f12d31884564c1658bf5391552.png",
                ["content"] = "```ansi\n[2;34m" .. os.date("%H:%M:%S - %d/%m/%Y", data.time) .. "[0m [2;37m-[0m [2;37m" .. data.message .. "[0m```"
            }
        )},
        function(body, size, headers, code)
            table.remove(pendingStatusMessages, 1)
            sendServerStatusToDiscord()
        end, function(error)
            table.remove(pendingStatusMessages, 1)
            sendServerStatusToDiscord()

            BaseWars:Warning("DISCORD - SERVER STATUS: " .. error)
        end)
    else
        timer.Simple(.5, function()
            sendServerStatusToDiscord()
        end)
    end
end
sendServerStatusToDiscord()

function BaseWars:ServerStatus(message)
    table.insert(pendingStatusMessages, {
        message = message,
        time = os.time()
    })
end

hook.Add("InitPostEntity", "BaseWars:ServerStatus", function()
    BaseWars:ServerStatus("Le server est ouvert.")
end) ]]--