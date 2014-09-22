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
		console.log 'Position in range 0-1: ', position

		PUBNUB.subscribe {
		  channel: channel
		  message: ->
		    console.log JSON.stringify(arguments)
		    position = Number(arguments[0])
		    servo.move(servo1, position)
		}