tessel = require 'tessel'
relaylib = require 'relay-mono'
relay = relaylib.use tessel.port['A']

PUBNUB = require "pubnub"
channel = process.argv[2]
uuid = tessel.deviceId()

pubnub = PUBNUB.init {
  publish_key: "demo"
  subscribe_key: "demo"
  uuid: uuid
}

relay.on 'ready', (version) ->
  console.log 'Connected to relays!'
  pubnub.subscribe
    channel: channel
    message: (data) ->
      data.forEach(x) ->
        relay.toggle x, (err) ->
        console.log("Error toggling " + x + ": ", err) if err

relay.on 'latch', (outlet, value) ->
  console.log('latch on relay outlet ' + outlet + ' switched to ', value)
