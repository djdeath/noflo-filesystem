fs = require 'fs'
noflo = require 'noflo'

class CreateWriteStream extends noflo.Component
  icon: 'file'
  constructor: ->
    @filename = null

    @inPorts =
      path: new noflo.Port 'string'
    @outPorts =
      out: new noflo.Port 'object'

    @inPorts.path.on 'data', (path) =>
      return unless @outPorts.out.isAttached()
      stream = fs.createWriteStream(path)
      stream.on 'open', (fd) =>
        @outPorts.out.send(stream)
        @outPorts.out.disconnect()

exports.getComponent = -> new CreateWriteStream
