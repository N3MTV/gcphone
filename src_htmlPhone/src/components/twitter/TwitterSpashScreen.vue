<template>
  <div class="splash">
    <img src="/html/static/img/twitter/bird.png">
  </div>
</template>

<script>
export default {
  created: function () {
    setTimeout(() => {
      this.$router.push({ name: 'twitter.screen' })
    }, 500)
  }
}
</script>

<style scoped>
  .splash{
    width: 100%;
    height: 100%;
    background-color: white; /*#1da1f2;*/
    display: flex;
    justify-content: center;
    align-items: center;
  }
  img {
    width: 80px;
    animation-name: zoom;
    animation-duration: 0.35s;
    animation-fill-mode: forwards;
  }
  @keyframes zoom {
    from {width: 180px;}
      to {width: 250px;}
  }
</style>
