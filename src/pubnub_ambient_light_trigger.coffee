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
      ambient.setLightTrigger 0.5
      ambient.on 'light-trigger', (data) ->
        PUBNUB.publish({channel: channel, message: {type:"Light detected!", data:data}})
        # clear the trigger
        ambient.clearLightTrigger()
        # wait a bit and reset the trigger
        setTimeout ->
          ambient.setLightTrigger 0.1
        , 1500

  ambient.on 'error', (err) -> console.error err
  
setTimeout conn, 1000