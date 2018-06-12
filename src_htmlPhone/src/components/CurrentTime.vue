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
      var time = new Date()
      var minutes = time.getMinutes()
      minutes = minutes > 9 ? minutes : '0' + minutes
      var heure = time.getHours()
      heure = heure > 9 ? heure : '0' + heure
      var datestring = heure + ':' + minutes
      this.time = datestring
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
