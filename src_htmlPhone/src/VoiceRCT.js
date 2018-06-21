const constraints = {
  video: false,
  audio: true
}

/* eslint-disable */
class VoiceRTC {

  constructor (RTCConfig) {
    this.myPeerConnection = null
    this.candidates = []
    this.listener = {}
    this.myCandidates = []
    this.audio = new Audio()
    this.offer = null
    this.answer = null
    this.initiator = null
    this.RTCConfig = RTCConfig
  }

  async init () {
    await this.close()
    this.myPeerConnection = new RTCPeerConnection(this.RTCConfig)
    this.stream = await navigator.mediaDevices.getUserMedia(constraints)
  }

  newConnection () {
    this.close()
    this.candidates = []
    this.myCandidates = []
    this.listener = {}
    this.offer = null
    this.answer = null
    this.initiator = null
    this.myPeerConnection = new RTCPeerConnection(this.RTCConfig)
    this.myPeerConnection.onaddstream = this.onaddstream.bind(this)
  }

  close () {
    if (this.myPeerConnection !== null) {
      this.myPeerConnection.close()
    }
    this.myPeerConnection = null
  }

  async prepareCall () {
    await this.init()
    this.newConnection()
    this.initiator = true
    this.myPeerConnection.addStream(this.stream)
    this.myPeerConnection.onicecandidate = this.onicecandidate.bind(this)
    this.offer = await this.myPeerConnection.createOffer()
    this.myPeerConnection.setLocalDescription(this.offer)
    return btoa(JSON.stringify(this.offer))
  }


  async acceptCall (infoCall) {
    console.log('JS acceptCall 1')
    console.log(infoCall.rtcOffer)
    const offer = JSON.parse(atob(infoCall.rtcOffer))
    console.log('JS acceptCall 1')
    this.newConnection()
    console.log('JS acceptCall 1')
    this.initiator = false
    console.log('JS acceptCall 1')
    this.stream = await navigator.mediaDevices.getUserMedia(constraints)
    console.log('JS acceptCall 1')
    this.myPeerConnection.onicecandidate = this.onicecandidate.bind(this)
    console.log('JS acceptCall 1')
    this.myPeerConnection.addStream(this.stream)
    console.log('JS acceptCall 1')
    this.offer = new RTCSessionDescription(offer)
    console.log('JS acceptCall 1')
    this.myPeerConnection.setRemoteDescription(this.offer)
    console.log('JS acceptCall 1')
    this.answer = await this.myPeerConnection.createAnswer()
    console.log('JS acceptCall 1')
    this.myPeerConnection.setLocalDescription(this.answer)
    console.log('JS acceptCall 1')
    return btoa(JSON.stringify(this.answer))
  }

  async onReceiveAnswer (answerData) {
    const answerObj = JSON.parse(atob(answerData))
    this.answer = new RTCSessionDescription(answerObj)
    this.myPeerConnection.setRemoteDescription(this.answer)
  }

  onicecandidate (event) {
    if (event.candidate !== undefined) {
      this.myCandidates.push(event.candidate)
      if (this.listener['onCandidate'] !== undefined) { 
        const candidates = this.getAvailableCandidates()
        for (let func of this.listener['onCandidate']) {
          func(candidates)
        }
      }
    }
  }

  getAvailableCandidates() {
    const candidates = btoa(JSON.stringify(this.myCandidates))
    this.myCandidates = []
    return candidates
  }

  addIceCandidates (candidatesRaw) {
    console.log(candidatesRaw)
    if (this.myPeerConnection !== null) {
      const candidates = JSON.parse(atob(candidatesRaw))
      candidates.forEach((candidate) => {
        if (candidate !== null) {
          console.log('CA ' + JSON.stringify(candidate))
          this.myPeerConnection.addIceCandidate(candidate)
        }
      })
    }
  }

  addEventListener (eventName, callBack) {
    if (eventName === 'onCandidate') {
      if (this.listener[eventName] === undefined) {
        this.listener[eventName] = []
      }
      this.listener[eventName].push(callBack)
      callBack(this.getAvailableCandidates())
    }
  }

  onaddstream (event) {
    this.audio.srcObject = event.stream
    this.audio.play()
  }

}

/* eslint-disable */
(async function () {
})()

export default VoiceRTC
