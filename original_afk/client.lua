local isAFK = false
local afkStartTime = 0
local lastPos = nil
local lastCheck = 0
local textureLoaded = false
local lastLogTime = 0

CreateThread(function()
    local dict = Config.Image.dict
    RequestStreamedTextureDict(dict, true)

    local timeout = 150
    while not HasStreamedTextureDictLoaded(dict) and timeout > 0 do
        RequestStreamedTextureDict(dict, true)
        Wait(50)
        timeout = timeout - 1
    end

    if HasStreamedTextureDictLoaded(dict) then
        textureLoaded = true
        print("[original_afk] YTD betöltve: " .. dict)
    else
        print("[original_afk] HIBA: YTD nem töltődött be: " .. dict)
    end
end)

local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if not onScreen then return end

    local camCoords = GetGameplayCamCoords()
    local dist = #(camCoords - vector3(x, y, z))
    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov * Config.Text.scale

    SetTextScale(0.0 * scale, Config.Text.scale)
    SetTextFont(Config.Text.font)
    SetTextProportional(1)
    SetTextColour(Config.Text.color.r, Config.Text.color.g, Config.Text.color.b, Config.Text.color.a)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    if Config.Text.outline then
        SetTextOutline()
    end
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
end

local function DrawImage3D(x, y, z, width, height)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if not onScreen then return end

    if not HasStreamedTextureDictLoaded(Config.Image.dict) then
        RequestStreamedTextureDict(Config.Image.dict, true)
        return
    end

    DrawSprite(Config.Image.dict, Config.Image.name, _x, _y, width, height, 0.0, 255, 255, 255, 255)
end

local function DrawCountdown(remaining)
    SetTextFont(4)
    SetTextScale(0.45, 0.45)
    SetTextColour(255, 200, 50, 255)
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString("~y~AFK-ig: ~w~" .. remaining .. " mp")
    DrawText(0.5, 0.88)
end

local function SetLocalAFK(state)
    if isAFK == state then return end
    isAFK = state

    local ped = PlayerPedId()
    if state then
        afkStartTime = GetGameTimer()
        SetEntityAlpha(ped, Config.AFKAlpha, false)
        TriggerServerEvent('original_afk:setAFK', true)
        if Config.LogToConsole then
            print("[original_afk] AFK státusz AKTÍV")
        end
    else
        afkStartTime = 0
        ResetEntityAlpha(ped)
        TriggerServerEvent('original_afk:setAFK', false)
        if Config.LogToConsole then
            print("[original_afk] Mozgás detektálva → AFK törölve")
        end
    end
end

CreateThread(function()
    while true do
        local sleep = 500
        local ped = PlayerPedId()

        if DoesEntityExist(ped) and not IsEntityDead(ped) then
            local currentPos = GetEntityCoords(ped)
            local now = GetGameTimer()

            if lastPos == nil then
                lastPos = currentPos
                lastCheck = now
            end

            local dist = #(currentPos - lastPos)

            if dist > Config.MoveThreshold then
                if isAFK then
                    SetLocalAFK(false)
                end
                lastPos = currentPos
                lastCheck = now
            else
                local stillTime = (now - lastCheck) / 1000
                local remaining = math.max(0, math.ceil(Config.AFKTimeout - stillTime))

                if stillTime >= Config.AFKTimeout then
                    if not isAFK then
                        SetLocalAFK(true)
                    end
                else
                    if Config.ShowCountdown then
                        local show = true
                        if Config.CountdownOnlyBelow > 0 and remaining > Config.CountdownOnlyBelow then
                            show = false
                        end
                        if show then
                            sleep = 0
                            DrawCountdown(remaining)
                        end
                    end

                    if Config.LogToConsole then
                        local logNow = now / 1000
                        if logNow - lastLogTime >= Config.LogInterval then
                            lastLogTime = logNow
                            print(("[original_afk] Állsz még: %.0f mp | AFK-ig: %d mp"):format(stillTime, remaining))
                        end
                    end
                end
            end

            if isAFK then
                sleep = 0
                if GetEntityAlpha(ped) ~= Config.AFKAlpha then
                    SetEntityAlpha(ped, Config.AFKAlpha, false)
                end
            end
        else
            if isAFK then
                SetLocalAFK(false)
            end
            lastPos = nil
        end

        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 500
        local players = GetActivePlayers()

        for _, playerId in ipairs(players) do
            local serverId = GetPlayerServerId(playerId)
            local ply = Player(serverId)
            local state = ply and ply.state or nil
            local targetPed = GetPlayerPed(playerId)

            if not DoesEntityExist(targetPed) then goto continue end

            if state and state.isAFK then
                sleep = 0

                if not IsEntityDead(targetPed) then
                    if GetEntityAlpha(targetPed) ~= Config.AFKAlpha then
                        SetEntityAlpha(targetPed, Config.AFKAlpha, false)
                    end

                    local headCoords = GetPedBoneCoords(targetPed, 0x796E, 0.0, 0.0, 0.0)

                    if Config.UseImage and textureLoaded then
                        DrawImage3D(
                            headCoords.x,
                            headCoords.y,
                            headCoords.z + Config.Image.offsetZ,
                            Config.Image.width,
                            Config.Image.height
                        )
                    end

                    if Config.ShowText then
                        local minutes = 0
                        if state.afkStart then
                            minutes = math.floor((GetCloudTimeAsInt() - state.afkStart) / 60)
                            if minutes < 0 then minutes = 0 end
                        end

                        local text = Config.Text.label
                        if Config.Text.showMinutes then
                            if minutes < 1 then
                                text = text .. " (<1 perc)"
                            else
                                text = text .. " (" .. minutes .. " perc)"
                            end
                        end

                        DrawText3D(
                            headCoords.x,
                            headCoords.y,
                            headCoords.z + Config.Text.offsetZ,
                            text
                        )
                    end
                end
            else
                if GetEntityAlpha(targetPed) == Config.AFKAlpha then
                    ResetEntityAlpha(targetPed)
                end
            end
            ::continue::
        end

        Wait(sleep)
    end
end)

AddEventHandler('onClientResourceStart', function(res)
    if res == GetCurrentResourceName() then
        isAFK = false
        lastPos = nil
        afkStartTime = 0
        lastLogTime = 0
        local ped = PlayerPedId()
        if DoesEntityExist(ped) then
            ResetEntityAlpha(ped)
        end
    end
end)