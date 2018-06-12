import Vue from 'vue'
import App from './App'
import router from './router'
import store from './store'
import VueTimeago from 'vue-timeago'
import PhoneAPI from './PhoneAPI'

Vue.use(VueTimeago, {
  name: 'timeago',
  locale: 'fr-FR',
  locales: {
    'fr-FR': require('vue-timeago/locales/fr-FR.json')
  }
})
Vue.config.productionTip = false

Vue.prototype.$bus = new Vue()
Vue.prototype.$phoneAPI = PhoneAPI

window.DDD = store

/* eslint-disable no-new */
new Vue({
  el: '#app',
  store,
  router,
  render: h => h(App)
})
