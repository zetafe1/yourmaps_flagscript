--[[
  Gizmo 3D integrado — portado do jo_libs gizmo (Jump On).
  Standalone: sem chamar jo_libs em runtime. Ver docs:
  https://docs.jumpon-studios.com/jo_libs/modules/gizmo/client
]]

FlagGizmo = FlagGizmo or {}

local M = FlagGizmo
local Prompt = FlagGizmoPrompt

local function gv(value, default)
    if value == nil then return default end
    return value
end

local defaultConfig = {
    enableCam = true,
    maxDistance = 3.0,
    maxCamDistance = 30.0,
    minY = -40,
    maxY = 40,
    movementSpeed = 0.05,
    maxMovementSpeed = 0.2,
    minMovementSpeed = 0.001,
    movementSpeedIncrement = 0.01,
    allowTranslateX = true,
    allowTranslateY = true,
    allowTranslateZ = true,
    allowRotateX = true,
    allowRotateY = true,
    allowRotateZ = true,
    allowSnapToGround = true,
    rotationSnap = 5,
    keys = {
        moveX = `INPUT_SCRIPTED_FLY_LR`,
        moveY = `INPUT_SCRIPTED_FLY_UD`,
        moveUp = `INPUT_FRONTEND_X`,
        moveDown = `INPUT_FRONTEND_RUP`,
        cancel = `INPUT_GAME_MENU_TAB_RIGHT_SECONDARY`,
        switchMode = `INPUT_RELOAD`,
        snapToGround = `INPUT_INTERACT_OPTION1`,
        confirm = `INPUT_FRONTEND_ACCEPT`,
        cameraSpeedUp = `INPUT_SELECT_PREV_WEAPON`,
        cameraSpeedDown = `INPUT_SELECT_NEXT_WEAPON`,
        rotationSnap = `INPUT_FRONTEND_Y`,
    },
}

local gizmoActive = false
local responseData = nil
local mode = 'translate'
local cam = nil
local previousCam = -1
local enableCam = false
local maxDistance = 0
local maxCamDistance = 0
local minY = 0
local maxY = 0
local movementSpeed = 0
local allowTranslateX = true
local allowTranslateY = true
local allowTranslateZ = true
local allowRotateX = true
local allowRotateY = true
local allowRotateZ = true
local allowSnapToGround = false
local stored = nil
local hookedFunc = nil
local target = 0
local needUpdateCamNUI = false
local onMove = nil
local groupName = 'interaction_FlagGizmo'
local camAnchorMode = 'entity'
local gizmoLabels = {}

local PED_BLOCKED_CONTROLS = {
    `INPUT_MOVE_UP_ONLY`,
    `INPUT_MOVE_DOWN_ONLY`,
    `INPUT_MOVE_LEFT_ONLY`,
    `INPUT_MOVE_RIGHT_ONLY`,
    `INPUT_MOVE_LEFT`,
    `INPUT_MOVE_RIGHT`,
    `INPUT_MOVE_DOWN`,
    `INPUT_MOVE_UP`,
    `INPUT_SPRINT`,
    `INPUT_JUMP`,
    `INPUT_DUCK`,
    `INPUT_COVER`,
    `INPUT_AIM`,
    `INPUT_MELEE_ATTACK`,
    `INPUT_MELEE_GRAPPLE`,
    `INPUT_MELEE_GRAPPLE_ATTACK`,
    `INPUT_MELEE_BLOCK`,
    `INPUT_SELECT_WEAPON`,
    `INPUT_OPEN_WHEEL_MENU`,
    `INPUT_ENTER`,
    `INPUT_INTERACT_LOCKON`,
    `INPUT_INTERACT_OPTION2`,
    `INPUT_HORSE_ENTER`,
    `INPUT_HORSE_ATTACK`,
    `INPUT_HORSE_MELEE`,
    `INPUT_HORSE_COLLECT`,
    0x8CC9CD42, -- X (mãos ao ar)
}

local function setPedGizmoBlocked(blocked)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, blocked)
    SetBlockingOfNonTemporaryEvents(ped, blocked)
    if blocked then
        ClearPedSecondaryTask(ped)
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
    end
end

