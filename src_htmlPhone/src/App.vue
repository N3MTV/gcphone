<template>
<div v-if="show === true" :style="{zoom: zoom}">
  <div class="phone_wrapper">
    <div class="phone_coque" :style="{backgroundImage: 'url(/html/static/img/coque/' + coque.value + ')'}"></div>
    <div id="app" class="phone_screen">
      <router-view></router-view>
    </div>
  </div>
</div>
</template>

<script>
import './PhoneBaseStyle.scss'
import './assets/css/font-awesome.min.css'
import { mapGetters, mapActions } from 'vuex'

export default {
  name: 'app',
  components: {
  },
  data: function () {
    return {
      soundCall: null
    }
  },
  methods: {
    ...mapActions(['loadConfig', 'rejectCall'])
  },
  computed: {
    ...mapGetters(['show', 'zoom', 'coque', 'appelsInfo', 'myPhoneNumber', 'volume'])
  },
  watch: {
    appelsInfo (newValue, oldValue) {
      if (this.appelsInfo !== null && this.appelsInfo.is_accepts !== true) {
        if (this.soundCall !== null) {
          this.soundCall.pause()
        }
        if (this.myPhoneNumber === this.appelsInfo.transmitter_num) {
          this.soundCall = new Audio('/html/static/sound/Phone_Call_Sound_Effect.ogg')
        } else {
          this.soundCall = new Audio('/html/static/sound/ring.ogg')
        }
        this.soundCall.loop = true
        this.soundCall.volume = this.volume
        this.soundCall.play()
      } else if (this.soundCall !== null) {
        this.soundCall.pause()
        this.soundCall = null
      }
      if (newValue === null && oldValue !== null) {
        this.$router.push({name: 'home'})
        return
      }
      if (newValue !== null) {
        this.$router.push({name: 'appels.active'})
      }
    },
    show () {
      if (this.appelsInfo !== null) {
        this.$router.push({name: 'appels.active'})
      } else {
        this.$router.push({name: 'home'})
      }
      if (this.show === false && this.appelsInfo !== null && this.appelsInfo.is_accepts === true) {
        this.rejectCall()
      }
    }
  },
  mounted: function () {
    this.loadConfig()
    window.addEventListener('message', (event) => {
      if (event.data.keyUp !== undefined) {
        this.$bus.$emit('keyUp' + event.data.keyUp)
      }
    })
    window.addEventListener('keyup', (event) => {
      const keyValid = ['ArrowRight', 'ArrowLeft', 'ArrowUp', 'ArrowDown', 'Backspace', 'Enter']
      if (keyValid.indexOf(event.key) !== -1) {
        this.$bus.$emit('keyUp' + event.key)
      }
    })
    // setTimeout(() => {
    //   this.$store.commit('SET_APPELS_INFO', {
    //     id: 1,
    //     transmitter_src: 5,
    //     // transmitter_num: '###-####',
    //     transmitter_num: '336-4557',
    //     receiver_src: undefined,
    //     // receiver_num: '336-4557',
    //     receiver_num: '###-####',
    //     is_valid: 0,
    //     is_accepts: 0,
    //     hidden: 0
    //   })
    // }, 1000)
  }
}
</script>

<style lang="scss">
</style>
