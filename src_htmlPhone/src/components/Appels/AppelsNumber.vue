

<template>
   <div class="phone_app">
    <PhoneTitle :title="IntlString('APP_PHONE_TITLE')" @back="quit" />
    <div class="content">
      <div class="number">
        {{ numeroFormat }}
        <span class="deleteNumber" @click.stop="deleteNumber"></span>
      </div>

      <div class="keyboard">
        <div
          class="key"
          v-for="(key, i) of keyInfo" :key="key.primary"
          :class="{'key-select': i === keySelect, 'keySpe': key.isNotNumber === true}"
          @click.stop="onPressKey(key)"
        >
          <span @click.stop="onPressKey(key)" class="key-primary">{{key.primary}}</span>
          <span @click.stop="onPressKey(key)" class="key-secondary">{{key.secondary}}</span>
        </div>
      </div>

      <div class="call">
        <div class="call-btn" :class="{'active': keySelect === 12}"
          @click.stop="onPressCall">
        <svg viewBox="0 0 24 24" @click.stop="onPressCall">
          <g transform="rotate(0, 12, 12)">
          <path d="M6.62,10.79C8.06,13.62 10.38,15.94 13.21,17.38L15.41,15.18C15.69,14.9 16.08,14.82 16.43,14.93C17.55,15.3 18.75,15.5 20,15.5A1,1 0 0,1 21,16.5V20A1,1 0 0,1 20,21A17,17 0 0,1 3,4A1,1 0 0,1 4,3H7.5A1,1 0 0,1 8.5,4C8.5,5.25 8.7,6.45 9.07,7.57C9.18,7.92 9.1,8.31 8.82,8.59L6.62,10.79Z"/>
            </g>
        </svg>
        </div>
      </div>

    </div>
   </div>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'
import PhoneTitle from './../PhoneTitle'
export default {
  components: {
    PhoneTitle
  },
  data () {
    return {
      numero: '',
      keyInfo: [
        {primary: '1', secondary: ''},
        {primary: '2', secondary: 'abc'},
        {primary: '3', secondary: 'def'},
        {primary: '4', secondary: 'ghi'},
        {primary: '5', secondary: 'jkl'},
        {primary: '6', secondary: 'mmo'},
        {primary: '7', secondary: 'pqrs'},
        {primary: '8', secondary: 'tuv'},
        {primary: '9', secondary: 'wxyz'},
        {primary: '✲', secondary: '', isNotNumber: true},
        {primary: '0', secondary: '+'},
        {primary: '#', secondary: '', isNotNumber: true}
      ],
      keySelect: 0
    }
  },
  methods: {
    ...mapActions(['startCall']),
    onLeft () {
      this.keySelect = Math.max(this.keySelect - 1, 0)
    },
    onRight () {
      this.keySelect = Math.min(this.keySelect + 1, 11)
    },
    onDown () {
      this.keySelect = Math.min(this.keySelect + 3, 12)
    },
    onUp () {
      if (this.keySelect > 2) {
        if (this.keySelect === 12) {
          this.keySelect = 10
        } else {
          this.keySelect = this.keySelect - 3
        }
      }
    },
    onEnter () {
      if (this.keySelect === 12) {
        if (this.numero.length > 0) {
          this.startCall({ numero: this.numeroFormat })
        }
      } else {
        this.numero += this.keyInfo[this.keySelect].primary
      }
    },
    onBackspace: function () {
      if (this.ignoreControls === true) return
      if (this.numero.length !== 0) {
        this.numero = this.numero.slice(0, -1)
      } else {
        history.back()
      }
    },
    deleteNumber () {
      if (this.numero.length !== 0) {
        this.numero = this.numero.slice(0, -1)
      }
    },
    onPressKey (key) {
      this.numero = this.numero + key.primary
    },
    onPressCall () {
      this.startCall({ numero: this.numeroFormat })
    },
    quit () {
      history.back()
    }
  },

  computed: {
    ...mapGetters(['IntlString', 'useMouse', 'useFormatNumberFrance']),
    numeroFormat () {
      if (this.useFormatNumberFrance === true) {
        return this.numero
      }
      const l = this.numero.startsWith('#') ? 4 : 3
      if (this.numero.length > l) {
        return this.numero.slice(0, l) + '-' + this.numero.slice(l)
      } else {
        return this.numero
      }
    }
  },

  created () {
    if (!this.useMouse) {
      this.$bus.$on('keyUpBackspace', this.onBackspace)
      this.$bus.$on('keyUpArrowLeft', this.onLeft)
      this.$bus.$on('keyUpArrowRight', this.onRight)
      this.$bus.$on('keyUpArrowDown', this.onDown)
      this.$bus.$on('keyUpArrowUp', this.onUp)
      this.$bus.$on('keyUpEnter', this.onEnter)
    } else {
      this.keySelect = -1
    }
  },
  beforeDestroy () {
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
  }
}
</script>

<style scoped>


.number{
  margin-top: 140px;
  width: 100%;
  height: 52px;
  font-size: 26px;
  line-height: 52px;
  text-align: right;
  padding-right: 8px;
  border-bottom: 1px solid #C0C0C0;
  margin-bottom: 8px;
  box-shadow: 0px -6px 12px 0px rgba(189,189,189,0.4);
  position: relative;
  padding-right: 60px;
}
.keyboard {
  display: flex;
  flex-wrap: wrap;
  width: 100%;
}
.key {
  position: relative;
  flex: 1 1 33.33%;
  text-align: center;
  height: 96px;
}

.key-select::after, .key:hover::after {
  content: '';
  position: absolute;
  top: calc(50% - 45px);
  left: calc(50% - 45px);
  display: block;
  width: 90px;
  height: 90px;
  background: radial-gradient(rgba(0, 0, 0, 0.04), rgba(0, 0, 0, 0.16));
  border-radius: 50%;
}

.key-primary {
  display: block;
  font-size: 36px;
  color: blue;
  line-height: 22px;
  padding-top: 36px;
}
.keySpe .key-primary {
  color: #2c3e50;
  line-height: 96px;
  padding: 0;
}

.key-secondary {
  text-transform: uppercase;
  display: block;
  font-size: 12px;
  color: black;
  line-height: 12px;
  padding-top: 6px;
}
.call {
  margin-top: 18px;
  display: flex;
  justify-content: center;
}
.call-btn {
  height: 70px;
  width: 70px;
  border-radius: 50%;
  background-color: rgba(67, 160, 71, 0.7);
}
.call-btn.active, .call-btn:hover {
  background-color: #43a047;
}
.call-btn svg {
  width: 50px;
  height: 50px;
  margin: 10px;
  fill: #EEE;
}
.deleteNumber {
  display: inline-block;
  position: absolute;
  background: #2C2C2C;
  top: 16px;
  right: 12px;
  height: 18px;
  width: 32px;
  padding: 0;
}
.deleteNumber:after {
  content: '';
  position: absolute;
  left: -5px;
  top:0;
  width: 0;
  height: 0;
  border-style: solid;
  border-width: 9px 5px 9px 0;
  border-color: transparent #2C2C2C transparent transparent;
}
</style>
