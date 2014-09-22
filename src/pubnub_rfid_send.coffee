tessel  = require 'tessel'
rfidlib = require 'rfid-pn532'
rfid    = rfidlib.use tessel.port['A']

channel = process.argv[2]
uuid    = tessel.deviceId()

PUBNUB = require("pubnub").init({
  publish_key: "demo",
  subscribe_key: "demo",
  uuid: uuid
});

rfid.on 'ready', (version) ->
  console.log('Ready to read RFID card');
  rfid.on 'data', (card) ->
    console.log 'UID:', card.uid.toString('hex')
    PUBNUB.publish
      channel: channel
      message: {uid: card.uid.toString('hex')}

rfid.on 'error', (err) -> console.error err



