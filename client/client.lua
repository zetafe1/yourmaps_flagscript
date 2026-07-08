-- yourmaps_flagscript - Full Client Script

DEFAULT_TYPE = nil
CURRENT_ITEM = nil
prop, propflag, propeagle = nil, nil, nil
equipped, flagout = false, false
local keylist = Config.keylist
local prop_map = Config.prop_map
local worldFlags = {}

local function isHandHeldModel(model)
    return model == 'mp001_p_mp_flag01x' or model == 's_mp_flag01x'
end

local function deleteEntity(obj)
    if obj and DoesEntityExist(obj) then
        DetachEntity(obj, true, true)
        SetEntityAsMissionEntity(obj, true, true)
        DeleteObject(obj)
    end
end

local function clearEquippedFlag()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    SetPedCanRagdoll(ped, true)
    deleteEntity(prop)
    deleteEntity(propflag)
    deleteEntity(propeagle)
    prop = nil
    propflag = nil
    propeagle = nil
    equipped = false
    flagout = false
end

local function spawnPlacedFlagWorld(data)
    if not data or not data.id or worldFlags[data.id] then return end
    local flagModel = prop_map[data.flag_type]
    if not flagModel then return end

    local x, y, z = data.x + 0.0, data.y + 0.0, data.z + 0.0
    local heading = data.heading or 0.0

    if isHandHeldModel(flagModel) then
        local flag = CreateObject(GetHashKey(flagModel), x, y, z, false, true, true)
        SetEntityHeading(flag, heading)
        PlaceObjectOnGroundProperly(flag)
        FreezeEntityPosition(flag, true)
        worldFlags[data.id] = { pole = nil, flag = flag, eagle = nil, data = data }
        if Config.persistentFlags and FlagInteractions then
            FlagInteractions.onPlacedSpawn(data.id, GetEntityCoords(flag), data, function()
                TriggerServerEvent('yourmaps_flags:server:pickup', data.id)
            end)
        end
        return
    end

    local pole = CreateObject(GetHashKey('mp001_s_mp_campflagpole01x'), x, y, z, false, true, true)
    local flag = CreateObject(GetHashKey(flagModel), x, y, z, false, true, true)
    local eagle = CreateObject(GetHashKey('p_eaglependant01x'), x, y, z, false, true, true)
    AttachEntityToEntity(flag, pole, 0, 0.0, 0.0, 2.9, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    AttachEntityToEntity(eagle, pole, 0, 0.0, 0.01, 3.72, -75.0, 0.0, -192.0, true, true, false, true, 1, true)
    SetEntityHeading(pole, heading)
    PlaceObjectOnGroundProperly(pole)
    FreezeEntityPosition(pole, true)
    worldFlags[data.id] = { pole = pole, flag = flag, eagle = eagle, data = data }
    if Config.persistentFlags and FlagInteractions then
        local anchor = pole or flag
        local c = GetEntityCoords(anchor)
        FlagInteractions.onPlacedSpawn(data.id, c, data, function()
            TriggerServerEvent('yourmaps_flags:server:pickup', data.id)
        end)
    end
end

local function despawnPlacedFlagWorld(flagId)
    if FlagInteractions then
        FlagInteractions.onPlacedDespawn(flagId)
    end
    local entry = worldFlags[flagId]
    if not entry then return end
    deleteEntity(entry.pole)
    deleteEntity(entry.flag)
    deleteEntity(entry.eagle)
    worldFlags[flagId] = nil
end

local function nearestPlacedFlag(maxDist)
    local ped = PlayerPedId()
    local pcoords = GetEntityCoords(ped)
    local bestId, bestDist, bestCoords = nil, maxDist or Config.persistentPickupDist, nil
    for id, entry in pairs(worldFlags) do
        local anchor = entry.pole or entry.flag
        if anchor and DoesEntityExist(anchor) then
            local coords = GetEntityCoords(anchor)
            local dist = #(pcoords - coords)
            if dist < bestDist then
                bestDist = dist
                bestId = id
                bestCoords = coords
            end
        end
    end
    return bestId, bestDist, bestCoords
end


--- DRAWTEXT3D
function DrawText3D(coords, text, size, font)
    local onScreen, screenX, screenY = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z + 1.0)
    if not onScreen then return end
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 223)
    SetTextCentre(1)
    DisplayText(CreateVarString(10, "LITERAL_STRING", text), screenX, screenY)
end

--Gender anim
function IsPedMale(ped)
    return Citizen.InvokeNative(0xECF041186C5A94DC, ped) == `MP_MALE`
