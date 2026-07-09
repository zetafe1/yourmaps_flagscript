--[[
  Interaction adapters for yourmaps_flagscript.

  Modes (Config.placedInteraction / Config.equippedInteraction):
    drawtext          — 3D text + key (legacy)
    native            — RedM UiPrompt / PromptRegister (NOT jo_libs)
    murphy_interact   — exports[resource]:AddInteraction
    blkb_interaction  — exports[resource]:GetApi():CreateInteraction
    pc_interaction    — alias of blkb_interaction (GetApi pattern)
    custom            — events + exports (see interactions_custom.example.lua)
]]

FlagInteractions = FlagInteractions or {}

local M = FlagInteractions
local targetHandles = {}

local nativeGroup
local nativePrompts = {}
local keyCooldown = false

local function modePlaced()
    return string.lower(Config.placedInteraction or 'drawtext')
end

local function modeEquipped()
    return string.lower(Config.equippedInteraction or (Config.useKeys and 'keys' or 'drawtext'))
end

local function interactionResource()
    if Config.interactionResource and Config.interactionResource ~= '' then
        return Config.interactionResource
    end
    local m = modePlaced()
    if m == 'murphy_interact' then return 'murphy_interact' end
    return 'blkb_interaction'
end

function M.controlForKey(keyName)
    if Config.keylist and Config.keylist[keyName] then
        return Config.keylist[keyName]
    end
    return Config.nativePromptControl or 0x760A9C6F
end

function M.usesDrawTextPlaced()
    return modePlaced() == 'drawtext'
end

function M.usesDrawTextEquipped()
    return modeEquipped() == 'drawtext'
end

function M.usesKeysEquipped()
    return modeEquipped() == 'keys'
end

function M.usesNativeEquipped()
    return modeEquipped() == 'native'
end

function M.usesKeysPlaced()
    return modePlaced() == 'drawtext'
end

function M.usesNativePlaced()
    return modePlaced() == 'native'
end

function M.usesTargetPlaced()
    local m = modePlaced()
    return m == 'murphy_interact' or m == 'blkb_interaction' or m == 'pc_interaction'
end

function M.usesCustomPlaced()
    return modePlaced() == 'custom'
end

local function setPromptVisible(name, visible)
    local p = nativePrompts[name]
    if not p then return end
    PromptSetEnabled(p, visible)
    PromptSetVisible(p, visible)
    if UiPromptSetEnabled then UiPromptSetEnabled(p, visible) end
    if UiPromptSetVisible then UiPromptSetVisible(p, visible) end
end

local function hideAllNativePrompts()
    for name in pairs(nativePrompts) do
        setPromptVisible(name, false)
    end
end

local function ensureNativePrompts()
    if nativeGroup then return end
    nativeGroup = GetRandomIntInRange(0, 0xffffff)
    local holdMs = tonumber(Config.nativePromptHoldMs) or 0

    local defs = {
        deploy = { key = Config.dropKey or 'G', label = Config.nativeDeployLabel or 'Place flag' },
        stash = { key = Config.deleteKey or 'BACKSPACE', label = Config.nativeStashLabel or 'Put flag away' },
        pickupPlaced = { key = Config.pickupKey or 'G', label = Config.nativePickupPlacedLabel or 'Pick up flag' },
        pickupTemp = { key = Config.pickupKey or 'G', label = Config.nativePickupTempLabel or 'Pick up flag' },
    }

    for name, def in pairs(defs) do
        local p = PromptRegisterBegin()
        PromptSetControlAction(p, M.controlForKey(def.key))
        PromptSetText(p, CreateVarString(10, 'LITERAL_STRING', def.label))
        PromptSetEnabled(p, false)
        PromptSetVisible(p, false)
        if holdMs > 0 then
            PromptSetHoldMode(p, holdMs)
        else
            PromptSetStandardMode(p, true)
        end
        PromptSetGroup(p, nativeGroup)
        PromptRegisterEnd(p)
        nativePrompts[name] = p
    end
end

local function showNativePrompts(activeNames, title)
    ensureNativePrompts()
    hideAllNativePrompts()
    for _, name in ipairs(activeNames) do
        setPromptVisible(name, true)
    end
    local label = CreateVarString(10, 'LITERAL_STRING', title or 'Flag')
    PromptSetActiveGroupThisFrame(nativeGroup, label)
end

local function nativeCompleted(promptName)
    local p = nativePrompts[promptName]
    if not p or not PromptIsEnabled(p) then return false end
    local holdMs = tonumber(Config.nativePromptHoldMs) or 0
    if holdMs > 0 then
        return PromptHasHoldModeCompleted(p)
    end
    return PromptHasStandardModeCompleted(p, 0)
