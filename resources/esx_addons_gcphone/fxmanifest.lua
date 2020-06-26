fx_version 'adamant'

game 'gta5'

client_script 'client.lua'

server_script {
  '@mysql-async/lib/MySQL.lua',
  'server.lua'
}

-- {
-- 	"display": "Police",
-- 	"subMenu": [
-- 		{
-- 		  "title": "Envoyer un message",
-- 		  "eventName": "esx_addons_gcphone:call",
-- 		  "type": {
-- 		  "number": "police"
-- 		}}
-- 	]
-- }
