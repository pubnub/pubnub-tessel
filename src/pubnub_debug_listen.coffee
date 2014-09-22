###
  NOTE: this is just a nodejs script for receiving messages from PubNub
###

channel = process.argv[2]

pubnub = require("pubnub").init {
  publish_key: "demo"
  subscribe_key: "demo"
  uuid: "your_name_here" + Math.floor(Math.random()*1000)
}

pubnub.subscribe {
  channel: channel
  message: ->
    console.log JSON.stringify(arguments)
}
