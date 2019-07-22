import Vue from 'vue'
import Vuex from 'vuex'

import phone from './modules/phone'
import contacts from './modules/contacts'
import messages from './modules/messages'
import appels from './modules/appels'
import bank from './modules/bank'
import bourse from './modules/bourse'
import irc from './modules/irc'
import twitter from './modules/twitter'

Vue.use(Vuex)

export default new Vuex.Store({
  modules: {
    phone,
    contacts,
    messages,
    appels,
    bank,
    bourse,
    irc,
    twitter
  },
  strict: true
})
