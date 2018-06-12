<template>
  <div class="splash">
    <img src="/html/static/img/app_tchat/splashtchat.png" alt="">
  </div>
</template>

<script>
export default {
  created: function () {
    setTimeout(() => {
      this.$router.push({ name: 'tchat.channel' })
    }, 700)
  }
}
</script>

<style scoped>
  .splash{
    width: 100%;
    height: 100%;
    background-color: #20201d;
    display: flex;
    justify-content: center;
    align-items: center;
  }
  img {
    width: 80px;
    animation-name: zoom;
    animation-duration: 0.7s;
    animation-fill-mode: forwards;
  }
  @keyframes zoom {
    from {width: 80px;}
      to {width: 250px;}
  }
</style>
