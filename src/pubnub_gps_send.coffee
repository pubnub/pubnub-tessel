tessel   = require 'tessel'
gpslib   = require 'gps-a2235h'
gps      = gpslib.use tessel.port['C']

channel = process.argv[2]
uuid    = tessel.deviceId()

PUBNUB = require("pubnub").init({
  publish_key: "demo",
  subscribe_key: "demo",
  uuid: uuid
});

gps.on 'ready', (version) ->
  console.log 'Ready to read GPS'
  publish = (type) ->
    (data) ->
      console.log ['got', type, JSON.stringify data].join("\t")
      PUBNUB.publish
        channel: channel
        message: {
          type: type
          data: data
        }

  gps.on 'coordinates', publish('coordinates')
  gps.on 'altitude', publish('altitude')
  gps.on 'fix', publish('fix')
  gps.on 'dropped', publish('dropped')

gps.on 'error', (err) -> console.error err
