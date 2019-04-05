<template>
  <div class="phone_app">
    <PhoneTitle :title="currentScreen.title" backgroundColor="#1da1f2" />
    <div class="phone_content">
      <component v-bind:is="currentScreen.component"/>
    </div>
    <div class="twitter_menu">
      <div
        v-for="(s, i) in screen"
        :key="i"
        class="twitter_menu-item">
        <i class="fa" :class="s.icon" :style="{color: i === currentScreenIndex ? '#1da1f2' : '#303030'}"></i>
      </div>
    </div>
  </div>
</template>

<script>
import PhoneTitle from './../PhoneTitle'
import TwitterView from './TwitterView'
import TwitterPostTweet from './TwitterPostTweet'
import TwitterAccount from './TwitterAccount'
import TwitterTopTweet from './TwitterTopTweet'

export default {
  components: {
    PhoneTitle
  },
  data () {
    return {
      currentScreenIndex: 0,
      screen: [
        {
          title: 'Twitter',
          component: TwitterView,
          icon: 'fa-home'
        },
        {
          title: 'Top Tweet',
          component: TwitterTopTweet,
          icon: 'fa-heart'
        },
        {
          title: 'Tweeter',
          component: TwitterPostTweet,
          icon: 'fa-comment'
        },
        {
          title: 'Mon Compte',
          component: TwitterAccount,
          icon: 'fa-cog'
        }
      ]
    }
  },
  computed: {
    currentScreen () {
      return this.screen[this.currentScreenIndex]
    }
  },
  watch: {
  },
  methods: {
    onLeft: function () {
      this.currentScreenIndex = Math.max(0, this.currentScreenIndex - 1)
    },
    onRight () {
      this.currentScreenIndex = Math.min(this.screen.length - 1, this.currentScreenIndex + 1)
    }
  },
  created: function () {
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
  },
  mounted () {
  },
  beforeDestroy: function () {
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
  }
}
</script>

<style scoped>
.twitter_menu {
  height: 56px;
  display: flex;
  width: 100%;
}
.twitter_menu-item {
  flex-grow: 1;
  flex-basis: 0;
  display: flex;
  justify-content: center;
  align-items: center;
}
</style>
