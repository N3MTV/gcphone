<template>
  <span>{{time}}</span>
</template>

<script>
export default {
  data () {
    return {
      time: '',
      myInterval: 0
    }
  },
  methods: {
    updateTime: function () {
      this.time = new Date().toTimeString().replace(/.*(\d{2}:\d{2}:\d{2}).*/, '$1')
    }
  },
  created: function () {
    this.updateTime()
    this.myInterval = setInterval(this.updateTime, 1000)
  },
  beforeDestroy: function () {
    clearInterval(this.myInterval)
  }
}
</script>

<style scoped>
</style>
