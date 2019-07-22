resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

name 'Mythic Framework GCPhone Port'
description 'GCPhone Port To Mythic Roleplay\'s Custom Framework'
author 'Alzar - https://github.com/Alzar'
version 'v1.0.0'
url 'https://github.com/mythicrp/mythic_phone'

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/static/css/app.css',
	'html/static/js/app.js',
	'html/static/js/manifest.js',
	'html/static/js/vendor.js',

	'html/static/config/config.json',
	
	-- Coque
	'html/static/img/coque/s8.png',
	'html/static/img/coque/iphonex.png',
	'html/static/img/coque/base.png',
	'html/static/img/coque/transparent.png',
	
	-- Background
	'html/static/img/background/back001.png',
	'html/static/img/background/back002.png',
	'html/static/img/background/back003.png',
	
	'html/static/img/icons_app/call.png',
	'html/static/img/icons_app/contacts.png',
	'html/static/img/icons_app/sms.png',
	'html/static/img/icons_app/settings.png',
	'html/static/img/icons_app/menu.png',
	'html/static/img/icons_app/bourse.png',
	'html/static/img/icons_app/irc.png',
	'html/static/img/icons_app/tchat.png',
	'html/static/img/icons_app/photo.png',
	'html/static/img/icons_app/bank.png',
	'html/static/img/icons_app/9gag.png',
	'html/static/img/icons_app/twitter.png',
	
	'html/static/img/app_bank/logo_mazebank.jpg',

	'html/static/img/app_irc/irc_splash.png',

	'html/static/img/app_tchat/splashtchat.png',

	'html/static/img/twitter/bird.png',
	'html/static/img/twitter/default_profile.png',
	'html/static/sound/Twitter_Sound_Effect.ogg',

	'html/static/img/courbure.png',
	'html/static/fonts/fontawesome-webfont.ttf',

	'html/static/sound/ring.ogg',
	'html/static/sound/ring2.ogg',
	'html/static/sound/tchatNotification.ogg',
	'html/static/sound/Phone_Call_Sound_Effect.ogg',

}

client_script {
	"config.lua",
	"client/animation.lua",
	"client/client.lua",
	"client/extension.lua",

	"client/apps/app_photo.lua",
	"client/apps/app_tchat.lua",
	"client/apps/app_irc.lua",
	"client/apps/app_bank.lua",
	"client/apps/app_twitter.lua"
}

server_script {
	"config.lua",
	"server/server.lua",
	"server/extension.lua",

	"server/apps/app_tchat.lua",
	"server/apps/app_irc.lua",
	"server/apps/app_twitter.lua",
	"server/apps/app_bank.lua"
}
