<template>
   <div class="screen">
    <div class='title'>Téléphone</div>
    <div class="content">
      <component :is="subMenu[currentMenuIndex].Comp" />
    </div>
    <div class="subMenu">
      <div class="subMenu-elem" :class="{'subMenu-elem-select': currentMenuIndex === i}"
        v-for="(Comp, i) of subMenu" :key="i">
        <i class="subMenu-icon fa" :class="['fa-' + Comp.icon]"></i>
        <span class="subMenu-name">{{Comp.name}}</span>
      </div>
    </div>
   </div>
</template>

<script>
import AppelsFavoris from './AppelsFavoris'
import AppelsContacts from './AppelsContacts'
import AppelsRecents from './AppelsRecents'

export default {
  components: {},
  data () {
    return {
      subMenu: [{
        Comp: AppelsFavoris,
        name: 'Favoris',
        icon: 'star'
      }, {
        Comp: AppelsRecents,
        name: 'Récents',
        icon: 'clock-o'
      }, {
        Comp: AppelsContacts,
        name: 'Conctats',
        icon: 'user'
      }],
      currentMenuIndex: 1
    }
  },
  methods: {
    onLeft () {
      this.currentMenuIndex = Math.max(this.currentMenuIndex - 1, 0)
    },
    onRight () {
      this.currentMenuIndex = Math.min(this.currentMenuIndex + 1, this.subMenu.length - 1)
    },
    onBackspace: function () {
      if (this.ignoreControls === true) return
      this.$router.push({ name: 'home' })
    }
  },

  created: function () {
    this.$bus.$on('keyUpBackspace', this.onBackspace)
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
  },
  beforeDestroy: function () {
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
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
.content{
  height: calc(100% - 68px);
  overflow-y: auto;
}
.subMenu{
  border-top: 1px solid rgba(0,0,0,0.24);
  display: flex;
  height: 34px;
}
.subMenu-elem {
  height: 100%;
  width: 100%;
  text-align: center;
  line-height: 34px;
  height: 34px;
  display: flex;
  flex-direction: column;
}
.subMenu-elem-select {
  color: #0288D1;
}
.subMenu-icon{
  margin-top: 4px;
  font-size: 14px;
  line-height: 14px;
  height: 14px;
}
.subMenu-name{
  display: block;
  font-size: 10px;
  height: 14px;
  line-height: 14px;
}
</style>