local function disableControls()
    DisableControlAction(0, `INPUT_ATTACK`, true)
    DisableControlAction(0, `INPUT_FRONTEND_X`, true)
    DisableControlAction(0, `INPUT_FRONTEND_RUP`, true)

    for i = 1, #PED_BLOCKED_CONTROLS do
        local control = PED_BLOCKED_CONTROLS[i]
        DisableControlAction(0, control, true)
        DisableControlAction(1, control, true)
        DisableControlAction(2, control, true)
    end

    DisablePlayerFiring(PlayerId(), true)
end

local function cameraAnchorPos()
    if camAnchorMode == 'entity' and target and DoesEntityExist(target) then
        return GetEntityCoords(target)
    end
    return GetEntityCoords(PlayerPedId())
end

local function canMoveCameraTo(newPos)
    return #(cameraAnchorPos() - newPos) <= maxCamDistance
end

local function pointEntity()
    if cam and target and DoesEntityExist(target) then
        PointCamAtEntity(cam, target)
        needUpdateCamNUI = true
    end
end

local function initCameraOnFlag()
    if not cam or not target or not DoesEntityExist(target) then return end
    local ec = GetEntityCoords(target)
    local viewDist = math.min(6.0, maxCamDistance * 0.35)
    SetCamCoord(cam, ec.x - viewDist, ec.y - viewDist, ec.z + 2.0)
    pointEntity()
end

local function showNUI(bool)
    LocalPlayer.state:set('yourmaps_flagscript_gizmo', bool, true)

    if bool then
        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(true)
        setPedGizmoBlocked(true)

        if enableCam then
            local currentCam = GetRenderingCam()
            previousCam = currentCam
            local coords, rot, fov
            if currentCam == -1 then
                coords = GetGameplayCamCoord()
                rot = GetGameplayCamRot(2)
                fov = GetGameplayCamFov()
            else
                coords = GetCamCoord(currentCam)
                rot = GetCamRot(currentCam, 2)
                fov = GetCamFov(currentCam)
            end

            cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', false)
            SetCamCoord(cam, coords.x, coords.y, coords.z + 0.5)
            SetCamRot(cam, rot.x, rot.y, rot.z, 2)
            SetCamFov(cam, fov)
            if currentCam == -1 then
                SetCamActive(cam, true)
                RenderScriptCams(true, true, 500, true, true)
            else
                SetCamActiveWithInterp(cam, currentCam, 500)
            end
            initCameraOnFlag()
            needUpdateCamNUI = true
        end
    else
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        setPedGizmoBlocked(false)

        if cam then
            if previousCam == -1 then
                RenderScriptCams(false, true, 500, true, true)
            else
                SetCamActiveWithInterp(previousCam, cam, 500)
            end
            SetCamActive(cam, false)
            DetachCam(cam)
            DestroyCam(cam, true)
            cam = nil
        end

        stored = nil
        hookedFunc = nil

        SendNUIMessage({
            action = 'SetupGizmo',
            data = { handle = nil },
        })
    end

    gizmoActive = bool
end

local function getSmartControlNormal(control, control2)
    if control2 then
        return GetDisabledControlNormal(0, control) - GetDisabledControlNormal(0, control2)
    end
    return GetDisabledControlNormal(0, control)
end

local function camMovement()
    if not cam then return end
    local moveX = getSmartControlNormal(defaultConfig.keys.moveX)
    local moveY = getSmartControlNormal(defaultConfig.keys.moveY)
    local moveZ = getSmartControlNormal(defaultConfig.keys.moveUp, defaultConfig.keys.moveDown)
    if moveX == 0 and moveY == 0 and moveZ == 0 then return end

    local x, y, z = table.unpack(GetCamCoord(cam))
    local rot = GetCamRot(cam, 2)
    local dx = math.sin(-rot.z * math.pi / 180) * movementSpeed
    local dy = math.cos(-rot.z * math.pi / 180) * movementSpeed
    local dx2 = math.sin(math.floor(rot.z + 90.0) % 360 * -1.0 * math.pi / 180) * movementSpeed
    local dy2 = math.cos(math.floor(rot.z + 90.0) % 360 * -1.0 * math.pi / 180) * movementSpeed

    if moveX ~= 0.0 then
        x = x - dx2 * moveX
        y = y - dy2 * moveX
    end
    if moveY ~= 0.0 then
        x = x - dx * moveY
        y = y - dy * moveY
    end
    if moveZ ~= 0.0 then
        z = z + moveZ * movementSpeed
    end

    local newPos = vector3(x, y, z)
    if canMoveCameraTo(newPos) then
        SetCamCoord(cam, x, y, z)
        pointEntity()
        needUpdateCamNUI = true
    end
