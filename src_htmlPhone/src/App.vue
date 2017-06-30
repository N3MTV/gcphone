<template>
  <div id="app" class="phone_screen">
    <router-view v-if="$root.urgenceOnly === false"></router-view>
    <UrgenceOnly v-else></UrgenceOnly>
  </div>
</template>

<script>
import './assets/css/font-awesome.min.css'
import UrgenceOnly from '@/components/UrgenceOnly'
export default {
  name: 'app',
  components: {
    UrgenceOnly
  },
  data: function () {
    return {
      keyEvent: ['ArrowRight', 'ArrowLeft', 'ArrowUp', 'ArrowDown', 'Backspace', 'Enter']
    }
  },
  mounted: function () {
    // For local teste
    // window.addEventListener('keyup', (event) => {
    window.onkeyup = (event) => {
      if (this.keyEvent.indexOf(event.key) !== -1) {
        this.$bus.$emit('keyUp' + event.key)
      }
    }
  }
}
</script>

<style >
.phone_wrapper{
    position: absolute;
    bottom: 2vh;
    right: 2vh;
    width: 266px;
    height: 500px;
}
.phone_screen{
    overflow: hidden;
    position: absolute;
    background-color: white;
    bottom: 48px;
    left: 17px;
    right: 16px;
    top: 48px;
}
* {
  font-family: 'Roboto', sans-serif;
  box-sizing: border-box;
}
*::-webkit-scrollbar-track
{
	box-shadow: inset 0 0 6px rgba(0,0,0,0.3);
	background-color: #F5F5F5;
}
*::-webkit-scrollbar
{
	width: 3px;
	background-color: transparent;
}
*::-webkit-scrollbar-thumb
{
	background-color: #666;
}
</style>
