<template>
  <div class='barre-header'>
    <span class='reseau'>{{config.reseau}}</span>
    <span class="time">
      <current-time></current-time>
    </span>
    <hr class = "batterie1">
    <hr class = "batterie2">
    <hr class = "barre1">
    <hr class = "barre2">
    <hr class = "barre3">
    <hr class = "barre4">
  </div>
</template>
<script>
import { mapGetters } from 'vuex'
import CurrentTime from './CurrentTime'
export default {
  computed: mapGetters(['config']),
  components: {
    CurrentTime
  }
}
</script>
<style scoped>
.barre-header {
    font-size: 11px;
    padding: 5px;
    position: absolute;
    width: 100%;
    top:0px;
    color: white;
    background-color: rgba(0, 0, 0, 0.6)
}
.barre-header hr {
    position: absolute;
    vertical-align: bottom;
    display: inline-block;
    float: right;
}
.barre1 {
    height: 12px;
    width: 3px;
    right: 58px;
    background-color: rgba(255, 255, 255, 0.6);
    color: rgba(255, 255, 255, 0.6);
    border: none;
    bottom: 0px;
}
.barre2 {
    height: 9px;
    width: 3px;
    right: 63px;
    background-color: white;
    border: none;
    bottom: 0px;
}
.barre3 {
    height: 6px;
    width: 3px;
    right: 68px;
    background-color: white;
    border: none;
    bottom: 0px;
}
.barre4 {
    height: 3px;
    width: 3px;
    right: 73px;
    background-color: white;
    border: none;
    bottom: 0px;
}
.time{
    text-align: right;
    float: right;
    padding-right: 10px;
}
.batterie { 
    text-align: right;
    float: right;
    padding-right: 12px;   
    }

.batterie1 {
    height: 9px;
    width: 5px;
    right: 46px;
    background-color: rgb(255, 255, 255);
    color: rgb(255, 255, 255);
    border-radius: 0.5px;
    border: none;
    bottom: 1px;
}
.batterie2 {
    height: 10.8px;
    width: 3px;
    right: 47px;
    bottom: 1px;
    background-color: rgba(255, 255, 255, 0.6);
    border: 0.5px solid white;
    border-radius: 1px;
}
.reseau {
    float: left;
    padding-left: 10px;
}
</style>
