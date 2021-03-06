var util = {
  inherits : function(ctor, superCtor) {
    ctor.super_ = superCtor;
    ctor.prototype = Object.create(superCtor.prototype, {
      constructor: {
        value: ctor,
        enumerable: false,
        writable: true,
        configurable: true
      }
    });
  }
};

var Stream = require('stream');

var REGEX = {
  dataurl: /data:(.*?)(?:;charset=(.*?))?(;base64)?,(.+)/i,
  newlines: /(\r)|(\n)/g
}
var MIME_INDEX = 1;
var CHARSET_INDEX = 2;
var ENCODED_INDEX = 3;
var DATA_INDEX = 4;

function dataurl() {}

function stripNewlines(string) {
  return string.replace(REGEX.newlines, '');
}

function isString(thing) {
  return typeof thing === 'string';
}

function makeHeader(options) {
  var dataUrlTemplate = 'data:' + options.mimetype;
  if (options.charset)
    dataUrlTemplate += ';charset=' + options.charset;
  if (options.encoded !== false)
    dataUrlTemplate += ';base64'
  dataUrlTemplate += ',';
  return dataUrlTemplate;
}

function makeDataUrlSync(header, data) {
  return (header + Buffer(data).toString('base64'));
}

function ConvertStream(options) {
  if (!(this instanceof ConvertStream))
    return new ConvertStream(options);
  this.encoded = true && options.encoded !== false;
  this.charset = options.charset;
  this.mimetype = options.mimetype;
  this.header = makeHeader(options);
  this.headerEmitted = false;
  this.readable = true;
  this.writable = true;
  this._buffer = Buffer(0);
  this.once('pipe', function (src) {
    this.pause = src.pause.bind(src);
    this.resume = src.resume.bind(src);
  }.bind(this));
}
util.inherits(ConvertStream, Stream);
ConvertStream.prototype._emit = Stream.prototype.emit;
ConvertStream.prototype.emitData = function emitData(data) {
  if (!this.headerEmitted) {
    this.emit('data', this.header);
    this.headerEmitted = true;
    this.emitData = this.emit.bind(this, 'data');
  }
  this.emit('data', data);
};
ConvertStream.prototype.convert = function convert(data) {
  if (!this.encoded)
    return data;
  data = Buffer.concat([this._buffer, Buffer(data)]);
  if (data.length < 3) {
    this._buffer = data;
    return;
  }
  var length = data.length;
  var remainderSize = length % 3;
  var offset = length - remainderSize;
  var current = data.slice(0, offset);
  this._buffer = data.slice(offset);
  return current.toString('base64');
};
ConvertStream.prototype.finish = function finish() {
  var data = this._buffer;
  if (!data.length)
    return;
  return this.emitData(
    this.encoded ? data.toString('base64') : data
  );
};
ConvertStream.prototype.write = function write(data) {
  var output = this.convert(data);
  if (output)
    this.emitData(output);
};
ConvertStream.prototype.end = function end(data) {
  if (data)
    this.write(data);
  this.finish();
  this.readable = false;
  this.writable = false;
  this.emit('end');
};

dataurl.stream = function (options) {
  return new ConvertStream(options);
};
dataurl.convert = function (options) {
  var header = makeHeader(options);
  return makeDataUrlSync(header, options.data);
};
dataurl.format = dataurl.convert;

dataurl.parse = function (string) {
  var match;
  if (!isString(string))
    return false;
  string = stripNewlines(string);
  if (!(match = REGEX.dataurl.exec(string)))
    return false;
  var encoded = !!match[ENCODED_INDEX];
  var base64 = (encoded ? 'base64' : null);
  var data = Buffer(match[DATA_INDEX], base64);
  var charset = match[CHARSET_INDEX];
  var mimetype = match[MIME_INDEX] || 'text/plain';
  return {
    mimetype: mimetype,
    charset: charset,
    data: data,
  }
};

module.exports = dataurl;
