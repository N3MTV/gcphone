import Vue from 'vue'
import Modal from '@/components/Modal/Modal.vue'
export default {
  CreateModal: function (propsData = {}) {
    return new Promise((resolve, reject) => {
      let modal = new (Vue.extend(Modal))({
        el: document.createElement('div'),
        propsData
      })
      window.DDD = modal
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
  }
}
