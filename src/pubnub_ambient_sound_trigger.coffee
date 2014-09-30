tessel     = require 'tessel'
ambientlib = require 'ambient-attx4'
ambient    = ambientlib.use tessel.port['A']

channel = process.argv[2]
uuid    = tessel.deviceId()

PUBNUB = require("pubnub").init({
  publish_key: "demo",
  subscribe_key: "demo",
  uuid: uuid
});

conn = ->
  ambient.on 'ready', (version) ->
    console.log 'Ready to read ambient sensor'
    setInterval ->
      ambient.setSoundTrigger 0.1
      ambient.on 'sound-trigger', (data) ->
        PUBNUB.publish({channel: channel, message: {type:"Sound detected!", data:data}})
        # clear the trigger
        ambient.clearSoundTrigger()
        # wait a bit and reset the trigger
        setTimeout ->
          ambient.setSoundTrigger 0.1
        , 1500

  ambient.on 'error', (err) -> console.error err
  
setTimeout conn, 1000