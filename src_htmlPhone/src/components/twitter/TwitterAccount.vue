<template>
  <div class='phone_content content inputText'>
    <template v-if="state === STATES.MENU">
       <div class="group select" data-type="button" @click="state = STATES.SET_ACCOUNT">      
        <input type='button' class="btn btn-blue" :value="IntlString('APP_TWITTER_ACCOUNT_LOGIN')" />
      </div>

      <div class="group" style="margin-top:40px;" data-type="button" @click="state = STATES.NOTIFICATION">      
        <input type='button' class="btn btn-blue" :value="IntlString('Notification')" />
      </div>

      <div class="group" style="margin-top:220px;" data-type="button" @click="state = STATES.NEW_ACCOUNT">      
        <input type='button' class="btn btn-blue" :value="IntlString('APP_TWITTER_ACCOUNT_NEW')" />
      </div>

    </template>

    <template v-else-if="state === STATES.SET_ACCOUNT">
      <div class="group select" data-type="text" data-model='username' data-maxlength = '64'>      
          <input type="text" :value="twitterUsername" @change="onChangeUsername">
          <span class="highlight"></span>
          <span class="bar"></span>
          <label>{{ IntlString('APP_TWITTER_ACCOUNT_USERNAME') }}</label>
      </div>
      
      <div class="group inputText" data-type="text" data-model='password' data-maxlength='10'>      
          <input autocomplete="new-password" type="password" :value="twitterPassword" @change="onChangePassword">
          <span class="highlight"></span>
          <span class="bar"></span>
          <label>{{ IntlString('APP_TWITTER_ACCOUNT_PASSWORD') }}</label>
      </div>

      <div style="margin-top: 42px; margin-bottom: 42px;" class="group img" data-type="button" @click='onPressChangeAvartar'>      
        <img :src="twitterAvatarUrl" height="128" width="128">
        <input type='button' class="btn btn-blue" :value="IntlString('APP_TWITTER_ACCOUNT_AVATAR')" />
      </div>

      <!-- <div class="group" data-type="button" @click="save">      
        <input type='button' class="btn btn-blue" :value="IntlString('APP_CONTACT_SAVE')" />
      </div>

      <div class="group" data-type="button" @click='cancel'>      
        <input type='button' class="btn btn-red" :value="IntlString('APP_CONTACT_CANCEL')" />
      </div> -->
    </template>

    <template v-else-if="state === STATES.NEW_ACCOUNT">
      <div class="group select" data-type="text" data-maxlength='64' :data-defaultValue="newAccount.username">      
          <input type="text" :value="newAccount.username" @change="setNewUser($event, 'username')">
          <span class="highlight"></span>
          <span class="bar"></span>
          <label>{{ IntlString('APP_TWITTER_ACCOUNT_USERNAME') }}</label>
      </div>
      
      <div class="group inputText" data-type="text" data-model='password' data-maxlength='30'>      
          <input autocomplete="new-password" type="password" :value="newAccount.password" @change="setNewUser($event, 'password')">
          <span class="highlight"></span>
          <span class="bar"></span>
          <label>{{ IntlString('APP_TWITTER_ACCOUNT_PASSWORD') }}</label>
      </div>

      <div class="group inputText" data-type="text" data-model='password' data-maxlength='30'>      
          <input autocomplete="new-password" type="password" :value="newAccount.passwordConfirm" @change="setNewUser($event, 'passwordConfirm')">
          <span class="highlight"></span>
          <span class="bar"></span>
          <label>{{ IntlString('APP_TWITTER_ACCOUNT_PASSWORD_CONFIRM') }}</label>
      </div>

      <div style="margin-top: 42px; margin-bottom: 42px;" class="group img" data-type="button" @click='onPressChangeAvartarLocal'>      
        <img :src="newAccount.avatarUrl" height="128" width="128">
        <input type='button' class="btn btn-blue" :value="IntlString('APP_TWITTER_ACCOUNT_AVATAR')" />
      </div>

      <div class="group" data-type="button" @click="createAccount">      
        <input type='button' class="btn" :class="validAccount ? 'btn-blue' : 'btn-gray'" :value="IntlString('APP_TWIITER_ACCOUNT_CREATE')" />
      </div>
    </template>
    <template v-else-if="state === STATES.NOTIFICATION">
      <h1 style="color:red">WIP</h1>
    </template>

  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