end

local function updateCamNUI()
    if not needUpdateCamNUI then return end
    if getSmartControlNormal(`INPUT_ATTACK`) > 0 then return end
    SendNUIMessage({
        action = 'SetCameraPosition',
        data = {
            position = GetFinalRenderedCamCoord(),
            rotation = GetFinalRenderedCamRot(2),
        },
    })
    needUpdateCamNUI = false
end

local function groundOffset()
    return tonumber(Config.placementGroundOffsetZ) or 0.0
end

local function snapEntityToGround(entity)
    if not entity or not DoesEntityExist(entity) then return nil, nil end
    local c = GetEntityCoords(entity)
    local found, groundZ = GetGroundZFor_3dCoord(c.x, c.y, c.z + 5.0, false)
    if found then
        SetEntityCoordsNoOffset(entity, c.x, c.y, groundZ + groundOffset(), false, false, false)
    end
    FreezeEntityPosition(entity, true)
    return GetEntityCoords(entity), GetEntityRotation(entity, 2)
end

local function refreshSpeedPrompt()
    Prompt.editKeyLabel(groupName, defaultConfig.keys.cameraSpeedUp,
        gizmoLabels.camSpeed:format(movementSpeed))
end

local function loadGizmoLabels()
    return {
        cancel = Config.placementGizmoCancel or 'Cancel',
        confirm = Config.placementGizmoConfirm or 'Confirm',
        switchRotate = Config.placementGizmoSwitchRotate or 'Switch to rotate mode',
        switchMove = Config.placementGizmoSwitchMove or 'Switch to move mode',
        camSpeed = Config.placementGizmoCamSpeed or 'Camera speed: x%.3f',
        rotationSnap = Config.placementGizmoRotationSnap or 'Rotation snap',
        moveLR = Config.placementGizmoMoveLR or 'Move left/right',
        moveFB = Config.placementGizmoMoveFB or 'Move forward/back',
        moveUp = Config.placementGizmoMoveUp or 'Move up',
        moveDown = Config.placementGizmoMoveDown or 'Move down',
        outOfRange = Config.placementGizmoOutOfRange or 'Distance beyond limit',
    }
end

local function buildCfg(cfg)
    cfg = cfg or {}
    return {
        enableCam = gv(cfg.enableCam, Config.placementJoEnableCam ~= false),
        maxDistance = gv(cfg.maxDistance, tonumber(Config.placementMaxDist) or defaultConfig.maxDistance),
        maxCamDistance = gv(cfg.maxCamDistance, tonumber(Config.placementJoMaxCamDist) or defaultConfig.maxCamDistance),
        minY = gv(cfg.minY, defaultConfig.minY),
        maxY = gv(cfg.maxY, defaultConfig.maxY),
        movementSpeed = gv(cfg.movementSpeed, tonumber(Config.placementJoMoveSpeed) or defaultConfig.movementSpeed),
        allowTranslateX = gv(cfg.allowTranslateX, true),
        allowTranslateY = gv(cfg.allowTranslateY, true),
        allowTranslateZ = gv(cfg.allowTranslateZ, true),
        allowRotateX = gv(cfg.allowRotateX, Config.placementAllowRotateX ~= false),
        allowRotateY = gv(cfg.allowRotateY, Config.placementAllowRotateY ~= false),
        allowRotateZ = gv(cfg.allowRotateZ, Config.placementAllowRotateZ ~= false),
        allowSnapToGround = gv(cfg.allowSnapToGround, Config.placementAllowSnapToGround ~= false),
        snapGroundLabel = cfg.snapGroundLabel or Config.placementGizmoGroundLabel or 'Place on ground',
        rotationSnap = gv(cfg.rotationSnap, tonumber(Config.placementRotationSnap) or defaultConfig.rotationSnap),
        onMove = cfg.onMove,
        promptTitle = cfg.promptTitle or Config.placementGizmoTitle or 'Place flag',
        camAnchor = cfg.camAnchor or Config.placementJoCamAnchor or 'entity',
    }
