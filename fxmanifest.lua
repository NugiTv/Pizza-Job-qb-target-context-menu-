fx_version 'cerulean'
game 'gta5'

author 'Yamie#9680'

description 'Pizza Runs'

lua54 'yes'

shared_scripts {
	'config.lua'
}

client_scripts {
    'client.lua'

}
escrow_ignore {
    'config.lua',  -- Only ignore one file
}
server_script 'server.lua'

--[[ client_scripts { 
"client.lua",
"config.lua"}

server_scripts { 
"server.lua",
"config.lua"
} ]]