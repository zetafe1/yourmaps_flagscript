--[[
  Adaptador de notificações — cada servidor escolhe o seu em Config.Notify.system

  vorp_right   — default básico (VORP NotifyRightTip)
  vorp_bottom  — VORP tip em baixo
  jo_libs      — jo.notif.right / rightError
  redem        — redem_roleplay:Tip
  custom       — Config.Notify.customClientEvent(src via server)
  none         — desactivado

  auto: jo_libs (se existir) → senão vorp_right
]]

local function notifyCfg()
    return Config.Notify or {}
end

local function resolveSystem()
    local system = string.lower(tostring(notifyCfg().system or 'vorp_right'))
    if system ~= 'auto' then
        return system
    end
    if jo and jo.notif and jo.notif.right then
        return 'jo_libs'
    end
    return 'vorp_right'
end

local function notifyDuration(duration)
    return tonumber(duration)
        or tonumber(notifyCfg().durationMs)
        or tonumber(Config.timeDisplay)
        or 5000
end

function FlagNotify(text, duration, kind)
    if not text or text == '' then return end

    local n = notifyCfg()
    if string.lower(tostring(n.system or 'vorp_right')) == 'none' then
        return
    end

    duration = notifyDuration(duration)
    kind = kind or 'info'
    local system = resolveSystem()

    if system == 'custom' and n.customClientEvent and n.customClientEvent ~= '' then
        TriggerEvent(n.customClientEvent, text, duration, kind)
        return
    end

    if system == 'jo_libs' then
        if jo and jo.notif then
            if kind == 'error' and jo.notif.rightError then
                jo.notif.rightError(text)
                return
            end
            if jo.notif.right then
                jo.notif.right(text, 'hud_textures', 'check', 'COLOR_WHITE', duration)
                return
            end
        end
        system = 'vorp_right'
    end

    if system == 'vorp_right' then
        if exports.vorp_core and exports.vorp_core.GetCore then
            local ok, core = pcall(function()
                return exports.vorp_core:GetCore()
            end)
            if ok and core and core.NotifyRightTip then
                core.NotifyRightTip(text, duration)
                return
            end
        end
        TriggerEvent('vorp:TipRight', text, duration)
        return
    end

    if system == 'vorp_bottom' then
        TriggerEvent('vorp:TipBottom', text, duration)
        return
    end

    if system == 'redem' then
        TriggerEvent('redem_roleplay:Tip', text, duration)
        return
    end

    TriggerEvent('vorp:TipRight', text, duration)
end

function FlagShowMessage(text, duration, kind)
    if Config.nativeText then
        local vstr = CreateVarString(10, 'LITERAL_STRING', text)
        Citizen.InvokeNative(0xFA233F8FE190514C, vstr)
        Citizen.InvokeNative(0xE9990552DEC71600)
        return
    end
    FlagNotify(text, duration, kind)
end

RegisterNetEvent('yourmaps_flags:client:notify')
AddEventHandler('yourmaps_flags:client:notify', function(text, kind, duration)
    FlagNotify(text, duration, kind)
end)

RegisterNetEvent('yourmaps_flags:TextTip')
AddEventHandler('yourmaps_flags:TextTip', function(text, duration)
    FlagNotify(text, duration, 'info')
end)

exports('Notify', FlagNotify)
exports('ShowMessage', FlagShowMessage)
