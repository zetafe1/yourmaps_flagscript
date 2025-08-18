-- yourmaps_flags - Server.lua (adaptado p/ VORP e REDEMRP)
-- Foco no VORP funcionando

local VorpCore = {}
local VorpInv = {}
local redemrpInventoryData = {}

-- Setup framework APIs
CreateThread(function()
    Wait(2000)
    local fw = string.upper(Config.framework)

    if fw == "VORP" then
        -- Get VORP Core and Inventory APIs
        TriggerEvent("getCore", function(core)
            VorpCore = core
        end)

        VorpInv = exports.vorp_inventory:vorp_inventoryApi()

        print("[yourmaps_flags] VORP Core e Inventory carregados.")

    elseif fw == "REDEMRP" then
        -- Load REDEMRP Inventory Data
        TriggerEvent("redemrp_inventory:getData", function(call)
            redemrpInventoryData = call
        end)

        print("[yourmaps_flags] RedEMRP Inventory carregado.")
    end
end)

-- Exibir texto pro jogador
local function displayUserText(text, source)
    local fw = string.upper(Config.framework)

    if fw == "REDEMRP" and Config.nativeText == false then
        TriggerClientEvent("redem_roleplay:Tip", source, text, Config.timeDisplay)
    else
        TriggerClientEvent("yourmaps_flags:TextTip", source, text, Config.timeDisplay)
    end
end

-- Registrar itens usáveis
CreateThread(function()
    Wait(3000) -- garantir que APIs carregaram
    local fw = string.upper(Config.framework)

    for _, item in ipairs(Config.items) do
        if fw == "REDEMRP" then
            RegisterServerEvent("RegisterUsableItem:" .. item.name)
            AddEventHandler("RegisterUsableItem:" .. item.name, function(source)
                TriggerClientEvent("yourmaps_flags_UseFlag", source, item.type)
            end)

        elseif fw == "VORP" and VorpInv then
            VorpInv.RegisterUsableItem(item.name, function(source)
                local User = VorpCore.getUser(source)
                if not User then return end
                local Character = User.getUsedCharacter
                local itemFound = VorpInv.getItemCount(source, item.name) > 0
                local type = item.type or Config.defaultFlagType

                local jobFound = not Config.joblock
                if Config.joblock then
                    for _, job in ipairs(Config.jobs) do
                        if Character.job == job then
                            jobFound = true
                            break
                        end
                    end
                end

                if itemFound and jobFound then
                    if Config.textOnUse then
                        displayUserText(Config.useKeys and (Config.flagouttext .. Config.deployFlagPrompt) or Config.flagouttext, source)
                    end
                    TriggerClientEvent("yourmaps_flags_UseFlag", source, type)
                elseif Config.debug then
                    print("[VORP FLAG USE FAILED]", item.name, itemFound, jobFound)
                end
            end)
            print("[yourmaps_flags] VORP item registrado: " .. item.name)
        end
    end
end)

-- Eventos client > server
RegisterServerEvent("yourmaps_flags:UseFlag")
AddEventHandler("yourmaps_flags:UseFlag", function(DEFAULT_TYPE)
    local src = source
    if Config.debug then
        print("[FLAG_USE]", src, DEFAULT_TYPE)
    end
    TriggerClientEvent('yourmaps_flags_UseFlag', src, DEFAULT_TYPE)
end)

-- Slash commands de debug
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
