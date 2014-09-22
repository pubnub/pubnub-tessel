// Generated by CoffeeScript 1.7.1
(function() {
  var led1, led2, tessel;

  tessel = require('tessel');

  led1 = tessel.led[0].output(1);

  led2 = tessel.led[1].output(0);

  setInterval(function() {
    console.log("I'm blinking! (Press CTRL + C to stop)");
    led1.toggle();
    return led2.toggle();
  }, 100);

}).call(this);
