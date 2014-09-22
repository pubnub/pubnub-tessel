tessel = require 'tessel'

channel = process.argv[2]
uuid    = tessel.deviceId()
led1    = tessel.led[0].output(1)
led2    = tessel.led[1].output(0)

pubnub = require('pubnub').init {
  subscribe_key: 'demo'
  publish_key: 'demo'
  uuid: uuid
}

console.log 'arguments:', JSON.stringify process.argv

pubnub.subscribe {
  channel: channel
  message: ->
    console.log "toggle", JSON.stringify(arguments)
    led1.toggle()
    led2.toggle()
}

console.log "listening on channel #{channel}..."

