fx_version "adamant"
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

author 'Tafé | YourMAPS'
description 'A fully configurable RedM flag system – players can equip, drop, and pick up custom flags with animations and attachments.'

ui_page 'nui/gizmo/index.html'

dependencies {
    'oxmysql',
}

files {
    'nui/gizmo/index.html',
    'nui/gizmo/assets/**',
}

shared_scripts {
    'config.lua',
    'lang.lua',
}

client_scripts {
    'client/notify.lua',
    'client/gizmo_prompt.lua',
    'client/gizmo.lua',
    'client/placement.lua',
    'client/interactions.lua',
    'client/client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/notify.lua',
    'server/server.lua',
    'server/persistence.lua',
}

data_file 'DLC_ITYP_REQUEST' 'stream/prop_yourflags_script.ytyp'
