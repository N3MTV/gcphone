<template>
  <div class='phone_content content inputText'>
    <template v-if="state === STATES.MENU">
      <template v-if="!isLogin">
        <div class="group" data-type="button" @click.stop="state = STATES.LOGIN">      
          <input type='button' class="btn btn-blue" @click.stop="state = STATES.LOGIN" :value="IntlString('APP_TWITTER_ACCOUNT_LOGIN')"/>
        </div>

        <div class="group" data-type="button" @click.stop="state = STATES.NOTIFICATION">      
          <input type='button' class="btn btn-blue" @click.stop="state = STATES.NOTIFICATION" :value="IntlString('APP_TWITTER_NOTIFICATION')" />
        </div>

        <div class="group bottom" data-type="button" @click.stop="state = STATES.NEW_ACCOUNT">      
          <input type='button' class="btn btn-red" @click.stop="state = STATES.NEW_ACCOUNT" :value="IntlString('APP_TWITTER_ACCOUNT_NEW')" />
        </div>
      </template>

      <template v-if="isLogin">
        <img :src="twitterAvatarUrl" height="128" width="128" style="align-self: center;">

        <div class="group" data-type="button" @click.stop="state = STATES.ACCOUNT">      
          <input type='button' class="btn btn-blue" @click.stop="state = STATES.ACCOUNT" :value="IntlString('APP_TWITTER_ACCOUNT_PARAM')" />
        </div>

        <div class="group" data-type="button" @click.stop="state = STATES.NOTIFICATION">      
          <input type='button' class="btn btn-blue" @click.stop="state = STATES.NOTIFICATION" :value="IntlString('APP_TWITTER_NOTIFICATION')" />
        </div>

        <div class="group bottom" data-type="button" @click.stop="logout">      
          <input type='button' class="btn btn-red" @click.stop="logout" :value="IntlString('APP_TWITTER_ACCOUNT_LOGOUT')" />
        </div>
      </template>
    </template>

    <template v-else-if="state === STATES.LOGIN">
      <div class="group inputText" data-type="text" data-maxlength='64' :data-defaultValue="localAccount.username">      
          <input type="text" :value="localAccount.username" @change="setLocalAccount($event, 'username')">
          <span class="highlight"></span>
          <span class="bar"></span>
          <label>{{ IntlString('APP_TWITTER_ACCOUNT_USERNAME') }}</label>
      </div>
      
      <div class="group inputText" data-type="text" data-model='password' data-maxlength='30'>      
          <input autocomplete="new-password" type="password" :value="localAccount.password" @change="setLocalAccount($event, 'password')">
          <span class="highlight"></span>
          <span class="bar"></span>
          <label>{{ IntlString('APP_TWITTER_ACCOUNT_PASSWORD') }}</label>
      </div>

      <div class="group" data-type="button" @click.stop="login">      
        <input type='button' class="btn btn-blue" @click.stop="login" :value="IntlString('APP_TWITTER_ACCOUNT_LOGIN')" />
      </div>
    </template>

    <template v-else-if="state === STATES.NOTIFICATION">
      <div class="groupCheckBoxTitle">
        <label>{{ IntlString('APP_TWITTER_NOTIFICATION_WHEN') }}</label>
      </div>

      <label class="group checkbox" data-type="button" @click.prevent.stop="setNotification(2)">
        <input type="checkbox" :checked="twitterNotification === 2" @click.prevent.stop="setNotification(2)">
        {{ IntlString('APP_TWITTER_NOTIFICATION_ALL') }}
      </label>
  
      <label class="group checkbox" data-type="button" @click.prevent.stop="setNotification(1)">
        <input type="checkbox" :checked="twitterNotification === 1" @click.prevent.stop="setNotification(1)">
        {{ IntlString('APP_TWITTER_NOTIFICATION_MENTION') }}
      </label>

      <label class="group checkbox" data-type="button" @click.prevent.stop="setNotification(0)">
        <input type="checkbox" :checked="twitterNotification === 0" @click.prevent.stop="setNotification(0)">
        {{ IntlString('APP_TWITTER_NOTIFICATION_NEVER') }}
      </label>

      <div class="groupCheckBoxTitle">
        <label>{{ IntlString('APP_TWITTER_NOTIFICATION_SOUND') }}</label>
      </div>

      <label class="group checkbox" data-type="button" @click.prevent.stop="setNotificationSound(true)">
        <input type="checkbox" :checked="twitterNotificationSound" @click.prevent.stop="setNotificationSound(true)">
        {{ IntlString('APP_TWITTER_NOTIFICATION_SOUND_YES') }}
      </label>
  
      <label class="group checkbox" data-type="button" @click.prevent.stop="setNotificationSound(false)">
        <input type="checkbox" :checked="!twitterNotificationSound" @click.prevent.stop="setNotificationSound(false)">
        {{ IntlString('APP_TWITTER_NOTIFICATION_SOUND_NO') }}
      </label>

    </template>

    <template v-else-if="state === STATES.ACCOUNT">

      <div style="margin-top: 42px; margin-bottom: 42px;" class="group img" data-type="button" @click.stop="onPressChangeAvartar">      
        <img :src="twitterAvatarUrl" height="128" width="128" @click.stop="onPressChangeAvartar">
        <input type='button' class="btn btn-blue" :value="IntlString('APP_TWITTER_ACCOUNT_AVATAR')" @click.stop="onPressChangeAvartar" />
      </div>

      <div class="group" data-type="button" @click.stop="changePassword">      
        <input type='button' class="btn btn-red" :value="IntlString('APP_TWITTER_ACCOUNT_CHANGE_PASSWORD')" @click.stop="changePassword"/>
      </div>

    </template>

    <template v-else-if="state === STATES.NEW_ACCOUNT">
  
      <div class="group inputText" data-type="text" data-maxlength='64' data-defaultValue="">      
          <input type="text" :value="localAccount.username" @change="setLocalAccount($event, 'username')">
          <span class="highlight"></span>
          <span class="bar"></span>
          <label>{{ IntlString('APP_TWITTER_NEW_ACCOUNT_USERNAME') }}</label>
      </div>
      
      <div class="group inputText" data-type="text" data-model='password' data-maxlength='30'>      
          <input autocomplete="new-password" type="password" :value="localAccount.password" @change="setLocalAccount($event, 'password')">
          <span class="highlight"></span>
          <span class="bar"></span>
          <label>{{ IntlString('APP_TWITTER_NEW_ACCOUNT_PASSWORD') }}</label>
      </div>
     

      <div class="group inputText" data-type="text" data-model='password' data-maxlength='30'>      
          <input autocomplete="new-password" type="password" :value="localAccount.passwordConfirm" @change="setLocalAccount($event, 'passwordConfirm')">
          <span class="highlight"></span>
          <span class="bar"></span>
          <label>{{ IntlString('APP_TWITTER_NEW_ACCOUNT_PASSWORD_CONFIRM') }}</label>
      </div>
      
      <div style="margin-top: 42px; margin-bottom: 42px;" class="group img" data-type="button" @click.stop="setLocalAccountAvartar($event)">      
        <img :src="localAccount.avatarUrl" height="128" width="128" @click.stop="setLocalAccountAvartar($event)">
        <input type='button' class="btn btn-blue" :value="IntlString('APP_TWITTER_NEW_ACCOUNT_AVATAR')" @click.stop="setLocalAccountAvartar($event)"/>
      </div>

      <div class="group" data-type="button" @click.stop="createAccount">      
        <input type='button' class="btn" :class="validAccount ? 'btn-blue' : 'btn-gray'" :value="IntlString('APP_TWIITER_ACCOUNT_CREATE')" @click.stop="createAccount"/>
      </div>
    </template>

  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import Modal from '@/components/Modal'

