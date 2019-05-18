<template>
  <div class="phone_content">
    <div class="img-fullscreen" v-if="imgZoom !== undefined" @click.stop="imgZoom = undefined">
      <img :src="imgZoom" />
    </div>
    <div class="tweets-wrapper" ref="elementsDiv">
        <div class="tweet" v-for='(tweet, key) in tweets' 
          v-bind:key="tweet.id"
          v-bind:class="{ select: key === selectMessage}"
          >
          <div class="tweet-img">
            <img :src="tweet.authorIcon || 'html/static/img/twitter/default_profile.png'" width="48" height="48"/>
          </div>
          <div class="tweet-content">
            <div class="tweet-head">
              <div class="tweet-head-author">{{ tweet.author }}</div>
              <div class="tweet-head-time">{{formatTime(tweet.time)}}</div>
            </div>
            <div class="tweet-message">
              <template v-if="!isImage(tweet.message)">{{ tweet.message }}</template>
              <img v-else :src="tweet.message" class="tweet-attachement-img" @click.stop="imgZoom = tweet.message">
            </div>
            <div class="tweet-like">

              <div class="item svgreply" @click.stop="reply(tweet)">
                <svg @click.stop="reply(tweet)" xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"><path fill="none" d="M0 0h24v24H0V0z"/><path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm0 14H6l-2 2V4h16v12z"/></svg>
              </div>
              
              <div class="item">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"><path d="M0 0h24v24H0z" fill="none"/><path d="M7 7h10v3l4-4-4-4v3H5v6h2V7zm10 10H7v-3l-4 4 4 4v-3h12v-6h-2v4z"/></svg>
              </div>

              <div v-if="tweet.isLikes" class="item svgdislike" @click.stop="twitterToogleLike({ tweetId: tweet.id })">     
                  <svg @click.stop="twitterToogleLike({ tweetId: tweet.id })" xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"><path d="M0 0h24v24H0z" fill="none"/><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>
                  <span @click.stop="twitterToogleLike({ tweetId: tweet.id })">{{ tweet.likes }}</span>
              </div>
              <div v-else class="svglike" @click.stop="twitterToogleLike({ tweetId: tweet.id })">
                  <svg @click.stop="twitterToogleLike({ tweetId: tweet.id })" xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"><path d="M0 0h24v24H0z" fill="none"/><path d="M16.5 3c-1.74 0-3.41.81-4.5 2.09C10.91 3.81 9.24 3 7.5 3 4.42 3 2 5.42 2 8.5c0 3.78 3.4 6.86 8.55 11.54L12 21.35l1.45-1.32C18.6 15.36 22 12.28 22 8.5 22 5.42 19.58 3 16.5 3zm-4.4 15.55l-.1.1-.1-.1C7.14 14.24 4 11.39 4 8.5 4 6.5 5.5 5 7.5 5c1.54 0 3.04.99 3.57 2.36h1.87C13.46 5.99 14.96 5 16.5 5c2 0 3.5 1.5 3.5 3.5 0 2.89-3.14 5.74-7.9 10.05z"/></svg>
                  <span @click.stop="twitterToogleLike({ tweetId: tweet.id })">{{ tweet.likes }}</span>
              </div>
              
              <div class="item">
                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"><path fill="none" d="M0 0h24v24H0V0z"/><path d="M18 16.08c-.76 0-1.44.3-1.96.77L8.91 12.7c.05-.23.09-.46.09-.7s-.04-.47-.09-.7l7.05-4.11c.54.5 1.25.81 2.04.81 1.66 0 3-1.34 3-3s-1.34-3-3-3-3 1.34-3 3c0 .24.04.47.09.7L8.04 9.81C7.5 9.31 6.79 9 6 9c-1.66 0-3 1.34-3 3s1.34 3 3 3c.79 0 1.5-.31 2.04-.81l7.12 4.16c-.05.21-.08.43-.08.65 0 1.61 1.31 2.92 2.92 2.92s2.92-1.31 2.92-2.92-1.31-2.92-2.92-2.92z"/></svg>
              </div>

            </div>
          </div>
        </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import Modal from '@/components/Modal/index.js'

