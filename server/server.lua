-- yourmaps_flags - Server.lua (mantém VORP + REDEMRP, com VORP corrigido)

-- Framework APIs
local VorpCore = nil
local VorpInv = nil
local redemrpInventoryData = nil

-- Util
local function fw()
    return string.upper(Config.framework or "OTHER")
end

-- Setup framework APIs
CreateThread(function()
    -- dá um tempinho pro framework subir
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

        print(("[yourmaps_flags] VORP pronto? Core=%s Inv=%s"):format(tostring(VorpCore ~= nil), tostring(VorpInv ~= nil)))

    elseif fw() == "REDEMRP" then
        TriggerEvent("redemrp_inventory:getData", function(call)
            redemrpInventoryData = call
        end)
        print("[yourmaps_flags] REDEMRP inventário carregado?")
    end
end)

-- Exibir texto (suporta ambos)
local function displayUserText(text, source)
    if fw() == "REDEMRP" and Config.nativeText == false then
        TriggerClientEvent("redem_roleplay:Tip", source, text, Config.timeDisplay)
    else
        TriggerClientEvent("yourmaps_flags:TextTip", source, text, Config.timeDisplay)
    end
end

-- Registrar itens usáveis
CreateThread(function()
    -- espera APIs ficarem prontas
    Wait(2500)

    for _, item in ipairs(Config.items or {}) do
        if fw() == "REDEMRP" then
            -- REDEMRP: evento padrão de "usable"
            RegisterServerEvent("RegisterUsableItem:" .. item.name)
            AddEventHandler("RegisterUsableItem:" .. item.name, function(source)
                local type_ = item.type or Config.defaultFlagType
                if Config.textOnUse then
                    displayUserText(Config.useKeys and (Config.flagouttext .. " " .. Config.deployFlagPrompt) or Config.flagouttext, source)
                end
                TriggerClientEvent("yourmaps_flags_UseFlag", source, type_)
            end)
            if Config.debug then
                print("[yourmaps_flags][REDEMRP] Registrado item usável: " .. item.name)
            end

        elseif fw() == "VORP" and VorpInv then
            -- ⚠️ VORP: a assinatura correta recebe um TABLE "data"
            -- data.source é o player, data.name/data.item podem existir dependendo da versão
            VorpInv.RegisterUsableItem(item.name, function(data)
                local src = data.source
                if not src then return end

                -- Se você realmente quiser checar contagem de item, pode:
                local hasItem = true
                if Config.itemRequired then
                    hasItem = (VorpInv.getItemCount(src, item.name) or 0) > 0
                end

                -- Job lock (desligado por padrão)
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
                    TriggerClientEvent("yourmaps_flags_UseFlag", src, type_)
                elseif Config.debug then
                    print(("[yourmaps_flags][VORP] use FAIL item=%s hasItem=%s jobOK=%s"):format(item.name, tostring(hasItem), tostring(jobOK)))
                end
            end)

            print("[yourmaps_flags][VORP] Registrado item usável: " .. item.name)
        end
    end
end)

-- Evento genérico (client pede uso por tipo)
RegisterServerEvent("yourmaps_flags:UseFlag")
AddEventHandler("yourmaps_flags:UseFlag", function(DEFAULT_TYPE)
    local src = source
    if Config.debug then
        print("[yourmaps_flags] yourmaps_flags:UseFlag =>", src, DEFAULT_TYPE)
    end
    TriggerClientEvent("yourmaps_flags_UseFlag", src, DEFAULT_TYPE)
end)

-- Comandos de teste (opcionais)
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
