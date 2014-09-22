tessel   = require 'tessel'
accellib = require 'accel-mma84'
accel    = accellib.use tessel.port['A']

channel = process.argv[2]
uuid    = tessel.deviceId()

PUBNUB = require("pubnub").init({
  publish_key: "demo",
  subscribe_key: "demo",
  uuid: uuid
});

accel.on 'ready', (version) ->
  console.log 'Ready to read accelerometer'
  accel.removeAllListeners 'data'
  accel.setOutputRate 0.5, ->
    accel.on 'data', (xyz) ->
      console.log 'xyz:', JSON.stringify xyz
      PUBNUB.publish
        channel: channel
        message: xyz

accel.on 'error', (err) -> console.error err
