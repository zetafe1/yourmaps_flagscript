--[[
  Subconjunto do jo_libs prompt (nativo RedM) — só para o gizmo integrado.
  Grupos com nome "interaction_*" aparecem sem displayGroup cada frame.
]]

FlagGizmoPrompt = FlagGizmoPrompt or {}

local M = FlagGizmoPrompt
local promptGroups = {}
local lastKey = 0
local promptHidden = {}

local function keyHash(key)
    if type(key) == 'number' then return key end
    if type(key) == 'string' then return joaat(key) end
    return 0
end

function M.create(group, label, key, holdTime, page)
    if not group or key == nil then return false end
    page = page or 0
    holdTime = holdTime or 0

    local primary = type(key) == 'table' and key[1] or key

    promptGroups[group] = promptGroups[group] or {
        group = (type(group) == 'string') and GetRandomIntInRange(0, 0xffffff) or group,
        prompts = {},
        nbrPage = 1,
    }
    promptGroups[group].prompts[page] = promptGroups[group].prompts[page] or {}

    if promptGroups[group].prompts[page][primary] then
        PromptDelete(promptGroups[group].prompts[page][primary])
    end

    local promptId = PromptRegisterBegin()
    promptGroups[group].prompts[page][primary] = promptId

    if type(key) == 'table' then
        for _, k in pairs(key) do
            promptGroups[group].prompts[page][k] = promptId
            PromptSetControlAction(promptId, keyHash(k))
        end
    else
        PromptSetControlAction(promptId, keyHash(key))
    end

    PromptSetText(promptId, CreateVarString(10, 'LITERAL_STRING', label))
    PromptSetPriority(promptId, 2)
    PromptSetEnabled(promptId, true)
    PromptSetVisible(promptId, true)
    if holdTime > 0 then
        PromptSetHoldMode(promptId, holdTime)
    end
    if type(group) ~= 'string' or not group:find('interaction') then
        PromptSetGroup(promptId, promptGroups[group].group, page)
        promptGroups[group].nbrPage = math.max(promptGroups[group].nbrPage, page + 1)
    end
    PromptRegisterEnd(promptId)
    return promptId
end

function M.isGroupExist(group)
    return promptGroups[group] ~= nil
end

function M.isExist(group, key, page)
    if not group or key == nil then return false end
    if not M.isGroupExist(group) then return false end
    page = page or 0
    local primary = type(key) == 'table' and key[1] or key
    return promptGroups[group].prompts[page] and promptGroups[group].prompts[page][primary] ~= nil
end

function M.setVisible(group, key, value, page)
    if not M.isExist(group, key, page) then return end
    page = page or 0
    local primary = type(key) == 'table' and key[1] or key
    if not value then
        promptHidden[group .. page .. primary] = true
    else
        promptHidden[group .. page .. primary] = nil
    end
    UiPromptSetVisible(promptGroups[group].prompts[page][primary], value)
end

function M.editKeyLabel(group, key, label, page)
    if not M.isExist(group, key, page) then return end
    page = page or 0
    local primary = type(key) == 'table' and key[1] or key
    PromptSetText(promptGroups[group].prompts[page][primary], CreateVarString(10, 'LITERAL_STRING', label))
end

function M.setEnabled(group, key, value, page)
    if not M.isExist(group, key, page) then return end
    page = page or 0
    local primary = type(key) == 'table' and key[1] or key
    UiPromptSetEnabled(promptGroups[group].prompts[page][primary], value)
end

function M.isVisible(group, key, page)
    if not M.isExist(group, key, page) then return false end
    page = page or 0
    local primary = type(key) == 'table' and key[1] or key
    if promptHidden[group .. page .. primary] then return false end
    return true
end

function M.isCompleted(group, key, fireMultipleTimes, page)
    local hashed = keyHash(type(key) == 'table' and key[1] or key)
    if not group or key == nil then return false end
    if fireMultipleTimes == nil then fireMultipleTimes = false end
    if not M.isGroupExist(group) then return false end
    page = page or 0
    local primary = type(key) == 'table' and key[1] or key
    if not M.isExist(group, key, page) then return false end
    if not M.isVisible(group, key, page) then return false end

    local promptId = promptGroups[group].prompts[page][primary]
    if PromptHasHoldModeCompleted and PromptHasHoldModeCompleted(promptId) then
        lastKey = promptId
        M.setEnabled(group, key, false, page)
        CreateThread(function()
            while IsDisabledControlPressed(0, hashed) or IsControlPressed(0, hashed) do
                Wait(0)
            end
            lastKey = 0
            M.setEnabled(group, key, true, page)
        end)
        return true
    end

    if IsControlJustPressed(0, hashed) then
        lastKey = hashed
        CreateThread(function()
            while IsControlPressed(0, hashed) do Wait(0) end
            lastKey = 0
        end)
        return true
    end

    if fireMultipleTimes and IsControlPressed(0, hashed) then
        return true
    end
    return false
end

function M.deleteGroup(group)
    if not promptGroups[group] then return end
    for _, prompts in pairs(promptGroups[group].prompts) do
        for _, prompt in pairs(prompts) do
            PromptDelete(prompt)
        end
    end
    promptGroups[group] = nil
end

function M.deleteAllGroups()
    for group in pairs(promptGroups) do
        M.deleteGroup(group)
    end
end

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    M.deleteAllGroups()
end)
