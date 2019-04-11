<template>
  <div class="phone_app">
    <PhoneTitle :title="'9 GAG (' + currentSelectPost + ')'" backgroundColor="#000" @back="quit"/>  
    <div class='phone_content' @click="onClick">
      <div class="post" v-if="currentPost !== undefined">
        <h1 class="post-title">{{ currentPost.title }}</h1>
        <div class="post-content">
          <video class="post-video" ref="video" v-if="currentPost.images.image460svwm !== undefined" autoplay loop :src="currentPost.images.image460svwm.url">
          </video>
          <img class="post-image" v-else :src="currentPost.images.image460.url" alt="">
        </div>
      </div>
      <div v-else class="loading">
        <div>CHARGEMENT</div>
      </div>
    </div>
  </div>
</template>

<script>
import PhoneTitle from './../PhoneTitle'
export default {
  components: {
    PhoneTitle
  },
  data () {
    return {
      nextCursor: 'c=10',
      currentSelectPost: 0,
      posts: []
    }
  },
  computed: {
    currentPost () {
      if (this.posts && this.posts.length > this.currentSelectPost) {
        return this.posts[this.currentSelectPost]
      }
      this.loadItems()
      return undefined
    }
  },
  methods: {
    async loadItems () {
      let url = 'https://9gag.com/v1/group-posts/group/default/type/hot?' + this.nextCursor
      const request = await fetch(url)
      const data = await request.json()
      this.posts.push(...data.data.posts)
      this.nextCursor = data.data.nextCursor
    },
    previewPost () {
      if (this.currentSelectPost === 0) {
        return 0
      }
      this.currentSelectPost -= 1
      setTimeout(() => {
        if (this.$refs.video !== undefined) {
          this.$refs.video.volume = 0.15
        }
      }, 200)
    },
    nextPost () {
      this.currentSelectPost += 1
      setTimeout(() => {
        if (this.$refs.video !== undefined) {
          this.$refs.video.volume = 0.15
        }
      }, 200)
    },
    onClick ($event) {
      if ($event.offsetX < 200) {
        this.previewPost()
      } else {
        this.nextPost()
      }
    },
    quit: function () {
      this.$router.push({ name: 'home' })
    }
  },
  created: function () {
    this.$bus.$on('keyUpArrowLeft', this.previewPost)
    this.$bus.$on('keyUpArrowRight', this.nextPost)
    this.$bus.$on('keyUpBackspace', this.quit)
  },
  beforeDestroy: function () {
    this.$bus.$off('keyUpArrowLeft', this.previewPost)
    this.$bus.$off('keyUpArrowRight', this.nextPost)
    this.$bus.$off('keyUpBackspace', this.quit)
  }
}
</script>

<style scoped lang="scss">
.post{
  display: flex;
  align-items: center;
  justify-content: center;
  flex-direction: column;
  
  .post-title {
    padding-left: 12px;
    font-size: 18px;
    height: 18px;
    overflow: hidden;
  }

  .post-content{
    display: flex;
    width: 390px;
    height: 670px;
  }

  .post-video, .post-image{
    object-fit: contain;
    max-width: 100%;
    max-height: 100%;
    width: auto;
    height: auto;
  }
}


.loading{
  height: 100%;
  background-color: black;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  div {
    text-align: center;
    margin-bottom: 36px;
  }
}
</style>
