<template>
  <div class="urgenceOnly">
      <div class="title">MODE URGENCE</div>
      <p>Vous ne pouvez contacter que les services publique</p>
      <button class='btn' v-for='(but,key) in buttons' :key='key' v-bind:class="{ select: key === currentSelect}">
        {{but.title}}
      </button>
  </div>
</template>

<script>
import request from './../request'
import CurrentTime from './CurrentTime'
import Modal from '@/components/Modal/index.js'

export default {
  components: {
    CurrentTime
  },
  data () {
    return {
      buttons: [{
        title: 'Ambulance',
        eventName: 'ambulancier:callAmbulancier',
        type: 'Coma'
      }, {
      //   title: 'Police',
      //   eventName: 'police:callPolice',
      //   type: 'Homme à terre'
      // }, {
        title: 'Hopital',
        eventName: 'ambulancier:selfRespawn'
      }],
      currentSelect: 0,
      ignoreControls: false
    }
  },
  methods: {
    onUp: function () {
      if (this.ignoreControls === true) return
      this.currentSelect = this.currentSelect === 0 ? this.buttons.length - 1 : this.currentSelect - 1
    },
    onDown: function () {
      if (this.ignoreControls === true) return
      this.currentSelect = this.currentSelect === this.buttons.length - 1 ? 0 : this.currentSelect + 1
    },
    onEnter: function () {
      if (this.ignoreControls === true) return
      let btn = this.buttons[this.currentSelect]
      if (btn.eventName === 'ambulancier:selfRespawn') {
        this.ignoreControls = true
        let choix = [{title: 'Annuler'}, {title: 'Annuler'}, {title: 'RESPAWN', color: 'red'}, {title: 'Annuler'}, {title: 'Annuler'}]
        Modal.CreateModal({choix}).then(reponse => {
          this.ignoreControls = false
          if (reponse.title === 'RESPAWN') {
            request.callEvent(btn.eventName, btn.type)
            request.closePhone()
          }
        })
      } else {
        request.callEvent(btn.eventName, btn.type)
        request.closePhone()
      }
    },
    onBack: function () {
      if (this.ignoreControls === true) return
      request.closePhone()
    }
  },
  created: function () {
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  beforeDestroy: function () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.urgenceOnly{
  position: relative;
  left: 0;
  top: 0;
  width: 100%;
  height: 100%;
  display: flex;
  background-color: #273238;
  flex-flow: column;
  flex-wrap: nowrap;
  align-items: center;
  justify-content: flex-start;
}

.title{
  margin-top: 20px;
  color: #E53935;
  background-color: white;
  padding: 5px 20px;
}
p {
  margin-top: 0;
  padding: 8px 36px;
  font-size: .6em;
  color: #C0C0C0;
  text-align: center;
}
button{
  border: none;
  width: 80%;
  height: 24px;
  background-color: #7f8c8d;
  color: white;
  margin-top: 24px;
}

button.select{
  background-color: #E53935;
}
</style>
