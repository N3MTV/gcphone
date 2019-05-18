<template>
  <div class="phone_app">
    <PhoneTitle :title="channelName" backgroundColor="#090f20" @back="onQuit"/>
    <div class="phone_content">
      <div class="elements" ref="elementsDiv">
          <div class="element" v-for='(elem) in tchatMessages' 
            v-bind:key="elem.id"
            >
            <div class="time">{{formatTime(elem.time)}}</div>
            <div class="message">
              {{elem.message}}
            </div>
          </div>
      </div>

      <div class='tchat_write'>
          <input type="text" placeholder="..." v-model="message" @keyup.enter.prevent="sendMessage">
          <span class='tchat_send' @click="sendMessage">></span>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import PhoneTitle from './../PhoneTitle'

export default {
  components: { PhoneTitle },
  data () {
    return {
      message: '',
      channel: '',
      currentSelect: 0
    }
  },
  computed: {
    ...mapGetters(['tchatMessages', 'tchatCurrentChannel', 'useMouse']),
    channelName () {
      return '# ' + this.channel
    }
  },
  watch: {
    tchatMessages () {
      const c = this.$refs.elementsDiv
      c.scrollTop = c.scrollHeight
    }
  },
  methods: {
    setChannel (channel) {
      this.channel = channel
      this.tchatSetChannel({ channel })
    },
    ...mapActions(['tchatSetChannel', 'tchatSendMessage']),
    scrollIntoViewIfNeeded () {
      this.$nextTick(() => {
        const $select = this.$el.querySelector('.select')
        if ($select !== null) {
          $select.scrollIntoViewIfNeeded()
        }
      })
    },
    onUp () {
      const c = this.$refs.elementsDiv
      c.scrollTop = c.scrollTop - 120
    },
    onDown () {
      const c = this.$refs.elementsDiv
      c.scrollTop = c.scrollTop + 120
    },
    async onEnter () {
      const rep = await this.$phoneAPI.getReponseText()
      if (rep !== undefined && rep.text !== undefined) {
        const message = rep.text.trim()
        if (message.length !== 0) {
          this.tchatSendMessage({
            channel: this.channel,
            message
          })
        }
      }
    },
    sendMessage () {
      const message = this.message.trim()
      if (message.length !== 0) {
        this.tchatSendMessage({
          channel: this.channel,
          message
        })
        this.message = ''
      }
    },
    onBack () {
      if (this.useMouse === true && document.activeElement.tagName !== 'BODY') return
      this.onQuit()
    },
    onQuit () {
      this.$router.push({ name: 'tchat.channel' })
    },
    formatTime (time) {
      const d = new Date(time)
      return d.toLocaleTimeString()
    }
  },
  created () {
    if (!this.useMouse) {
      this.$bus.$on('keyUpArrowDown', this.onDown)
      this.$bus.$on('keyUpArrowUp', this.onUp)
      this.$bus.$on('keyUpEnter', this.onEnter)
    } else {
      this.currentSelect = -1
    }
    this.$bus.$on('keyUpBackspace', this.onBack)
    this.setChannel(this.$route.params.channel)
  },
  mounted () {
    window.c = this.$refs.elementsDiv
    const c = this.$refs.elementsDiv
    c.scrollTop = c.scrollHeight
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>

.elements{
  height: calc(100% - 56px);
  background-color: #20201d;
  color: white;
  display: flex;
  flex-direction: column;
  padding-bottom: 12px;
  overflow-y: auto;
}

.element{
  color: #a6a28c;
  flex: 0 0 auto;
  width: 100%;
  display: flex;
  /* margin: 9px 12px;
  line-height: 18px;
  font-size: 18px;
  padding-bottom: 6px;
  
  flex-direction: row;
  height: 60px; */
}

.time{
  padding-right: 6px;
  font-size: 12px;

}

.message{
  width: 100%;
  color: #FFC629;
}

.tchat_write{
    height: 56px;
    widows: 100%;
    background: #20201d;
    display: flex;
    justify-content: space-around;
    align-items: center;
}
.tchat_write input{
    width: 75%;
    margin-left: 6%;
    border: none;
    outline: none;
    font-size: 16px;
    padding: 3px 5px;
    float: left;
    height: 36px;
    background-color: #00071c;
    color: white;
}
.tchat_write input::placeholder {
  color: #ccc;
}
.tchat_send{
    width: 32px;
    height: 32px;
    float: right;
    border-radius: 50%;
    background-color: #5e0576;
    margin-right: 12px;
    margin-bottom: 2px;
    color: white;
    line-height: 32px;
    text-align: center;
}
.elements::-webkit-scrollbar-track
  {
      box-shadow: inset 0 0 6px rgba(0,0,0,0.3);
      background-color: #a6a28c;
  }
.elements::-webkit-scrollbar
  {
      width: 3px;
      background-color: transparent;
  }
.elements::-webkit-scrollbar-thumb
  {
      background-color: #FFC629;
  }
</style>
