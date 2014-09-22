tessel = require 'tessel'
servolib = require 'servo-pca9685'
servo = servolib.use(tessel.port['A'])

servo1 = 1

channel = process.argv[2]
uuid    = tessel.deviceId()

PUBNUB = require("pubnub").init({
  publish_key: "demo",
  subscribe_key: "demo",
  uuid: uuid
});

servo.on 'ready', ->
	console.log 'Activating Servo'
	position = 0
	servo.configure servo1, 0.05, 0.12, ->
		setInterval ->
			console.log 'Position in range 0-1: ', position

			PUBNUB.publish
	          channel: channel
	          message: {
	            position: position
	          }
			servo.move(servo1, position)

			if position == 0
				position = 1
			else
				position = 0
		, 4000