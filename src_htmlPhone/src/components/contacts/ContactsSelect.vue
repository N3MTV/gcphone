<template>
  <div class="contact">
    <list :list='lcontacts' title="Contacts" v-on:select="onSelect"></list>
  </div>
</template>

<script>
import List from './../List.vue'
import request from '../../request'

export default {
  components: {
    List
  },
  data () {
    return {
      contacts: []
    }
  },
  computed: {
    lcontacts: function () {
      let addContact = {display: 'Enter un numero', letter: '+', backgroundColor: 'orange', num: -1}
      if (this.$root.contacts.length !== 0) {
        let contacts = this.$root.contacts.slice()
        contacts.sort((a, b) => a.display.localeCompare(b.display))
        return [addContact, ...contacts]
      }
      return [addContact]
    }
  },
  methods: {
    onSelect: function (contact) {
      if (contact.num === -1) { //
        request.getReponseText({
          limit: 10
        }).then(data => {
          let message = data.text.trim()
          if (message !== '') {
            this.$router.push({path: '/message/' + message + '/' + message})
          }
        })
      } else {
        this.$router.push({path: '/message/' + contact.number + '/' + contact.display})
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
