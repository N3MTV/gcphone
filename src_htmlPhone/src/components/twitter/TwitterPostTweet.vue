<template>
  <div class="phone_content">
    <div class='tweet_write'>
        <div class="input">
          <span class="input-blink"></span>
          <span>Quoi de neuf ?</span>
        </div>
        <span class='tweet_send'>Tweeter</span>
    </div>
  </div>
</template>

<script>
import { mapActions } from 'vuex'

export default {
  components: {},
  data () {
    return {
    }
  },
  computed: {
  },
  watch: {
  },
  methods: {
    ...mapActions(['twitterPostTweet']),
    onUp: function () {
      if (this.ignoreControls === true) return
      if (this.selectMessage === -1) {
        this.selectMessage = 0
      } else {
        this.selectMessage = this.selectMessage === 0 ? 0 : this.selectMessage - 1
      }
      this.scrollIntoViewIfNeeded()
    },
    onDown () {
      if (this.ignoreControls === true) return
      if (this.selectMessage === -1) {
        this.selectMessage = 0
      } else {
        this.selectMessage = this.selectMessage === this.tweets.length - 1 ? this.selectMessage : this.selectMessage + 1
      }
      this.scrollIntoViewIfNeeded()
    },
    async onEnter () {
      const rep = await this.$phoneAPI.getReponseText({
        // text: 'https://i.imgur.com/axLm3p6.png'
      })
      if (rep !== undefined && rep.text !== undefined) {
        const message = rep.text.trim()
        if (message.length !== 0) {
          this.twitterPostTweet({ message })
        }
      }
    }
  },
  created: function () {
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
  },
  async mounted () {
  },
  beforeDestroy: function () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
  }
}
</script>

<style scoped>
.phone_content {
  background: #c0deed;
}

.tweet_write{
    widows: 100%;
    display: flex;
    flex-direction: column;
    justify-content: space-around;
    align-items: flex-end;
}
.tweet_write .input{
    align-self: center;
    width: 90%;
    margin-top: 20px;
    border: none;
    outline: none;
    font-size: 16px;
    padding: 13px 16px;
    height: 336px;
    background-color: #ffffff;
    color: white;
    border-radius: 16px;
}

.tweet_write .input span{
  color: #A0A0A0;
  font-size: 20px;
}

.tweet_send{
  align-self: flex-end;
    width: 120px;
    height: 32px;
    float: right;
    border-radius: 16px;
    background-color: #0084b4;
    margin-right: 12px;
    margin-bottom: 2px;
    color: white;
    line-height: 32px;
    text-align: center;
    margin: 26px 20px;
    font-size: 16px;
}

.input-blink {
  animation: blink-empty 1s infinite;
  border-left: transparent solid 1px;
  margin:5px 
}
@keyframes blink-empty {
  50% {border-left: 1px solid #333;}
}
</style>
