-- yourmaps_flagscript - Full Config

Config = {}

-- FRAMEWORK SETUP
Config.framework = 'VORP' -- OPTIONS: "VORP", "REDEMRP", "OTHER"
Config.LocaleLanguage = 'en' -- 'en', 'fr', 'pt', 'es', 'it' (see lang.lua)
-- Optional per-string overrides: Config.Locale = { pickup_flag_prompt = '[%s] Custom text' }
Config.Locale = {}
Config.nativeText = false
Config.timeDisplay = 5000
Config.disableHorseAnimation = false

-- COMMANDS
Config.slashCommands = false
Config.flaguse = "flag"
Config.flagdrop = "flagdrop"
Config.flagpickup = "flagpickup"
Config.flagdelete = "flagdelete"
Config.setDefaultType = "flagdefault"
Config.defaultFlagType = "american"

-- CHAT SUGGESTIONS (filled from lang.lua via ApplyFlagLocale)

-- KEYBINDS
Config.useKeys = true
Config.takeOutFlag = false
Config.pickupKey = "G"
Config.dropKey = "G"
Config.deleteKey = "BACKSPACE"
Config.displayPickupDist = 2.0
Config.maxPickupDist = 2.0

-- Player-facing strings are set in lang.lua (ApplyFlagLocale)

-- INTERACTION (how the player interacts with flags)
-- Ground / placed flag (pick up / persistent):
--   'drawtext' | 'native' | 'murphy_interact' | 'blkb_interaction' | 'pc_interaction' | 'custom'
Config.placedInteraction = 'drawtext'
-- Equipped flag (place / stash):
--   'keys' (pickupKey/deleteKey) | 'native' (RedM prompt) | 'drawtext'
Config.equippedInteraction = 'keys'
-- Resource for murphy_interact / blkb_interaction / pc_interaction
Config.interactionResource = 'blkb_interaction'
-- Native RedM prompt (NOT jo_libs) — control hash, e.g. G = 0x760A9C6F
Config.nativePromptControl = 0x760A9C6F
Config.nativePromptHoldMs = 0          -- 0 = press; >0 = hold (ms)

-- TEXT DISPLAY
Config.textOnUse = true
Config.flagouttext = ''
Config.textOnDrop = false
Config.textOnPickup = false

-- PERSISTENT FLAGS (leave flags at camp / home)
-- Requires oxmysql + run ym_flags_placed.sql
Config.persistentFlags = true
Config.persistentMaxPerPlayer = 15          -- max placed flags per character
Config.persistentOwnerOnly = true           -- only owner can pick up placed flag
Config.persistentConsumeOnPlace = true      -- remove item from inventory when placed
Config.persistentReturnItemOnPickup = true  -- return item when picked up
Config.persistentPickupDist = 2.5           -- distance to pick up placed flag
Config.persistentDisplayDist = 8.0          -- distance to show 3D prompt / target

-- JOB LOCKING
Config.joblock = false
Config.jobs = {
    "sheriff",
    "ranger",
    "police",
}

