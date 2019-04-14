<template>
  <div class="phone_app">
    <PhoneTitle :title="title" :showInfoBare="showInfoBare" v-if="showHeader" @back="back"/>
    <!-- <InfoBare v-if="showInfoBare"/>
    <div v-if="title !== ''" class="phone_title" v-bind:style="styleTitle()">{{title}}</div>
    -->
    <div class="phone_content elements">
        <div class="element" v-for='(elem, key) in list' 
          v-bind:key="elem[keyDispay]"
          v-bind:class="{ select: key === currentSelect}"
          @click.stop="selectItem(elem)"
          @contextmenu.prevent="optionItem(elem)"
          >
            <div class="elem-pic" v-bind:style="stylePuce(elem)" @click.stop="selectItem(elem)">
              {{elem.letter || elem[keyDispay][0]}}
            </div>
            <div @click.stop="selectItem(elem)" v-if="elem.puce !== undefined && elem.puce !== 0" class="elem-puce">{{elem.puce}}</div>
            <div @click.stop="selectItem(elem)" v-if="elem.keyDesc === undefined || elem.keyDesc === ''" class="elem-title">{{elem[keyDispay]}}</div>
            <div @click.stop="selectItem(elem)" v-if="elem.keyDesc !== undefined && elem.keyDesc !== ''" class="elem-title-has-desc">{{elem[keyDispay]}}</div>
            <div @click.stop="selectItem(elem)" v-if="elem.keyDesc !== undefined && elem.keyDesc !== ''" class="elem-description">{{elem.keyDesc}}</div>
        </div>
    </div>
  </div>
</template>

<script>
import PhoneTitle from './PhoneTitle'
import InfoBare from './InfoBare'
import { mapGetters } from 'vuex'

export default {
  name: 'hello',
  components: {
    PhoneTitle, InfoBare
  },
  data: function () {
    return {
      currentSelect: 0
    }
  },
  props: {
    title: {
      type: String,
      default: 'Title'
    },
    showHeader: {
      type: Boolean,
      default: true
    },
    showInfoBare: {
      type: Boolean,
      default: true
    },
    list: {
      type: Array,
      required: true
    },
    color: {
      type: String,
      default: '#FFFFFF'
    },
    backgroundColor: {
      type: String,
      default: '#4CAF50'
    },
    keyDispay: {
      type: String,
      default: 'display'
    },
    disable: {
      type: Boolean,
      default: false
    },
    titleBackgroundColor: {
      type: String,
      default: '#FFFFFF'
    }
  },
  watch: {
    list: function () {
      this.currentSelect = 0
    }
  },
  computed: {
    ...mapGetters(['useMouse'])
  },
  methods: {
    styleTitle: function () {
      return {
        color: this.color,
        backgroundColor: this.backgroundColor
      }
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
    },
    scrollIntoViewIfNeeded: function () {
      this.$nextTick(() => {
        document.querySelector('.select').scrollIntoViewIfNeeded()
      })
    },
    onUp: function () {
      if (this.disable === true) return
      this.currentSelect = this.currentSelect === 0 ? this.list.length - 1 : this.currentSelect - 1
      this.scrollIntoViewIfNeeded()
    },
    onDown: function () {
      if (this.disable === true) return
      this.currentSelect = this.currentSelect === this.list.length - 1 ? 0 : this.currentSelect + 1
      this.scrollIntoViewIfNeeded()
    },
    selectItem (item) {
      this.$emit('select', item)
    },
    optionItem (item) {
      this.$emit('option', item)
    },
    back () {
      this.$emit('back')
    },
    onRight: function () {
      if (this.disable === true) return
      this.$emit('option', this.list[this.currentSelect])
    },
    onEnter: function () {
      if (this.disable === true) return
      this.$emit('select', this.list[this.currentSelect])
    }
  },
  created: function () {
    if (!this.useMouse) {
      this.$bus.$on('keyUpArrowDown', this.onDown)
      this.$bus.$on('keyUpArrowUp', this.onUp)
      this.$bus.$on('keyUpArrowRight', this.onRight)
      this.$bus.$on('keyUpEnter', this.onEnter)
    } else {
      this.currentSelect = -1
    }
  },
  beforeDestroy: function () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpEnter', this.onEnter)
  }
}
</script>

<style scoped>
.list{
  height: 100%;
}


.elements{
  overflow-y: auto;
}

.element{
  height: 58px;
  line-height: 58px;
  display: flex;
  align-items: center;
  position: relative;
}

.element.select, .element:hover {
   background-color: #DDD;
}

.elem-pic{
  margin-left: 12px;
  height: 48px;
  width: 48px;
  text-align: center;
  line-height: 48px;
  font-weight: 700;
}
.elem-puce{
  background-color: red;
  color:white;
  height: 18px;
  width: 18px;
  line-height: 18px;
  border-radius: 50%;
  text-align: center;
  font-size: 14px;
  margin: 0px;
  padding: 0px;
  position: absolute;
  left: 42px;
  top: 36px;
  z-index: 6;
}
.elem-title{
  margin-left: 12px;
}
.elem-title-has-desc {
  margin-top:-15px;
  margin-left: 12px;
}
.elem-description{
  text-align:left;
  color:grey;
  position:absolute;
  display:block;
  width:75%;
  left:73px;
  top:12px;
  font-size:13.5px;
  font-style:italic;
  overflow:hidden;
  text-overflow:ellipsis;
  white-space: nowrap;
}
</style>
