<template>
  <div class="home" v-bind:style="{background: 'url(' + backgroundURL +')'}">
    <InfoBare />
    <span class="warningMess" v-if="messages.length >= 220">Saturation mémoires !<br>{{messages.length}} / 250</span>
    <div class='home_buttons'>
      <button 
          v-for="(but, key) of listApps" 
          v-bind:key="but.name" 
          v-bind:class="{ select: key === currentSelect}"
          v-bind:style="{backgroundImage: 'url(' + but.icons +')'}"
         >
          {{but.name}}
          <span class="puce" v-if="but.puce !== undefined && but.puce !== 0">{{but.puce}}</span>
      </button>
      <div class="btn_menu_ctn">
        <button 
          class="btn_menu"
            :class="{ select: listApps.length === currentSelect}"
            v-bind:style="{backgroundImage: 'url(' + '/html/static/img/icons_app/menu.png' +')'}"
          >
        </button>
      </div>
    </div> 
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import InfoBare from './InfoBare'
import Apps from './Apps'

export default {
  components: {
    InfoBare
  },
  data () {
    return {
      currentSelect: 0
    }
  },
  computed: {
    ...mapGetters(['nbMessagesUnread', 'backgroundURL', 'messages']),
    listApps () {
      return Apps.filter(e => e.inHomePage === true).map(app => {
        if (app.puceRef !== undefined) {
          app.puce = this[app.puceRef]
        }
        return app
      })
    }
  },
  methods: {
    ...mapActions(['closePhone', 'setMessages']),
    onLeft () {
      this.currentSelect = (this.currentSelect + this.listApps.length) % (this.listApps.length + 1)
    },
    onRight () {
      this.currentSelect = (this.currentSelect + 1) % (this.listApps.length + 1)
    },
    onUp () {
      this.currentSelect = Math.max(this.currentSelect - 4, 0)
    },
    onDown () {
      this.currentSelect = Math.min(this.currentSelect + 4, this.listApps.length)
    },
    onEnter () {
      if (this.currentSelect === this.listApps.length) {
        this.$router.push({ name: 'menu' })
      } else {
        const name = this.listApps[this.currentSelect].routeName
        this.$router.push({ name })
      }
    },
    onBack () {
      this.closePhone()
    }
  },
  created () {
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
    // this.Di = window.setInterval(() => {
    //   console.log('add')
    //   const time = new Date().getTime()
    //   this.setMessages([
    //     ...this.messages,
    //     {
    //       id: time,
    //       transmitter: '01',
    //       receiver: '06',
    //       time: time,
    //       message: 'Salut sa va ?!!!',
    //       isRead: 0,
    //       owner: 0
    //     }
    //   ])
    // }, 2000)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
    // window.clearInterval(this.Di)
  }
}
</script>

<style>
.home{
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

.home_buttons{
  display: flex;
  width: 100%;
  bottom:1px;
  position: absolute;
  align-items: flex-end;
  flex-flow: row;
  flex-wrap: wrap;
  margin-bottom: 0px;
  justify-content: space-between;
  transition: all 0.5s ease-in-out;
}
button{
  position: relative;
  margin: 0px;
  border: none;
  width: 58px;
  height: 65px;
  color: white;
  background-size: 43px 43px;
  background-position: 8px 5px;
  background-repeat: no-repeat;
  background-color: transparent;
  font-size: 9px;
  padding-top: 46px;
  font-weight: 700;
  text-shadow: -1px 0 0 rgba(0,0,0, 0.8), 
             1px 0 0 rgba(0,0,0, 0.8),
             0 -1px 0 rgba(0,0,0, 0.8),
             0 1px 0 rgba(0,0,0, 0.8);
  text-align: center;
}
.btn_menu_ctn{
  width: 100%;
  display: flex;
  height: 56px;
  justify-content: center;
  align-content: center;
}
.btn_menu {
  text-align: center;
  height: 50px;
}

button .puce{
  position: absolute;
  display: block;
  background-color: #1450b8;
  font-size: 12px;
  width: 20px;
  height: 20px;
  line-height: 20px;
  text-align: center;
  border-radius: 50%;
  border: 1px solid white;
  top: 28px;
  left: 36px;
}
button.select{
  background-color: rgba(255,255,255, 0.7);
  border-radius: 12px;
}
button .star{ 
  position: absolute;
    width: 16px;
    top:4px;
    left: 4px;
}
</style>
