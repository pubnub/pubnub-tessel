tessel = require 'tessel'
climatelib = require 'climate-si7020'
climate = climatelib.use(tessel.port['D'])

channel = process.argv[2]
uuid    = tessel.deviceId()

PUBNUB = require("pubnub").init({
  publish_key: "demo",
  subscribe_key: "demo",
  uuid: uuid
});

climate.on 'ready', (version) ->
  console.log 'Ready to read climate sensor'
  setInterval ->
  	climate.readTemperature ->
  		temp_args = arguments
  		climate.readHumidity ->
  			humid_args = arguments
	  		console.log "Temp in C : ", JSON.stringify(temp_args[1].toFixed(4)), " ", "Humidity: ", JSON.stringify(humid_args[1].toFixed(4)),"%RH"
	  		PUBNUB.publish
	          channel: channel
	          message: {
	            temperature: temp_args
	            humidity: humid_args
	          }
  , 2000

climate.on 'error', (err) -> console.error err