end

function M.isActive()
    return gizmoActive
end

function M.cancel()
    if not gizmoActive then return end
    responseData = { canceled = true }
    showNUI(false)
end

---@param entity number
---@param cfg table|nil
---@param allowPlace function|nil
---@return table|nil
function M.moveEntity(entity, cfg, allowPlace)
    if gizmoActive then
        showNUI(false)
        Wait(50)
    end
    if not entity or not DoesEntityExist(entity) then return nil end

    cfg = buildCfg(cfg)
    target = entity

    enableCam = cfg.enableCam
    maxDistance = cfg.maxDistance
    maxCamDistance = cfg.maxCamDistance
    minY = cfg.minY
    maxY = cfg.maxY
    movementSpeed = cfg.movementSpeed
    allowTranslateX = cfg.allowTranslateX
    allowTranslateY = cfg.allowTranslateY
    allowTranslateZ = cfg.allowTranslateZ
    allowRotateX = cfg.allowRotateX
    allowRotateY = cfg.allowRotateY
    allowRotateZ = cfg.allowRotateZ
    allowSnapToGround = cfg.allowSnapToGround
    rotationSnapRad = cfg.rotationSnap * math.pi / 180
    mode = 'translate'
    onMove = cfg.onMove
    camAnchorMode = cfg.camAnchor
    gizmoLabels = loadGizmoLabels()

    FreezeEntityPosition(entity, true)
    SetEntityCollision(entity, false, false)

    stored = {
        coords = GetEntityCoords(entity),
        rotation = GetEntityRotation(entity, 2),
    }
    hookedFunc = allowPlace
    responseData = {}

    showNUI(true)
    DisplayHud(false)
    Wait(500)

    SendNUIMessage({
        action = 'SetupGizmo',
        data = {
            handle = entity,
            position = stored.coords,
            rotation = stored.rotation,
            gizmoMode = mode,
            allowTranslateX = allowTranslateX,
            allowTranslateY = allowTranslateY,
            allowTranslateZ = allowTranslateZ,
            allowRotateX = allowRotateX,
            allowRotateY = allowRotateY,
            allowRotateZ = allowRotateZ,
            rotationSnap = rotationSnapRad,
            allowSnapToGround = allowSnapToGround,
        },
    })

    CreateThread(function()
        while gizmoActive do
            disableControls()
            if cam then
                camMovement()
            end
            updateCamNUI()
            Wait(0)
        end
    end)

    Prompt.create(groupName, gizmoLabels.cancel, defaultConfig.keys.cancel)
    Prompt.create(groupName, gizmoLabels.confirm, defaultConfig.keys.confirm)
    Prompt.create(groupName, gizmoLabels.switchRotate, defaultConfig.keys.switchMode)
    if allowSnapToGround then
        Prompt.create(groupName, cfg.snapGroundLabel, defaultConfig.keys.snapToGround)
    end
    Prompt.create(groupName, gizmoLabels.camSpeed:format(movementSpeed),
        { defaultConfig.keys.cameraSpeedUp, defaultConfig.keys.cameraSpeedDown })
    Prompt.create(groupName, gizmoLabels.rotationSnap, defaultConfig.keys.rotationSnap)
    Prompt.setVisible(groupName, defaultConfig.keys.rotationSnap, false)
    if cam then
        Prompt.create(groupName, gizmoLabels.moveLR, defaultConfig.keys.moveX)
        Prompt.create(groupName, gizmoLabels.moveFB, defaultConfig.keys.moveY)
        Prompt.create(groupName, gizmoLabels.moveDown, defaultConfig.keys.moveDown)
        Prompt.create(groupName, gizmoLabels.moveUp, defaultConfig.keys.moveUp)
    end

    while gizmoActive do
        if Prompt.isCompleted(groupName, defaultConfig.keys.switchMode) then
            mode = (mode == 'translate' and 'rotate' or 'translate')
            SendNUIMessage({ action = 'SetGizmoMode', data = mode })
            Prompt.editKeyLabel(groupName, defaultConfig.keys.switchMode,
                mode == 'translate' and gizmoLabels.switchRotate or gizmoLabels.switchMove)
            Prompt.setVisible(groupName, defaultConfig.keys.rotationSnap, mode == 'rotate')
        end

        if allowSnapToGround and Prompt.isCompleted(groupName, defaultConfig.keys.snapToGround) then
            local newPos, newRot = snapEntityToGround(entity)
            if not newPos then
                newPos = GetEntityCoords(entity)
                newRot = GetEntityRotation(entity, 2)
            end
            if onMove then onMove(newPos, newRot) end
            SendNUIMessage({
                action = 'SetupGizmo',
                data = {
                    handle = entity,
                    position = newPos,
                    rotation = newRot,
                    gizmoMode = mode,
                    allowTranslateX = allowTranslateX,
                    allowTranslateY = allowTranslateY,
                    allowTranslateZ = allowTranslateZ,
                    allowRotateX = allowRotateX,
                    allowRotateY = allowRotateY,
                    allowRotateZ = allowRotateZ,
                    rotationSnap = rotationSnapRad,
                },
            })
        end

        if Prompt.isCompleted(groupName, defaultConfig.keys.cameraSpeedUp) then
            movementSpeed = math.min(defaultConfig.maxMovementSpeed,
                movementSpeed + defaultConfig.movementSpeedIncrement)
            refreshSpeedPrompt()
        end

        if Prompt.isCompleted(groupName, defaultConfig.keys.cameraSpeedDown) then
            movementSpeed = math.max(defaultConfig.minMovementSpeed,
                movementSpeed - defaultConfig.movementSpeedIncrement)
            refreshSpeedPrompt()
        end

        if Prompt.isCompleted(groupName, defaultConfig.keys.confirm) then
            local coords = GetEntityCoords(entity)
            responseData = {
                entity = entity,
                coords = coords,
                position = coords,
                rotation = GetEntityRotation(entity, 2),
            }
            showNUI(false)
            break
        end

        if Prompt.isCompleted(groupName, defaultConfig.keys.cancel) then
            responseData = {
                canceled = true,
                entity = entity,
                coords = stored.coords,
                position = stored.coords,
                rotation = stored.rotation,
            }
            SetEntityCoordsNoOffset(entity, stored.coords.x, stored.coords.y, stored.coords.z, false, false, false)
            SetEntityRotation(entity, stored.rotation.x, stored.rotation.y, stored.rotation.z, 2, false)
            showNUI(false)
            break
        end

        if Prompt.isCompleted(groupName, defaultConfig.keys.rotationSnap) then
            SendNUIMessage({ action = 'EnableRotationSnap', data = true })
            while Prompt.isCompleted(groupName, defaultConfig.keys.rotationSnap, true) do
                Wait(0)
            end
            SendNUIMessage({ action = 'EnableRotationSnap', data = false })
        end

        Wait(0)
    end

    Prompt.deleteGroup(groupName)
    DisplayHud(true)

    if responseData and responseData.canceled then
        return responseData
    end
    if responseData and responseData.position then
        return responseData
    end
    return nil
