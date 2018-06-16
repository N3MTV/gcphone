<template>
  <div class="screen">
    <div class='title'>Paramètres</div>
    <div class='elements'>
      <div class='element'
          v-for='(elem, key) in paramList' 
          v-bind:class="{ select: key === currentSelect}"
          v-bind:key="key">
        <i class="fa" v-bind:class="elem.icons" v-bind:style="{color: elem.color}"></i>
        <div class="element-content">
          <span class="element-title">{{elem.title}}</span>
          <span v-if="elem.value" class="element-value">{{elem.value}}</span>
        </div>
      </div>
    </div>
    
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import List from './../List.vue'
import Modal from '@/components/Modal/index.js'

export default {
  components: {
    List
  },
  data () {
    return {
      ignoreControls: false,
      currentSelect: 0
    }
  },
  computed: {
    ...mapGetters(['myPhoneNumber', 'backgroundLabel', 'coqueLabel', 'zoom', 'config', 'volume']),
    paramList () {
      return [
        {
          icons: 'fa-phone',
          title: 'Mon numéro',
          value: this.myPhoneNumber
        },
        {
          icons: 'fa-picture-o',
          title: 'Fond d\'écran',
          value: this.backgroundLabel,
          onValid: 'onChangeBackground',
          values: this.config.background
        },
        {
          icons: 'fa-mobile',
          title: 'Coque telephone',
          value: this.coqueLabel,
          onValid: 'onChangeCoque',
          values: this.config.coque
        },
        {
          icons: 'fa-search',
          title: 'Zoom',
          value: this.zoom,
          onValid: 'setZoom',
          onLeft: this.ajustZoom(-1),
          onRight: this.ajustZoom(1),
          values: {
            '250 %': '250%',
            '200 %': '200%',
            '150 %': '150%',
            '125 %': '125%',
            '100 %': '100%',
            '75 %': '75%'
          }
        },
        {
          icons: 'fa-volume-down',
          title: 'Volume',
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
          icons: 'fa-exclamation-triangle',
          color: '#c0392b',
          title: 'Formater',
          onValid: 'resetPhone',
          values: {
            'TOUT SUPPRIMER': 'accept',
            'Annuler': 'cancel'
          }
        }
      ]
    },
    valumeDisplay () {
      return `${Math.floor(this.volume * 100)} %`
    }
  },
  methods: {
    ...mapActions(['setZoon', 'setBackground', 'setCoque', 'setVolume']),
    scrollIntoViewIfNeeded: function () {
      this.$nextTick(() => {
        document.querySelector('.select').scrollIntoViewIfNeeded()
      })
    },
    onBackspace: function () {
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
    onEnter: function () {
      if (this.ignoreControls === true) return
      let param = this.paramList[this.currentSelect]
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
    onChangeBackground: function (param, data) {
      let val = data.value
      if (val === 'URL') {
        this.$phoneAPI.getReponseText().then(valueText => {
          this.setBackground({
            label: 'Custom',
            value: valueText.text
          })
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
        const percent = Math.max(50, (parseInt(this.zoom) || 100) + inc)
        this.setZoon(`${percent}%`)
      }
    },
    setPhoneVolume (param, data) {
      this.setVolume(data.value)
    },
    ajustVolume (inc) {
      return () => {
        const newVolume = Math.max(0, Math.min(1, this.volume + inc))
        this.setVolume(newVolume)
      }
    },
    resetPhone: function (param, data) {
      if (data.title !== 'Annuler') {
        this.ignoreControls = true
        let choix = [{title: 'Annuler'}, {title: 'Annuler'}, {title: 'EFFACER', color: 'red'}, {title: 'Annuler'}, {title: 'Annuler'}]
        Modal.CreateModal({choix}).then(reponse => {
          this.ignoreControls = false
          if (reponse.title === 'EFFACER') {
            this.$phoneAPI.deleteALL()
          }
        })
      }
    }
  },

  created: function () {
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
  },
  beforeDestroy: function () {
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
.screen{
  position: relative;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
}
.title{
  padding-left: 16px;
  height: 34px;
  line-height: 34px;
  font-weight: 700;
  color: white;
  background-color: #2c3e50;
}
.elements{
  height: calc(100% - 34px);
  overflow-y: auto;
}
.element{
    height: 40px;
    line-height: 40px;
    display: flex;
    align-items: center;
    position: relative;
}
.element .fa{
  color: #27ae60;
  margin-left: 6px;
  height: 32px;
  width: 32px;
  text-align: center;
  line-height: 32px;
}
.element-content{
  display: block;
  height: 40px;
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
  font-size: 0.8em;
}
.element-value{
  display: block;
  line-height: 8px;
  height: 8px;
  font-size: 0.6em;
  color: #808080;
}
.element.select{
   background-color: #DDD;
}
</style>
