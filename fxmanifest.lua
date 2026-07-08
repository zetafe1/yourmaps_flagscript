fx_version "adamant"
games {"rdr3"}
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

author 'Tafé | YourMAPS'
description 'A fully configurable RedM flag system – players can equip, drop, and pick up custom flags with animations and attachments.'

dependencies {
    'oxmysql',
}

shared_scripts {
    'config.lua',
    'lang.lua',
}

client_scripts {
    'client/interactions.lua',
    'client/client.lua',
    -- Optional: copy interactions_custom.example.lua → interactions_custom.lua
    -- 'client/interactions_custom.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua',
    'server/persistence.lua',
}

data_file 'DLC_ITYP_REQUEST' 'stream/prop_yourflags_script.ytyp'
