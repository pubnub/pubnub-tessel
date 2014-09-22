tessel = require 'tessel'
irlib = require 'ir-attx4'
PUBNUB = require "pubnub"
ir = irlib.use tessel.port['A']

channel = process.argv[2]
uuid = tessel.deviceId()

pubnub = PUBNUB.init {
	publish_key: "demo"
	subscribe_key: "demo"
	uuid: uuid
}

ir.on 'ready', (version) ->
	console.log('Connected to IR!');
	pubnub.subscribe {
		channel: channel
		message: (data) ->
			intVals = data.split(",")
			intVals.forEach (x, i) -> intVals[i] = parseInt(x, 16)
			ir.sendRawSignal 38, Buffer(intVals), (err) ->
				console.log("Unable to send signal: ", err) if err
				console.log("Signal sent!") if !err
	}
	

ir.on 'error', (err) -> console.error err

ir. on 'data', (data) ->
	console.log("Received RX Data: ", data.toString('hex'))