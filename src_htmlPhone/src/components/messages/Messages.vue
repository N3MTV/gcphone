<template>
  <div class="phone_app messages">
    <PhoneTitle :title="displayContact" :backgroundColor="color"/>
    <div class="img-fullscreen" v-if="imgZoom !== undefined" >
      <img :src="imgZoom" />
    </div>
    
    <div id='sms_list'>
        <div class="sms" v-bind:class="{ select: key === selectMessage}" v-for='(mess, key) in messagesList' v-bind:key="mess.id">
            <span class='sms_message sms_me' 
              v-bind:class="{ sms_other : mess.owner === 0}" :style="colorSmsOwner[mess.owner]">
              <img v-if="isSMSImage(mess)" class="sms-img" :src="mess.message">
              <span v-else>{{mess.message}}</span>
                
                <span ><timeago class="sms_time" :since='mess.time' :auto-update="20" :style="colorSmsOwner[mess.owner]"></timeago></span>
            </span>
        </div>
    </div>

    <div id='sms_write'>
        <input type="text" :placeholder="IntlString('APP_MESSAGE_PLACEHOLDER_ENTER_MESSAGE')">
        <div class="sms_send">
          <svg height="24" viewBox="0 0 24 24" width="24">
    <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
    <path d="M0 0h24v24H0z" fill="none"/>
</svg>
        </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import { generateColorForStr, getBestFontColor } from './../../Utils'
import PhoneTitle from './../PhoneTitle'
import Modal from '@/components/Modal/index.js'

export default {
  data () {
    return {
      ignoreControls: false,
      selectMessage: -1,
      display: '',
      phoneNumber: '',
      imgZoom: undefined
    }
  },
  components: {
    PhoneTitle
  },
  methods: {
    ...mapActions(['setMessageRead', 'sendMessage', 'deleteMessage']),
    resetScroll () {
      this.$nextTick(() => {
        let elem = document.querySelector('#sms_list')
        elem.scrollTop = elem.scrollHeight
        this.selectMessage = -1
      })
    },
    scrollIntoViewIfNeeded () {
      this.$nextTick(() => {
        const elem = this.$el.querySelector('.select')
        if (elem !== null) {
          elem.scrollIntoViewIfNeeded()
        }
      })
    },
    onUp: function () {
      if (this.ignoreControls === true) return
      if (this.selectMessage === -1) {
        this.selectMessage = this.messagesList.length - 1
      } else {
        this.selectMessage = this.selectMessage === 0 ? 0 : this.selectMessage - 1
      }
      this.scrollIntoViewIfNeeded()
    },
    onDown () {
      if (this.ignoreControls === true) return
      if (this.selectMessage === -1) {
        this.selectMessage = this.messagesList.length - 1
      } else {
        this.selectMessage = this.selectMessage === this.messagesList.length - 1 ? this.selectMessage : this.selectMessage + 1
      }
      this.scrollIntoViewIfNeeded()
    },
    onEnter () {
      if (this.ignoreControls === true) return
      if (this.selectMessage !== -1) {
        this.onActionMessage()
      } else {
        this.$phoneAPI.getReponseText().then(data => {
          let message = data.text.trim()
          if (message !== '') {
            this.sendMessage({
              phoneNumber: this.phoneNumber,
              message
            })
          }
        })
      }
    },
    isSMSImage (mess) {
      return /^https?:\/\/.*\.(png|jpg|jpeg|gif)/.test(mess.message)
    },
    onActionMessage () {
      let message = this.messagesList[this.selectMessage]
      let isGPS = /^GPS: -?\d*(\.\d+), -?\d*(\.\d+)/.test(message.message)
      let hasNumber = /#([0-9]+)/.test(message.message)
      let isSMSImage = this.isSMSImage(message)
      let choix = [{
        id: 'delete',
        title: this.IntlString('APP_MESSAGE_DELETE'),
        icons: 'fa-circle-o'
      }, {
        id: -1,
        title: this.IntlString('CANCEL'),
        icons: 'fa-undo'
      }]
      if (isGPS === true) {
        choix = [{
          id: 'gps',
          title: this.IntlString('APP_MESSAGE_SET_GPS'),
          icons: 'fa-location-arrow'
        }, ...choix]
      }
      if (hasNumber === true) {
        const num = message.message.match(/#([0-9-]*)/)[1]
        choix = [{
          id: 'num',
          title: `${this.IntlString('APP_MESSAGE_SMS')} ${num}`,
          number: num,
          icons: 'fa-phone'
        }, ...choix]
      }
      if (isSMSImage === true) {
        choix = [{
          id: 'zoom',
          title: this.IntlString('APP_MESSAGE_ZOOM_IMG'),
          icons: 'fa-search'
        }, ...choix]
      }
      this.ignoreControls = true
      Modal.CreateModal({choix}).then(data => {
        if (data.id === 'delete') {
          this.deleteMessage({ id: message.id })
        } else if (data.id === 'gps') {
          let val = message.message.match(/((-?)\d+(\.\d+))/g)
          this.$phoneAPI.setGPS(val[0], val[1])
        } else if (data.id === 'num') {
          this.phoneNumber = data.number
          this.display = undefined
        } else if (data.id === 'zoom') {
          this.imgZoom = message.message
        }
        this.ignoreControls = false
        this.selectMessage = -1
      })
    },
    onBackspace () {
      if (this.imgZoom !== undefined) {
        this.imgZoom = undefined
        return
      }
      if (this.ignoreControls === true) return
      if (this.selectMessage !== -1) {
        this.selectMessage = -1
      } else {
        this.$router.push({path: '/messages'})
      }
    },
    onRight: function () {
      if (this.ignoreControls === true) return
      if (this.selectMessage === -1) {
        this.ignoreControls = true
        Modal.CreateModal({choix: [
          {id: 1, title: this.IntlString('APP_MESSAGE_SEND_GPS'), icons: 'fa-location-arrow'},
          {id: -1, title: this.IntlString('CANCEL'), icons: 'fa-undo'}
        ]}).then(data => {
          if (data.id === 1) {
            this.sendMessage({
              phoneNumber: this.phoneNumber,
              message: '%pos%'
            })
          }
          this.ignoreControls = false
        })
      }
    }
  },
  computed: {
    ...mapGetters(['IntlString', 'messages', 'contacts']),
    messagesList () {
      return this.messages.filter(e => e.transmitter === this.phoneNumber).sort((a, b) => a.time - b.time)
    },
    displayContact () {
      if (this.display !== undefined) {
        return this.display
      }
      const c = this.contacts.find(c => c.number === this.phoneNumber)
      if (c !== undefined) {
        return c.display
      }
      return this.phoneNumber
    },
    color () {
      return generateColorForStr(this.phoneNumber)
    },
    colorSmsOwner () {
      return [
        {
          backgroundColor: this.color,
          color: getBestFontColor(this.color)
        }, {}
      ]
    }
  },
  watch: {
    messagesList () {
      this.setMessageRead(this.phoneNumber)
      this.resetScroll()
    }
  },
  created: function () {
    this.display = this.$route.params.display
    this.phoneNumber = this.$route.params.number
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
    this.$bus.$on('keyUpArrowRight', this.onRight)
  },
  beforeDestroy: function () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
  }
}
</script>

