--[[
    yourmaps_flagscript — translations (loaded after config.lua).
    Set Config.LocaleLanguage in config.lua: 'en', 'fr', 'pt', 'es', 'it'
    Optional per-key overrides: Config.Locale['key'] = 'your text'
]]

local LOCALES = {
    en = {
        pickup_flag_prompt = '[%s] Pick up the flag',
        deploy_flag_prompt = '[%s] Place the flag on the ground',
        flag_already_dropped = 'You have already placed a flag on the ground. Pick it up before deploying another.',
        native_equipped_title = 'Flag',
        native_placed_title = 'Placed flag',
        native_temp_title = 'Flag',
        native_deploy_label = 'Place flag',
        native_stash_label = 'Put flag away',
        native_pickup_placed_label = 'Pick up flag',
        native_pickup_temp_label = 'Pick up flag',
        flag_dropped = 'Flag dropped!',
        flag_picked_up = 'Flag picked up!',
        flag_far = 'The flag is too far away to be picked up!',
        persistent_pickup_prompt = '[%s] Pick up flag',
        persistent_place = 'Flag placed.',
        persistent_pickup = 'Flag picked up.',
        persistent_max = 'You have reached the maximum number of placed flags.',
        persistent_not_owner = 'This flag does not belong to you.',
        persistent_place_fail = 'Could not place the flag.',
        placement_gizmo_ground = 'Place on ground',
        placement_gizmo_cancel = 'Cancel',
        placement_gizmo_confirm = 'Confirm',
        placement_gizmo_switch_rotate = 'Switch to rotate mode',
        placement_gizmo_switch_move = 'Switch to move mode',
        placement_gizmo_free_cam = 'Free camera',
        placement_gizmo_focus_flag = 'Focus on flag',
        placement_gizmo_cam_speed = 'Camera speed: x%.3f',
        placement_gizmo_rotation_snap = 'Rotation snap',
        placement_gizmo_move_lr = 'Move left/right',
        placement_gizmo_move_fb = 'Move forward/back',
        placement_gizmo_move_up = 'Move up',
        placement_gizmo_move_down = 'Move down',
        placement_gizmo_out_of_range = 'Distance beyond limit',
        placement_cancelled = 'Placement cancelled.',
        cmd_default_desc = 'Set default flag type.',
        cmd_takeout_desc = 'Take out a flag.',
        cmd_drop_desc = 'Dropped a flag.',
        cmd_pickup_desc = 'Picked up a flag.',
        cmd_delete_desc = 'Put the flag away.',
    },
    pt = {
        pickup_flag_prompt = '[%s] Apanhar a bandeira',
        deploy_flag_prompt = '[%s] Colocar a bandeira no chão',
        flag_already_dropped = 'Já tens uma bandeira no chão. Apanha-a antes de colocar outra.',
        native_equipped_title = 'Bandeira',
        native_placed_title = 'Bandeira colocada',
        native_temp_title = 'Bandeira',
        native_deploy_label = 'Colocar bandeira',
        native_stash_label = 'Guardar bandeira',
        native_pickup_placed_label = 'Recolher bandeira',
        native_pickup_temp_label = 'Levantar bandeira',
        flag_dropped = 'Bandeira largada!',
        flag_picked_up = 'Bandeira apanhada!',
        flag_far = 'A bandeira está demasiado longe para ser apanhada!',
        persistent_pickup_prompt = '[%s] Recolher bandeira',
        persistent_place = 'Bandeira colocada.',
        persistent_pickup = 'Bandeira recolhida.',
        persistent_max = 'Já atingiste o máximo de bandeiras colocadas.',
        persistent_not_owner = 'Esta bandeira não é tua.',
        persistent_place_fail = 'Não foi possível colocar a bandeira.',
        placement_gizmo_ground = 'Colocar no chão',
        placement_gizmo_cancel = 'Cancelar',
        placement_gizmo_confirm = 'Confirmar',
        placement_gizmo_switch_rotate = 'Alternar modo rotação',
        placement_gizmo_switch_move = 'Alternar modo mover',
        placement_gizmo_free_cam = 'Câmera livre',
        placement_gizmo_focus_flag = 'Focar bandeira',
        placement_gizmo_cam_speed = 'Velocidade da câmera: x%.3f',
        placement_gizmo_rotation_snap = 'Encaixe de rotação',
        placement_gizmo_move_lr = 'Mover E/D',
        placement_gizmo_move_fb = 'Mover F/T',
        placement_gizmo_move_up = 'Subir',
        placement_gizmo_move_down = 'Descer',
        placement_gizmo_out_of_range = 'Distância além do permitido',
        placement_cancelled = 'Colocação cancelada.',
        cmd_default_desc = 'Definir tipo de bandeira por defeito.',
        cmd_takeout_desc = 'Tirar uma bandeira.',
        cmd_drop_desc = 'Largou uma bandeira.',
        cmd_pickup_desc = 'Apanhou uma bandeira.',
        cmd_delete_desc = 'Guardar a bandeira.',
    },
    fr = {
        pickup_flag_prompt = '[%s] Ramasser le drapeau',
        deploy_flag_prompt = '[%s] Poser le drapeau au sol',
        flag_already_dropped = 'Vous avez déjà posé un drapeau. Ramassez-le avant d\'en déployer un autre.',
        native_equipped_title = 'Drapeau',
        native_placed_title = 'Drapeau posé',
        native_temp_title = 'Drapeau',
        native_deploy_label = 'Poser le drapeau',
        native_stash_label = 'Ranger le drapeau',
        native_pickup_placed_label = 'Ramasser le drapeau',
        native_pickup_temp_label = 'Ramasser le drapeau',
        flag_dropped = 'Drapeau posé !',
        flag_picked_up = 'Drapeau ramassé !',
        flag_far = 'Le drapeau est trop loin pour être ramassé !',
        persistent_pickup_prompt = '[%s] Ramasser le drapeau',
        persistent_place = 'Drapeau placé.',
        persistent_pickup = 'Drapeau ramassé.',
        persistent_max = 'Vous avez atteint le nombre maximum de drapeaux placés.',
        persistent_not_owner = 'Ce drapeau ne vous appartient pas.',
        persistent_place_fail = 'Impossible de placer le drapeau.',
        placement_gizmo_ground = 'Poser au sol',
        placement_gizmo_cancel = 'Annuler',
        placement_gizmo_confirm = 'Confirmer',
        placement_gizmo_switch_rotate = 'Mode rotation',
        placement_gizmo_switch_move = 'Mode déplacement',
        placement_gizmo_free_cam = 'Caméra libre',
        placement_gizmo_focus_flag = 'Viser le drapeau',
        placement_gizmo_cam_speed = 'Vitesse caméra : x%.3f',
        placement_gizmo_rotation_snap = 'Aimant rotation',
        placement_gizmo_move_lr = 'Gauche/droite',
        placement_gizmo_move_fb = 'Avant/arrière',
        placement_gizmo_move_up = 'Monter',
        placement_gizmo_move_down = 'Descendre',
        placement_gizmo_out_of_range = 'Distance hors limite',
        placement_cancelled = 'Placement annulé.',
        cmd_default_desc = 'Définir le type de drapeau par défaut.',
        cmd_takeout_desc = 'Sortir un drapeau.',
        cmd_drop_desc = 'A posé un drapeau.',
        cmd_pickup_desc = 'A ramassé un drapeau.',
        cmd_delete_desc = 'Ranger le drapeau.',
    },
    es = {
        pickup_flag_prompt = '[%s] Recoger la bandera',
        deploy_flag_prompt = '[%s] Colocar la bandera en el suelo',
        flag_already_dropped = 'Ya has colocado una bandera. Recógela antes de desplegar otra.',
        native_equipped_title = 'Bandera',
        native_placed_title = 'Bandera colocada',
        native_temp_title = 'Bandera',
        native_deploy_label = 'Colocar bandera',
        native_stash_label = 'Guardar bandera',
        native_pickup_placed_label = 'Recoger bandera',
        native_pickup_temp_label = 'Recoger bandera',
        flag_dropped = '¡Bandera colocada!',
        flag_picked_up = '¡Bandera recogida!',
        flag_far = '¡La bandera está demasiado lejos para recogerla!',
        persistent_pickup_prompt = '[%s] Recoger bandera',
        persistent_place = 'Bandera colocada.',
        persistent_pickup = 'Bandera recogida.',
        persistent_max = 'Has alcanzado el máximo de banderas colocadas.',
        persistent_not_owner = 'Esta bandera no te pertenece.',
        persistent_place_fail = 'No se pudo colocar la bandera.',
        placement_gizmo_ground = 'Colocar en el suelo',
        placement_gizmo_cancel = 'Cancelar',
        placement_gizmo_confirm = 'Confirmar',
        placement_gizmo_switch_rotate = 'Modo rotación',
        placement_gizmo_switch_move = 'Modo mover',
        placement_gizmo_free_cam = 'Cámara libre',
        placement_gizmo_focus_flag = 'Enfocar bandera',
        placement_gizmo_cam_speed = 'Velocidad cámara: x%.3f',
        placement_gizmo_rotation_snap = 'Ajuste de rotación',
        placement_gizmo_move_lr = 'Mover I/D',
        placement_gizmo_move_fb = 'Mover A/T',
        placement_gizmo_move_up = 'Subir',
        placement_gizmo_move_down = 'Bajar',
        placement_gizmo_out_of_range = 'Distancia fuera de límite',
        placement_cancelled = 'Colocación cancelada.',
        cmd_default_desc = 'Establecer tipo de bandera por defecto.',
        cmd_takeout_desc = 'Sacar una bandera.',
        cmd_drop_desc = 'Dejó una bandera.',
        cmd_pickup_desc = 'Recogió una bandera.',
        cmd_delete_desc = 'Guardar la bandera.',
    },
    it = {
        pickup_flag_prompt = '[%s] Raccogli la bandiera',
        deploy_flag_prompt = '[%s] Posiziona la bandiera a terra',
        flag_already_dropped = 'Hai già posizionato una bandiera. Raccoglila prima di piazzarne un\'altra.',
        native_equipped_title = 'Bandiera',
        native_placed_title = 'Bandiera posizionata',
        native_temp_title = 'Bandiera',
        native_deploy_label = 'Posiziona bandiera',
        native_stash_label = 'Riponi bandiera',
        native_pickup_placed_label = 'Raccogli bandiera',
        native_pickup_temp_label = 'Raccogli bandiera',
        flag_dropped = 'Bandiera posizionata!',
        flag_picked_up = 'Bandiera raccolta!',
        flag_far = 'La bandiera è troppo lontana per essere raccolta!',
        persistent_pickup_prompt = '[%s] Raccogli bandiera',
        persistent_place = 'Bandiera posizionata.',
        persistent_pickup = 'Bandiera raccolta.',
        persistent_max = 'Hai raggiunto il numero massimo di bandiere posizionate.',
        persistent_not_owner = 'Questa bandiera non ti appartiene.',
        persistent_place_fail = 'Impossibile posizionare la bandiera.',
        placement_gizmo_ground = 'Posiziona a terra',
        placement_gizmo_cancel = 'Annulla',
        placement_gizmo_confirm = 'Conferma',
        placement_gizmo_switch_rotate = 'Modalità rotazione',
        placement_gizmo_switch_move = 'Modalità sposta',
        placement_gizmo_free_cam = 'Camera libera',
        placement_gizmo_focus_flag = 'Inquadra bandiera',
        placement_gizmo_cam_speed = 'Velocità camera: x%.3f',
        placement_gizmo_rotation_snap = 'Snap rotazione',
        placement_gizmo_move_lr = 'Sinistra/destra',
        placement_gizmo_move_fb = 'Avanti/indietro',
        placement_gizmo_move_up = 'Salire',
        placement_gizmo_move_down = 'Scendere',
        placement_gizmo_out_of_range = 'Distanza oltre il limite',
        placement_cancelled = 'Posizionamento annullato.',
        cmd_default_desc = 'Imposta il tipo di bandiera predefinito.',
        cmd_takeout_desc = 'Tira fuori una bandiera.',
        cmd_drop_desc = 'Ha posizionato una bandiera.',
        cmd_pickup_desc = 'Ha raccolto una bandiera.',
        cmd_delete_desc = 'Riponi la bandiera.',
    },
}

