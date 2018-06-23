const state = {
  bankAmont: '0'
}

const getters = {
  bankAmont: ({ bankAmont }) => bankAmont
}

const actions = {
}

const mutations = {
  SET_BANK_AMONT (state, bankAmont) {
    state.bankAmont = bankAmont
  }
}

export default {
  state,
  getters,
  actions,
  mutations
}

