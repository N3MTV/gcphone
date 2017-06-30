<template>
  <div class="contact">
    <list :list='lcontacts' title="Contacts" v-on:select="onSelect"></list>
  </div>
</template>

<script>
import List from './../List.vue'

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
      let addContact = {display: 'Ajouter un contact', letter: '+', num: '', id: -1}
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
      this.$router.push({path: '/contact/' + contact.id})
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
