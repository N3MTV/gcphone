<template>
<transition name="modal">
    <div
      class="modal-mask"
      >
        <div class="modal-container" @click.stop >
          <h2 :style="{color}">{{ title }}</h2>
          <textarea 
            class="modal-textarea"
            :class="{oneline: limit <= 18}"
            ref="textarea"
            :style="{borderColor: color}"
            v-model="inputText"
            :maxlength="limit"
          ></textarea>
          <div class="botton-container">
            <button
              :style="{color}"
              @click="cancel"
            >
              {{ IntlString('CANCEL') }}
            </button>
            <button
              :style="{color}"
              @click="valide"
            >
              {{ IntlString('OK') }}
            </button>
          </div>

        </div>
    </div>
  </transition>
</template>

<script>
import store from './../../store'
import { mapGetters } from 'vuex'

export default {
  name: 'TextModal',
  store: store,
  data () {
    return {
      inputText: ''
    }
  },
  props: {
    title: {
      type: String,
      default: () => ''
    },
    text: {
      type: String,
      default: () => ''
    },
    limit: {
      type: Number,
      default: 255
    }
  },
  computed: {
    ...mapGetters(['IntlString', 'themeColor']),
    color () {
      return this.themeColor || '#2A56C6'
    }
  },
  methods: {
    scrollIntoViewIfNeeded () {
      this.$nextTick(() => {
        document.querySelector('.modal-choix.select').scrollIntoViewIfNeeded()
      })
    },
    onUp () {
      this.currentSelect = this.currentSelect === 0 ? 0 : this.currentSelect - 1
      this.scrollIntoViewIfNeeded()
    },
    onDown () {
      this.currentSelect = this.currentSelect === this.choix.length - 1 ? this.currentSelect : this.currentSelect + 1
      this.scrollIntoViewIfNeeded()
    },
    selectItem (elem) {
      this.$emit('select', elem)
    },
    onEnter () {
      this.$emit('select', this.choix[this.currentSelect])
    },
    cancel () {
      this.$emit('cancel')
    },
    valide () {
      this.$emit('valid', {
        text: this.inputText
      })
    }
  },
  created () {
    this.inputText = this.text
  },
  mounted () {
    this.$nextTick(() => {
      this.$refs.textarea.focus()
    })
  },
  beforeDestroy () {
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
        align-items: center;
        justify-content: center;
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
        width: 90%;
        overflow-y: auto;
        padding: 15px 20px;
        font-size: 18px;
    }

    h2 {
      font-size: 22px;
    }

    .modal-textarea {
      width: 100%;
      height: 140px;
      border: none;
      resize: none;
      border-bottom: 3px solid red;
      outline: none;
      font-size: 18px;
    }
    .modal-textarea.oneline {
      height: 38px;
    }


    .botton-container {
      margin-top: 12px;
      display: flex;
      justify-content: flex-end;
    }

    .botton-container button {
      background-color: transparent;
      border: none;
      font-size: 18px;
      font-weight: 700;
      padding: 6px 12px;
      outline: none;
    }
    .botton-container button:hover {
      background-color: rgba(0, 0, 0, .1);
    }



</style>