const STATES = Object.freeze({
  MENU: 0,
  SET_ACCOUNT: 1,
  NEW_ACCOUNT: 2,
  NOTIFICATION: 3
})
export default {
  components: {
  },
  data () {
    return {
      STATES,
      state: STATES.MENU,
      newAccount: {
        username: 'John Doe',
        password: '123456',
        passwordConfirm: '123456',
        avatarUrl: 'https://i.imgur.com/ncX6mh7.jpg' // null
      }
    }
  },
  computed: {
    ...mapGetters(['IntlString', 'twitterUsername', 'twitterPassword', 'twitterAvatarUrl']),
    validAccount () {
      return this.newAccount.username.length >= 4 && this.newAccount.password.length >= 6 && this.newAccount.password === this.newAccount.passwordConfirm
    }
  },
  methods: {
    ...mapActions(['twitterLogin', 'twitterSetAvatar', 'twitterCreateNewAccount']),
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
      if (select === null) {
        select = document.querySelector('.group')
        select.classList.add('select')
        return
      }
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
      console.log('onEnter')
      if (this.ignoreControls === true) return
      let select = document.querySelector('.group.select')
      if (select === null) return

      if (select.dataset !== null) {
        if (select.dataset.type === 'text') {
          const $input = select.querySelector('input')
          let options = {
            limit: parseInt(select.dataset.maxlength) || 64,
            text: select.dataset.defaultValue || ''
          }
          this.$phoneAPI.getReponseText(options).then(data => {
            $input.value = data.text
            $input.dispatchEvent(new window.Event('change'))
          })
        }
        if (select.dataset.type === 'button') {
          select.click()
        }
      }
    },
    setNewUser ($event, key) {
      this.newAccount[key] = $event.target.value
    },
    onChangeUsername ($event) {
      const username = $event.target.value
      this.twitterLogin({
        username,
        password: this.twitterPassword
      })
    },
    onChangePassword ($event) {
      const password = $event.target.value
      this.twitterLogin({
        username: this.twitterUsername,
        password
      })
    },
    onBack () {
      if (this.state !== this.STATES.MENU) {
        this.state = this.STATES.MENU
        this.$phoneAPI.debugStore()
      }
    },
    onPressChangeAvartar () {
      this.$phoneAPI.getReponseText({text: this.twitterAvatarUrl || 'https://i.imgur.com/'}).then(data => {
        this.twitterSetAvatar({avatarUrl: data.text})
      })
    },
    onPressChangeAvartarLocal () {
      this.$phoneAPI.getReponseText({text: this.twitterAvatarUrl || 'https://i.imgur.com/'}).then(data => {
        this.newAccount.avatarUrl = data.text
      })
    },
    createAccount () {
      if (this.validAccount === true) {
        this.twitterCreateNewAccount(this.newAccount)
        this.state = this.STATES.MENU
      }
    },
    cancel () {
      this.state = STATES.MENU
    }
  },
  created: function () {
    this.$bus.$on('keyUpArrowDown', this.onDown)
    this.$bus.$on('keyUpArrowUp', this.onUp)
    this.$bus.$on('keyUpEnter', this.onEnter)
    this.$bus.$on('keyUpBackspace', this.onBack)
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
  margin: 6px 10px;
  margin-top: 28px;
  height: calc(100% - 48px);
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
  background:#0084b4; 
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
}

.group .btn.btn-blue{
  border: 1px solid #0084b4;
  color: #0084b4;
  background-color: white;
  font-weight: 500;
  border-radius: 10px;
}
.group.select .btn.btn-blue{
  background-color: #00aced;
  color: white;
  border: none;
}

.group .btn.btn-red{
  border: 1px solid #e0245e;
  color: #e0245e;
  background-color: white;
  font-weight: 500;
  border-radius: 10px;
}
.group.select .btn.btn-red{
  background-color: #e0245e;
  color: white;
  border: none;
}

.group .btn.btn-gray{
  border: none;
  color: #222;
  background-color: #AAA;
  font-weight: 500;
  border-radius: 10px;
}
.group.select .btn.btn-gray{
  background-color: #757575;
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