end

local function targetId(flagId)
    return ('ym_flag_%s'):format(tostring(flagId))
end

local function removeTarget(flagId)
    local id = targetId(flagId)
    local handle = targetHandles[flagId]
    if not handle then
        handle = id
    end
    local res = interactionResource()
    local m = modePlaced()
    if m == 'murphy_interact' then
        pcall(function()
            if GetResourceState(res) == 'started' and exports[res] and exports[res].RemoveInteraction then
                exports[res]:RemoveInteraction(handle)
            end
        end)
    elseif m == 'blkb_interaction' or m == 'pc_interaction' then
        pcall(function()
            if GetResourceState(res) == 'started' and exports[res] and exports[res].GetApi then
                local api = exports[res]:GetApi()
                if api and api.DeleteInteraction then
                    api.DeleteInteraction(id)
                end
            end
        end)
    end
    targetHandles[flagId] = nil
end

local function addTarget(flagId, coords, label, onPickup)
    local m = modePlaced()
    local res = interactionResource()
    local id = targetId(flagId)
    removeTarget(flagId)

    if m == 'murphy_interact' then
        if GetResourceState(res) ~= 'started' then return end
        local exp = exports[res]
        if not exp or not exp.AddInteraction then return end
        local ok = pcall(function()
            exp:AddInteraction({
                id = id,
                coords = vector3(coords.x, coords.y, coords.z),
                distance = Config.persistentDisplayDist or 8.0,
                interactDst = Config.persistentPickupDist or 2.5,
                options = {
                    {
                        label = label or Config.persistentPickupPrompt or 'Pick up flag',
                        action = function()
                            onPickup()
                        end,
                    },
                },
            })
        end)
        if ok then targetHandles[flagId] = id end

    elseif m == 'blkb_interaction' or m == 'pc_interaction' then
        if GetResourceState(res) ~= 'started' then return end
        local ok, api = pcall(function()
            return exports[res]:GetApi()
        end)
        if not ok or not api or not api.CreateInteraction then return end
        pcall(function()
            api.CreateInteraction(
                id,
                vector3(coords.x, coords.y, coords.z),
                {
                    {
                        text = label or Config.persistentPickupPrompt or 'Pick up flag',
                        onSelect = function()
                            onPickup()
                        end,
                    },
                },
                Config.persistentDisplayDist or 8.0,
                Config.persistentPickupDist or 2.5
            )
            targetHandles[flagId] = id
        end)
    end
end

function M.onPlacedSpawn(flagId, coords, data, onPickup)
    if M.usesTargetPlaced() then
        CreateThread(function()
            local tries = 0
            while tries < 40 do
                if GetResourceState(interactionResource()) == 'started' then
                    addTarget(flagId, coords, Config.persistentPickupPrompt, onPickup)
                    return
                end
                tries = tries + 1
                Wait(250)
            end
        end)
    elseif M.usesCustomPlaced() then
        TriggerEvent('yourmaps_flags:custom:placedSpawned', {
            id = flagId,
            coords = coords,
            data = data,
            pickup = onPickup,
        })
    end
end

function M.onPlacedDespawn(flagId)
    if M.usesTargetPlaced() then
        removeTarget(flagId)
    elseif M.usesCustomPlaced() then
        TriggerEvent('yourmaps_flags:custom:placedDespawned', flagId)
    end
end

function M.clearAllTargets()
    for flagId in pairs(targetHandles) do
        removeTarget(flagId)
    end
end

--- State providers (set from client.lua each tick or once)
M.state = {
    equipped = false,
    flagout = false,
    persistent = false,
    prop = nil,
    nearestPlacedId = nil,
    nearestPlacedCoords = nil,
    nearestPlacedDist = nil,
    onDeploy = nil,
    onStash = nil,
    onPickupTemp = nil,
    onPickupPlaced = nil,
}

