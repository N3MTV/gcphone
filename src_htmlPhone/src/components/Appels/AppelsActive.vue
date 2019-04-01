<template>
   <div class="phone_app">
     <div class="backblur" v-bind:style="{background: 'url(' + backgroundURL +')'}"></div>
     <InfoBare />
     <div class="num">{{appelsDisplayNumber}}</div>
     <div class="contactName">{{appelsDisplayName}}</div>

     <div class="time"></div>
     <div class="time-display">{{timeDisplay}}</div>

    <div class="actionbox">
      <div class="action raccrocher" :class="{disable: status === 0 && select !== 0}">
        <svg viewBox="0 0 24 24">
          <g transform="rotate(135, 12, 12)">
          <path d="M6.62,10.79C8.06,13.62 10.38,15.94 13.21,17.38L15.41,15.18C15.69,14.9 16.08,14.82 16.43,14.93C17.55,15.3 18.75,15.5 20,15.5A1,1 0 0,1 21,16.5V20A1,1 0 0,1 20,21A17,17 0 0,1 3,4A1,1 0 0,1 4,3H7.5A1,1 0 0,1 8.5,4C8.5,5.25 8.7,6.45 9.07,7.57C9.18,7.92 9.1,8.31 8.82,8.59L6.62,10.79Z"/>
            </g>
        </svg>
      </div>

      <div class="action deccrocher" v-if="status === 0" :class="{disable: status === 0 && select !== 1}">
        <svg viewBox="0 0 24 24" >
          <g transform="rotate(0, 12, 12)">
          <path d="M6.62,10.79C8.06,13.62 10.38,15.94 13.21,17.38L15.41,15.18C15.69,14.9 16.08,14.82 16.43,14.93C17.55,15.3 18.75,15.5 20,15.5A1,1 0 0,1 21,16.5V20A1,1 0 0,1 20,21A17,17 0 0,1 3,4A1,1 0 0,1 4,3H7.5A1,1 0 0,1 8.5,4C8.5,5.25 8.7,6.45 9.07,7.57C9.18,7.92 9.1,8.31 8.82,8.59L6.62,10.79Z"/>
            </g>
        </svg>
      
      </div>
     </div>
   </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import InfoBare from './../InfoBare'

export default {
  components: {
    InfoBare
  },
  data () {
    return {
      numero: '###-####',
      contactName: 'Inconnu',
      time: -1,
      intervalNum: undefined,
      select: -1,
      status: 0
    }
  },
  methods: {
    ...mapActions(['appelsInfo', 'acceptCall', 'rejectCall', 'ignoreCall']),
    onBackspace () {
      if (this.status === 1) {
        this.onRejectCall()
      } else {
        this.onIgnoreCall()
      }
    },
    onEnter () {
      if (this.status === 0) {
        if (this.select === 0) {
          this.onRejectCall()
        } else {
          this.onAcceptCall()
        }
      }
    },
    onLeft () {
      if (this.status === 0) {
        this.select = 0
      }
    },
    onRight () {
      if (this.status === 0) {
        this.select = 1
      }
    },
    updateTime () {
      this.time += 1
    },
    onRejectCall () {
      this.rejectCall()
    },
    onAcceptCall () {
      this.acceptCall()
    },
    onIgnoreCall () {
      this.ignoreCall()
      this.$router.push({ name: 'home' })
    },
    startTimer () {
      if (this.intervalNum === undefined) {
        this.time = 0
        this.intervalNum = setInterval(this.updateTime, 1000)
      }
    }
  },

  watch: {
    appelsInfo () {
      if (this.appelsInfo === null) return
      if (this.appelsInfo.is_accepts === true) {
        this.status = 1
        this.startTimer()
      }
    }
  },

  computed: {
    ...mapGetters(['backgroundURL', 'appelsInfo', 'appelsDisplayName', 'appelsDisplayNumber', 'myPhoneNumber']),
    timeDisplay () {
      if (this.time < 0) {
        return '. . .'
      }
      const min = Math.floor(this.time / 60)
      let sec = this.time % 60
      if (sec < 10) {
        sec = '0' + sec
      }
      return `${min}:${sec}`
    }
  },

  mounted () {
    if (this.appelsInfo.initiator === true) {
      this.status = 1
    }
  },

  created: function () {
    this.$bus.$on('keyUpBackspace', this.onBackspace)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpArrowLeft', this.onLeft)
    this.$bus.$on('keyUpArrowRight', this.onRight)
  },
  beforeDestroy: function () {
    this.$bus.$off('keyUpBackspace', this.onBackspace)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpArrowLeft', this.onLeft)
    this.$bus.$off('keyUpArrowRight', this.onRight)
    if (this.intervalNum !== undefined) {
      window.clearInterval(this.intervalNum)
    }
  }
}
</script>

<style scoped>
.backblur{
  top: -6px;
  left: -6px;
  right:-6px;
  bottom: -6px;
  position: absolute;
  background-size: cover !important;
  filter: blur(6px);
}
.num{
  position: absolute;
  text-shadow: 0px 0px 15px black, 0px 0px 15px black;
  top: 60px;
  left: 0;
  right: 0;
  color: rgba(255, 255, 255, 0.9);
  text-align: center;
  font-size: 46px;
}
.contactName{
  position: absolute;
  text-shadow: 0px 0px 15px black, 0px 0px 15px black;
  top: 100px;
  left: 0;
  right: 0;
  color: rgba(255, 255, 255, 0.8);
  text-align: center;
  margin-top: 16px;
  font-size: 36px;
}

.time{
  position: relative;
  top: 280px;
  left: 125px;
  width: 150px;
  height: 150px;
  border-top: 2px solid white;
  border-radius: 50%;
  animation: rond 1.8s infinite linear;
}
.time-display{
  text-shadow: 0px 0px 15px black, 0px 0px 15px black;
  position: relative;
  top: 195px;
  line-height: 20px;
  left: 125px;
  width: 150px;
  height: 91px;
  color: white;
  font-size: 36px;
  text-align: center
}

.actionbox {
  position: absolute;
  display: flex;
  bottom: 70px;
  left: 0;
  right: 0;
  justify-content: space-around;
}

.action {
  height: 100px;
  width: 100px;
  border-radius: 50%;
}

.raccrocher {
  background-color: red;
}

.deccrocher {
  background-color: #43a047;
}

.disable {
  background-color: #4d4d4d;
}

.action svg{
  width: 60px;
  height: 60px;
  margin: 20px;
  fill: #EEE;
}


@keyframes rond {
  from {
    rotate: 0deg
  }
  to {
    rotate: 360deg
  }
}
</style>