local function resolveCode()
    local c = tostring(Config.LocaleLanguage or 'en'):lower():gsub('%s+', '')
    if LOCALES[c] then
        return c
    end
    if c == 'pt-br' or c == 'pt_br' or c == 'br' then
        return 'pt'
    end
    return 'en'
end

local CODE = resolveCode()
local PACK = LOCALES[CODE] or LOCALES.en
local FALLBACK = LOCALES.en or {}

--- @param key string
--- @return string
function Locale(key)
    if type(key) ~= 'string' then
        return tostring(key)
    end
    local o = Config.Locale
    if o and o[key] ~= nil then
        return o[key]
    end
    local v = PACK[key]
    if v ~= nil then
        return v
    end
    v = FALLBACK[key]
    if v ~= nil then
        return v
    end
    return key
end

local function keyLabel(name, fallback)
    if Config.keylist and Config.keylist[name] then
        return name
    end
    return fallback or name or 'G'
end

function ApplyFlagLocale()
    local pickupKey = keyLabel(Config.pickupKey, 'G')
    local dropKey = keyLabel(Config.dropKey, 'G')

    Config.pickupFlagPrompt = string.format(Locale('pickup_flag_prompt'), pickupKey)
    Config.deployFlagPrompt = string.format(Locale('deploy_flag_prompt'), dropKey)
    Config.flagAlreadyDroppedText = Locale('flag_already_dropped')

    Config.nativeEquippedTitle = Locale('native_equipped_title')
    Config.nativePlacedTitle = Locale('native_placed_title')
    Config.nativeTempTitle = Locale('native_temp_title')
    Config.nativeDeployLabel = Locale('native_deploy_label')
    Config.nativeStashLabel = Locale('native_stash_label')
    Config.nativePickupPlacedLabel = Locale('native_pickup_placed_label')
    Config.nativePickupTempLabel = Locale('native_pickup_temp_label')

    Config.flagdroptext = Locale('flag_dropped')
    Config.flagpickuptext = Locale('flag_picked_up')
    Config.flagfartext = Locale('flag_far')

    Config.persistentPickupPrompt = string.format(Locale('persistent_pickup_prompt'), pickupKey)
    Config.persistentPlaceText = Locale('persistent_place')
    Config.persistentPickupText = Locale('persistent_pickup')
    Config.persistentMaxText = Locale('persistent_max')
    Config.persistentNotOwnerText = Locale('persistent_not_owner')
    Config.persistentPlaceFailText = Locale('persistent_place_fail')
    Config.placementCancelledText = Locale('placement_cancelled')
    Config.placementGizmoTitle = Locale('native_equipped_title')
    Config.placementGizmoGroundLabel = Locale('placement_gizmo_ground')
    Config.placementGizmoCancel = Locale('placement_gizmo_cancel')
    Config.placementGizmoConfirm = Locale('placement_gizmo_confirm')
    Config.placementGizmoSwitchRotate = Locale('placement_gizmo_switch_rotate')
    Config.placementGizmoSwitchMove = Locale('placement_gizmo_switch_move')
    Config.placementGizmoFreeCam = Locale('placement_gizmo_free_cam')
    Config.placementGizmoFocusFlag = Locale('placement_gizmo_focus_flag')
    Config.placementGizmoCamSpeed = Locale('placement_gizmo_cam_speed')
    Config.placementGizmoRotationSnap = Locale('placement_gizmo_rotation_snap')
    Config.placementGizmoMoveLR = Locale('placement_gizmo_move_lr')
    Config.placementGizmoMoveFB = Locale('placement_gizmo_move_fb')
    Config.placementGizmoMoveUp = Locale('placement_gizmo_move_up')
    Config.placementGizmoMoveDown = Locale('placement_gizmo_move_down')
    Config.placementGizmoOutOfRange = Locale('placement_gizmo_out_of_range')

    Config.flagdefaultdescription = Locale('cmd_default_desc')
    Config.flagtakeouttdescription = Locale('cmd_takeout_desc')
    Config.flagdropdescription = Locale('cmd_drop_desc')
    Config.flagpickupdescription = Locale('cmd_pickup_desc')
    Config.flagdeletedescription = Locale('cmd_delete_desc')
end

ApplyFlagLocale()
