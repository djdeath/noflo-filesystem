noflo = require 'noflo'

class EndWriteStream extends noflo.Component
  icon: 'times'
  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
    @outPorts =
      out: new noflo.Port 'object'

    @inPorts.in.on 'data', (stream) =>
      stream.end(() =>
        return unless @outPorts.out.isAttached()
        @outPorts.out.send(stream)
        @outPorts.out.disconnect())

exports.getComponent = -> new EndWriteStream
