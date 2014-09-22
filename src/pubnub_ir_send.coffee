tessel  = require 'tessel'
irlib   = require 'ir-attx4'
ir      = irlib.use tessel.port['A']

channel = process.argv[2]
uuid    = tessel.deviceId()

PUBNUB = require("pubnub").init({
  publish_key: "demo",
  subscribe_key: "demo",
  uuid: uuid
});

ir.on 'ready', (version) ->
  console.log('Ready to read IR sensor...');
  ir.on 'data', (data) ->
    console.log 'IR:', data.toString()
    PUBNUB.publish
      channel: channel
      message: {ir: data.toString()}

ir.on 'error', (err) -> console.error err



