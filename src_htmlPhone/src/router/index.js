import Vue from 'vue'
import Router from 'vue-router'
import Home from '@/components/Home'

import Contacts from '@/components/contacts/Contacts'
import ContactsSelect from '@/components/contacts/ContactsSelect'
import Contact from '@/components/contacts/Contact'

import MessagesList from '@/components/messages/MessagesList'
import Messages from '@/components/messages/Messages'

import Call from '@/components/call/Call'

import Paramtre from '@/components/parametre/Parametre'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'Home',
      component: Home
    },
    {
      path: '/contacts',
      name: 'Contacts',
      component: Contacts
    },
    {
      path: '/contacts/select',
      name: 'Contact Select',
      component: ContactsSelect
    },
    {
      path: '/contact/:id',
      name: 'New Contacts',
      component: Contact
    },
    {
      path: '/messages',
      name: 'Messages',
      component: MessagesList
    },
    {
      path: '/message/:num/:display',
      name: 'Message',
      component: Messages
    },
    {
      path: '/call',
      name: 'Téléphone',
      component: Call
    }, {
      path: '/paramtre',
      name: 'Paramtre',
      component: Paramtre
    }, {
      path: '*',
      redirect: '/'
    }
  ]
})