function M.init(mainThread)
    CreateThread(function()
        while true do
            Wait(0)
            local s = M.state
            local equipped = s.equipped
            local flagout = s.flagout

            -- === Equipped: native prompts (only place + stash) ===
            if M.usesNativeEquipped() and equipped and flagout then
                showNativePrompts({ 'deploy', 'stash' }, Config.nativeEquippedTitle or 'Flag')
                if nativeCompleted('deploy') then
                    if s.onDeploy then s.onDeploy() end
                    Wait(500)
                elseif nativeCompleted('stash') then
                    if s.onStash then s.onStash() end
                    Wait(500)
                end

            -- === Equipped: keys ===
            elseif M.usesKeysEquipped() and flagout and equipped then
                if not keyCooldown and IsControlPressed(0, M.controlForKey(Config.pickupKey or 'G')) then
                    keyCooldown = true
                    if s.onDeploy then s.onDeploy() end
                    Wait(1500)
                    keyCooldown = false
                elseif not keyCooldown and IsControlPressed(0, M.controlForKey(Config.deleteKey or 'BACKSPACE')) then
                    keyCooldown = true
                    if s.onStash then s.onStash() end
                    Wait(2000)
                    keyCooldown = false
                end

            -- === Placed pickup: native (only when NOT holding a flag) ===
            elseif M.usesNativePlaced() and not equipped then
                local nearId = s.nearestPlacedId
                local nearCoords = s.nearestPlacedCoords
                local nearDist = s.nearestPlacedDist
                local showPlaced = nearId and nearCoords and nearDist and nearDist <= (Config.persistentPickupDist or 2.5)

                if showPlaced and s.persistent then
                    showNativePrompts({ 'pickupPlaced' }, Config.nativePlacedTitle or 'Placed flag')
                    if nativeCompleted('pickupPlaced') then
                        if s.onPickupPlaced then s.onPickupPlaced(nearId) end
                        Wait(500)
                    end
                elseif flagout and not s.persistent and s.prop then
                    local ped = PlayerPedId()
                    local dist = #(GetEntityCoords(ped) - GetEntityCoords(s.prop))
                    if dist <= (Config.maxPickupDist or 2.0) then
                        showNativePrompts({ 'pickupTemp' }, Config.nativeTempTitle or 'Flag')
                        if nativeCompleted('pickupTemp') then
                            if s.onPickupTemp then s.onPickupTemp() end
                            Wait(500)
                        end
                    else
                        hideAllNativePrompts()
                        Wait(200)
                    end
                else
                    hideAllNativePrompts()
                    Wait(200)
                end

            -- === Placed pickup: keys (drawtext) ===
            elseif M.usesKeysPlaced() and not equipped and not M.usesTargetPlaced() and not M.usesCustomPlaced() then
                if not keyCooldown and s.persistent and IsControlPressed(0, M.controlForKey(Config.pickupKey or 'G')) then
                    local nearId = s.nearestPlacedId
                    if nearId then
                        keyCooldown = true
                        if s.onPickupPlaced then s.onPickupPlaced(nearId) end
                        Wait(1500)
                        keyCooldown = false
                    end
                elseif not keyCooldown and flagout and not s.persistent and IsControlPressed(0, M.controlForKey(Config.pickupKey or 'G')) then
                    keyCooldown = true
                    if s.onPickupTemp then s.onPickupTemp() end
                    Wait(1500)
                    keyCooldown = false
                else
                    Wait(200)
                end
            else
                hideAllNativePrompts()
                Wait(250)
            end
        end
    end)

    if M.usesDrawTextPlaced() or M.usesDrawTextEquipped() then
        CreateThread(function()
            while true do
                Wait(1)
                local s = M.state
                if M.usesDrawTextEquipped() and s.equipped and s.flagout then
                    local ped = PlayerPedId()
                    local c = GetEntityCoords(ped)
                    DrawText3D(vector3(c.x, c.y, c.z + 1.0), Config.deployFlagPrompt, 0.35, 1)
                elseif M.usesDrawTextPlaced() and s.persistent and not s.equipped and s.nearestPlacedCoords and s.nearestPlacedDist then
                    if s.nearestPlacedDist <= (Config.persistentDisplayDist or 8.0) then
                        DrawText3D(s.nearestPlacedCoords, Config.persistentPickupPrompt, 0.35, 1)
                    else
                        Wait(300)
                    end
                elseif M.usesDrawTextPlaced() and s.flagout and not s.equipped and s.prop and not s.persistent then
                    local ped = PlayerPedId()
                    local dist = #(GetEntityCoords(ped) - GetEntityCoords(s.prop))
                    if dist < (Config.displayPickupDist or 2.0) then
                        DrawText3D(GetEntityCoords(s.prop), Config.pickupFlagPrompt, 0.35, 1)
                    else
                        Wait(300)
                    end
                else
                    Wait(400)
                end
            end
        end)
    end

    if mainThread then
        mainThread()
    end
end

-- Exports for custom integration (other resources)
exports('PickupPlacedFlag', function(flagId)
    TriggerServerEvent('yourmaps_flags:server:pickup', flagId)
end)

exports('GetInteractionModes', function()
    return { placed = modePlaced(), equipped = modeEquipped() }
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    M.clearAllTargets()
    hideAllNativePrompts()
end)
