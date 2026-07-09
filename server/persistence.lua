-- Persistent world flags (yourmaps_flagscript)

local function prop_map_valid(flagType)
    return Config.prop_map and Config.prop_map[flagType] ~= nil
end

local placedFlags = {}

local function fw()
    return string.upper(Config.framework or "OTHER")
end

local function resolveCharacter(user)
    if not user or not user.getUsedCharacter then return nil end
    local used = user.getUsedCharacter
    if type(used) == "function" then
        return used()
    end
    if type(used) == "table" then
        return used
    end
    return nil
end

local function getCharId(src)
    if fw() == "VORP" and VorpCore then
        local User = VorpCore.getUser(src)
        if not User then return nil end
        local Character = resolveCharacter(User)
        if Character and Character.charIdentifier then
            return tostring(Character.charIdentifier)
        end
    elseif fw() == "REDEMRP" and VorpCore then
        local User = VorpCore.getUser(src)
        if User then
            local Character = resolveCharacter(User)
            if Character and (Character.charid or Character.charIdentifier) then
                return tostring(Character.charid or Character.charIdentifier)
            end
        end
    end
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find("license:") then
            return id
        end
    end
    return tostring(src)
end

local function getLicense(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:find("license:") then
            return id
        end
    end
    return nil
end

local function notify(src, text, kind)
    FlagNotifyPlayer(src, text, kind or 'info')
end

local function placeFailed(src)
    TriggerClientEvent("yourmaps_flags:client:placeFailed", src)
    notify(src, Config.persistentPlaceFailText, 'error')
end

local function itemForType(flagType)
    for _, item in ipairs(Config.items or {}) do
        if item.type == flagType then
            return item.name
        end
    end
    return nil
end

local function removeItem(src, itemName)
    if not itemName or not Config.persistentConsumeOnPlace then
        return true
    end
    if fw() == "VORP" and VorpInv then
        return VorpInv.subItem(src, itemName, 1)
    end
    return true
end

local function addItem(src, itemName)
    if not itemName or not Config.persistentReturnItemOnPickup then
        return true
    end
    if fw() == "VORP" and VorpInv then
        return VorpInv.addItem(src, itemName, 1)
    end
    return true
end

local function countForChar(charId, cb)
    MySQL.scalar("SELECT COUNT(*) FROM ym_flags_placed WHERE char_id = ?", { charId }, function(count)
        cb(tonumber(count) or 0)
    end)
end

local function broadcastSpawn(row)
    TriggerClientEvent("yourmaps_flags:client:spawnPlaced", -1, row)
end

local function broadcastDespawn(flagId)
    TriggerClientEvent("yourmaps_flags:client:despawnPlaced", -1, flagId)
end

local function syncAllClients()
    local list = {}
    for _, row in pairs(placedFlags) do
        list[#list + 1] = row
    end
    TriggerClientEvent("yourmaps_flags:client:syncPlaced", -1, list)
end

function LoadPersistentFlags(done)
    MySQL.query("SELECT * FROM ym_flags_placed", {}, function(rows)
        placedFlags = {}
        if rows then
            for _, row in ipairs(rows) do
                placedFlags[row.id] = row
            end
        end
        if Config.debug then
            local n = 0
            for _ in pairs(placedFlags) do n = n + 1 end
            print(("[yourmaps_flags] Loaded %d persistent flag(s)."):format(n))
        end
        if done then done() end
    end)
end

CreateThread(function()
    if not Config.persistentFlags then return end
    Wait(1500)
    LoadPersistentFlags(syncAllClients)
end)

AddEventHandler("onResourceStart", function(res)
    if res ~= GetCurrentResourceName() or not Config.persistentFlags then return end
    CreateThread(function()
        Wait(2000)
        LoadPersistentFlags(syncAllClients)
    end)
end)

RegisterNetEvent("yourmaps_flags:server:requestSync", function()
    local src = source
    if not Config.persistentFlags then return end
    local list = {}
    for _, row in pairs(placedFlags) do
        list[#list + 1] = row
    end
    TriggerClientEvent("yourmaps_flags:client:syncPlaced", src, list)
end)

RegisterNetEvent("yourmaps_flags:server:place", function(data)
    local src = source
    if not Config.persistentFlags or type(data) ~= "table" then return end

    local flagType = data.flagType
    local itemName = data.itemName or itemForType(flagType)
    if not flagType or not prop_map_valid(flagType) then return end
    if not itemName then return end

    local charId = getCharId(src)
    if not charId then
        placeFailed(src)
        return
    end

    countForChar(charId, function(count)
        if count >= (Config.persistentMaxPerPlayer or 15) then
            placeFailed(src)
            notify(src, Config.persistentMaxText, 'warn')
            return
        end

        if Config.persistentConsumeOnPlace and not removeItem(src, itemName) then
            placeFailed(src)
            return
        end

        local identifier = getLicense(src)
        MySQL.insert(
            "INSERT INTO ym_flags_placed (char_id, identifier, flag_type, item_name, x, y, z, heading) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
            {
                charId,
                identifier,
                flagType,
                itemName,
                tonumber(data.x) or 0.0,
                tonumber(data.y) or 0.0,
                tonumber(data.z) or 0.0,
                tonumber(data.heading) or 0.0,
            },
            function(insertId)
                if not insertId or insertId == 0 then
                    if Config.persistentConsumeOnPlace then
                        addItem(src, itemName)
                    end
                    if Config.debug then
                        print("[yourmaps_flags] INSERT failed — did you run ym_flags_placed.sql?")
                    end
                    placeFailed(src)
                    return
                end

                local row = {
                    id = insertId,
                    char_id = charId,
                    identifier = identifier,
                    flag_type = flagType,
                    item_name = itemName,
                    x = tonumber(data.x) or 0.0,
                    y = tonumber(data.y) or 0.0,
                    z = tonumber(data.z) or 0.0,
                    heading = tonumber(data.heading) or 0.0,
                }
                placedFlags[insertId] = row
                broadcastSpawn(row)
                notify(src, Config.persistentPlaceText, 'success')
            end
        )
    end)
end)

RegisterNetEvent("yourmaps_flags:server:pickup", function(flagId)
    local src = source
    if not Config.persistentFlags then return end

    flagId = tonumber(flagId)
    local row = flagId and placedFlags[flagId]
    if not row then return end

    local charId = getCharId(src)
    if Config.persistentOwnerOnly and charId ~= tostring(row.char_id) then
        notify(src, Config.persistentNotOwnerText, 'error')
        return
    end

    MySQL.update("DELETE FROM ym_flags_placed WHERE id = ?", { flagId }, function(affected)
        if not affected or affected < 1 then return end

        placedFlags[flagId] = nil
        if Config.persistentReturnItemOnPickup then
            addItem(src, row.item_name)
        end
        broadcastDespawn(flagId)
        notify(src, Config.persistentPickupText, 'success')
    end)
end)
