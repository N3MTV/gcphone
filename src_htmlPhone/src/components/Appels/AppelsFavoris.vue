<template>
  <div>
    <list :list='callList' :showHeader="false" :disable='ignoreControls' v-on:select="onSelect"></list>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import List from './../List.vue'
import Modal from '@/components/Modal/index.js'

export default {
  name: 'Favoris',
  components: { List },
  data () {
    return {
      ignoreControls: false
    }
  },
  computed: {
    ...mapGetters(['config']),
    callList () {
      return this.config.serviceCall || []
    }
  },
  methods: {
    onSelect (itemSelect) {
      if (this.ignoreControls === true) return
      this.ignoreControls = true
      Modal.CreateModal({choix: [...itemSelect.subMenu, {title: 'Retour'}]}).then(rep => {
        this.ignoreControls = false
        if (rep.title === 'Retour') return
        this.$router.push({ name: 'messages.view', params: { number: itemSelect.subMenu[0].type.number, display: itemSelect.display } })
      })
    }
  },

  created () {
  },

  beforeDestroy () {
  }
}
</script>

<style scoped>

</style>