<style scoped>
.messages{
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    height: calc(100% - 20px);
    background-color: #DDD;    
}
#sms_contact{
    background-color: #4CAF50;
    color: white;
    height: 34px;
    line-height: 34px;
    padding-left: 5px;
}
#sms_list{
    height: calc(100% - 34px - 26px);
    overflow-y: auto;
    padding-bottom: 8px;
}



.sms{
  overflow: auto;
  zoom: 1;
}

.sms-img{
  width: 100%;
  height: auto;
}
.img-fullscreen {
  position: fixed;
  z-index: 999999;
  background-color: rgba(20, 20, 20, 0.8);
  left: 0;
  top: 0;
  right: 0;
  bottom: 0;
  display: flex;
  justify-content: center;
  align-items: center;
}
.img-fullscreen img {
  display: flex;
  max-width: 90vw;
  max-height: 95vh;
}

.sms_me{
  float: right;
  background-color: white;
  padding: 5px 10px;
  max-width: 90%;
  margin-right: 5%;
  margin-top: 10px;
}

.sms_other{
    background-color: #4CAF50;
    color:white;
    float: left;
    padding: 5px 10px;
    max-width: 90%;
    margin-left: 5%;
    margin-top: 10px;
}


.sms_time{
    display: block;
    font-size: 12px;
}

.sms_me .sms_time{
    color: #AAA;
}
.sms_other .sms_time{
    color: #555;
}
.messages{
  position: relative;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
}
.sms.select .sms_message{
  background-color: rgb(0, 0, 0) !important;
  color: #d4d4d4 !important;
}

.sms.select .sms_message .sms_time {
  background-color: inherit !important;
}

.sms_message{
  word-wrap: break-word;
  max-width: 80%;
  font-size: 24px;
}

#sms_write{
    height: 56px;
    margin: 10px;
    width: 380px;
    background-color: white;
    border-radius: 56px;
}
#sms_write input{
    height: 56px;
    border: none;
    outline: none;
    font-size: 18px;
    margin-left: 14px;
    padding: 12px 5px;
    background-color: rgba(236, 236, 241, 0)
}

.sms_send{
    float: right;
    margin-right: 10px;
}
.sms_send svg{
    margin: 10px; 
    width: 36px;
    height: 36px;
    fill: #C0C0C0;
}
</style>