-- ITEM REQUIREMENTS
Config.itemRequired = false
Config.items = {

{name = 'ambarinoflag', label = 'Ambarino State Flag', type = 'ambarino_1', c = 1},
{name = 'americanflag', label = 'American Flag', type = 'american', c = 1},
{name = 'australiaflag', label = 'Australia Flag', type = 'australia', c = 1},
{name = 'belgiumflag', label = 'Belgium Flag', type = 'belgium', c = 1},
{name = 'brflag', label = 'Brasil Flag', type = 'br', c = 1},
{name = 'canadaflag', label = 'Canada Flag', type = 'canada', c = 1},
{name = 'cataloniaflag', label = 'Catalonia Flag', type = 'catalonia', c = 1},
{name = 'chinaflag', label = 'China Flag', type = 'china', c = 1},
{name = 'comancheflag', label = 'Comanche Tribe Flag', type = 'comanche', c = 1},
{name = 'confflag', label = 'Confederation Flag', type = 'conf', c = 1},
{name = 'cubaflag', label = 'Cuba Flag', type = 'cuba', c = 1},
{name = 'czechflag', label = 'Czech Republic Flag', type = 'czech', c = 1},
{name = 'denmarkflag', label = 'Denmark Flag', type = 'denmark', c = 1},
{name = 'finlandflag', label = 'Finland Flag', type = 'finland', c = 1},
{name = 'flandresflag', label = 'Flanders Flag', type = 'flandres', c = 1},
{name = 'frflag', label = 'France Flag', type = 'fr', c = 1},
{name = 'gerflag', label = 'Germany Flag', type = 'ger', c = 1},
{name = 'guarmaflag', label = 'Guarma Flag', type = 'guarma', c = 1},
{name = 'hungaryflag', label = 'Hungary Flag', type = 'hungary', c = 1},
{name = 'inuitflag', label = 'Inuit Tribe Flag', type = 'inuit', c = 1},
{name = 'irishflag', label = 'Irish Flag', type = 'irish', c = 1},
{name = 'itflag', label = 'Italia Flag', type = 'it', c = 1},
{name = 'jmflag', label = 'Jamaica Flag', type = 'jm', c = 1},
{name = 'kuwaitflag', label = 'Kuwait Flag', type = 'kuwait', c = 1},
{name = 'lakotaflag', label = 'Lakota Council Tribe Flag', type = 'lakota', c = 1},
{name = 'lemoyneflag', label = 'Lemoyne State Flag', type = 'lemoyne_1', c = 1},
{name = 'lgbtqflag', label = 'LGBTQ Flag', type = 'lgbtq', c = 1},
{name = 'mexicanflag', label = 'Mexican Flag', type = 'mexican', c = 1},
{name = 'navajoflag', label = 'Navajo Tribe Flag', type = 'navajo', c = 1},
{name = 'newaustinflag', label = 'New Austin State Flag', type = 'newaustin_1', c = 1},
{name = 'newhannoverflag', label = 'New Hannover State Flag', type = 'newhannover_1', c = 1},
{name = 'newzealandflag', label = 'New Zealand Flag', type = 'newzealand', c = 1},
{name = 'philippinesflag', label = 'Philippines Flag', type = 'philippines', c = 1},
{name = 'piratesflag', label = 'Pirate Flag', type = 'pirates', c = 1},
{name = 'polandflag', label = 'Poland Flag', type = 'poland', c = 1},
{name = 'portugalflag', label = 'Portugal Flag', type = 'portugal', c = 1},
{name = 'puertoricoflag', label = 'Puerto Rico Flag', type = 'puertorico', c = 1},
{name = 'redflag', label = 'Red Flag', type = 'red', c = 1},
{name = 'russiaflag', label = 'Russia Flag', type = 'russia', c = 1},
{name = 'saudiflag', label = 'Saudi Arabia Flag', type = 'saudi', c = 1},
{name = 'serbiaflag', label = 'Serbia Flag', type = 'serbia', c = 1},
{name = 'spainflag', label = 'Spain Flag', type = 'spain', c = 1},
{name = 'swedenflag', label = 'Sweden Flag', type = 'sweden', c = 1},
{name = 'thailandflag', label = 'Thailand Flag', type = 'thailand', c = 1},
{name = 'turkeyflag', label = 'Turkey Flag', type = 'turkey', c = 1},
{name = 'ukflag', label = 'Uk Flag', type = 'uk', c = 1},
{name = 'ukraineflag', label = 'Ukraine Flag', type = 'ukraine', c = 1},
{name = 'unionflag', label = 'Union Flag', type = 'union', c = 1},
{name = 'westelizabethflag', label = 'West Elizabeth State Flag', type = 'westelizabeth_1', c = 1},
{name = 'whiteflag', label = 'White Flag', type = 'white', c = 1},
{name = 'whitelongflag', label = 'White Flag Long', type = 'whitelongflag', c = 1},
{name = 'flaggang01', label = 'Gang Flag 01', type = 'gang01', c = 1},
{name = 'flaggang02', label = 'Gang Flag 02', type = 'gang02', c = 1},
{name = 'flaggang03', label = 'Gang Flag 03', type = 'gang03', c = 1},
{name = 'flaggang04', label = 'Gang Flag 04', type = 'gang04', c = 1},
{name = 'flaggang05', label = 'Gang Flag 05', type = 'gang05', c = 1},
{name = 'flaggang06', label = 'Gang Flag 06', type = 'gang06', c = 1},
{name = 'flaggang07', label = 'Gang Flag 07', type = 'gang07', c = 1},
{name = 'flaggang08', label = 'Gang Flag 08', type = 'gang08', c = 1},
{name = 'flaggang09', label = 'Gang Flag 09', type = 'gang09', c = 1},
{name = 'flaggang10', label = 'Gang Flag 10', type = 'gang10', c = 1},
{name = 'flaggang11', label = 'Gang Flag 11', type = 'gang11', c = 1},
{name = 'flaggang12', label = 'Gang Flag 12', type = 'gang12', c = 1}
    
}

