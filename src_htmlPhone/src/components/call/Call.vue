<template>
  <div class="screen">
    <list :list='callList' title="Téléphone" :disable='ignoreControls' v-on:select="onSelect"></list>
  </div>
</template>

<script>
import List from './../List.vue'
import request from '../../request'
import Modal from '@/components/Modal/index.js'

export default {
  components: {
    List
  },
  data () {
    return {
      title: 'Téléphone',
      ignoreControls: false,
      callList: [{
        display: 'Police',
        subMenu: [
          {title: 'Signaler un vol', eventName: 'police:callPolice', type: 'Vole'},
          {title: 'Signaler une agression', eventName: 'police:callPolice', type: 'Aggression'},
          {title: 'Autre', eventName: 'police:callPoliceCustom'},
          {title: 'Annuler l\'appel en cour', color: 'orange', eventName: 'police:cancelCall'}
        ]
      }, {
        display: 'Ambulance',
        subMenu: [
          {title: 'Appel Coma', eventName: 'ambulancier:callAmbulancier', type: 'Coma'},
          {title: 'Appel ambulance', eventName: 'ambulancier:callAmbulancier', type: 'Soin'},
          {title: 'Respawn', eventName: 'ambulancier:selfRespawn'},
          {title: 'Annuler l\'appel en cour', color: 'orange', eventName: 'ambulancier:cancelCall'}
        ]
      }, {
        display: 'Taxi',
        subMenu: [
          {title: '1 personne', eventName: 'taxi:callService', type: '1 personne'},
          {title: '2 personnes', eventName: 'taxi:callService', type: '2 personnes'},
          {title: '3 personnes', eventName: 'taxi:callService', type: '3 personnes'},
          {title: 'Annuler l\'appel en cour', color: 'orange', eventName: 'taxi:cancelCall'}
        ]
      }, {
        display: 'Mecano',
        subMenu: [
          {title: 'Moto', eventName: 'mecano:callMecano', type: 'Moto'},
          {title: 'Voiture', eventName: 'mecano:callMecano', type: 'Voiture'},
          {title: 'Camionnette', eventName: 'mecano:callMecano', type: 'Camionnette'},
          {title: 'Camion', eventName: 'mecano:callMecano', type: 'Camion'},
          {title: 'Annuler l\'appel en cour', color: 'orange', eventName: 'mecano:cancelCall'}
        ]
      }]
    }
  },
  methods: {
    onSelect: function (call) {
      if (this.ignoreControls === true) return
      this.ignoreControls = true
      Modal.CreateModal({choix: [...call.subMenu, {title: 'Retour'}]}).then(rep => {
        this.ignoreControls = false
        if (rep.title === 'Retour') return
        request.callEvent(rep.eventName, rep.type)
      })
    },
    onBackspace: function () {
      if (this.ignoreControls === true) return
      history.back()
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
}
</style>