end

function PlayGenderedAnim(maleDict, maleAnim, femaleDict, femaleAnim, duration)
    local ped = PlayerPedId()
    RequestAnimDict(maleDict)
    RequestAnimDict(femaleDict)
    while not HasAnimDictLoaded(maleDict) or not HasAnimDictLoaded(femaleDict) do Wait(0) end

    if IsPedMale(ped) then
        TaskPlayAnim(ped, maleDict, maleAnim, 8.0, -8.0, duration or -1, 1, 0, false, false, false)
    else
        TaskPlayAnim(ped, femaleDict, femaleAnim, 8.0, -8.0, duration or -1, 1, 0, false, false, false)
    end
end

---disable keys
CreateThread(function()
    while true do
        Wait(0)
        if equipped then
            local ped = PlayerPedId()
            SetCurrentPedWeapon(ped, GetHashKey("WEAPON_UNARMED"), true)
            local keysToBlock = { --- you can change this to the keys you need to block!!
                0xE6F612E4, -- 1
                0x1CE6D9EB, -- 2
                0x4F49CC4C, -- 3
                0xF6C4E10D, -- 4
                0xB4E465B4, -- 5
                0x01597C0C, -- 6
                0x0F39B3D4, -- 7
                0x606B36F6, -- 8
                0xD7F7B5F5, -- 9
                0xC3BADC72, ---f3
                0x7A6E7C3D, ---f6
                0x07CE1E61, -- Attack (left mouse / RT)
                0xB2F377E8, -- Melee (F or R2)
                0x63A38F2C, -- Alternate melee (E)
                0x91C9A817, -- Weapon wheel (ALT or scroll)
                0xAC4BD4F1, -- TAB (weapon select)
            
            }
            for _, key in pairs(keysToBlock) do
                DisableControlAction(0, key, true)
            end
            EnableControlAction(0, 0x760A9C6F, true) -- G (drop flag -- on config by default)
            EnableControlAction(0, `INPUT_PUSH_TO_TALK`, true)
        else
            Wait(500)
        end
    end
end)

