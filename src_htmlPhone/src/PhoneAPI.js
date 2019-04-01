import store from '@/store'
import VoiceRTC from './VoiceRCT'

let USE_VOICE_RTC = false
const BASE_URL = 'http://gcphone/'

/* eslint-disable camelcase */
class PhoneAPI {
  constructor () {
    window.addEventListener('message', (event) => {
      const eventType = event.data.event
      if (eventType !== undefined && typeof this['on' + eventType] === 'function') {
        this['on' + eventType](event.data)
      } else if (event.data.show !== undefined) {
        store.commit('SET_PHONE_VISIBILITY', event.data.show)
      }
    })
    this.config = null
    this.voiceRTC = null
  }

  async post (method, data) {
    const ndata = data === undefined ? '{}' : JSON.stringify(data)
    const response = await window.jQuery.post(BASE_URL + method, ndata)
    return JSON.parse(response)
  }

  async log (...data) {
    if (process.env.NODE_ENV === 'production') {
      return this.post('log', data)
    } else {
      return console.log(...data)
    }
  }

  // === Gestion des messages
  async sendMessage (phoneNumber, message) {
    return this.post('sendMessage', {phoneNumber, message})
  }
  async deleteMessage (id) {
    return this.post('deleteMessage', {id})
  }
  async deleteMessagesNumber (number) {
    return this.post('deleteMessageNumber', {number})
  }
  async deleteAllMessages () {
    return this.post('deleteAllMessage')
  }
  async setMessageRead (number) {
    return this.post('setReadMessageNumber', {number})
  }

  // === Gestion des contacts
  async updateContact (id, display, phoneNumber) {
    return this.post('updateContact', { id, display, phoneNumber })
  }
  async addContact (display, phoneNumber) {
    return this.post('addContact', { display, phoneNumber })
  }
  async deleteContact (id) {
    return this.post('deleteContact', { id })
  }

  // == Gestion des appels
  async appelsDeleteHistorique (numero) {
    return this.post('appelsDeleteHistorique', { numero })
  }
  async appelsDeleteAllHistorique () {
    return this.post('appelsDeleteAllHistorique')
  }

  // === Autre
  async closePhone () {
    return this.post('closePhone')
  }
  async setGPS (x, y) {
    return this.post('setGPS', {x, y})
  }
  async takePhoto () {
    return this.post('takePhoto')
  }
  async getReponseText (data) {
    if (process.env.NODE_ENV === 'production') {
      return this.post('reponseText', data || {})
    } else {
      return {text: window.prompt()}
    }
  }
  async callEvent (eventName, data) {
    return this.post('callEvent', {eventName, data})
  }
  async deleteALL () {
    localStorage.clear()
    store.dispatch('tchatReset')
    store.dispatch('resetPhone')
    store.dispatch('resetMessage')
    store.dispatch('resetContact')
    store.dispatch('resetBourse')
    store.dispatch('resetAppels')
    return this.post('deleteALL')
  }
  async getConfig () {
    if (this.config === null) {
      const response = await window.jQuery.get('/html/static/config/config.json')
      if (process.env.NODE_ENV === 'production') {
        this.config = JSON.parse(response)
      } else {
        this.config = response
      }
      if (this.config.useWebRTCVocal === true) {
        this.voiceRTC = new VoiceRTC(this.config.RTCConfig)
        USE_VOICE_RTC = true
      }
      console.log('JS USE RTC', this.config.useWebRTCVocal)
      this.notififyUseRTC(this.config.useWebRTCVocal)
    }
    return this.config
  }

  onsetEnableApp (data) {
    store.dispatch('setEnableApp', data)
  }

  // === App Tchat
  async tchatGetMessagesChannel (channel) {
    this.post('tchat_getChannel', { channel })
  }
  async tchatSendMessage (channel, message) {
    this.post('tchat_addMessage', { channel, message })
  }

  // ==========================================================================
  //  Gestion des events
  // ==========================================================================
  onupdateMyPhoneNumber (data) {
    store.commit('SET_MY_PHONE_NUMBER', data.myPhoneNumber)
  }
  onupdateMessages (data) {
    store.commit('SET_MESSAGES', data.messages)
  }
  onnewMessage (data) {
    store.commit('ADD_MESSAGE', data.message)
  }
  onupdateContacts (data) {
    store.commit('SET_CONTACTS', data.contacts)
  }
  onhistoriqueCall (data) {
    store.commit('SET_APPELS_HISTORIQUE', data.historique)
  }
  onupdateBankbalance (data) {
    store.commit('SET_BANK_AMONT', data.banking)
  }
  onupdateBourse (data) {
    store.commit('SET_BOURSE_INFO', data.bourse)
  }
  // Call
  async startCall (numero, extraData = undefined) {
    if (USE_VOICE_RTC === true) {
      const rtcOffer = await this.voiceRTC.prepareCall()
      return this.post('startCall', { numero, rtcOffer, extraData })
    } else {
      return this.post('startCall', { numero, extraData })
    }
  }
  async acceptCall (infoCall) {
    if (USE_VOICE_RTC === true) {
      const rtcAnswer = await this.voiceRTC.acceptCall(infoCall)
      return this.post('acceptCall', { infoCall, rtcAnswer })
    } else {
      return this.post('acceptCall', { infoCall })
    }
  }
  async rejectCall (infoCall) {
    return this.post('rejectCall', { infoCall })
  }

  async notififyUseRTC (use) {
    return this.post('notififyUseRTC', use)
  }

  onwaitingCall (data) {
    store.commit('SET_APPELS_INFO_IF_EMPTY', {
      ...data.infoCall,
      initiator: data.initiator
    })
  }
  onacceptCall (data) {
    if (USE_VOICE_RTC === true) {
      if (data.initiator === true) {
        this.voiceRTC.onReceiveAnswer(data.infoCall.rtcAnswer)
      }
      this.voiceRTC.addEventListener('onCandidate', (candidates) => {
        this.post('onCandidates', { id: data.infoCall.id, candidates })
      })
    }
    store.commit('SET_APPELS_INFO_IS_ACCEPTS', true)
  }
  oncandidatesAvailable (data) {
    this.voiceRTC.addIceCandidates(data.candidates)
  }
  onrejectCall (data) {
    if (this.voiceRTC !== null) {
      this.voiceRTC.close()
    }
    store.commit('SET_APPELS_INFO', null)
  }
  // Tchat Event
  ontchat_receive (data) {
    store.dispatch('tchatAddMessage', data)
  }
  ontchat_channel (data) {
    store.commit('TCHAT_SET_MESSAGES', data)
  }

  // =====================
  onautoStartCall (data) {
    this.startCall(data.number, data.extraData)
  }
  onautoAcceptCall (data) {
    store.commit('SET_APPELS_INFO', data.infoCall)
    this.acceptCall(data.infoCall)
  }

}

const instance = new PhoneAPI()

export default instance
