<template>
  <div class="home" v-bind:style="{background: 'url(' + backgroundImg +')'}">
    <span class="warningMess" v-if="this.$root.messages.length >= 220">Saturation mémoires !<br>{{this.$root.messages.length}} / 250</span>
    <span class="time"><current-time></current-time></span>
    <div class='home_buttons'>
      <button v-for="(but, key) of buttons" 
          v-bind:key="but.title" 
          v-bind:class="{ select: key === currentSelect}"
          v-bind:style="{backgroundImage: 'url(' + but.img +')'}">
          {{but.title}}
          <span class="puce" v-if="but.puce !== undefined && but.puce !== 0">{{but.puce}}</span>
      </button>
    </div> 
  </div>
</template>

<script>
import request from './../request'
import CurrentTime from './CurrentTime'
export default {
  components: {
    CurrentTime
  },
  data () {
    return {
      buttons: [{
        title: 'Contacts',
        img: '/html/static/img/contacts.png',
        urlPath: 'contacts'
      }, {
        title: 'Messages',
        img: '/html/static/img/sms.png',
        urlPath: 'Messages',
        puce: this.getNbNoReadMessage()
      }, {
        title: 'Téléphone',
        img: '/html/static/img/call.png',
        urlPath: 'call'
      }, {
        title: 'Parametres',
        img: '/html/static/img/settings.png',
        urlPath: 'paramtre'
      }],
      currentSelect: 0
    }
  },
  computed: {
    backgroundImg: function () {
      let backImg = localStorage['background_img'] || 'back001.jpg'
      if (backImg.startsWith('http') === true) {
        return backImg
      }
      return '/html/static/img/' + backImg
    }
  },
  watch: {
    '$root.messages': function () {
      this.buttons[1].puce = this.getNbNoReadMessage()
    }
  },
  methods: {
    getNbNoReadMessage: function () {
      return this.$root.messages.reduce((acc, v) => acc - v.isRead, this.$root.messages.length)
    },
    onLeft: function () {
      this.currentSelect = this.currentSelect === 0 ? this.buttons.length - 1 : this.currentSelect - 1
    },
    onRight: function () {
      this.currentSelect = this.currentSelect === this.buttons.length - 1 ? 0 : this.currentSelect + 1
    },
    onUp: function () {
      this.currentSelect = Math.max(0, this.currentSelect - 3)
    },
    onDown: function () {
      this.currentSelect = Math.min(this.buttons.length - 1, this.currentSelect + 3)
    },
    onEnter: function () {
      let path = this.buttons[this.currentSelect].urlPath
      this.$router.push({path})
    },
    onBack: function () {
      request.closePhone()
    }
  },
  created: function () {
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  beforeDestroy: function () {
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.home{
  background: url(../../static/img/back001.jpg);
  background-size: cover !important;
  position: relative;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  display: flex;
  align-content: center;
  justify-content: center;
}
.warningMess{
  display: block;
  position: absolute;
  left: 0;
  right: 0;
  color: red;
  text-align: center;
  top: 150px;
  font-size: 1.4em;
  text-shadow: -1px 0 0 rgba(0,0,0, 0.8), 
            1px 0 0 rgba(0,0,0, 0.8),
            0 -1px 0 rgba(0,0,0, 0.8),
            0 1px 0 rgba(0,0,0, 0.8);
}
.time{
  font-size: 48px;
  margin-top: 100px;
   color: white;
  text-shadow: -1px 0 0 rgba(0,0,0, 0.8), 
             1px 0 0 rgba(0,0,0, 0.8),
             0 -1px 0 rgba(0,0,0, 0.8),
             0 1px 0 rgba(0,0,0, 0.8);
}
.home_buttons{
  display: flex;
  width: 100%;
  position: absolute;
  bottom: 0;
  margin-bottom: 12px;
  align-items: flex-end;
  flex-flow: row;
  flex-wrap: wrap;
  justify-content: space-between;
}
button{
  position: relative;
  margin: 2px;
  border: none;
  width: 64px;
  height: 72px;
  color: white;
  background-size: 48px 48px;
  background-position: 6px 6px;
  background-repeat: no-repeat;
  background-color: transparent;
  font-size: 10px;
  padding-top: 52px;
  font-weight: 700;
  text-shadow: -1px 0 0 rgba(0,0,0, 0.8), 
             1px 0 0 rgba(0,0,0, 0.8),
             0 -1px 0 rgba(0,0,0, 0.8),
             0 1px 0 rgba(0,0,0, 0.8);
}
button .puce{
  position: absolute;
  display: block;
  background-color: darkorange;
  width: 16px;
  height: 16px;
  line-height: 14px;
  text-align: center;
  border-radius: 50%;
  border: 1px solid white;
  top: 38px;
  left: 38px;
}
button.select{
  background-color: rgba(255,255,255, 0.7);
  border-radius: 12px;
}
</style>
