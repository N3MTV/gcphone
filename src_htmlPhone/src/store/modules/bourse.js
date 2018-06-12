const state = {
  bourseInfo: []
}

const getters = {
  bourseInfo: ({ bourseInfo }) => bourseInfo
}

const actions = {
  resetBourse ({ commit }) {
    commit('SET_BOURSE_INFO', [])
  }
}

const mutations = {
  SET_BOURSE_INFO (state, bourseInfo) {
    state.bourseInfo = bourseInfo
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
  state.bourseInfo = [{
    difference: 0,
    libelle: 'Trest trop long mais bon',
    price: 154.2
  }, {
    difference: 20,
    libelle: 'Entre B',
    price: 54.2
  }, {
    difference: -20.5,
    libelle: 'Entre C',
    price: 254.2
  }]
}
