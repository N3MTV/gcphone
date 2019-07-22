import PhoneAPI from './../../PhoneAPI'
const LOCAL_NAME = 'gc_irc_channels'

let ircAudio = null

const state = {
  channels: JSON.parse(localStorage[LOCAL_NAME] || null) || [],
  currentChannel: null,
  messagesChannel: []
}

const getters = {
  ircChannels: ({ channels }) => channels,
  ircCurrentChannel: ({ currentChannel }) => currentChannel,
  ircMessages: ({ messagesChannel }) => messagesChannel
}

const actions = {
  ircReset ({commit}) {
    commit('IRC_SET_MESSAGES', { messages: [] })
    commit('IRC_SET_CHANNEL', { channel: null })
    commit('IRC_REMOVES_ALL_CHANNELS')
  },
  ircSetChannel ({ state, commit, dispatch }, { channel }) {
    if (state.currentChannel !== channel) {
      commit('IRC_SET_MESSAGES', { messages: [] })
      commit('IRC_SET_CHANNEL', { channel })
      dispatch('ircGetMessagesChannel', { channel })
    }
  },
  ircAddMessage ({ state, commit, getters }, { message }) {
    const channel = message.channel
    if (state.channels.find(e => e.channel === channel) !== undefined) {
      if (ircAudio !== null) {
        ircAudio.pause()
        ircAudio = null
      }
      ircAudio = new Audio('/html/static/sound/tchatNotification.ogg')
      ircAudio.volume = getters.volume
      ircAudio.play()
    }
    commit('IRC_ADD_MESSAGES', { message })
  },
  ircAddChannel ({ commit }, { channel }) {
    let joined = new Date()
    commit('IRC_ADD_CHANNEL', { channel: channel, joined: joined })
    PhoneAPI.ircJoinChannel(channel)
  },
  ircAddChannels ({ commit }, { channels }) {
    commit('IRC_ADD_CHANNELS', { channels })
  },
  ircRemoveChannel ({ commit }, { channel }) {
    commit('IRC_REMOVES_CHANNELS', { channel })
    PhoneAPI.ircLeaveChannel(channel)
  },
  ircGetMessagesChannel ({ commit }, { channel }) {
    PhoneAPI.ircGetMessagesChannel(channel)
  },
  ircSendMessage (state, { channel, message }) {
    PhoneAPI.ircSendMessage(channel, message)
  }
}

const mutations = {
  IRC_SET_CHANNEL (state, { channel }) {
    state.currentChannel = channel
  },
  IRC_ADD_CHANNEL (state, { channel }) {
    const dupeChannel = state.channels.find(a => a.channel === channel)
    if (dupeChannel) {
      return
    }
    state.channels.push({
      channel
    })
    localStorage[LOCAL_NAME] = JSON.stringify(state.channels)
  },
  IRC_ADD_CHANNELS (state, { channels }) {
    state.channels = channels
    localStorage[LOCAL_NAME] = JSON.stringify(state.channels)
  },
  IRC_REMOVES_CHANNELS (state, { channel }) {
    state.channels = state.channels.filter(c => {
      return c.channel !== channel
    })
    localStorage[LOCAL_NAME] = JSON.stringify(state.channels)
  },
  IRC_REMOVES_ALL_CHANNELS (state) {
    state.channels = []
    localStorage[LOCAL_NAME] = JSON.stringify(state.channels)
  },
  IRC_ADD_MESSAGES (state, { message }) {
    if (message.channel === state.currentChannel) {
      state.messagesChannel.push(message)
    }
  },
  IRC_SET_MESSAGES (state, { messages }) {
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
  state.channels = JSON.parse('[{"channel":"teste", "joined": 1528671680000}]')
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