--create flag
function createFlagWithEagle(flagModel)
    local ped = PlayerPedId()
    local x, y, z = table.unpack(GetEntityCoords(ped))
    local isHandHeld = flagModel == 'mp001_p_mp_flag01x' or flagModel == 's_mp_flag01x'

    local pole = nil
    local eagle = nil
    local flag = CreateObject(GetHashKey(flagModel), x, y, z+0.2, true, true, true)

    if not isHandHeld then
        pole = CreateObject(GetHashKey('mp001_s_mp_campflagpole01x'), x, y, z+0.2, true, true, true)
        eagle = CreateObject(GetHashKey('p_eaglependant01x'), x, y, z+0.2, true, true, true)

        AttachEntityToEntity(flag, pole, 0, 0.0, 0.0, 2.9, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        AttachEntityToEntity(eagle, pole, 0, 0.0, 0.01, 3.72, -75.0, 0.0, -192.0, true, true, false, true, 1, true)

        local boneIndexRightHand = GetPedBoneIndex(ped, 11316)
        AttachEntityToEntity(pole, ped, boneIndexRightHand, 0.0, -0.03, 0.5, 0.5, 180.0, 0.0, true, true, false, true, 1, true)
    else

        local boneIndexRightHand = GetPedBoneIndex(ped, 11316)
        AttachEntityToEntity(flag, ped, boneIndexRightHand, 0.0, -0.03, 0.4, 0.5, 180.0, 0.0, true, true, false, true, 1, true)
    end

    SetPedCanRagdoll(ped, false)
    RequestAnimDict("script_re@rally@hostage")
    while not HasAnimDictLoaded("script_re@rally@hostage") do Wait(0) end
    TaskPlayAnim(ped, "script_re@rally@hostage", "base_rallymale03", 2.0, -2.0, -1, 67109393, 0.0, false, 1245184, false, "UpperbodyFixup_filter", false)

    CreateThread(function()
        while equipped do
            if IsEntityPlayingAnim(ped, "mech_crawl@base", "idle2stealth", 3)
            or IsEntityPlayingAnim(ped, "mech_crawl@base", "stealth2idle", 3)
            or IsEntityPlayingAnim(ped, "mech_crawl@base", "idle", 3) then

                TriggerEvent('yourmaps_flags:DelFlag')
                break
            end
    
            if not IsEntityPlayingAnim(ped, "script_re@rally@hostage", "base_rallymale03", 3) then
                TaskPlayAnim(ped, "script_re@rally@hostage", "base_rallymale03", 2.0, -2.0, -1, 67109393, 0.0, false, 1245184, false, "UpperbodyFixup_filter", false)
            end
    
            Wait(1500)
        end
        SetPedCanRagdoll(ped, true)
    end)

    flagout = true
    return pole, flag, eagle
end


-- FLAG USE EVENT
RegisterNetEvent('yourmaps_flags_UseFlag')
AddEventHandler('yourmaps_flags_UseFlag', function(flagType, itemName)
    CURRENT_ITEM = itemName
    if equipped then
        TriggerEvent("yourmaps_flags:DelFlag")
    else
        if flagout and not Config.persistentFlags then
            local text = Config.flagAlreadyDroppedText 
            if string.upper(Config.framework) == 'VORP' and not Config.nativeText then
                TriggerEvent('vorp:TipBottom', text, Config.timeDisplay)
            elseif string.upper(Config.framework) == 'REDEMRP' and not Config.nativeText then
                TriggerEvent('redem_roleplay:Tip', text, Config.timeDisplay)
            else
                displayText(text, Config.timeDisplay)
            end
            return
        end

        if prop_map[flagType] then
            prop, propflag, propeagle = createFlagWithEagle(prop_map[flagType])
            equipped = true
            flagout = true 
            DEFAULT_TYPE = flagType

            if Config.textOnUse then
                local text = Config.flagouttext
                if Config.useKeys then
                    text = text .. " " .. Config.deployFlagPrompt
                end
                if string.upper(Config.framework) == 'VORP' and not Config.nativeText then
                    TriggerEvent('vorp:TipBottom', text, Config.timeDisplay)
                elseif string.upper(Config.framework) == 'REDEMRP' and not Config.nativeText then
                    TriggerEvent('redem_roleplay:Tip', text, Config.timeDisplay)
                else
                    displayText(text, Config.timeDisplay)
                end
            end
        end
    end
end)


--- FLAG DELETE EVENT
RegisterNetEvent('yourmaps_flags:DelFlag')
AddEventHandler('yourmaps_flags:DelFlag', function()
    clearEquippedFlag()
end)

-- FLAG DROP EVENT
RegisterNetEvent('yourmaps_flags:DropFlag')
AddEventHandler('yourmaps_flags:DropFlag', function()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    SetPedCanRagdoll(ped, true)

    if prop and equipped then
        local coords = GetEntityCoords(ped)
        local forward = GetEntityForwardVector(ped)

        DetachEntity(prop, true, true)
        SetEntityCoords(prop, coords.x + forward.x, coords.y + forward.y, coords.z - 1.0, false, false, false, false)
        PlaceObjectOnGroundProperly(prop)
        SetEntityRotation(prop, 0, 0, 0, false, true)
        SetEntityHeading(prop, GetEntityHeading(ped) + 90)
        FreezeEntityPosition(prop, true)

        if Config.persistentFlags then
            TriggerServerEvent('yourmaps_flags:server:place', {
                flagType = DEFAULT_TYPE,
                itemName = CURRENT_ITEM,
                x = GetEntityCoords(prop).x,
                y = GetEntityCoords(prop).y,
                z = GetEntityCoords(prop).z,
                heading = GetEntityHeading(prop),
            })
            clearEquippedFlag()
            return
        end

        equipped = false

        if Config.textOnDrop then
            local text = Config.flagdroptext
            if string.upper(Config.framework) == 'VORP' and not Config.nativeText then
                TriggerEvent('vorp:TipBottom', text, Config.timeDisplay)
            elseif string.upper(Config.framework) == 'REDEMRP' and not Config.nativeText then
                TriggerEvent('redem_roleplay:Tip', text, Config.timeDisplay)
            else
                displayText(text, Config.timeDisplay)
            end
        end
    end
end)

-- FLAG PICKUP EVENT
RegisterNetEvent('yourmaps_flags:PickupFlag')
AddEventHandler('yourmaps_flags:PickupFlag', function()
    if prop then
        local ped = PlayerPedId()
        local dist = #(GetEntityCoords(ped) - GetEntityCoords(prop))
        if dist < Config.maxPickupDist then
            TriggerEvent('yourmaps_flags:DelFlag') 
            Wait(100) 
            prop, propflag, propeagle = createFlagWithEagle(prop_map[DEFAULT_TYPE])
            equipped = true
            flagout = true

            if Config.textOnPickup then
                local text = Config.flagpickuptext
                if string.upper(Config.framework) == 'VORP' and not Config.nativeText then
                    TriggerEvent('vorp:TipBottom', text, Config.timeDisplay)
                elseif string.upper(Config.framework) == 'REDEMRP' and not Config.nativeText then
                    TriggerEvent('redem_roleplay:Tip', text, Config.timeDisplay)
                else
                    displayText(text, Config.timeDisplay)
                end
            end
        else
            local text = Config.flagfartext
            if string.upper(Config.framework) == 'VORP' and not Config.nativeText then
                TriggerEvent('vorp:TipBottom', text, Config.timeDisplay)
            elseif string.upper(Config.framework) == 'REDEMRP' and not Config.nativeText then
                TriggerEvent('redem_roleplay:Tip', text, Config.timeDisplay)
            else
                displayText(text, Config.timeDisplay)
            end
        end
    end
end)


-- CLEANUP ON RESPAWN
if string.upper(Config.framework) == 'VORP' then
    RegisterNetEvent('vorp:PlayerForceRespawn')
    AddEventHandler('vorp:PlayerForceRespawn', function()
        TriggerEvent('yourmaps_flags:DelFlag')
    end)
else
    RegisterNetEvent("playerSpawned")
    AddEventHandler("playerSpawned", function()
        TriggerEvent('yourmaps_flags:DelFlag')
    end)
end

CreateThread(function()
    while true do
        Wait(150)
        if not FlagInteractions then goto continue end
        local nearId, nearDist, nearCoords = nearestPlacedFlag(Config.persistentDisplayDist)
        FlagInteractions.state.equipped = equipped
        FlagInteractions.state.flagout = flagout
        FlagInteractions.state.persistent = Config.persistentFlags
        FlagInteractions.state.prop = prop
        FlagInteractions.state.nearestPlacedId = nearId
        FlagInteractions.state.nearestPlacedDist = nearDist
        FlagInteractions.state.nearestPlacedCoords = nearCoords
        ::continue::
    end
end)

FlagInteractions.state.onDeploy = function()
    TriggerEvent('yourmaps_flags:DropFlag')
end
FlagInteractions.state.onStash = function()
    TriggerEvent('yourmaps_flags:DelFlag')
end
FlagInteractions.state.onPickupTemp = function()
    TriggerEvent('yourmaps_flags:PickupFlag')
end
FlagInteractions.state.onPickupPlaced = function(flagId)
    TriggerServerEvent('yourmaps_flags:server:pickup', flagId)
end

FlagInteractions.init()

RegisterNetEvent('yourmaps_flags:client:syncPlaced')
AddEventHandler('yourmaps_flags:client:syncPlaced', function(list)
    for id, _ in pairs(worldFlags) do
        despawnPlacedFlagWorld(id)
    end
    if not list then return end
    for _, row in ipairs(list) do
        spawnPlacedFlagWorld(row)
    end
end)

RegisterNetEvent('yourmaps_flags:client:spawnPlaced')
AddEventHandler('yourmaps_flags:client:spawnPlaced', function(row)
    spawnPlacedFlagWorld(row)
end)

RegisterNetEvent('yourmaps_flags:client:despawnPlaced')
AddEventHandler('yourmaps_flags:client:despawnPlaced', function(flagId)
    despawnPlacedFlagWorld(flagId)
end)

CreateThread(function()
    if not Config.persistentFlags then return end
    Wait(3000)
    TriggerServerEvent('yourmaps_flags:server:requestSync')
end)

-- TEST COMMANDS -- REMOVE THEM FROM PLAYERS IF YOU WANT
RegisterCommand('dropflag', function()
    if equipped then
        local ped = PlayerPedId()
        ClearPedTasks(ped)
        PlayGenderedAnim("mech_pickup@plant@corn@a", "exit_front", "mech_pickup@plant@corn@a_f", "exit_front_female", 1750)
        Wait(1750)
        DetachEntity(prop, true, true)
        DetachEntity(propflag, true, true)
        DetachEntity(propeagle, true, true)
        ClearPedTasks(ped)
        equipped = false
    end
end, false)

RegisterCommand('pickupflag', function()
    if not equipped and DEFAULT_TYPE then
        local ped = PlayerPedId()
        PlayGenderedAnim("mech_pickup@plant@corn@a", "enter_front", "mech_pickup@plant@corn@a_f", "enter_front_female", 1750)
        Wait(1750)
        prop, propflag, propeagle = createFlagWithEagle(prop_map[DEFAULT_TYPE])
        equipped = true
    end
end, false)
