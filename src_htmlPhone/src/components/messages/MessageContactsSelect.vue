<template>
  <div class="contact">
    <list :list='lcontacts' :title="IntlString('APP_MESSAGE_CONTACT_TITLE')" v-on:select="onSelect" @back="back"></list>
  </div>
</template>

<script>
import List from './../List.vue'
import { mapGetters } from 'vuex'
import Modal from '@/components/Modal/index.js'

export default {
  components: {
    List
  },
  data () {
    return {
    }
  },
  computed: {
    ...mapGetters(['IntlString', 'contacts', 'useMouse']),
    lcontacts () {
      let addContact = {
        display: this.IntlString('APP_MESSAGE_CONTRACT_ENTER_NUMBER'),
        letter: '+',
        backgroundColor: 'orange',
        num: -1
      }
      return [addContact, ...this.contacts]
    }
  },
  methods: {
    onSelect (contact) {
      if (contact.num === -1) {
        Modal.CreateTextModal({
          title: this.IntlString('APP_PHONE_ENTER_NUMBER'),
          limit: 10
        }).then(data => {
          let message = data.text.trim()
          if (message !== '') {
            this.$router.push({
              name: 'messages.view',
              params: {
                number: message,
                display: message
              }
            })
          }
        })
      } else {
        this.$router.push({name: 'messages.view', params: contact})
      }
    },
    back () {
      history.back()
    }
  },
  created () {
    this.$bus.$on('keyUpBackspace', this.back)
  },

  beforeDestroy () {
    this.$bus.$off('keyUpBackspace', this.back)
  }
}
</script>

<style scoped>
.contact{
  position: relative;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
}
</style>
