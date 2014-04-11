fs = require 'fs'
noflo = require 'noflo'

class PauseReadStream extends noflo.Component
  icon: 'pause'
  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
    @outPorts =
      out: new noflo.Port 'object'

    @inPorts.in.on 'data', (stream) =>
      stream.pause()
      return unless @outPorts.out.isAttached()
      @outPorts.out.send(stream)
      @outPorts.out.disconnect()

exports.getComponent = -> new PauseReadStream
