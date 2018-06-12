<template>
  <div class="screen">
    <div class='elements'>
      <img class="logo_maze" src="/html/static/img/app_bank/logo_mazebank.jpg">
      <div class='element'>
        <div class="element-content">
          <hr>
          <span>$ {{ bankAmontFormat }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  data () {
    return {
    }
  },
  computed: {
    ...mapGetters(['bankAmont']),
    bankAmontFormat () {
      return Intl.NumberFormat().format(this.bankAmont)
    }
  },
  methods: {
    onBackspace: function () {
      this.$router.push({ name: 'home' })
    }
  },
  created: function () {
    this.$bus.$on('keyUpBackspace', this.onBackspace)
  },
  beforeDestroy: function () {
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
  background-color: #e1090a;
}
.title{
  padding-left: 16px;
  height: 34px;
  line-height: 34px;
  font-weight: 700;
  color: white;
  background-color: rgb(76, 175, 80);
}
.elements{
  overflow-y: auto;
  margin-left: auto;
  margin-right: auto;
  top: 50%;
  transform: translateY(-50%);
  position: relative;
  width: 50%;
  text-align: center;
}
.logo_maze {
    width: 75%; 
    text-align: center;
}
.elements hr{
    width: 100%;
    box-shadow: none;
    border: 1px solid white;
}
.element-content{
  display: block;
  height: 40px;
  width: 100%;
  display: flex;
  flex-flow: column;
  justify-content: center;
  color: white;
}
</style>
