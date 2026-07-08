-- yourmaps_flagscript - Server.lua (VORP + REDEMRP)

-- Framework APIs (global — also used by persistence.lua)
VorpCore = nil
VorpInv = nil
local redemrpInventoryData = nil

-- Util
local function fw()
    return string.upper(Config.framework or "OTHER")
end

-- Setup framework APIs
CreateThread(function()
    -- wait for framework to start
    Wait(1000)

    if fw() == "VORP" then
        -- Core
        local tries = 0
        while VorpCore == nil and tries < 30 do
            TriggerEvent("getCore", function(core) VorpCore = core end)
            tries = tries + 1
            Wait(200)
        end

        -- Inventory API
        tries = 0
        while VorpInv == nil and tries < 30 do
            pcall(function()
                VorpInv = exports.vorp_inventory:vorp_inventoryApi()
            end)
            tries = tries + 1
            Wait(200)
        end

        print(("[yourmaps_flags] VORP ready? Core=%s Inv=%s"):format(tostring(VorpCore ~= nil), tostring(VorpInv ~= nil)))

    elseif fw() == "REDEMRP" then
        TriggerEvent("redemrp_inventory:getData", function(call)
            redemrpInventoryData = call
        end)
        print("[yourmaps_flags] REDEMRP inventory loaded?")
    end
end)

-- Display text (both frameworks)
local function displayUserText(text, source)
    if fw() == "REDEMRP" and Config.nativeText == false then
        TriggerClientEvent("redem_roleplay:Tip", source, text, Config.timeDisplay)
    else
        TriggerClientEvent("yourmaps_flags:TextTip", source, text, Config.timeDisplay)
    end
end

-- Register usable items
CreateThread(function()
    -- wait for APIs
    Wait(2500)

    for _, item in ipairs(Config.items or {}) do
        if fw() == "REDEMRP" then
            -- REDEMRP: standard usable event
            RegisterServerEvent("RegisterUsableItem:" .. item.name)
            AddEventHandler("RegisterUsableItem:" .. item.name, function(source)
                local type_ = item.type or Config.defaultFlagType
                if Config.textOnUse then
                    displayUserText(Config.useKeys and (Config.flagouttext .. " " .. Config.deployFlagPrompt) or Config.flagouttext, source)
                end
                TriggerClientEvent("yourmaps_flags_UseFlag", source, type_, item.name)
            end)
            if Config.debug then
                print("[yourmaps_flags][REDEMRP] Registered usable item: " .. item.name)
            end

        elseif fw() == "VORP" and VorpInv then
            -- VORP: callback receives a TABLE "data"
            -- data.source is the player; data.name/data.item may exist depending on version
            VorpInv.RegisterUsableItem(item.name, function(data)
                local src = data.source
                if not src then return end

                -- Optional item count check
                local hasItem = true
                if Config.itemRequired then
                    hasItem = (VorpInv.getItemCount(src, item.name) or 0) > 0
                end

                -- Job lock (disabled by default)
                local jobOK = true
                if Config.joblock then
                    local User = VorpCore and VorpCore.getUser and VorpCore.getUser(src)
                    local Character = User and (User.getUsedCharacter and User.getUsedCharacter() or User.getUsedCharacter) or nil
                    local charJob = Character and (Character.job or Character.jobName or Character.Job or Character.job and Character.job.name) or nil
                    jobOK = false
                    for _, j in ipairs(Config.jobs or {}) do
                        if charJob == j then
                            jobOK = true
                            break
                        end
                    end
                end

                if hasItem and jobOK then
                    local type_ = item.type or Config.defaultFlagType
                    if Config.textOnUse then
                        displayUserText(Config.useKeys and (Config.flagouttext .. " " .. Config.deployFlagPrompt) or Config.flagouttext, src)
                    end
                    TriggerClientEvent("yourmaps_flags_UseFlag", src, type_, item.name)
                elseif Config.debug then
                    print(("[yourmaps_flags][VORP] use FAIL item=%s hasItem=%s jobOK=%s"):format(item.name, tostring(hasItem), tostring(jobOK)))
                end
            end)

            print("[yourmaps_flags][VORP] Registered usable item: " .. item.name)
        end
    end
end)

-- Generic event (client requests use by type)
RegisterServerEvent("yourmaps_flags:UseFlag")
AddEventHandler("yourmaps_flags:UseFlag", function(DEFAULT_TYPE)
    local src = source
    if Config.debug then
        print("[yourmaps_flags] yourmaps_flags:UseFlag =>", src, DEFAULT_TYPE)
    end
    TriggerClientEvent("yourmaps_flags_UseFlag", src, DEFAULT_TYPE, nil)
end)

-- Optional test commands
CreateThread(function()
    if Config.slashCommands then
        RegisterCommand(Config.flagdrop, function(source)
            TriggerClientEvent('yourmaps_flags:DropFlag', source)
        end)
        RegisterCommand(Config.flagpickup, function(source)
            TriggerClientEvent('yourmaps_flags:PickupFlag', source)
        end)
        RegisterCommand(Config.flagdelete, function(source)
            TriggerClientEvent('yourmaps_flags:DelFlag', source)
        end)
    end
end)
