const url = 'http://gcphone/'
const post = function (method, data) {
  let ndata = data === undefined ? '{}' : JSON.stringify(data)
  return window.jQuery.post(url + method, ndata).then(data => JSON.parse(data))
}

if (process.env.NODE_ENV === 'production') {
  console.log = function (...data) {
    post('log', {data})
  }
}

export default {
  getContacts: function () {
    if (process.env.NODE_ENV === 'production') {
      return post('getContacts')
    } else {
      return Promise.resolve([
        {id: 0, display: 'User01', number: '01'},
        {id: 1, display: 'User02', number: '02'},
        {id: 2, display: 'User03', number: '03'},
        {id: 3, display: 'User04', number: '04'}
      ])
    }
  },
  deleteContact: function (id) {
    return post('deleteContact', {id})
  },

  addContact: function (display, phoneNumber) {
    return post('addContact', {display, phoneNumber})
  },

  updateContact: function (id, display, phoneNumber) {
    return post('updateContact', {id, display, phoneNumber})
  },

  getMessages: function () {
    if (process.env.NODE_ENV === 'production') {
      return post('getMessages')
    } else {
      let time = new Date().getTime()
      return Promise.resolve([
        {id: 1, transmitter: '01', receiver: '06', time: time - 160, message: 'Salut sa va ?!!!', isRead: true, owner: false},
        {id: 2, transmitter: '01', time, message: 'Tu fait quoi?', isRead: false, owner: false},
        {id: 0, transmitter: '01', time, message: 'Oui est toi ?', isRead: true, owner: true},
        {id: 1, transmitter: '01', time, message: 'GPS : 244 - 123', isRead: true, owner: false},
        {id: 2, transmitter: '01', time, message: 'Tu fait quoi?', isRead: false, owner: false},
        {id: 0, transmitter: '01', time, message: 'Oui est toi ?', isRead: true, owner: true},
        {id: 1, transmitter: '01', time, message: 'Salut sa va ?', isRead: true, owner: false},
        {id: 2, transmitter: '01', time, message: 'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff', isRead: false, owner: false},
        {id: 0, transmitter: '01', time, message: 'GPS: -1034.5810546875, -2734.1027832031', isRead: true, owner: true},
        {id: 3, transmitter: '02', time, message: 'Salut sa va ?', isRead: true, owner: false},
        {id: 4, transmitter: '04', time, message: 'Salut sa va ?', isRead: true, owner: false},
        {id: 5, transmitter: '04', time, message: 'Salut sa va ?', isRead: true, owner: false},
        {id: 6, transmitter: '09', time, message: 'Tu sais pas !', isRead: true, owner: false}
      ])
    }
  },
  sendMessage: function (phoneNumber, message) {
    return post('sendMessage', {phoneNumber, message})
  },
  deleteMessage: function (id) {
    post('deleteMessage', {id})
  },
  deleteMessageNumber: function (number) {
    post('deleteMessageNumber', {number})
  },
  deleteAllMessage: function () {
    post('deleteAllMessage')
  },
  setReadMessageNumber: function (number) {
    post('setReadMessageNumber', {number})
  },
  getReponseText: function (data) {
    if (process.env.NODE_ENV === 'production') {
      return post('reponseText', data || {})
    } else {
      return Promise.resolve({text: 'http://i.imgur.com/8nr0gw1.jpg'})
    }
  },

  setGPS: function (x, y) {
    return post('setGPS', {x, y})
  },
  callEvent: function (eventName, data) {
    return post('callEvent', {eventName, data})
  },
  deleteALL: function () {
    localStorage.clear()
    return post('deleteALL')
  },
  closePhone: function () {
    return post('closePhone')
  }
}
