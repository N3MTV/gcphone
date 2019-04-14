<template>
  <div class="phone_title_content" :style="style" :class="{'hasInfoBare': showInfoBare}" >
    <InfoBare v-if="showInfoBare" />
    <div class="phone_title" :style="{backgroundColor: backgroundColor}">
      <button class="btn-back" @click.stop="back"><i class="fa fa-arrow-left" @click.stop="back"></i></button>
      {{title}}
    </div>
  </div>
</template>
<script>
import { mapGetters } from 'vuex'
import InfoBare from './InfoBare'

export default {
  components: {
    InfoBare
  },
  computed: {
    ...mapGetters(['themeColor']),
    style () {
      return {
        backgroundColor: this.backgroundColor || this.themeColor,
        color: this.color || '#FFF'
      }
    }
  },
  methods: {
    back () {
      this.$emit('back')
    }
  },
  props: {
    title: {
      type: String,
      required: true
    },
    showInfoBare: {
      type: Boolean,
      default: true
    },
    backgroundColor: {
      type: String
    }
  }
}
</script>
<style scoped>
</style>
