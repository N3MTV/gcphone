import PhoneAPI from './../../PhoneAPI'

const state = {
  messages: []
}

const getters = {
  messages: ({ messages }) => messages,
  nbMessagesUnread: ({ messages }) => {
    return messages.filter(e => e.isRead !== 1).length
  }
}

const actions = {
  setMessages ({ commit }, messages) {
    commit('SET_MESSAGES', messages)
  },
  sendMessage ({ commit }, {phoneNumber, message}) {
    PhoneAPI.sendMessage(phoneNumber, message)
  },
  deleteMessage ({ commit }, { id }) {
    PhoneAPI.deleteMessage(id)
  },
  deleteMessagesNumber ({ commit, state }, { num }) {
    PhoneAPI.deleteMessagesNumber(num)
    commit('SET_MESSAGES', state.messages.filter(mess => {
      return mess.transmitter !== num
    }))
  },
  deleteAllMessages ({ commit }) {
    PhoneAPI.deleteAllMessages()
    commit('SET_MESSAGES', [])
  },
  setMessageRead ({ commit }, num) {
    PhoneAPI.setMessageRead(num)
    commit('SET_MESSAGES_READ', { num })
  },
  resetMessage ({ commit }) {
    commit('SET_MESSAGES', [])
  }
}

const mutations = {
  SET_MESSAGES (state, messages) {
    state.messages = messages
  },
  ADD_MESSAGE (state, message) {
    state.messages.push(message)
  },
  SET_MESSAGES_READ (state, { num }) {
    for (let i = 0; i < state.messages.length; i += 1) {
      if (state.messages[i].transmitter === num && state.messages[i].isRead !== 1) {
        state.messages[i].isRead = 1
      }
    }
  }
}

export default {
  state,
  getters,
  actions,
  mutations
}

if (process.env.NODE_ENV !== 'production') {
  const time = new Date().getTime()
  state.messages = [
    {id: 1, transmitter: '01', receiver: '06', time: time - 160, message: 'Salut sa va ?!!!', isRead: 1, owner: false},
    {id: 2, transmitter: '01', time, message: 'Tu fait quoi?', isRead: 1, owner: false},
    {id: 3, transmitter: '01', time, message: 'Oui est toi ?', isRead: 1, owner: true},
    {id: 4, transmitter: '01', time, message: 'GPS : 244 - 123', isRead: 1, owner: false},
    {id: 5, transmitter: '01', time, message: 'Tu fait quoi?', isRead: 1, owner: false},
    {id: 6, transmitter: '01', time, message: 'Oui est toi ?', isRead: 1, owner: true},
    {id: 7, transmitter: '01', time, message: 'Salut sa va ?', isRead: 1, owner: false},
    {id: 8, transmitter: '01', time, message: 'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff', isRead: 0, owner: false},
    {id: 9, transmitter: '01', time, message: 'GPS: -1034.5810546875, -2734.1027832031', isRead: 1, owner: true},
    {id: 10, transmitter: '02', time, message: 'Salut sa va ?', isRead: 1, owner: false},
    {id: 11, transmitter: '04', time, message: 'Salut sa va ?', isRead: 1, owner: false},
    {id: 12, transmitter: '04', time, message: 'Salut sa va ?', isRead: 1, owner: false},
    {id: 13, transmitter: '09', time, message: 'Tu sais pas !', isRead: 1, owner: false}
  ]
}
