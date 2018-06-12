<template>
  <div class="list">
    <InfoBare class="infobare" />
    <div class="title"># {{ channel }}</div>
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
        <input type="text" placeholder="Envoyer un message">
        <span class='tchat_send'>></span>
    </div>

  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import InfoBare from './../InfoBare'
export default {
  components: { InfoBare },
  data () {
    return {
      channel: '',
      currentSelect: 0
    }
  },
  computed: {
    ...mapGetters(['tchatMessages', 'tchatCurrentChannel'])
  },
  watch: {
    tchatMessages () {
      console.log('tchatMessages')
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
        this.$el.querySelector('.select').scrollIntoViewIfNeeded()
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
    onBack () {
      this.$router.push({ name: 'tchat.channel' })
    },
    formatTime (time) {
      const d = new Date(time)
      return d.toLocaleTimeString()
    }
  },
  created: function () {
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
    this.setChannel(this.$route.params.channel)
  },
  mounted () {
    window.c = this.$refs.elementsDiv
    const c = this.$refs.elementsDiv
    c.scrollTop = c.scrollHeight
  },
  beforeDestroy: function () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.list{
  height: 100%;
}
.infobare{
  background-color: #00071c;
}
.title{
  padding-top: 22px;
  padding-left: 16px;
  height: 54px;
  line-height: 34px;
  font-weight: 700;
  background-color: #090f20;
  color: white;
}

.elements{
  height: calc(100% - 54px - 26px);
  overflow-y: auto;
  background-color: #20201d;
  color: white;
  display: flex;
  flex-direction: column;
  padding-bottom: 12px;
  /* justify-content: flex-end; */
  overflow-y: auto;
}

.element{
  color: #a6a28c;
  margin: 3px 6px;
  line-height: 12px;
  font-size: 12px;
  position: relative;
  padding-bottom: 6px;
  display: flex;
}

.time{
  padding-right: 6px;
  font-size: 9px;
}

.message{
    color: #FFC629;
}

.tchat_write{
    height: 26px;
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
    font-size: 0.6em;
    padding: 3px 5px;
    float: left;
    height: 18px;
    background-color: #00071c;
    color: white;
}
.tchat_write input::placeholder {
  color: #ccc;
}
.tchat_send{
    width: 20px;
    height: 20px;
    float: right;
    border-radius: 50%;
    background-color: #5e0576;
    margin-right: 12px;
    margin-bottom: 2px;
    color: white;
    line-height: 20px;
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
