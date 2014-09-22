tessel  = require 'tessel'
blelib  = require 'ble-ble113a'
ble     = blelib.use tessel.port['A']

channel = process.argv[2]
uuid    = tessel.deviceId()

PUBNUB = require("pubnub").init({
  publish_key: "demo",
  subscribe_key: "demo",
  uuid: uuid
});

ble.reset()

ble.on 'ready', ->
  console.log 'Scanning...'
  ble.startScanning()

ble.on 'discover', (peripheral) ->
  console.log 'discover:', peripheral.toString()
  PUBNUB.publish
    channel: channel
    message: {peripheral: JSON.parse(peripheral.toString())}
