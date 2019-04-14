import PhoneAPI from './../../PhoneAPI'

const state = {
  appelsHistorique: [],
  appelsInfo: null
}

const getters = {
  appelsHistorique: ({ appelsHistorique }) => appelsHistorique,
  appelsInfo: ({ appelsInfo }) => appelsInfo,
  appelsDisplayName (state, getters) {
    if (state.appelsInfo === null) {
      return 'ERROR'
    }
    if (state.appelsInfo.hidden === true) {
      return getters.IntlString('APP_PHONE_NUMBER_HIDDEN')
    }
    const num = getters.appelsDisplayNumber
    const contact = getters.contacts.find(e => e.number === num) || {}
    return contact.display || getters.IntlString('APP_PHONE_NUMBER_UNKNOWN')
  },
  appelsDisplayNumber (state, getters) {
    if (state.appelsInfo === null) {
      return 'ERROR'
    }
    if (getters.isInitiatorCall === true) {
      return state.appelsInfo.receiver_num
    }
    if (state.appelsInfo.hidden === true) {
      return '###-####'
    }
    return state.appelsInfo.transmitter_num
  },
  isInitiatorCall (state, getters) {
    if (state.appelsInfo === null) {
      return false
    }
    return state.appelsInfo.initiator === true
  }
}

const actions = {
  startCall ({ commit }, { numero }) {
    PhoneAPI.startCall(numero)
  },
  acceptCall ({ state }) {
    PhoneAPI.acceptCall(state.appelsInfo)
  },
  rejectCall ({ state }) {
    PhoneAPI.rejectCall(state.appelsInfo)
  },
  ignoreCall ({ commit }) {
    commit('SET_APPELS_INFO', null)
    // PhoneAPI.ignoreCall(state.appelsInfo)
  },
  appelsDeleteHistorique ({ commit, state }, { numero }) {
    PhoneAPI.appelsDeleteHistorique(numero)
    commit('SET_APPELS_HISTORIQUE', state.appelsHistorique.filter(h => {
      return h.num !== numero
    }))
  },
  appelsDeleteAllHistorique ({ commit }) {
    PhoneAPI.appelsDeleteAllHistorique()
    commit('SET_APPELS_HISTORIQUE', [])
  },
  resetAppels ({ commit }) {
    commit('SET_APPELS_HISTORIQUE', [])
    commit('SET_APPELS_INFO', null)
  }
}

const mutations = {
  SET_APPELS_HISTORIQUE (state, appelsHistorique) {
    state.appelsHistorique = appelsHistorique
  },
  SET_APPELS_INFO_IF_EMPTY (state, appelsInfo) {
    if (state.appelsInfo === null) {
      state.appelsInfo = appelsInfo
    }
  },
  SET_APPELS_INFO (state, appelsInfo) {
    state.appelsInfo = appelsInfo
  },
  SET_APPELS_INFO_IS_ACCEPTS (state, isAccepts) {
    if (state.appelsInfo !== null) {
      state.appelsInfo = Object.assign({}, state.appelsInfo, {
        is_accepts: isAccepts
      })
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
  // eslint-disable-next-line
  state.appelsHistorique = [{"id":1,"incoming":0,"num":"336-4557","owner":"336-4557","accepts":0,"time":1528374759000},{"id":2,"incoming":0,"num":"police","owner":"336-4557","accepts":1,"time":1528374787000},{"id":3,"incoming":1,"num":"555-5555","owner":"336-4557","accepts":1,"time":1528374566000},{"id":4,"incoming":1,"num":"555-5555","owner":"336-4557","accepts":0,"time":1528371227000}]
  state.appelsInfo = {
    initiator: false,
    id: 5,
    transmitter_src: 5,
    // transmitter_num: '###-####',
    transmitter_num: '336-4557',
    receiver_src: undefined,
    // receiver_num: '336-4557',
    receiver_num: '###-####',
    is_valid: 0,
    is_accepts: 0,
    hidden: 0
  }
}