const STATES = Object.freeze({
  MENU: 0,
  NEW_ACCOUNT: 1,
  LOGIN: 2,
  ACCOUNT: 3,
  NOTIFICATION: 4
})
export default {
  components: {
  },
  data () {
    return {
      STATES,
      state: STATES.MENU,
      localAccount: {
        username: '',
        password: '',
        passwordConfirm: '',
        avatarUrl: null
      },
      notification: 0,
      notificationSound: false
    }
  },
  computed: {
    ...mapGetters(['IntlString', 'useMouse', 'twitterUsername', 'twitterPassword', 'twitterAvatarUrl', 'twitterNotification', 'twitterNotificationSound']),
    isLogin () {
      return this.twitterUsername !== undefined && this.twitterUsername !== ''
    },
    validAccount () {
      return this.localAccount.username.length >= 4 && this.localAccount.password.length >= 6 && this.localAccount.password === this.localAccount.passwordConfirm
    }
  },
  methods: {
    ...mapActions(['twitterLogin', 'twitterChangePassword', 'twitterLogout', 'twitterSetAvatar', 'twitterCreateNewAccount', 'setTwitterNotification', 'setTwitterNotificationSound']),
    onUp: function () {
      if (this.ignoreControls === true) return
      let select = document.querySelector('.group.select')
      if (select === null) {
        select = document.querySelector('.group')
        select.classList.add('select')
        return
      }
      while (select.previousElementSibling !== null) {
        if (select.previousElementSibling.classList.contains('group')) {
          break
        }
        select = select.previousElementSibling
      }
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
      while (select.nextElementSibling !== null) {
        if (select.nextElementSibling.classList.contains('group')) {
          break
        }
        select = select.nextElementSibling
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
    onBack () {
      if (this.state !== this.STATES.MENU) {
        this.state = this.STATES.MENU
      } else {
        this.$bus.$emit('twitterHome')
      }
    },
    setLocalAccount ($event, key) {
      this.localAccount[key] = $event.target.value
    },
    async setLocalAccountAvartar ($event) {
      try {
        const data = await Modal.CreateTextModal({
          text: this.twitterAvatarUrl || 'https://i.imgur.com/'
        })
        this.localAccount.avatarUrl = data.text
      } catch (e) {}
    },
    async onPressChangeAvartar () {
      try {
        const data = await Modal.CreateTextModal({
          text: this.twitterAvatarUrl || 'https://i.imgur.com/'
        })
        this.twitterSetAvatar({avatarUrl: data.text})
      } catch (e) {}
    },
    login () {
      this.twitterLogin({
        username: this.localAccount.username,
        password: this.localAccount.password
      })
      this.state = STATES.MENU
    },
    logout () {
      this.twitterLogout()
    },
    createAccount () {
      if (this.validAccount === true) {
        this.twitterCreateNewAccount(this.localAccount)
        this.localAccount = {
          username: '',
          password: '',
          passwordConfirm: '',
          avatarUrl: null
        }
        this.state = this.STATES.MENU
      }
    },
    cancel () {
      this.state = STATES.MENU
    },
    setNotification (value) {
      this.setTwitterNotification(value)
    },
    setNotificationSound (value) {
      this.setTwitterNotificationSound(value)
    },
    async changePassword (value) {
      try {
        const password1 = await Modal.CreateTextModal({limit: 30})
        if (password1.text === '') return
        const password2 = await Modal.CreateTextModal({limit: 30})
        if (password2.text === '') return
        if (password2.text !== password1.text) {
          this.$notify({
            title: this.IntlString('APP_TWITTER_NAME'),
            message: this.IntlString('APP_TWITTER_NOTIF_NEW_PASSWORD_MISS_MATCH'),
            icon: 'twitter',
            backgroundColor: '#e0245e80'
          })
          return
        } else if (password2.text.length < 6) {
          this.$notify({
            title: this.IntlString('APP_TWITTER_NAME'),
            message: this.IntlString('APP_TWITTER_NOTIF_NEW_PASSWORD_LENGTH_ERROR'),
            icon: 'twitter',
            backgroundColor: '#e0245e80'
          })
          return
        }
        this.twitterChangePassword(password2.text)
      } catch (e) {
        console.error(e)
      }
    }
  },
  created () {
    if (!this.useMouse) {
      this.$bus.$on('keyUpArrowDown', this.onDown)
      this.$bus.$on('keyUpArrowUp', this.onUp)
      this.$bus.$on('keyUpEnter', this.onEnter)
      this.$bus.$on('keyUpBackspace', this.onBack)
    }
  },
  beforeDestroy () {
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
  display: flex;
  flex-direction: column;
}
.group { 
  position:relative; 
  margin-top:24px; 
}
.group.inputText { 
  position:relative; 
  margin-top:45px; 
}

.group.bottom {
  margin-top: auto;
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
.group.inputText label 				 {
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

.checkbox {
  display: flex;
  height: 42px;
  line-height: 42px;
  align-items: center;
  color: #0084b4;
  font-weight: 700;
  border-radius: 6px;
  padding-left: 12px;
  margin-top: 4px;
}

.checkbox input {
  width: 24px;
  height: 0px;
  opacity: 1;
}

.checkbox input::after {
  box-sizing: border-box;
  content: '';
  opacity: 1;
  position: absolute;
  left: 6px;
  margin-top: -10px;
  width: 20px;
  height: 20px;
  background-color: white;
  border: 3px #0084b4 solid;
  border-radius: 50%;
}

.checkbox input:checked::after {
  background-color: #0084b4;
}

.checkbox.select {
  border: 1px solid #0084b4;
  background-color: #00aced;
  color: white;
}

.groupCheckBoxTitle {
  font-weight: 700;
  margin-top: 12px;
}

/* active state */
.group.inputText input:focus ~ label, .group.inputText input:valid ~ label 		{
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
.group.select .btn.btn-blue, .group:hover .btn.btn-blue{
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
.group.select .btn.btn-red, .group:hover .btn.btn-red{
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
.group.select .btn.btn-gray, .group:hover .btn.btn-gray{
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
