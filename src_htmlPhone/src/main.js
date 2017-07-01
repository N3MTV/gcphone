// The Vue build version to load with the `import` command
// (runtime-only or standalone) has been set in webpack.base.conf with an alias.
import Vue from 'vue'
import App from './App'
import router from './router'
import VueTimeago from 'vue-timeago'

Vue.use(VueTimeago, {
  name: 'timeago', // component name, `timeago` by default
  locale: 'fr-FR',
  locales: {
    // you will need json-loader in webpack 1
    'fr-FR': require('vue-timeago/locales/fr-FR.json')
  }
})
Vue.config.productionTip = false

/* eslint-disable no-new */
const bus = new Vue()
Vue.prototype.$bus = bus
new Vue({
  el: '#app',
  router,
  template: `<div v-if="show === true" :style="{zoom: zoom}">
  <div class="phone_wrapper" :style="{backgroundImage: 'url(/html/static/img/coque/' + coque + ')'}">
    <App class="phone_screen"/>
  </div>
  </div>`,
  components: { App },
  data: {
    contacts: [],
    messages: [],
    coque: localStorage['coque_img'] || 'bleu.png',
    show: false,
    urgenceOnly: false,
    myPhoneNumber: '',
    zoom: localStorage['zoom'] || '100%'
  },
  created: function () {
    if (process.env.NODE_ENV !== 'production') {
      this.show = true
      window.addEventListener('keyup', (event) => {
        if (event.key !== '7') return
        this.contacts.push({
          display: 'lol',
          number: '09',
          id: 15
        })
        this.messages.push({id: 6, transmitter: '09', time: new Date().getTime(), message: 'GPS: 5555555555555555, 22222222', isRead: 0, owner: Math.random() > 0.5 ? 1 : 0})
        // this.urgenceOnly = !this.urgenceOnly
      })
    }
    // in Game
    window.addEventListener('message', (event) => {
      // console.log(JSON.stringify(event.data))
      if (event.data.keyUp !== undefined) {
        this.$bus.$emit('keyUp' + event.data.keyUp)
      }
      if (event.data.show !== undefined) {
        this.$router.push({path: '/'})
        this.show = event.data.show
      }
      if (event.data.event === 'updateMessages') {
        this.messages = event.data.messages
      }
      if (event.data.event === 'updateContacts') {
        this.contacts = event.data.contacts
      }
      if (event.data.event === 'updateYyPhoneNumber') {
        this.myPhoneNumber = event.data.myPhoneNumber
      }
      if (event.data.event === 'updateDead') {
        this.urgenceOnly = event.data.isDead === 1
      }
    })
  }
})