-- ALL FLAG PROPS
Config.prop_map = {
    ambarino_1 = 'prop_flag_ambarino',
    american = 'prop_flag_us',
    australia = 'prop_flag_au',
    belgium = 'prop_flag_belg',
    br = 'prop_flag_br',
    canada = 'prop_flag_ca',
    catalonia = 'prop_flag_catalonia',
    china = 'prop_flag_china',
    comanche = 'prop_flag_comanche',
    conf = 'prop_flag_conf',
    cuba = 'prop_flag_cuba',
    czech = 'prop_flag_czech',
    denmark = 'prop_flag_den',
    finland = 'prop_flag_fin',
    flandres = 'prop_flag_nl',
    fr = 'prop_flag_fr',
    ger = 'prop_flag_ger',
    guarma = 'prop_flag_guarma',
    hungary = 'prop_flag_hungary',
    inuit = 'prop_flag_inuit',
    irish = 'prop_flag_irish',
    it = 'prop_flag_it',
    jm = 'prop_flag_jm',
    kuwait = 'prop_flag_kuwait',
    lakota = 'prop_flag_lakota',
    lemoyne_1 = 'prop_flag_lemoyne',
    lgbtq = 'prop_flag_lgbtq',
    mexican = 'prop_flag_mx',
    navajo = 'prop_flag_navajo',
    newaustin_1 = 'prop_flag_newaustin',
    newhannover_1 = 'prop_flag_newhannover',
    newzealand = 'prop_flag_nz',
    philippines = 'prop_flag_phi',
    pirates = 'prop_flag_pirates',
    poland = 'prop_flag_pl',
    portugal = 'prop_flag_pt',
    puertorico = 'prop_flag_puerto_rico',
    red = 'mp001_p_mp_flag01x',
    russia = 'prop_flag_ru',
    saudi = 'prop_flag_saudi',
    serbia = 'prop_flag_serbia',
    spain = 'prop_flag_spain',
    sweden = 'prop_flag_sweden',
    thailand = 'prop_flag_thai',
    turkey = 'prop_flag_turkey',
    uk = 'prop_flag_uk',
    ukraine = 'prop_flag_ukraine',
    union = 'prop_flag_union',
    westelizabeth_1 = 'prop_flag_westelizabeth',
    white = 's_mp_flag01x',
    whitelongflag = 'prop_flag_crew01x',
    gang01 = 'prop_flag_gang01',
    gang02 = 'prop_flag_gang02',
    gang03 = 'prop_flag_gang03',
    gang04 = 'prop_flag_gang04',
    gang05 = 'prop_flag_gang05',
    gang06 = 'prop_flag_gang06',
    gang07 = 'prop_flag_gang07',
    gang08 = 'prop_flag_gang08',
    gang09 = 'prop_flag_gang09',
    gang10 = 'prop_flag_gang10',
    gang11 = 'prop_flag_gang11',
    gang12 = 'prop_flag_gang12'
}


-- Key hash list
Config.keylist = {
    ["A"] = 0x7065027D, ["B"] = 0x4CC0E2FE, ["C"] = 0x9959A6F0, ["D"] = 0x9959A6F0, ["E"] = 0xCEFD9220,
    ["F"] = 0xA8E3F467, ["G"] = 0x760A9C6F, ["H"] = 0x24978A28, ["I"] = 0xC1989F95, ["J"] = 0xF3830D8E,
    ["K"] = 0x3F0A1F58, ["L"] = 0x80F28E95, ["M"] = 0xE31C6A41, ["N"] = 0x4F49CC4C, ["O"] = 0xB1D8D8E5,
    ["P"] = 0xAD9EE7F2, ["Q"] = 0xE8A25867, ["R"] = 0xE30CD707, ["S"] = 0xD27782E3, ["T"] = 0xCE1D95BF,
    ["U"] = 0xD8F73058, ["V"] = 0x7F8D09B8, ["W"] = 0x8FD015D8, ["X"] = 0x8CC9CD42, ["Y"] = 0xD7F7B5F5,
    ["Z"] = 0x26E9DC00, ["LEFTALT"] = 0x8AAA0AD4, ["BACKSPACE"] = 0x156F7119, ["ENTER"] = 0xC7B5340A,
    ["RIGHTBRACKET"] = 0x430593AA, ["LEFTBRACKET"] = 0xA5BDCD3C, ["CTRL"] = 0xD9D0E1C0, ["TAB"] = 0xB238FE0B,
    ["SHIFT"] = 0x8FFC75D6, ["F1"] = 0xA8E3F467, ["F2"] = 0x8E6B8AF4, ["F3"] = 0xC3BADC72, ["F4"] = 0x1F6EEB0F,
    ["F5"] = 0xD7F7B5F5, ["F6"] = 0x7A6E7C3D, ["1"] = 0xE6F612E4, ["2"] = 0x1CE6D9EB, ["3"] = 0x4F49CC4C,
    ["4"] = 0xF6C4E10D, ["5"] = 0xB4E465B4, ["6"] = 0x01597C0C, ["7"] = 0x0F39B3D4, ["8"] = 0x606B36F6,
    ["UP"] = 0x05CA7C52, ["DOWN"] = 0x6319DB71, ["LEFT"] = 0xA65EBAB4, ["RIGHT"] = 0xDEB34313,
    ["DEL"] = 0x4AF4D473, ["PGUP"] = 0x446258B6, ["PGDN"] = 0x3C3DD371
}



Config.debug = false