export default {
  components: {},
  data () {
    return {
      selectMessage: -1,
      ignoreControls: false,
      imgZoom: undefined
    }
  },
  computed: {
    ...mapGetters(['favoriteTweets', 'IntlString', 'useMouse']),
    tweets () {
      return this.favoriteTweets
    }
  },
  watch: {
  },
  methods: {
    ...mapActions(['twitterLogin', 'twitterPostTweet', 'twitterToogleLike', 'fetchFavoriteTweets']),
    async showOption () {
      this.ignoreControls = true
      const tweet = this.tweets[this.selectMessage]
      let optionsChoix = [{
        id: 1,
        title: 'Like / Unlike',
        icons: 'fa-heart'
      }, {
        id: 2,
        title: 'Répondre',
        icons: 'fa-reply'
      }, {
        id: -1,
        title: this.IntlString('CANCEL'),
        icons: 'fa-undo'
      }]
      if (this.isImage(tweet.message)) {
        optionsChoix = [{
          id: 3,
          title: this.IntlString('APP_MESSAGE_ZOOM_IMG'),
          icons: 'fa-search'
        }, ...optionsChoix]
      }
      const choix = await Modal.CreateModal({ choix: optionsChoix })
      this.ignoreControls = false
      switch (choix.id) {
        case 1:
          this.twitterToogleLike({ tweetId: tweet.id })
          break
        case 2:
          this.reply(tweet)
          break
        case 3:
          this.imgZoom = tweet.message
          break
      }
    },
    isImage (mess) {
      return /^https?:\/\/.*\.(png|jpg|jpeg|gif)/.test(mess)
    },
    async reply (tweet) {
      const authorName = tweet.author
      try {
        this.ignoreControls = true
        const rep = await Modal.CreateTextModal({
          title: 'Répondre',
          text: `@${authorName} `
        })
        if (rep !== undefined && rep.text !== undefined) {
          const message = rep.text.trim()
          if (message.length !== 0) {
            this.twitterPostTweet({ message })
          }
        }
      } catch (e) {
      } finally {
        this.ignoreControls = false
      }
    },
    resetScroll () {
      this.$nextTick(() => {
        let elem = document.querySelector('#tweets')
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
      if (this.ignoreControls === true) return
      if (this.selectMessage === -1) {
        this.newTweet()
      } else {
        this.showOption()
      }
    },
    onBack () {
      if (this.imgZoom !== undefined) {
        this.imgZoom = undefined
        return
      }
      if (this.ignoreControls === true) return
      if (this.selectMessage !== -1) {
        this.selectMessage = -1
      } else {
        this.$bus.$emit('twitterHome')
      }
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
    }
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  mounted () {
    this.fetchFavoriteTweets()
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
  .svgreply:hover {
    cursor: pointer;
    fill: #1da1f2;
    color: #1da1f2;
  }
  .svglike:hover {
    cursor: pointer;
    fill: red;
    color: red;
  }
  .svgdislike {
    fill: red;
    color: red;
  }
  .svgdislike:hover {
    cursor: pointer;
    fill: #C0C0C0;
    color: #C0C0C0;
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
.tweets-wrapper{
  height: 100%;
  background-color: #c0deed;
  color: black;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
}

.tweet{
  background-color: white;
  flex: 0 0 auto;
  width: 100%;
  display: flex;
  flex-direction: row;
  border-bottom: #CCC 1px solid;
  padding-top: 6px;
}
.tweet.select {
  background-color: #c0deed;
}

.tweet-img {
  width: 96px;
  display: flex;
  justify-content: center;
}

.tweet-img img{
  border-radius: 50%;
}

.tweet-content {
  width: 100%;
}

.tweet-head {
  padding-bottom: 4px;
  font-size: 14px;
  display: flex;
  flex-direction: row;
  font-weight: 700;
}

.tweet-head-author {
  width: 100%;
}
.tweet-head-time {
  font-size: 12px;
  text-align: right;
  padding-right: 6px;
  color: #888;
}

.tweet-message{
  font-size: 14px;
  color: 000;
  min-height: 36px;
  word-break: break-word;
}

.tweet-attachement-img {
  width: 96%;
}

.tweet-like {
  margin-top: 6px;
  display: flex;
  width: 100%;
  height: 24px;
  font-size: 12px;
  line-height: 24px;
  font-weight: 700;
}
.tweet-like div {
  width: 80px;
}

.tweet_write{
    height: 56px;
    widows: 100%;
    background: #c0deed;
    display: flex;
    justify-content: space-around;
    align-items: center;
}
.tweet_write input{
    width: 75%;
    margin-left: 6%;
    border: none;
    outline: none;
    font-size: 16px;
    padding: 3px 12px;
    float: left;
    height: 36px;
    background-color: #ffffff;
    color: white;
    border-radius: 16px;
}
.tweet_write input::placeholder {
  color: #888;
}
.tweet_send{
    width: 32px;
    height: 32px;
    float: right;
    border-radius: 50%;
    background-color: #0084b4;
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
      background-color: #1da1f2;
  }
</style>
