<template>
  <div class="phone_app">
    <div class="elements">
        <div class="element" :class="{'active': selectIndex === key}" v-for='(histo, key) in historique' :key="key"
          @click.stop="selectItem(histo)"
          >
            <div @click.stop="selectItem(histo)" class="elem-pic" :style="stylePuce(histo)">{{histo.letter}}</div>
            <div @click.stop="selectItem(histo)" class="elem-content">
              <div @click.stop="selectItem(histo)" class="elem-content-p">{{histo.display}}</div>
              <div @click.stop="selectItem(histo)" class="elem-content-s">
                <div 
                    @click.stop="selectItem(histo)"
                    class="elem-histo-pico" 
                    :class="{'reject': hc.accept === false}" 
                    v-for="(hc, i) in histo.lastCall" :key="i">
                    <svg @click.stop="selectItem(histo)" v-if="hc.accepts === 1 && hc.incoming === 1" viewBox="0 0 24 24" fill="#43a047">
                      <path d="M9,5v2h6.59L4,18.59L5.41,20L17,8.41V15h2V5H9z"/>
                    </svg>
                    <svg @click.stop="selectItem(histo)" v-else-if="hc.accepts === 1 && hc.incoming === 0" viewBox="0 0 24 24" fill="#43a047">
                      <path d="M20,5.41L18.59,4L7,15.59V9H5v10h10v-2H8.41L20,5.41z"/>
                    </svg>
                    <svg @click.stop="selectItem(histo)" v-else-if="hc.accepts === 0 && hc.incoming === 1" viewBox="0 0 24 24" fill="#D32F2F">
                      <path @click.stop="selectItem(histo)" d="M3,8.41l9,9l7-7V15h2V7h-8v2h4.59L12,14.59L4.41,7L3,8.41z"/>
                    </svg>
                    <svg @click.stop="selectItem(histo)" v-else-if="hc.accepts === 0 && hc.incoming === 0" viewBox="0 0 24 24" fill="#D32F2F">
                      <path d="M19.59,7L12,14.59L6.41,9H11V7H3v8h2v-4.59l7,7l9-9L19.59,7z"/>
                    </svg>
                </div>
                
                <div v-if="histo.lastCall.length !==0" class="lastCall">
                  <timeago :since='histo.lastCall[0].date' :auto-update="20"></timeago>
                </div>
              </div>
            </div>
            <div class="elem-icon" @click.stop="selectItem(histo)">
              <i class="fa fa-phone" @click.stop="selectItem(histo)"></i>
            </div>
        </div>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import { groupBy, generateColorForStr } from '@/Utils'
import Modal from '@/components/Modal/index.js'

