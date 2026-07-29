local afkPlayers = {}

RegisterNetEvent('original_afk:setAFK', function(isAFK)
    local src = source
    local player = Player(src)
    if not player then return end

    player.state:set('isAFK', isAFK, true)

    if isAFK then
        afkPlayers[src] = os.time()
        player.state:set('afkStart', afkPlayers[src], true)
    else
        afkPlayers[src] = nil
        player.state:set('afkStart', nil, true)
    end
end)

CreateThread(function()
    while true do
        Wait(5000)

        local now = os.time()
        for src, startTime in pairs(afkPlayers) do
            if GetPlayerName(src) then
                local elapsed = now - startTime
                if elapsed >= Config.KickAfter then
                    local name = GetPlayerName(src) or "Ismeretlen"
                    local msg = string.format(Config.ChatMessage, name)

                    TriggerClientEvent('chat:addMessage', -1, {
                        color = { 255, 50, 50 },
                        multiline = false,
                        args = { "SYSTEM", msg }
                    })

                    DropPlayer(src, Config.KickReason)
                    afkPlayers[src] = nil
                end
            else
                afkPlayers[src] = nil
            end
        end
    end
end)

AddEventHandler('playerDropped', function()
    afkPlayers[source] = nil
end)