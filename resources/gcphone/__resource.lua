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
	'html/static/img/background/back001.jpg',
	'html/static/img/background/back002.jpg',
	'html/static/img/background/back003.jpg',
	'html/static/img/background/01.jpg',
	'html/static/img/background/02.jpg',
	'html/static/img/background/03.jpg',
	'html/static/img/background/04.jpg',
	'html/static/img/background/05.jpg',
	'html/static/img/background/06.jpg',
	'html/static/img/background/07.jpg',
	'html/static/img/background/08.jpg',
	'html/static/img/background/09.jpg',
	'html/static/img/background/10.jpg',
	'html/static/img/background/11.jpg',
	'html/static/img/background/12.jpg',
	'html/static/img/background/13.jpg',
	'html/static/img/background/14.jpg',
	'html/static/img/background/15.jpg',
	'html/static/img/background/16.jpg',
	'html/static/img/background/17.jpg',
	'html/static/img/background/18.jpg',
	'html/static/img/background/19.jpg',
	'html/static/img/background/20.jpg',
	'html/static/img/background/21.jpg',
	
	'html/static/img/icons_app/call.png',
	'html/static/img/icons_app/contacts.png',
	'html/static/img/icons_app/sms.png',
	'html/static/img/icons_app/settings.png',
	'html/static/img/icons_app/menu.png',
	'html/static/img/icons_app/bourse.png',
	'html/static/img/icons_app/tchat.png',
	'html/static/img/icons_app/photo.png',
	'html/static/img/icons_app/bank.png',
	
	'html/static/img/app_bank/logo_mazebank.jpg',

	'html/static/img/app_tchat/splashtchat.png',

	'html/static/img/courbure.png',
	'html/static/fonts/fontawesome-webfont.ttf',

	'html/static/sound/ring.ogg',
	'html/static/sound/tchatNotification.ogg',
	'html/static/sound/Phone_Call_Sound_Effect.ogg',

}

client_script {
	"client/client.lua",
	"client/animation.lua",
	"client/photo.lua",
	"client/app_tchat.lua",
}

server_script {
	'@mysql-async/lib/MySQL.lua',
	"server/server.lua",
	"server/app_tchat.lua",
}

server_export 'GetNumberServer'