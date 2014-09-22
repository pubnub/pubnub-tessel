tessel = require 'tessel'

led1 = tessel.led[0].output(1)
led2 = tessel.led[1].output(0)

setInterval ->
    console.log "I'm blinking! (Press CTRL + C to stop)"
    led1.toggle()
    led2.toggle()
, 100

