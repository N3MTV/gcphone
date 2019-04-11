<template>
  <div>
    <list :list='contactsList' :showHeader="false" v-on:select="onSelect"></list>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import { generateColorForStr } from '@/Utils'
import List from './../List.vue'

export default {
  name: 'Contacts',
  components: { List },
  data () {
    return {
    }
  },
  methods: {
    ...mapActions(['startCall']),
    onSelect (itemSelect) {
      if (itemSelect !== undefined) {
        if (itemSelect.custom === true) {
          this.$router.push({name: 'appels.number'})
        } else {
          this.startCall({ numero: itemSelect.number })
        }
      }
    }
  },
  computed: {
    ...mapGetters(['IntlString', 'contacts']),
    contactsList () {
      return [{
        display: this.IntlString('APP_PHONE_ENTER_NUMBER'),
        letter: '#',
        backgroundColor: '#D32F2F',
        custom: true
      }, ...this.contacts.slice(0).map(c => {
        c.backgroundColor = generateColorForStr(c.number)
        return c
      })]
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
