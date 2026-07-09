--[[
  yourmaps_flagscript — notification adapter (server)
]]

function FlagNotifyPlayer(src, text, kind)
    if not src or not text or text == '' then return end

    local n = Config.Notify or {}
    local duration = tonumber(n.durationMs) or tonumber(Config.timeDisplay) or 5000
    kind = kind or 'info'

    if string.lower(tostring(n.system or 'vorp_right')) == 'none' then
        return
    end

    if string.lower(tostring(n.system or '')) == 'custom' and n.customServerEvent and n.customServerEvent ~= '' then
        TriggerClientEvent(n.customServerEvent, src, text, kind, duration)
        return
    end

    TriggerClientEvent('yourmaps_flags:client:notify', src, text, kind, duration)
end
