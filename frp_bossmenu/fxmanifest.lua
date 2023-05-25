fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page 'html/index.html'

shared_scripts {
	'@ox_lib/init.lua',
    '@es_extended/imports.lua'
}

client_scripts {
	'client.lua'
}
server_scripts{
	'@oxmysql/lib/MySQL.lua',
	"server.lua"
}

files {
	'html/index.html',
	'html/main.css',
	'html/main.js',
}
