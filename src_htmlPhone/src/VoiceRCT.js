const constraints = {
  video: false,
  audio: true
}

/* eslint-disable */
class VoiceRTC {

  constructor (phoneAPI) {
    this.phoneAPI = phoneAPI
    this.myPeerConnection = null
    this.candidates = []
    this.audio = new Audio()
    this.offer = null
    this.answer = null
    this.initiator = null
    this.RTCConfig = {
      iceServers: [{
        urls: ['turn:youserve.com'],
        username: 'user',
        credential: 'pass'
      }]
    }
  }

  async init () {
    await this.close()
    this.myPeerConnection = new RTCPeerConnection(this.RTCConfig)
    this.stream = await navigator.mediaDevices.getUserMedia(constraints)
  }

  newConnection () {
    this.close()
    this.candidates = []
    this.offer = null
    this.answer = null
    this.initiator = null
    this.myPeerConnection = new RTCPeerConnection(this.RTCConfig)
    this.myPeerConnection.onaddstream = this.onaddstream
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
    const promise = new Promise((resolve, reject) => {
      this.myPeerConnection.onicecandidate = this.onicecandidatePromise(resolve, reject)
    })
    this.offer = await this.myPeerConnection.createOffer()
    this.myPeerConnection.setLocalDescription(this.offer)
    return promise
  }

  async acceptCall (infoCall) {
    console.log('acceptCall 1')
    const data = JSON.parse(atob(infoCall.rtcOffer))
    console.log('acceptCall 2')
    this.newConnection()
    console.log('acceptCall 3')
    this.initiator = false
    console.log('acceptCall 4')
    this.stream = await navigator.mediaDevices.getUserMedia(constraints)
    console.log('acceptCall 5')
    this.myPeerConnection.addStream(this.stream)
    console.log('acceptCall 5')
    this.offer = new RTCSessionDescription(data.offer)
    console.log('acceptCall 6')
    this.candidates = data.candidates
    console.log('acceptCall 7')
    this.myPeerConnection.setRemoteDescription(this.offer)
    console.log('acceptCall 8')
    this.candidates.forEach((candidate) => {
      this.myPeerConnection.addIceCandidate(candidate)
    })
    console.log('acceptCall 9')
    this.answer = await this.myPeerConnection.createAnswer()
    console.log('acceptCall 10')
    this.myPeerConnection.setLocalDescription(this.answer)
    return btoa(JSON.stringify(this.answer))
  }

  async onReceiveAnswer (answerData) {
    const answerObj = JSON.parse(atob(answerData))
    this.answer = new RTCSessionDescription(answerObj)

    this.myPeerConnection.setRemoteDescription(this.answer)
  }

  onicecandidatePromise (resolve, reject) {
    return (event) => {
      if (event.candidate !== undefined) {
        this.candidates.push(event.candidate)
        if (this.candidates.length === 1) {
          resolve(this.getRTCOffer())
        }
      }
    }
  }

  getRTCOffer () {
    const dataOffer = JSON.stringify({
      offer: this.offer,
      candidates: this.candidates
    })
    return btoa(dataOffer)
  }

  onaddstream (event) {
    if (this.initiator = true) return
    this.audio.srcObject = event.stream
    this.audio.play()
  }

}

/* eslint-disable */
(async function () {
})()

export default VoiceRTC
