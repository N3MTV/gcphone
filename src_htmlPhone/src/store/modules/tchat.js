import PhoneAPI from './../../PhoneAPI'
const LOCAL_NAME = 'gc_tchat_channels'

let TchatAudio = null

const state = {
  channels: JSON.parse(localStorage[LOCAL_NAME] || null) || [],
  currentChannel: null,
  messagesChannel: []
}

const getters = {
  tchatChannels: ({ channels }) => channels,
  tchatCurrentChannel: ({ currentChannel }) => currentChannel,
  tchatMessages: ({ messagesChannel }) => messagesChannel
}

const actions = {
  tchatReset ({commit}) {
    commit('TCHAT_SET_MESSAGES', { messages: [] })
    commit('TCHAT_SET_CHANNEL', { channel: null })
    commit('TCHAT_REMOVES_ALL_CHANNELS')
  },
  tchatSetChannel ({ state, commit, dispatch }, { channel }) {
    if (state.currentChannel !== channel) {
      commit('TCHAT_SET_MESSAGES', { messages: [] })
      commit('TCHAT_SET_CHANNEL', { channel })
      dispatch('tchatGetMessagesChannel', { channel })
    }
  },
  tchatAddMessage ({ state, commit, getters }, { message }) {
    const channel = message.channel
    if (state.channels.find(e => e.channel === channel) !== undefined) {
      if (TchatAudio !== null) {
        TchatAudio.pause()
        TchatAudio = null
      }
      TchatAudio = new Audio('/html/static/sound/tchatNotification.ogg')
      TchatAudio.volume = getters.volume
      TchatAudio.play()
    }
    commit('TCHAT_ADD_MESSAGES', { message })
  },
  tchatAddChannel ({ commit }, { channel }) {
    commit('TCHAT_ADD_CHANNELS', { channel })
  },
  tchatRemoveChannel ({ commit }, { channel }) {
    commit('TCHAT_REMOVES_CHANNELS', { channel })
  },
  tchatGetMessagesChannel ({ commit }, { channel }) {
    PhoneAPI.tchatGetMessagesChannel(channel)
  },
  tchatSendMessage (state, { channel, message }) {
    PhoneAPI.tchatSendMessage(channel, message)
  }
}

const mutations = {
  TCHAT_SET_CHANNEL (state, { channel }) {
    state.currentChannel = channel
  },
  TCHAT_ADD_CHANNELS (state, { channel }) {
    state.channels.push({
      channel
    })
    localStorage[LOCAL_NAME] = JSON.stringify(state.channels)
  },
  TCHAT_REMOVES_CHANNELS (state, { channel }) {
    state.channels = state.channels.filter(c => {
      return c.channel !== channel
    })
    localStorage[LOCAL_NAME] = JSON.stringify(state.channels)
  },
  TCHAT_REMOVES_ALL_CHANNELS (state) {
    state.channels = []
    localStorage[LOCAL_NAME] = JSON.stringify(state.channels)
  },
  TCHAT_ADD_MESSAGES (state, { message }) {
    if (message.channel === state.currentChannel) {
      state.messagesChannel.push(message)
    }
  },
  TCHAT_SET_MESSAGES (state, { messages }) {
    state.messagesChannel = messages
  }
}

export default {
  state,
  getters,
  actions,
  mutations
}

if (process.env.NODE_ENV !== 'production') {
  state.currentChannel = 'debug'
  state.messagesChannel = JSON.parse('[{"channel":"teste","message":"teste","id":6,"time":1528671680000},{"channel":"teste","message":"Hop","id":5,"time":1528671153000}]')
  for (let i = 0; i < 200; i++) {
    state.messagesChannel.push(Object.assign({}, state.messagesChannel[0], { id: 100 + i, message: 'mess ' + i }))
  }
  state.messagesChannel.push({
    message: 'Message sur plusieur ligne car il faut bien !!! Ok !',
    id: 5000,
    time: new Date().getTime()
  })
  state.messagesChannel.push({
    message: 'Message sur plusieur ligne car il faut bien !!! Ok !',
    id: 5000,
    time: new Date().getTime()
  })
  state.messagesChannel.push({
    message: 'Message sur plusieur ligne car il faut bien !!! Ok !',
    id: 5000,
    time: new Date(4567845).getTime()
  })
}