end

RegisterNUICallback('gizmo:UpdateEntity', function(data, cb)
    local entity = data.handle
    if not entity or not DoesEntityExist(entity) or not stored then
        cb({ status = 'invalid' })
        return
    end

    local position = vector3(data.position.x, data.position.y, data.position.z)
    local rotation = vector3(data.rotation.x, data.rotation.y, data.rotation.z)

    if (not maxDistance or #(position - stored.coords) <= maxDistance)
        and (not hookedFunc or hookedFunc(position)) then
        SetEntityCoordsNoOffset(entity, position.x, position.y, position.z, false, false, false)
        SetEntityRotation(entity, rotation.x, rotation.y, rotation.z, 2, false)
        FreezeEntityPosition(entity, true)
        needUpdateCamNUI = true
        if onMove then onMove(position, rotation) end
        cb({ status = 'ok' })
        return
    end

    position = GetEntityCoords(entity)
    rotation = GetEntityRotation(entity, 2)
    cb({
        status = gizmoLabels.outOfRange,
        position = { x = position.x, y = position.y, z = position.z },
        rotation = { x = rotation.x, y = rotation.y, z = rotation.z },
    })
end)

exports('IsGizmoActive', function()
    return M.isActive()
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    if gizmoActive then
        showNUI(false)
    end
end)
