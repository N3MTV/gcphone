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
import List from './../List.vue'
import request from '../../request'
import Modal from '@/components/Modal/index.js'

export default {
  components: {
    List
  },
  data () {
    return {
      paramList: [
        {icons: 'fa-phone', title: 'Mon numéro', value: this.$root.myPhoneNumber},
        // eslint-disable-next-line
        {icons: 'fa-picture-o', title: 'Font d\'écran', value: localStorage['background_display'] || 'Calvin & Hobbes', onValid: 'onChangeBackground', values: {
          'Calvin & Hobbes': 'back001.jpg',
          'Destiny': 'back002.jpg',
          'Guitare': '01.jpg',
          'Los Santos': '02.jpg',
          'Poursuite': '03.jpg',
          'Franklin': '04.jpg',
          'Police boom': '05.jpg',
          'Trevor & Michael': '06.jpg',
          'San Andreas': '07.jpg',
          'Cité': '08.jpg',
          'Ciel & Forêt': '09.jpg',
          'Forêt Colorer': '10.jpg',
          'Vague Géante': '11.jpg',
          'Lion': '12.jpg',
          'Planète': '13.jpg',
          'Rose': '14.jpg',
          'Bleu': '15.jpg',
          'Noir': '16.jpg',
          'Chocolat': '17.jpg',
          'Assassins\'s Creed': '18.jpg',
          'Stalactite': '19.jpg',
          'Origin': '20.jpg',
          'Pacman': '21.jpg',
          'Custom URL': 'URL'
        }},
        // eslint-disable-next-line
        {icons: 'fa-mobile', title: 'Coque telephone', value: localStorage['coque_display'] || 'Bleu', onValid: 'onChangeCoque', values: {
          'Coque Bleu': 'bleu.png',
          'Coque blanc': 'blanc.png',
          'Coque Jaune': 'jaune.png',
          'Coque Leopard': 'leopard.png',
          'Coque Noir': 'noir.png',
          'Coque Or': 'or.png',
          'Coque Rose': 'rose.png',
          'Coque Rouge': 'rouge.png',
          'Coque Vert': 'vert.png',
          'Coque Violet': 'violet.png',
          'Coque Zebre': 'zebre.png'
        }},
        // {icons: 'fa-paint-brush', title: 'Theme color', value: 'Defaut'},
        // eslint-disable-next-line
        {icons: 'fa-search', title: 'Zoom', onValid: 'setZoom', values: {
          '250 %': '250%',
          '200 %': '200%',
          '150 %': '150%',
          '125 %': '125%',
          '100 %': '100%',
          '75 %': '75%'
        }},
        // eslint-disable-next-line
        {icons: 'fa-exclamation-triangle', color: '#c0392b', title: 'Formater', onValid: 'resetPhone', values: {
          'TOUT SUPPRIMER': 'accept',
          'Annuler': 'cancel'
        }}
      ],
      ignoreControls: false,
      currentSelect: 0
    }
  },
  methods: {
    scrollIntoViewIfNeeded: function () {
      this.$nextTick(() => {
        document.querySelector('.select').scrollIntoViewIfNeeded()
      })
    },
    onBackspace: function () {
      if (this.ignoreControls === true) return
      history.back()
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
        request.getReponseText().then(valueText => {
          localStorage['background_display'] = data.title
          localStorage['background_img'] = valueText.text
          param.value = valueText.text
        })
      } else {
        localStorage['background_display'] = data.title
        localStorage['background_img'] = data.value
        param.value = data.title
      }
    },
    onChangeCoque: function (param, data) {
      localStorage['coque_display'] = data.title
      localStorage['coque_img'] = data.value
      param.value = data.title
      this.$root.coque = data.value
    },
    resetPhone: function (param, data) {
      if (data.title !== 'Annuler') {
        this.ignoreControls = true
        let choix = [{title: 'Annuler'}, {title: 'Annuler'}, {title: 'EFFACER', color: 'red'}, {title: 'Annuler'}, {title: 'Annuler'}]
        Modal.CreateModal({choix}).then(reponse => {
          this.ignoreControls = false
          if (reponse.title === 'EFFACER') {
            request.deleteALL()
          }
        })
      }
    },
    setZoom: function (param, data) {
      localStorage['zoom'] = data.value
      this.$root.zoom = data.value
    }
  },

  created: function () {
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBackspace)
  },
  beforeDestroy: function () {
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
