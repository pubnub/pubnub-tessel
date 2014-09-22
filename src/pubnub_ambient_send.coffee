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

ambient.on 'ready', (version) ->
  console.log 'Ready to read ambient sensor'
  setInterval ->
    ambient.getLightLevel ->
      light_args = arguments
      ambient.getSoundLevel ->
        sound_args = arguments
        console.log "Light:", JSON.stringify(light_args), " ", "Sound:", JSON.stringify(sound_args)
        PUBNUB.publish
          channel: channel
          message: {
            light: light_args
            sound: sound_args
          }
  , 2000

ambient.on 'error', (err) -> console.error err
