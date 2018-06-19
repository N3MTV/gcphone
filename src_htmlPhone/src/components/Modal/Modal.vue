<template>
<transition name="modal">
    <div class="modal-mask">

        <div class="modal-container">
            <div class="modal-choix" 
              v-bind:class="{ select: index === currentSelect}" 
              v-for="(val, index) in choix" :key='index'
              v-bind:style="{color: val.color}">
                <i class="fa" :class="val.icons" ></i>{{val.title}}
            </div>
          

        </div>
    </div>
  </transition>
</template>

<script>
export default {
  name: 'Modal',
  data: function () {
    return {
      currentSelect: 0
    }
  },
  props: {
    choix: {
      type: Array,
      default: function () {
        return []
      }
    }
  },
  methods: {
    scrollIntoViewIfNeeded: function () {
      this.$nextTick(() => {
        document.querySelector('.modal-choix.select').scrollIntoViewIfNeeded()
      })
    },
    onUp: function () {
      this.currentSelect = this.currentSelect === 0 ? 0 : this.currentSelect - 1
      this.scrollIntoViewIfNeeded()
    },
    onDown: function () {
      this.currentSelect = this.currentSelect === this.choix.length - 1 ? this.currentSelect : this.currentSelect + 1
      this.scrollIntoViewIfNeeded()
    },
    onEnter: function () {
      this.$emit('select', this.choix[this.currentSelect])
    },
    cancel: function () {
      this.$emit('cancel')
    }
  },
  created: function () {
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.cancel)
  },
  beforeDestroy: function () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.cancel)
  }
}
</script>

<style scoped>
    .modal-mask {
        position: absolute;
        z-index: 99;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background-color: rgba(0, 0, 0, .3);
        display: flex;
        align-items: flex-end;
        transition: opacity .3s ease;
    }

    .modal-container {
        width: 100%;
        margin: 0;
        padding: 0;
        background-color: #fff;
        border-radius: 2px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, .33);
        transition: all .3s ease;
        padding-bottom: 16px;
        max-height: 100%;
        overflow-y: auto;
    }

    .modal-title {
        text-align: center;
        height: 32px;
        line-height: 32px;
        color: #42B2DC;
        border-bottom: 2px solid #42B2DC;
    }
    .modal-choix {
        height: 56px;
        line-height: 56px;
        color: gray;
        position: relative;
        font-weight: 400;
        font-size: 22px;
    }
    .modal-choix .fa {
        font-size: 18px;
        line-height: 24px;
        margin-left: 12px;
        margin-right: 12px;
    }
    .modal-choix .picto {
        z-index: 500;
        position: absolute;
        width: 42px;
        background-size: 100% !important;
        background-position-y: 100%;
        height: 42px;
    }
    .modal-choix.select {
        background-color: #E3E3E3;
        color: #42B2DC;
    }



</style>
