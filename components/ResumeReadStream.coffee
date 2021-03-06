fs = require 'fs'
noflo = require 'noflo'

class ResumeReadStream extends noflo.Component
  icon: 'play'
  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
    @outPorts =
      out: new noflo.Port 'object'

    @inPorts.in.on 'data', (stream) =>
      stream.resume()
      return unless @outPorts.out.isAttached()
      @outPorts.out.send(stream)
      @outPorts.out.disconnect()

exports.getComponent = -> new ResumeReadStream
