<template>
  <div class="home" v-bind:style="{background: 'url(' + backgroundURL +')'}">
    <InfoBare />
    <span class="warningMess" v-if="messages.length >= warningMessageCount">
      <div class="warningMess_icon"><i class="fa fa-warning"></i></div>
      <span class="warningMess_content">
        <span class="warningMess_title">{{ IntlString('PHONE_WARNING_MESSAGE') }}</span><br>
        <span class="warningMess_mess">{{messages.length}} / {{warningMessageCount}} {{IntlString('PHONE_WARNING_MESSAGE_MESS')}}</span>
      </span>
    </span>
    <div class='home_buttons'>
      <button 
          v-for="(but, key) of AppsHome" 
          v-bind:key="but.name" 
          v-bind:class="{ select: key === currentSelect}"
          v-bind:style="{backgroundImage: 'url(' + but.icons +')'}"
          @click="openApp(but)"
         >
          {{but.intlName}}
          <span class="puce" v-if="but.puce !== undefined && but.puce !== 0">{{but.puce}}</span>
      </button>
      <div class="btn_menu_ctn">
        <button 
          class="btn_menu"
          :class="{ select: AppsHome.length === currentSelect}"
          v-bind:style="{backgroundImage: 'url(' + '/html/static/img/icons_app/menu.png' +')'}"
          @click="openApp({routeName: 'menu'})"
          >
        </button>
      </div>
    </div> 
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import InfoBare from './InfoBare'

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
    ...mapGetters(['IntlString', 'useMouse', 'nbMessagesUnread', 'backgroundURL', 'messages', 'AppsHome', 'warningMessageCount'])
  },
  methods: {
    ...mapActions(['closePhone', 'setMessages']),
    onLeft () {
      this.currentSelect = (this.currentSelect + this.AppsHome.length) % (this.AppsHome.length + 1)
    },
    onRight () {
      this.currentSelect = (this.currentSelect + 1) % (this.AppsHome.length + 1)
    },
    onUp () {
      this.currentSelect = Math.max(this.currentSelect - 4, 0)
    },
    onDown () {
      this.currentSelect = Math.min(this.currentSelect + 4, this.AppsHome.length)
    },
    openApp (app) {
      this.$router.push({ name: app.routeName })
    },
    onEnter () {
      this.openApp(this.AppsHome[this.currentSelect] || {routeName: 'menu'})
    },
    onBack () {
      this.closePhone()
    }
  },
  created () {
    if (!this.useMouse) {
      this.$bus.$on('keyUpArrowLeft', this.onLeft)
      this.$bus.$on('keyUpArrowRight', this.onRight)
      this.$bus.$on('keyUpArrowDown', this.onDown)
      this.$bus.$on('keyUpArrowUp', this.onUp)
      this.$bus.$on('keyUpEnter', this.onEnter)
    } else {
      this.currentSelect = -1
    }
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped="true">
.home{
  background-size: cover !important;
  background-position: center !important;
  position: relative;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  display: flex;
  align-content: center;
  justify-content: center;
  color: gray;
}
.warningMess{
  background-color: white;
  position: absolute;
  left: 12px;
  right: 12px;
  top: 34px;
  min-height: 64px;
  display: flex;
  padding: 12px;
  border-radius: 4px;
  box-shadow: 0 2px 2px 0 rgba(0,0,0,.14), 0 3px 1px -2px rgba(0,0,0,.2), 0 1px 5px 0 rgba(0,0,0,.12);
}
.warningMess .warningMess_icon{
  display: flex;
  width: 16%;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  height: 42px;
  width: 42px;
  border-radius: 50%;
}
.warningMess .warningMess_icon .fa {
  text-align: center;
  color: #F94B42;
}
.warningMess .warningMess_content{
  padding-left: 12px;
}
.warningMess_title {
  font-size: 20px;
}
.warningMess_mess {
  font-size: 16px;
}

.home_buttons{
  display: flex;
  padding: 0 16px; 
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
  width: 80px;
  height: 110px;
  color: white;
  background-size: 64px 64px;
  background-position: center 6px;
  background-repeat: no-repeat;
  background-color: transparent;
  font-size: 14px;
  padding-top: 72px;
  font-weight: 700;
  text-shadow: -1px 0 0 rgba(0,0,0, 0.8), 
             1px 0 0 rgba(0,0,0, 0.8),
             0 -1px 0 rgba(0,0,0, 0.8),
             0 1px 0 rgba(0,0,0, 0.8);
  text-align: center;
}


button .puce{
  position: absolute;
  display: block;
  background-color: #1450b8;
  font-size: 14px;
  width: 28px;
  height: 28px;
  line-height: 28px;
  text-align: center;
  border-radius: 50%;
  border: 1px solid white;
  bottom: 32px;
  right: 12px;
}
button.select, button:hover{
  background-color: rgba(255,255,255, 0.7);
  border-radius: 12px;
}

.btn_menu_ctn{
  width: 100%;
  display: flex;
  height: 80px;
  justify-content: center;
  align-content: center;
}
.btn_menu {
  height: 50px;
}

</style>
