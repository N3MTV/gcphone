server_script '@mysql-async/lib/MySQL.lua'
-- server_script 'mysqltimestamp'

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/static/css/app.css',
	'html/static/js/app.js',
	'html/static/js/manifest.js',
	'html/static/js/vendor.js',
	
	'html/static/img/coque/bleu.png',
	'html/static/img/coque/blanc.png',
	'html/static/img/coque/jaune.png',
	'html/static/img/coque/leopard.png',
	'html/static/img/coque/noir.png',
	'html/static/img/coque/or.png',
	'html/static/img/coque/rose.png',
	'html/static/img/coque/rouge.png',
	'html/static/img/coque/vert.png',
	'html/static/img/coque/violet.png',
	'html/static/img/coque/zebre.png',
	
	'html/static/img/back001.jpg',
	'html/static/img/back002.jpg',
	'html/static/img/back003.jpg',
	'html/static/img/01.jpg',
	'html/static/img/02.jpg',
	'html/static/img/03.jpg',
	'html/static/img/04.jpg',
	'html/static/img/05.jpg',
	'html/static/img/06.jpg',
	'html/static/img/07.jpg',
	'html/static/img/08.jpg',
	'html/static/img/09.jpg',
	'html/static/img/10.jpg',
	'html/static/img/11.jpg',
	'html/static/img/12.jpg',
	'html/static/img/13.jpg',
	'html/static/img/14.jpg',
	'html/static/img/15.jpg',
	'html/static/img/16.jpg',
	'html/static/img/17.jpg',
	'html/static/img/18.jpg',
	'html/static/img/19.jpg',
	'html/static/img/20.jpg',
	'html/static/img/21.jpg',
	
	
	'html/static/img/call.png',
	'html/static/img/contacts.png',
	'html/static/img/sms.png',
	'html/static/img/settings.png',

	'html/static/fonts/fontawesome-webfont.ttf',

}

client_script {
	"animation.lua",
	"client.lua"
}

server_script {
	"server.lua"
}

