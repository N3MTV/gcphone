<template>
  <div class="phone_app">
    <PhoneTitle :title="IntlString('APP_CONFIG_TITLE')" @back="onBackspace"/>
    <div class='phone_content elements'>
      <div class='element'
          v-for='(elem, key) in paramList' 
          v-bind:class="{ select: key === currentSelect}"
          v-bind:key="key"
          @click.stop="onPressItem(key)"  
        >
        <i class="fa" v-bind:class="elem.icons" v-bind:style="{color: elem.color}" @click.stop="onPressItem(key)"></i>
        <div class="element-content" @click.stop="onPressItem(key)">
          <span class="element-title" @click.stop="onPressItem(key)">{{elem.title}}</span>
          <span v-if="elem.value" class="element-value" @click.stop="onPressItem(key)">{{elem.value}}</span>
        </div>
      </div>
    </div>
    
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import PhoneTitle from './../PhoneTitle'
import Modal from '@/components/Modal/index.js'

export default {
  components: {
    PhoneTitle
  },
  data () {
    return {
      ignoreControls: false,
      currentSelect: 0
    }
  },
  computed: {
    ...mapGetters(['IntlString', 'useMouse', 'myPhoneNumber', 'backgroundLabel', 'coqueLabel', 'zoom', 'config', 'volume', 'availableLanguages']),
    paramList () {
      const cancelStr = this.IntlString('CANCEL')
      const confirmResetStr = this.IntlString('APP_CONFIG_RESET_CONFIRM')
      const cancelOption = {}
      const confirmReset = {}
      cancelOption[cancelStr] = 'cancel'
      confirmReset[confirmResetStr] = 'accept'
      return [
        {
          icons: 'fa-phone',
          title: this.IntlString('APP_CONFIG_MY_MUNBER'),
          value: this.myPhoneNumber
        },
        {
          icons: 'fa-picture-o',
          title: this.IntlString('APP_CONFIG_WALLPAPER'),
          value: this.backgroundLabel,
          onValid: 'onChangeBackground',
          values: this.config.background
        },
        {
          icons: 'fa-mobile',
          title: this.IntlString('APP_CONFIG_CASE'),
          value: this.coqueLabel,
          onValid: 'onChangeCoque',
          values: this.config.coque
        },
        {
          icons: 'fa-search',
          title: this.IntlString('APP_CONFIG_ZOOM'),
          value: this.zoom,
          onValid: 'setZoom',
          onLeft: this.ajustZoom(-1),
          onRight: this.ajustZoom(1),
          values: {
            '125 %': '125%',
            '100 %': '100%',
            '80 %': '80%',
            '60 %': '60%',
            '40 %': '40%',
            '20 %': '20%'
          }
        },
        {
          icons: 'fa-volume-down',
          title: this.IntlString('APP_CONFIG_VOLUME'),
          value: this.valumeDisplay,
          onValid: 'setPhoneVolume',
          onLeft: this.ajustVolume(-0.01),
          onRight: this.ajustVolume(0.01),
          values: {
            '100 %': 1,
            '80 %': 0.8,
            '60 %': 0.6,
            '40 %': 0.4,
            '20 %': 0.2,
            '0 %': 0
          }
        },
        {
          icons: 'fa-globe',
          title: this.IntlString('APP_CONFIG_LANGUAGE'),
          onValid: 'onChangeLanguages',
          values: {
            ...this.availableLanguages,
            ...cancelOption
          }
        },
        {
          icons: 'fa-mouse-pointer',
          title: this.IntlString('APP_CONFIG_MOUSE_SUPPORT'),
          onValid: 'onChangeMouseSupport',
          values: {
            'Yes': true,
            'No': false,
            ...cancelOption
          }
        },
        {
          icons: 'fa-exclamation-triangle',
          color: '#c0392b',
          title: this.IntlString('APP_CONFIG_RESET'),
          onValid: 'resetPhone',
          values: {
            ...confirmReset,
            ...cancelOption
          }
        }
      ]
    },
    valumeDisplay () {
      return `${Math.floor(this.volume * 100)} %`
    }
  },
  methods: {
    ...mapActions(['getIntlString', 'setZoon', 'setBackground', 'setCoque', 'setVolume', 'setLanguage', 'setMouseSupport']),
    scrollIntoViewIfNeeded: function () {
      this.$nextTick(() => {
        document.querySelector('.select').scrollIntoViewIfNeeded()
      })
    },
    onBackspace () {
      if (this.ignoreControls === true) return
      this.$router.push({ name: 'home' })
    },
    onUp: function () {
      if (this.ignoreControls === true) return
      this.currentSelect = this.currentSelect === 0 ? 0 : this.currentSelect - 1
      this.scrollIntoViewIfNeeded()
    },
    onDown: function () {
      if (this.ignoreControls === true) return
      this.currentSelect = this.currentSelect === this.paramList.length - 1 ? this.currentSelect : this.currentSelect + 1
      this.scrollIntoViewIfNeeded()
    },
    onRight () {
      if (this.ignoreControls === true) return
      let param = this.paramList[this.currentSelect]
      if (param.onRight !== undefined) {
        param.onRight(param)
      }
    },
    onLeft () {
      if (this.ignoreControls === true) return
      let param = this.paramList[this.currentSelect]
      if (param.onLeft !== undefined) {
        param.onLeft(param)
      }
    },
    actionItem (param) {
      if (param.values !== undefined) {
        this.ignoreControls = true
        let choix = Object.keys(param.values).map(key => {
          return {title: key, value: param.values[key], picto: param.values[key]}
        })
        Modal.CreateModal({choix}).then(reponse => {
          this.ignoreControls = false
          if (reponse.title === 'cancel') return
          this[param.onValid](param, reponse)
        })
      }
    },
    onPressItem (index) {
      this.actionItem(this.paramList[index])
    },
    onEnter () {
      if (this.ignoreControls === true) return
      this.actionItem(this.paramList[this.currentSelect])
    },
    async onChangeBackground (param, data) {
      let val = data.value
      if (val === 'URL') {
        this.ignoreControls = true
        Modal.CreateTextModal({
          text: 'https://i.imgur.com/'
        }).then(valueText => {
          if (valueText.text !== '' && valueText.text !== undefined && valueText.text !== null && valueText.text !== 'https://i.imgur.com/') {
            this.setBackground({
              label: 'Custom',
              value: valueText.text
            })
          }
        }).finally(() => {
          this.ignoreControls = false
        })
      } else {
        this.setBackground({
          label: data.title,
          value: data.value
        })
      }
    },
    onChangeCoque: function (param, data) {
      this.setCoque({
        label: data.title,
        value: data.value
      })
    },
    setZoom: function (param, data) {
      this.setZoon(data.value)
    },
    ajustZoom (inc) {
      return () => {
        const percent = Math.max(10, (parseInt(this.zoom) || 100) + inc)
        this.setZoon(`${percent}%`)
      }
    },
    setPhoneVolume (param, data) {
      this.setVolume(data.value)
    },
    ajustVolume (inc) {
      return () => {
        const newVolume = Math.max(0, Math.min(1, parseFloat(this.volume) + inc))
        this.setVolume(newVolume)
      }
    },
    onChangeLanguages (param, data) {
      if (data.value !== 'cancel') {
        this.setLanguage(data.value)
      }
    },
    onChangeMouseSupport (param, data) {
      if (data.value !== 'cancel') {
        this.setMouseSupport(data.value)
        this.onBackspace()
      }
    },
    resetPhone: function (param, data) {
      if (data.value !== 'cancel') {
        this.ignoreControls = true
        const cancelStr = this.IntlString('CANCEL')
        const confirmResetStr = this.IntlString('APP_CONFIG_RESET_CONFIRM')
        let choix = [{title: cancelStr}, {title: cancelStr}, {title: confirmResetStr, color: 'red', reset: true}, {title: cancelStr}, {title: cancelStr}]
        Modal.CreateModal({choix}).then(reponse => {
          this.ignoreControls = false
          if (reponse.reset === true) {
            this.$phoneAPI.deleteALL()
          }
        })
      }
    }
  },

  created () {
    if (!this.useMouse) {
      this.$bus.$on('keyUpArrowRight', this.onRight)
      this.$bus.$on('keyUpArrowLeft', this.onLeft)
      this.$bus.$on('keyUpArrowDown', this.onDown)
      this.$bus.$on('keyUpArrowUp', this.onUp)
      this.$bus.$on('keyUpEnter', this.onEnter)
    } else {
      this.currentSelect = -1
    }
    this.$bus.$on('keyUpBackspace', this.onBackspace)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBackspace)
  }
}
</script>

<style scoped>
.element{
  height: 58px;
  line-height: 58px;
  display: flex;
  align-items: center;
  position: relative;
}
.element .fa{
  color: #27ae60;
  margin-left: 6px;
  height: 52px;
  width: 52px;
  text-align: center;
  line-height: 52px;
}
.element-content{
  display: block;
  height: 58px;
  width: 100%;
  margin-left: 6px;
  display: flex;
  flex-flow: column;
  justify-content: center;
}
.element-title{
  display: block;
  margin-top: 4px;
  height: 22px;
  line-height: 22px;
  font-size: 20px;
}
.element-value{
  display: block;
  line-height: 16px;
  height: 8px;
  font-size: 16px;
  color: #808080;
}
.element.select, .element:hover{
   background-color: #DDD;
}
</style>
