<template>
  <div class="list">
    <div class="title" v-bind:style="classTitle()">{{title}}</div>
    <div class="elements">
        <div class="element" v-for='(elem, key) in list' 
          v-bind:key="elem[keyDispay]"
          v-bind:class="{ select: key === currentSelect}"
          >
            <div class="elem-pic" v-bind:style="classTitle(elem)">
              {{elem.letter || elem[keyDispay][0]}}
            </div>
            <div v-if="elem.puce !== undefined && elem.puce !== 0" class="elem-puce">{{elem.puce}}</div>
            <div class="elem-title">{{elem[keyDispay]}}</div>
        </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'hello',
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
    }
  },
  watch: {
    list: function () {
      this.currentSelect = 0
    }
  },
  computed: {
  },
  methods: {
    classTitle: function (data) {
      data = data || {}
      return {
        color: data.color || this.color,
        backgroundColor: data.backgroundColor || this.backgroundColor
      }
    },
    scrollIntoViewIfNeeded: function () {
      this.$nextTick(() => {
        document.querySelector('.select').scrollIntoViewIfNeeded()
      })
    },
    onUp: function () {
      if (this.disable === true) return
      this.currentSelect = this.currentSelect === 0 ? 0 : this.currentSelect - 1
      this.scrollIntoViewIfNeeded()
    },
    onDown: function () {
      if (this.disable === true) return
      this.currentSelect = this.currentSelect === this.list.length - 1 ? this.currentSelect : this.currentSelect + 1
      this.scrollIntoViewIfNeeded()
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
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpArrowRight', this.onRight)
    this.$bus.$on('keyUpEnter', this.onEnter)
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
.title{
    padding-left: 16px;
    height: 34px;
    line-height: 34px;
    font-weight: 700;
}

.elements{
  height: calc(100% - 34px);
  overflow-y: auto;
}
.element{
    height: 40px;
    line-height: 40px;
    display: flex;
    align-items: center;
    position: relative;
}

.element.select{
   background-color: #DDD;
}

.elem-pic{
    margin-left: 6px;
    height: 32px;
    width: 32px;
    text-align: center;
    line-height: 32px;
    font-weight: 700;
    border-radius: 50%;
}
.elem-puce{
  background-color: red;
  color:white;
  height: 12px;
  width: 12px;
  line-height: 12px;
  border-radius: 50%;
  text-align: center;
  font-size: 8px;
  margin: 0px;
  padding: 0px;
  position: absolute;
  left: 27px;
  top: 23px;
  z-index: 6;
}
.elem-title{
  margin-left: 6px;
}
</style>
