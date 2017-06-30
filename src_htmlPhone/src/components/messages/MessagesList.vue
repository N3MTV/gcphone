<template>
  <div class="screen">
    <list :list='messagesData' :disable="disableList" title="Messages" @select="onSelect" @option='onOption'></list>
  </div>
</template>

<script>
import Modal from '@/components/Modal/index.js'
import List from '@/components/List'
import request from './../../request'
export default {
  components: {
    List
  },
  data () {
    return {
      nouveauMessage: {backgroundColor: '#C0C0C0', display: 'Nouveau message', letter: '+', id: -1},
      // messagesData: [this.nouveauMessage],
      disableList: false
    }
  },
  methods: {
    onSelect: function (data) {
      if (data.id === -1) {
        this.$router.push({path: '/contacts/select'})
      } else {
        this.$router.push({path: '/message/' + data.number + '/' + data.display})
      }
    },
    onOption: function (data) {
      if (data.number === undefined) return
      this.disableList = true
      Modal.CreateModal({
        choix: [
          {id: 1, title: 'Effacer la conversation', icons: 'fa-circle-o'},
          {id: 2, title: 'Effacer toutes conv.', icons: 'fa-circle-o'},
          {id: 3, title: 'Annuler', icons: 'fa-undo'}
        ]
      }).then(rep => {
        if (rep.id === 1) {
          request.deleteMessageNumber(data.number)
        } else if (rep.id === 2) {
          request.deleteAllMessage()
        }
        this.disableList = false
      })
    },
    // updateList: function () {
    //   Promise.all([request.getMessages(), request.getContacts()]).then(data => {
    //     let messages = data[0]
    //     let contacts = data[1]
    //     let messGroup = messages.reduce((rv, x) => {
    //       if (rv[x['transmitter']] === undefined) {
    //         let contact = contacts.find(e => e.number === x.transmitter)
    //         let display = contact !== undefined ? contact.display : x.transmitter
    //         rv[x['transmitter']] = {noRead: 0, display}
    //       }
    //       console.log('isRead', x.isRead)
    //       if (x.isRead === 0) {
    //         rv[x['transmitter']].noRead += 1
    //       }
    //       return rv
    //     }, {})
    //     let mess = []
    //     Object.keys(messGroup).forEach(key => {
    //       mess.push({
    //         display: messGroup[key].display,
    //         puce: messGroup[key].noRead,
    //         number: key
    //       })
    //     })
    //     this.messagesData = [this.nouveauMessage, ...mess]
    //   })
    // },
    back: function () {
      if (this.disableList === true) return
      this.$router.push({path: '/'})
    }
  },
  computed: {
    messagesData: function () {
      let messages = this.$root.messages
      let contacts = this.$root.contacts
      let messGroup = messages.reduce((rv, x) => {
        if (rv[x['transmitter']] === undefined) {
          let contact = contacts.find(e => e.number === x.transmitter)
          let display = contact !== undefined ? contact.display : x.transmitter
          rv[x['transmitter']] = {noRead: 0, display}
        }
        if (x.isRead === 0) {
          rv[x['transmitter']].noRead += 1
        }
        rv[x['transmitter']].lastMessage = Math.max(x.time, rv[x['transmitter']].lastMessage || 0)
        return rv
      }, {})
      let mess = []
      Object.keys(messGroup).forEach(key => {
        mess.push({
          display: messGroup[key].display,
          puce: messGroup[key].noRead,
          number: key,
          lastMessage: messGroup[key].lastMessage
        })
      })
      mess.sort((a, b) => b.lastMessage - a.lastMessage)
      return [this.nouveauMessage, ...mess]
    }
  },
  created: function () {
    // this.updateList()
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
