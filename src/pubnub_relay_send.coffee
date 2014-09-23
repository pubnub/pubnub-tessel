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
  setInterval ->
    relay.toggle 1, (err) ->
      console.log("Error toggling 1: ", err) if err
    relay.toggle 2, (err) ->
      console.log("Error toggling 2: ", err) if err
  , 2000

relay.on 'latch', (outlet, value) ->
  console.log('latch on relay outlet ' + outlet + ' switched to ', value)
  pubnub.publish 
    channel: channel
    message: {
      outlet: outlet
      value: value
    }
