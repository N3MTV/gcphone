<template>
  <div class="phone_app">
    <PhoneTitle :title="channelName" backgroundColor="#1ec2a0" @back="onQuit"/>
    <div class="phone_content">
      <div class="elements" ref="elementsDiv">
          <div class="element" v-for='(elem) in ircMessages' 
            v-bind:key="elem.id"
            >
            <div class="time">{{formatTime(elem.time)}}</div>
            <div class="message">
              {{elem.message}}
            </div>
          </div>
      </div>

      <div class='irc_write'>
          <input type="text" placeholder="..." v-model="message" @keyup.enter.prevent="sendMessage">
          <span class='irc_send' @click="sendMessage">></span>
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
    ...mapGetters(['ircMessages', 'ircCurrentChannel', 'useMouse']),
    channelName () {
      return '# ' + this.channel
    }
  },
  watch: {
    ircMessages () {
      const c = this.$refs.elementsDiv
      c.scrollTop = c.scrollHeight
    }
  },
  methods: {
    setChannel (channel) {
      this.channel = channel
      this.ircSetChannel({ channel })
    },
    ...mapActions(['ircSetChannel', 'ircSendMessage']),
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
          this.ircSendMessage({
            channel: this.channel,
            message
          })
        }
      }
    },
    sendMessage () {
      const message = this.message.trim()
      if (message.length !== 0) {
        this.ircSendMessage({
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
      this.$router.push({ name: 'irc.channel' })
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
  background-color: #0c0c0c;
  color: white;
  display: flex;
  flex-direction: column;
  padding-bottom: 12px;
  overflow-y: auto;
}

.element{
  color: #158770;
  -ms-flex: 0 0 auto;
  flex: 0 0 auto;
  width: 100%;
  display: -ms-flexbox;
  display: flex;
  padding: 14px;
}

.element:nth-child(odd) {
  background: rgba(21, 135, 112, 0.1);
}

.time{
  font-size: 12px;
  width: 25%;
  padding-top: 5px;
}

.message{
  width: 100%;
  color: #ffffff;
}

.irc_write{
  height: 56px;
  widows: 100%;
  background: #0c0c0c;
  display: flex;
  justify-content: space-around;
  align-items: center;
}
.irc_write input{
  width: 75%;
  margin-left: 6%;
  border: none;
  outline: none;
  font-size: 16px;
  padding: 3px 5px;
  float: left;
  height: 36px;
  background-color: #1ec2a0;
  color: #0c0c0c;
}
.irc_write input::placeholder {
  color: #0c0c0c;
}
.irc_send{
  width: 32px;
  height: 32px;
  float: right;
  border-radius: 50%;
  background-color: #1ec2a0;
  margin-right: 12px;
  margin-bottom: 2px;
  color: #0c0c0c;
  line-height: 32px;
  text-align: center;
}
.elements::-webkit-scrollbar-track {
  box-shadow: inset 0 0 6px rgba(0,0,0,0.3);
  background-color: #10725e;
}

.elements::-webkit-scrollbar {
  width: 3px;
  background-color: transparent;
}

.elements::-webkit-scrollbar-thumb {
  background-color: #1ec2a0;
}
</style>
