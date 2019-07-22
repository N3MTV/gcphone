<template>
  <div class="phone_app">
    <PhoneTitle :title="IntlString('APP_IRC_TITLE')" backgroundColor="#0c0c0c" @back="onBack" />
    <div class="elements">
      <button class="button" @click.stop="addChannelOption"><i class="fa fa-plus" @click.stop="addChannelOption"></i></button>
      <div class="element"  @contextmenu.prevent="onRight(elem.channel)" v-for='(elem, key) in ircChannels' 
        v-bind:key="elem.channel"
        v-bind:class="{ select: key === currentSelect}"
        @click.stop="showChannel(elem.channel, elem.joined)"
        >
          <div class="elem-title" @click.stop="showChannel(elem.channel)" @contextmenu.prevent="onRight(elem.channel)"><span class="diese" @click.stop="showChannel(elem.channel)" @contextmenu.prevent="onRight(elem.channel)">#</span> {{elem.channel}} <span class="joined" @click.stop="showChannel(elem.channel)" @contextmenu.prevent="onRight(elem.channel)">- joined {{formatTime(elem.joined)}}</span></div>
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
    ...mapGetters(['IntlString', 'useMouse', 'ircChannels', 'Apps'])
  },
  methods: {
    ...mapActions(['ircAddChannel', 'ircRemoveChannel']),
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
      this.currentSelect = this.currentSelect === this.ircChannels.length - 1 ? this.currentSelect : this.currentSelect + 1
      this.scrollIntoViewIfNeeded()
    },
    async onRight (channel) {
      if (this.ignoreControls === true) return
      this.ignoreControls = true
      let choix = [
        {id: 1, title: this.IntlString('APP_IRC_NEW_CHANNEL'), icons: 'fa-plus', color: 'green'},
        {id: 2, title: this.IntlString('APP_IRC_DELETE_CHANNEL'), icons: 'fa-minus', color: 'orange'},
        {id: 3, title: this.IntlString('APP_IRC_CANCEL'), icons: 'fa-undo'}
      ]
      if (this.ircChannels.length === 0) {
        choix.splice(1, 1)
      }
      const rep = await Modal.CreateModal({ choix })
      this.ignoreControls = false
      switch (rep.id) {
        case 1:
          this.addChannelOption()
          break
        case 2:
          this.removeChannelOption(channel)
          break
        case 3 :
      }
    },
    async onEnter () {
      if (this.ignoreControls === true) return
      if (this.ircChannels.length === 0) {
        this.ignoreControls = true
        let choix = [
          {id: 1, title: this.IntlString('APP_IRC_NEW_CHANNEL'), icons: 'fa-plus', color: 'green'},
          {id: 3, title: this.IntlString('APP_IRC_CANCEL'), icons: 'fa-undo'}
        ]
        const rep = await Modal.CreateModal({ choix })
        this.ignoreControls = false
        if (rep.id === 1) {
          this.addChannelOption()
        }
      } else {
        const channel = this.ircChannels[this.currentSelect].channel
        this.showChannel(channel)
      }
    },
    showChannel (channel, time) {
      this.$router.push({ name: 'irc.channel.show', params: { channel } })
    },
    onBack () {
      if (this.ignoreControls === true) return
      this.$router.push({ name: 'home' })
    },
    formatTime (time) {
      let d = new Date()
      if (time != null) {
        d = new Date(time)
      }
      return d.toLocaleDateString()
    },
    async addChannelOption () {
      try {
        const rep = await Modal.CreateTextModal({limit: 20, title: this.IntlString('APP_IRC_NEW_CHANNEL')})
        let channel = (rep || {}).text || ''
        channel = channel.toLowerCase()
        if (channel.length > 0) {
          // this.currentSelect = 0
          this.ircAddChannel({ channel })
        }
      } catch (e) {}
    },
    async removeChannelOption (channel) {
      // this.currentSelect = 0
      this.ircRemoveChannel({ channel })
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

<style lang="scss" scoped>
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

.elements {
  height: calc(100% - 54px);
  overflow-y: auto;
  background-color: #1ec2a0;
  color: #ffffff;

  .element {
    height: 55px;
    line-height: 55px;
    display: flex;
    align-items: center;
    position: relative;

    .elem-title {
      margin-left: 15px;
      font-size: 20px;
      transition: .15s;
    }

    .elem-title .diese {
      color: #0c0c0c;
      font-size: 22px;
      font-weight: 700;
      line-height: 40px;
    }

    .joined {
      color: #0c0c0c;
      font-size: 12px;
      height: 30px;
      display: none;
    }
  }

  .element.select, .element:hover {
    background-color: #10725e;
    transition: all ease-in 0.15s;
    cursor: pointer;

    .joined {
      display: inline;
    }
  }

  .element.select .elem-title, .element:hover .elem-title {
    margin-left: 25px;
  }

  .elements::-webkit-scrollbar-track {
    background-color: #F5F5F5;
  }

  .elements::-webkit-scrollbar {
    width: 3px;
    background-color: transparent;
  }

  .elements::-webkit-scrollbar-thumb {
    background-color: #0c0c0c;
  }
}

.button:hover {
  background-color: rgba(255, 255, 255, 0.3);
  color: white;
}

.button {
  width: 42px;
  height: 42px;
  line-height: 42px;
  border-radius: 50%;
  background-color: transparent;
  border: none;
  margin: 0;
  padding: 0;
  position: absolute;
  right: 16px;
  top: 35px;
  color: rgba(255, 255, 255, 0.7);
  outline: none;
  text-shadow: none;
  text-align: center;
}
</style>
