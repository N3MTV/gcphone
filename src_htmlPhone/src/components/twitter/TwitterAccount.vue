<template>
  <div class="phone_content content inputText">

    <div class="group select" data-type="text" data-model='username' data-maxlength = '64'>      
        <input type="text" v-model="twitterUsername">
        <span class="highlight"></span>
        <span class="bar"></span>
        <label>{{ IntlString('APP_TWITER_ACCOUNT_USERNAME') }}</label>
    </div>

    <div class="group select" data-type="text" data-model='password' data-maxlength = '64'>      
        <input type="password" v-model="twitterPassword">
        <span class="highlight"></span>
        <span class="bar"></span>
        <label>{{ IntlString('APP_TWITER_ACCOUNT_PASSWORD') }}</label>
    </div>

    <div style="margin-top: 56px;" class="group img" data-type="button" data-action='onPressChangeAvartar'>      
        <img :src="twitterAvatarUrl" height="128" width="128">
        <input type='button' class="btn btn-green" :value="IntlString('APP_TWITER_ACCOUNT_AVATAR')" />
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import PhoneTitle from './../PhoneTitle'

export default {
  components: { PhoneTitle },
  data () {
    return {
      selectMessage: -1
    }
  },
  computed: {
    ...mapGetters(['IntlString', 'twitterUsername', 'twitterPassword', 'twitterAvatarUrl'])
  },
  watch: {
  },
  methods: {
    ...mapActions(['twitterLogin', 'twitterSetAvatar']),
    onUp: function () {
      if (this.ignoreControls === true) return
      let select = document.querySelector('.group.select')
      if (select.previousElementSibling !== null) {
        document.querySelectorAll('.group').forEach(elem => {
          elem.classList.remove('select')
        })
        select.previousElementSibling.classList.add('select')
        let i = select.previousElementSibling.querySelector('input')
        if (i !== null) {
          i.focus()
        }
      }
    },
    onDown: function () {
      if (this.ignoreControls === true) return
      let select = document.querySelector('.group.select')
      if (select.nextElementSibling !== null) {
        document.querySelectorAll('.group').forEach(elem => {
          elem.classList.remove('select')
        })
        select.nextElementSibling.classList.add('select')
        let i = select.nextElementSibling.querySelector('input')
        if (i !== null) {
          i.focus()
        }
      }
    },
    onEnter: function () {
      if (this.ignoreControls === true) return
      let select = document.querySelector('.group.select')
      if (select.dataset.type === 'text') {
        let options = {
          limit: parseInt(select.dataset.maxlength) || 64,
          text: select.querySelector('input').value
        }
        this.$phoneAPI.getReponseText(options).then(data => {
          const key = select.dataset.model
          const newLogin = {
            username: this.twitterUsername,
            password: this.twitterPassword
          }
          newLogin[key] = data.text
          this.twitterLogin(newLogin)
        })
      }
      if (select.dataset.action && this[select.dataset.action]) {
        this[select.dataset.action]()
      }
    },
    onBack () {
      this.$router.push({ name: 'twitter.screen' })
    },
    onPressChangeAvartar () {
      this.$phoneAPI.getReponseText({text: this.twitterAvatarUrl || 'https://i.imgur.com/'}).then(data => {
        this.twitterSetAvatar({avatarUrl: data.text})
      })
    }
  },
  created: function () {
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
  },
  mounted () {
  },
  beforeDestroy: function () {
    this.$bus.$off('keyUpArrowDown', this.onDown)
    this.$bus.$off('keyUpArrowUp', this.onUp)
    this.$bus.$off('keyUpEnter', this.onEnter)
    this.$bus.$off('keyUpBackspace', this.onBack)
  }
}
</script>

<style scoped>
.content{
    padding: 6px 10px;
    padding-top: 28px;
}
.group { 
  position:relative; 
  margin-top:24px; 
}
.group.inputText { 
  position:relative; 
  margin-top:45px; 
}

.group.img {
  display: flex;
  flex-direction: row;
  align-items: center;
}

.group.img img{
  display: flex;
  flex-direction: row;
  flex-grow: 0;
  flex: 0 0 128px;
  height: 128px;
  margin-right: 24px;
}

input 				{
  font-size:24px;
  display:block;
  width:100%;
  border:none;
  border-bottom:1px solid #757575;
}
input:focus 		{ outline:none; }

/* LABEL ======================================= */
label 				 {
  color:#999; 
  font-size:18px;
  font-weight:normal;
  position:absolute;
  pointer-events:none;
  left:5px;
  top:10px;
  transition:0.2s ease all; 
  -moz-transition:0.2s ease all; 
  -webkit-transition:0.2s ease all;
}

/* active state */
input:focus ~ label, input:valid ~ label 		{
  top:-24px;
  font-size:18px;
  color:#0084b4;
}

/* BOTTOM BARS ================================= */
.bar 	{ position:relative; display:block; width:100%; }
.bar:before, .bar:after 	{
  content:'';
  height:2px; 
  width:0;
  bottom:1px; 
  position:absolute;
  background:#1da1f2; 
  transition:0.2s ease all; 
  -moz-transition:0.2s ease all; 
  -webkit-transition:0.2s ease all;
}
.bar:before {
  left:50%;
}
.bar:after {
  right:50%; 
}

/* active state */
input:focus ~ .bar:before, input:focus ~ .bar:after,
.group.select input ~ .bar:before, .group.select input ~ .bar:after{
  width:50%;
}

/* HIGHLIGHTER ================================== */
.highlight {
  position:absolute;
  height:60%; 
  width:100px; 
  top:25%; 
  left:0;
  pointer-events:none;
  opacity:0.5;
}

/* active state */
input:focus ~ .highlight {
  -webkit-animation:inputHighlighter 0.3s ease;
  -moz-animation:inputHighlighter 0.3s ease;
  animation:inputHighlighter 0.3s ease;
}

.group .btn{
    width: 100%;
    padding: 0px 0px;
    height: 48px;
    color: #fff;
    border: 0 none;
    font-size: 22px;
    font-weight: 500;
    line-height: 34px;
    color: #202129;
    background-color: #edeeee;
}
.group.select .btn{
    /* border: 6px solid #C0C0C0; */
    line-height: 18px;
    font-weight: 500;
    border-radius: 10px;
}

.group .btn.btn-green{
  border: 1px solid #0084b4;
  color: #0084b4;
  background-color: white;
  font-weight: 500;
  border-radius: 10px;
}
.group.select .btn.btn-green{
  background-color: #00aced;
  color: white;
  border: none;
}

/* ANIMATIONS ================ */
@-webkit-keyframes inputHighlighter {
	from { background:#5264AE; }
  to 	{ width:0; background:transparent; }
}
@-moz-keyframes inputHighlighter {
	from { background:#5264AE; }
  to 	{ width:0; background:transparent; }
}
@keyframes inputHighlighter {
	from { background:#5264AE; }
  to 	{ width:0; background:transparent; }
}
</style>