export default {
  name: 'Recents',
  components: {},
  data () {
    return {
      ignoreControls: false,
      selectIndex: 0
    }
  },
  methods: {
    ...mapActions(['startCall', 'appelsDeleteHistorique', 'appelsDeleteAllHistorique']),
    getContact (num) {
      const find = this.contacts.find(e => e.number === num)
      return find
    },
    scrollIntoViewIfNeeded: function () {
      this.$nextTick(() => {
        this.$el.querySelector('.active').scrollIntoViewIfNeeded()
      })
    },
    onUp () {
      if (this.ignoreControls === true) return
      this.selectIndex = Math.max(0, this.selectIndex - 1)
      this.scrollIntoViewIfNeeded()
    },
    onDown () {
      if (this.ignoreControls === true) return
      this.selectIndex = Math.min(this.historique.length - 1, this.selectIndex + 1)
      this.scrollIntoViewIfNeeded()
    },
    async selectItem (item) {
      const numero = item.num
      const isValid = numero.startsWith('#') === false
      this.ignoreControls = true
      let choix = [
        {id: 1, title: this.IntlString('APP_PHONE_DELETE'), icons: 'fa-trash', color: 'orange'},
        {id: 2, title: this.IntlString('APP_PHONE_DELETE_ALL'), icons: 'fa-trash', color: 'red'},
        {id: 3, title: this.IntlString('CANCEL'), icons: 'fa-undo'}
      ]
      if (isValid === true) {
        choix = [{id: 0, title: this.IntlString('APP_PHONE_CALL'), icons: 'fa-phone'}, ...choix]
      }
      const rep = await Modal.CreateModal({ choix })
      this.ignoreControls = false
      switch (rep.id) {
        case 0:
          this.startCall({ numero })
          break
        case 1:
          this.appelsDeleteHistorique({ numero })
          break
        case 2 :
          this.appelsDeleteAllHistorique()
      }
    },
    async onEnter () {
      if (this.ignoreControls === true) return
      this.selectItem(this.historique[this.selectIndex])
    },
    stylePuce (data) {
      data = data || {}
      if (data.icon !== undefined) {
        return {
          backgroundImage: `url(${data.icon})`,
          backgroundSize: 'cover',
          color: 'rgba(0,0,0,0)'
        }
      }
      return {
        color: data.color || this.color,
        backgroundColor: data.backgroundColor || this.backgroundColor,
        borderRadius: '50%'
      }
    }
  },
  computed: {
    ...mapGetters(['IntlString', 'useMouse', 'appelsHistorique', 'contacts']),
    historique () {
      let grpHist = groupBy(this.appelsHistorique, 'num')
      let hist = []
      for (let key in grpHist) {
        const hg = grpHist[key]
        const histoByDate = hg.map(e => {
          e.date = new Date(e.time)
          return e
        }).sort((a, b) => {
          return b.date - a.date
        }).slice(0, 6)
        const contact = this.getContact(key) || { letter: '#' }
        hist.push({
          num: key,
          display: contact.display || key,
          lastCall: histoByDate,
          letter: contact.letter || contact.display[0],
          backgroundColor: contact.backgroundColor || generateColorForStr(key),
          icon: contact.icon
        })
      }
      hist.sort((a, b) => {
        return b.lastCall[0].time - a.lastCall[0].time
      })
      return hist
    }
  },
  created () {
    if (!this.useMouse) {
      this.$bus.$on('keyUpArrowDown', this.onDown)
      this.$bus.$on('keyUpArrowUp', this.onUp)
      this.$bus.$on('keyUpEnter', this.onEnter)
    } else {
      this.selectIndex = -1
    }
  },
  beforeDestroy () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
  }
}
</script>

<style scoped>
  .content {
    height: 100%;
  }
  .elements {
    overflow-y: auto;
  }
  .element{
    height: 58px;
    line-height: 58px;
    display: flex;
    align-items: center;
    position: relative;
    margin: 14px 10px;
    border-radius: 2px;
    box-shadow: 0 2px 2px 0 rgba(0,0,0,.14), 0 3px 1px -2px rgba(0,0,0,.2), 0 1px 5px 0 rgba(0,0,0,.12);
  }
  .active, .element:hover {
    background: radial-gradient(rgba(3, 168, 244, 0.14), rgba(3, 169, 244, 0.26));
  }
  .elem-pic{
    margin-left: 12px;
    height: 48px;
    width: 48px;
    text-align: center;
    line-height: 48px;
    font-weight: 700;
    border-radius: 50%;
    color: white;
  }

  .elem-content{
    margin-left: 12px;
    width: auto;
    flex-grow: 1
  }

  .elem-content-p{
    font-size: 20px;
    line-height: 20px;
  }
   .elem-content-s{
    font-size: 12px;
    line-height: 18px;
    width: 100%;
    display: flex;
  }
  .elem-histo-pico {
    display: flex;
    flex-direction: column;
  }
  .elem-histo-pico svg {
    width: 16px;
    height: 16px;
  }
  .lastCall {
    padding-left: 4px;
  }
  .elem-icon{
    width: 28px;
  }
</style>
