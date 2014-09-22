tessel  = require 'tessel'
cameralib = require 'camera-vc0706'
camera = cameralib.use tessel.port['A']

channel = process.argv[2]
uuid    = tessel.deviceId()

notificationLED = tessel.led[3]

camera.on 'ready', () ->
  PUBNUB = require("pubnub").init {
    publish_key: "demo",
    subscribe_key: "demo",
    uuid: uuid
  }
  
  console.log("camera ready")
  notificationLED.high()
  camera.setResolution 'qqvga', ->
    camera.takePicture (err, image) ->
      if err
        console.log('error taking image', err)
      else
        notificationLED.low()
        image_string = image.toString('hex')
        console.log("sending image", image_string)
        PUBNUB.publish
          channel: channel
          message: {image: image_string}
      camera.disable()

camera.on 'error', (err) -> console.error err
