local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function sendRequest(data)
    local jsonData = HttpService:JSONEncode(data)
    local requestBody = {
        Url = getgenv().hook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = jsonData
    }
    local Request = http_request or request or HttpPost or syn.request
    Request(requestBody)
end

local function getPlayerData()
    local gui = player.PlayerGui.CoreGUI
    local level = gui.LevelFrame.LevelBox.LevelNumber.Text
    local bank = gui.StatsFrame.Frame2.Frame.Container.Bank.Amt.Text
    local xpText = gui.LevelFrame.Bar.Stat.Text
    local xpnow, xpmax = xpText:match("(%d+)/(%d+)")
    local playerCount = #Players:GetPlayers()
    
    if not xpnow or not xpmax then return nil end
    
    local xpNeeded = tonumber(xpmax) - tonumber(xpnow)
    local allowanceMath = math.ceil(xpNeeded / 1600)
    
    return {
        name = player.Name,
        bank = bank,
        level = level,
        xpnow = xpnow,
        xpmax = xpmax,
        allowances = allowanceMath,
        players = playerCount
    }
end

local function sendWebhookClassic()
    pcall(function()
        local data = getPlayerData()
        if not data then return end
        
        local embedData = {
            ["embeds"] = {{
                ["title"] = "",
                ["description"] = "account: ``"..data.name.."``\nbank: ``"..data.bank.."``\nlevel: ``"..data.level.."``\nxp: ``"..data.xpnow.."/"..data.xpmax.." XP``\nallowances left: ``"..data.allowances.."``\nplayers in server: ``"..data.players.."``",
                ["color"] = 3284510
            }}
        }
        sendRequest(embedData)
    end)
end

local function sendWebhook()
    pcall(function()
        local data = getPlayerData()
        if not data then return end
        
        local embedData = {
            ["embeds"] = {{
                ["title"] = "",
                ["description"] = "",
                ["fields"] = {
                    {["name"] = "account", ["value"] = "```"..data.name.."```", ["inline"] = false},
                    {["name"] = "bank", ["value"] = "```"..data.bank.."```", ["inline"] = false},
                    {["name"] = "current level", ["value"] = "```lvl "..data.level.."```", ["inline"] = false},
                    {["name"] = "xp", ["value"] = "```"..data.xpnow.."/"..data.xpmax.." XP```", ["inline"] = false},
                    {["name"] = "estimated allowances until lvl up", ["value"] = "```"..data.allowances.." allowances```", ["inline"] = false},
                    {["name"] = "players in server", ["value"] = "```"..data.players.." players```", ["inline"] = false}
                },
                ["color"] = _G.EmbedColor or 3284510
            }}
        }
        sendRequest(embedData)
    end)
end

local function startFarm()
    local stylingvalue

    if _G.BasicStyling then
        stylingvalue = "using basic styling"
    else
        stylingvalue = "not using basic styling"
    end

    pcall(function()
        local data = {
            ["content"] = "loaded in server, " .. stylingvalue .. ". ≽^•⩊•^≼"
        }
        sendRequest(data)
    end)
if not game:IsLoaded() then
    game.Loaded:Wait()
end
	wait(10)

    if _G.BasicStyling then
        sendWebhookClassic()
    else
        sendWebhook()
    end
end

startFarm()

_G.OnATMClaimed = function()
    if _G.BasicStyling then
        sendWebhookClassic()
    else
        sendWebhook()
    end
end
