--[[
  Colocação de bandeira — gizmo integrado (port jo_libs, standalone).
]]

FlagPlacement = FlagPlacement or {}

local M = FlagPlacement
local active = false

local function ensurePoleAssembly(pole, flag, eagle)
    if not pole or not DoesEntityExist(pole) then return end
    if flag and DoesEntityExist(flag) and not IsEntityAttachedToEntity(flag, pole) then
        AttachEntityToEntity(flag, pole, 0, 0.0, 0.0, 2.9, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    end
    if eagle and DoesEntityExist(eagle) and not IsEntityAttachedToEntity(eagle, pole) then
        AttachEntityToEntity(eagle, pole, 0, 0.0, 0.01, 3.72, -75.0, 0.0, -192.0, true, true, false, true, 1, true)
    end
end

local function groundOffset()
    return tonumber(Config.placementGroundOffsetZ) or 0.0
end

local function maxPlacementDist()
    return tonumber(Config.placementMaxDist) or 3.0
end

local function getGroundZ(x, y, zHint)
    local hint = (zHint or 0.0) + 3.0
    local found, groundZ = GetGroundZFor_3dCoord(x, y, hint, false)
    if found then
        return groundZ + groundOffset()
    end
    return (zHint or 0.0) + groundOffset()
end

local function setPlacementPhysics(pole, flag, eagle)
    for _, ent in ipairs({ pole, flag, eagle }) do
        if ent and DoesEntityExist(ent) then
            SetEntityCollision(ent, false, false)
            FreezeEntityPosition(ent, true)
            SetEntityInvincible(ent, true)
        end
    end
end

local function restoreVisuals(pole, flag, eagle)
    for _, ent in ipairs({ pole, flag, eagle }) do
        if ent and DoesEntityExist(ent) then
            ResetEntityAlpha(ent)
            SetEntityCollision(ent, true, true)
            SetEntityInvincible(ent, false)
        end
    end
end

local function spawnInFrontOfPed(anchor, pole, flag, eagle)
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    local dist = tonumber(Config.placementSpawnDist) or 1.5
    local x = pedCoords.x + forward.x * dist
    local y = pedCoords.y + forward.y * dist
    local z = getGroundZ(x, y, pedCoords.z)

    SetEntityCoords(anchor, x, y, z, false, false, false, false)
    SetEntityHeading(anchor, GetEntityHeading(ped) + (Config.placementHeadingOffset or 90.0))
    if pole then
        ensurePoleAssembly(pole, flag, eagle)
    end
end

local function isCancelled(result)
    return not result or result.canceled or result.cancelled
end

function M.isActive()
    return active or (FlagGizmo and FlagGizmo.isActive())
end

function M.cancel()
    active = false
    if FlagGizmo then FlagGizmo.cancel() end
    if FlagInteractions and FlagInteractions.state then
        FlagInteractions.state.placementActive = false
    end
end

--- @param ctx table
function M.start(ctx)
    if active or not ctx or not FlagGizmo then return false end
    local pole, flag, eagle = ctx.pole, ctx.flag, ctx.eagle
    local anchor = pole or flag
    if not anchor or not DoesEntityExist(anchor) then return false end

    active = true
    if FlagInteractions and FlagInteractions.state then
        FlagInteractions.state.placementActive = true
    end

    ClearPedTasks(PlayerPedId())
    DetachEntity(pole or 0, true, true)
    DetachEntity(flag or 0, true, true)
    DetachEntity(eagle or 0, true, true)
    if pole then ensurePoleAssembly(pole, flag, eagle) end
    setPlacementPhysics(pole, flag, eagle)
    spawnInFrontOfPed(anchor, pole, flag, eagle)

    CreateThread(function()
        local result = FlagGizmo.moveEntity(anchor, {
            enableCam = Config.placementJoEnableCam ~= false,
            maxDistance = maxPlacementDist(),
            maxCamDistance = tonumber(Config.placementJoMaxCamDist) or 30.0,
            movementSpeed = tonumber(Config.placementJoMoveSpeed) or 0.10,
            allowSnapToGround = Config.placementAllowSnapToGround ~= false,
            allowRotateX = Config.placementAllowRotateX ~= false,
            allowRotateY = Config.placementAllowRotateY ~= false,
            allowRotateZ = Config.placementAllowRotateZ ~= false,
            snapGroundLabel = Config.placementGizmoGroundLabel,
            promptTitle = Config.placementGizmoTitle,
        }, function(pos)
            return #(vector3(pos.x, pos.y, pos.z) - GetEntityCoords(PlayerPedId())) <= maxPlacementDist()
        end)

        active = false
        if FlagInteractions and FlagInteractions.state then
            FlagInteractions.state.placementActive = false
        end

        if isCancelled(result) then
            restoreVisuals(pole, flag, eagle)
            if ctx.onCancel then ctx.onCancel() end
            return
        end

        restoreVisuals(pole, flag, eagle)
        if pole then ensurePoleAssembly(pole, flag, eagle) end

        local coords = result.coords or result.position or GetEntityCoords(anchor)
        local rot = result.rotation or GetEntityRotation(anchor, 2)
        if type(rot) == 'table' and rot.x then
            rot = vector3(rot.x + 0.0, rot.y + 0.0, rot.z + 0.0)
        end
        local heading = rot.z or GetEntityHeading(anchor)
        FreezeEntityPosition(anchor, true)

        if ctx.onConfirm then
            ctx.onConfirm(vector3(coords.x, coords.y, coords.z), heading, {
                skipGroundSnap = true,
                rotation = rot,
            })
        end
    end)

    return true
end
