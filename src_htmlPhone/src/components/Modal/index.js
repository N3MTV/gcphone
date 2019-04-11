import Vue from 'vue'
import Modal from './Modal'
import TextModal from './TextModal'
import store from '@/store'
import PhoneAPI from '@/PhoneAPI'

export default {
  CreateModal (propsData = {}) {
    return new Promise((resolve, reject) => {
      let modal = new (Vue.extend(Modal))({
        el: document.createElement('div'),
        propsData
      })
      document.querySelector('#app').appendChild(modal.$el)
      modal.$on('select', (data) => {
        resolve(data)
        modal.$el.parentNode.removeChild(modal.$el)
        modal.$destroy()
      })
      modal.$on('cancel', () => {
        resolve({title: 'cancel'})
        modal.$el.parentNode.removeChild(modal.$el)
        modal.$destroy()
      })
    })
  },
  CreateTextModal (propsData = {}) {
    if (store.getters.useMouse === false) {
      return PhoneAPI.getReponseText(propsData)
    }
    return new Promise((resolve, reject) => {
      let modal = new (Vue.extend(TextModal))({
        el: document.createElement('div'),
        propsData
      })
      document.querySelector('#app').appendChild(modal.$el)
      modal.$on('valid', (data) => {
        resolve(data)
        modal.$el.parentNode.removeChild(modal.$el)
        modal.$destroy()
      })
      modal.$on('cancel', () => {
        reject('UserCancel')
        modal.$el.parentNode.removeChild(modal.$el)
        modal.$destroy()
      })
    })
  }
}
