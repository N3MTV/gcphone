<template>
  <div class="contact">
    <list :list='lcontacts' :title="IntlString('APP_MESSAGE_CONTACT_TITLE')" v-on:select="onSelect"></list>
  </div>
</template>

<script>
import List from './../List.vue'
import { mapGetters } from 'vuex'

export default {
  components: {
    List
  },
  data () {
    return {
    }
  },
  computed: {
    ...mapGetters(['IntlString', 'contacts']),
    lcontacts: function () {
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
    onSelect: function (contact) {
      if (contact.num === -1) {
        this.$phoneAPI.getReponseText({
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
    back: function () {
      history.back()
    }
  },
  created: function () {
    this.$bus.$on('keyUpBackspace', this.back)
  },

  beforeDestroy: function () {
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
