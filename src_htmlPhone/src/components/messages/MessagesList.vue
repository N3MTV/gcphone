<template>
  <div class="screen">
    <list :list='messagesData' :disable="disableList" title="Messages" @select="onSelect" @option='onOption'></list>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import { generateColorForStr } from '@/Utils'
import Modal from '@/components/Modal/index.js'
import List from '@/components/List'

export default {
  components: {
    List
  },
  data () {
    return {
      nouveauMessage: {backgroundColor: '#C0C0C0', display: 'Nouveau message', letter: '+', id: -1},
      disableList: false
    }
  },
  methods: {
    ...mapActions(['deleteMessagesNumber', 'deleteAllMessages']),
    onSelect: function (data) {
      if (data.id === -1) {
        this.$router.push({name: 'messages.selectcontact'})
      } else {
        this.$router.push({name: 'messages.view', params: data})
      }
    },
    onOption: function (data) {
      if (data.number === undefined) return
      this.disableList = true
      Modal.CreateModal({
        choix: [
          {id: 1, title: 'Effacer la conversation', icons: 'fa-circle-o', color: 'orange'},
          {id: 2, title: 'Effacer toutes conv.', icons: 'fa-circle-o', color: 'red'},
          {id: 3, title: 'Annuler', icons: 'fa-undo'}
        ]
      }).then(rep => {
        if (rep.id === 1) {
          this.deleteMessagesNumber({num: data.number})
        } else if (rep.id === 2) {
          this.deleteAllMessages()
        }
        this.disableList = false
      })
    },
    back: function () {
      if (this.disableList === true) return
      this.$router.push({ name: 'home' })
    }
  },
  computed: {
    ...mapGetters(['contacts', 'messages']),
    messagesData: function () {
      let messages = this.messages
      let contacts = this.contacts
      let messGroup = messages.reduce((rv, x) => {
        if (rv[x['transmitter']] === undefined) {
          let contact = contacts.find(e => e.number === x.transmitter)
          let display = contact !== undefined ? contact.display : x.transmitter
          rv[x['transmitter']] = {noRead: 0, display, lastMessage: 0}
        }
        if (x.isRead === 0) {
          rv[x['transmitter']].noRead += 1
        }
        if (x.time >= rv[x['transmitter']].lastMessage) {
          rv[x['transmitter']].lastMessage = x.time
          rv[x['transmitter']].keyDesc = x.message
        }
        return rv
      }, {})
      let mess = []
      Object.keys(messGroup).forEach(key => {
        mess.push({
          display: messGroup[key].display,
          puce: messGroup[key].noRead,
          number: key,
          lastMessage: messGroup[key].lastMessage,
          keyDesc: messGroup[key].keyDesc,
          backgroundColor: generateColorForStr(key)
        })
      })
      mess.sort((a, b) => b.lastMessage - a.lastMessage)
      return [this.nouveauMessage, ...mess]
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
.screen{
  position: relative;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
}
</style>
