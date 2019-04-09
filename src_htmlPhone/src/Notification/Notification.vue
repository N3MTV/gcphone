<template>
  <div class="notifications">
    <div
      v-for='notif in list'
      :key="notif.id"
      class="notification"
      :style="style(notif)"
    >
      <div class="title">
        <i v-if="notif.icon" class="fa" :class="'fa-' + notif.icon"/> {{notif.title}}
      </div>
      <div class="message">{{notif.message}}</div>
    </div>
  </div>
</template>

<script>
import events from './events'

export default {
  data () {
    return {
      currentId: 0,
      list: []
    }
  },
  mounted () {
    events.$on('add', this.addItem)
  },
  methods: {
    async addItem (event = {}) {
      const dataNotif = {
        ...event,
        id: this.currentId ++,
        duration: parseInt(event.duration) || 3000
      }
      this.list.push(dataNotif)
      window.setTimeout(() => {
        this.destroy(dataNotif.id)
      }, dataNotif.duration)
      if (event.sound !== null && event.sound !== undefined) {
        const audio = new Audio('/html/static/sound/' + event.sound)
        audio.addEventListener('ended', () => {
          audio.src = null
        })
        audio.play()
      }
    },
    style (notif) {
      return {
        backgroundColor: notif.backgroundColor
      }
    },
    destroy (id) {
      this.list = this.list.filter(n => n.id !== id)
    }
  }
}
</script>

<style scoped>
  .notification {
    width: 450px;
    background-color: rgba(29, 161, 242, 0.6);
    color: white;
    padding: 8px 16px;
    margin-bottom: 8px;
    border-radius: 6px;
  }
  .title {
    font-size: 18px;
  }
  .message {
    font-size: 16px;
  }
</style>
