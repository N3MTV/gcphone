<template>
  <div class="phone_app">
    <PhoneTitle :title="IntlString('APP_DARKTCHAT_TITLE')" backgroundColor="#090f20" @back="onBack" />
    <div class="elements" @contextmenu.prevent="addChannelOption">
        <div class="element" v-for='(elem, key) in tchatChannels' 
          v-bind:key="elem.channel"
          v-bind:class="{ select: key === currentSelect}"
          @click.stop="showChannel(elem.channel)"
          >
            <div class="elem-title" @click.stop="showChannel(elem.channel)"><span class="diese">#</span> {{elem.channel}}</div>
        </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import Modal from '@/components/Modal/index.js'
import PhoneTitle from './../PhoneTitle'

export default {
  components: { PhoneTitle },
  data: function () {
    return {
      currentSelect: 0,
      ignoreControls: false
    }
  },
  watch: {
    list: function () {
      this.currentSelect = 0
    }
  },
  computed: {
    ...mapGetters(['IntlString', 'useMouse', 'tchatChannels', 'Apps'])
  },
  methods: {
    ...mapActions(['tchatAddChannel', 'tchatRemoveChannel']),
    scrollIntoViewIfNeeded () {
      this.$nextTick(() => {
        const $select = this.$el.querySelector('.select')
        if ($select !== null) {
          $select.scrollIntoViewIfNeeded()
        }
      })
    },
    onUp () {
      if (this.ignoreControls === true) return
      this.currentSelect = this.currentSelect === 0 ? 0 : this.currentSelect - 1
      this.scrollIntoViewIfNeeded()
    },
    onDown () {
      if (this.ignoreControls === true) return
      this.currentSelect = this.currentSelect === this.tchatChannels.length - 1 ? this.currentSelect : this.currentSelect + 1
      this.scrollIntoViewIfNeeded()
    },
    async onRight () {
      if (this.ignoreControls === true) return
      this.ignoreControls = true
      let choix = [
        {id: 1, title: this.IntlString('APP_DARKTCHAT_NEW_CHANNEL'), icons: 'fa-plus', color: 'green'},
        {id: 2, title: this.IntlString('APP_DARKTCHAT_DELETE_CHANNEL'), icons: 'fa-minus', color: 'orange'},
        {id: 3, title: this.IntlString('APP_DARKTCHAT_CANCEL'), icons: 'fa-undo'}
      ]
      if (this.tchatChannels.length === 0) {
        choix.splice(1, 1)
      }
      const rep = await Modal.CreateModal({ choix })
      this.ignoreControls = false
      switch (rep.id) {
        case 1:
          this.addChannelOption()
          break
        case 2:
          this.removeChannelOption()
          break
        case 3 :
      }
    },
    async onEnter () {
      if (this.ignoreControls === true) return
      if (this.tchatChannels.length === 0) {
        this.ignoreControls = true
        let choix = [
          {id: 1, title: this.IntlString('APP_DARKTCHAT_NEW_CHANNEL'), icons: 'fa-plus', color: 'green'},
          {id: 3, title: this.IntlString('APP_DARKTCHAT_CANCEL'), icons: 'fa-undo'}
        ]
        const rep = await Modal.CreateModal({ choix })
        this.ignoreControls = false
        if (rep.id === 1) {
          this.addChannelOption()
        }
      } else {
        const channel = this.tchatChannels[this.currentSelect].channel
        this.showChannel(channel)
      }
    },
    showChannel (channel) {
      this.$router.push({ name: 'tchat.channel.show', params: { channel } })
    },
    onBack () {
      if (this.ignoreControls === true) return
      this.$router.push({ name: 'home' })
    },
    async addChannelOption () {
      try {
        const rep = await Modal.CreateTextModal({limit: 20, title: this.IntlString('APP_DARKTCHAT_NEW_CHANNEL')})
        let channel = (rep || {}).text || ''
        channel = channel.toLowerCase().replace(/[^a-z]/g, '')
        if (channel.length > 0) {
          this.currentSelect = 0
          this.tchatAddChannel({ channel })
        }
      } catch (e) {}
    },
    async removeChannelOption () {
      const channel = this.tchatChannels[this.currentSelect].channel
      this.currentSelect = 0
      this.tchatRemoveChannel({ channel })
    }
  },
  created () {
    if (!this.useMouse) {
      this.$bus.$on('keyUpArrowDown', this.onDown)
      this.$bus.$on('keyUpArrowUp', this.onUp)
      this.$bus.$on('keyUpArrowRight', this.onRight)
      this.$bus.$on('keyUpEnter', this.onEnter)
      this.$bus.$on('keyUpBackspace', this.onBack)
    } else {
      this.currentSelect = -1
    }
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.list{
  height: 100%;
}
.title{
  padding-top: 22px;
  padding-left: 16px;
  height: 54px;
  line-height: 34px;
  font-weight: 700;
  color: white;
}

.elements{
  height: calc(100% - 54px);
  overflow-y: auto;
  background-color: #20201d;
  color: #a6a28c
}
.element{
  height: 42px;
  line-height: 42px;
  display: flex;
  align-items: center;
  position: relative;
}

.elem-title{
  margin-left: 6px;
  font-size: 20px;
  text-transform: capitalize;
  transition: .15s;
}
.elem-title .diese {
  color: #60ac39;
  font-size: 22px;
  font-weight: 700;
  line-height: 40px;
}

.element.select, .element:hover{
   background-color: #FFC629;
   color: black;
}
.element.select .elem-title, .element:hover .elem-title {
   margin-left: 12px;
}
.element.select .elem-title .diese, .element:hover .elem-title .diese {
   color:#5e0576;
}
 .elements::-webkit-scrollbar-track
    {
        box-shadow: inset 0 0 6px rgba(0,0,0,0.3);
        background-color: #F5F5F5;
    }
  .elements::-webkit-scrollbar
    {
        width: 3px;
        background-color: transparent;
    }
  .elements::-webkit-scrollbar-thumb
    {
        background-color: #FFC629;
    }
</style>
