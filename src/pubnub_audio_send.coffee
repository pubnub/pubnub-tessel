tessel  = require 'tessel'
audiolib = require 'audio-vs1053b'
audio = audiolib.use tessel.port['B']

channel = process.argv[2]
uuid    = tessel.deviceId()

console.log("channel", channel)
console.log("uuid", uuid)

chunks = []

audio.on 'ready', () ->
  PUBNUB = require("pubnub").init {
    publish_key: "demo",
    subscribe_key: "demo",
    uuid: uuid
  }

  audio.setInput 'mic', (err) ->
    chunks = []

    audio.on 'data', (data) ->
      chunks.push(data)

    audio.startRecording 'voice', (err) ->
      console.log 'start recording'
      setTimeout ->
        audio.stopRecording (err) ->
          console.log 'stop recording'
          chunk_str = Buffer.concat(chunks).toString('hex')
          console.log 'got audio data', chunk_str
          PUBNUB.publish
            channel: channel
            message: {
              audio: chunk_str
            }
      , 1000

audio.on 'error', (err) -> throw err