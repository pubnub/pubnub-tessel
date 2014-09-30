tessel    = require 'tessel'
dataurl   = require './dataurl.js'
cameralib = require 'camera-vc0706'
camera = cameralib.use tessel.port['B'], resolution: 'qqvga'


channel = 'tesseldemo'
uuid    = tessel.deviceId()

notificationLED = tessel.led[3]

camera.on 'ready', () ->
  PUBNUB = require("pubnub").init {
    publish_key: "demo",
    subscribe_key: "demo",
    uuid: uuid
  }

  console.log("camera ready")
  setInterval ->
    notificationLED.high()
    camera.takePicture (err, image) ->
      if err
        console.log('error taking image', err)
      else
        notificationLED.low()
        console.log "sending image"
        PUBNUB.publish
          channel: channel
          message: {
            uuid: uuid
            ts: new Date().toISOString()
            image: dataurl.format({
              data: image
              mimetype: "image/jpg"
            })
          }
          callback: -> console.log "image sent"
  , 15000

camera.on 'error', (err) -> console.error err