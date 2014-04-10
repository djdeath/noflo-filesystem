fs = require 'fs'
noflo = require 'noflo'

class CreateReadStream extends noflo.Component
  icon: 'file'
  constructor: ->
    @filename = null

    @inPorts =
      path: new noflo.Port 'string'
    @outPorts =
      out: new noflo.Port 'object'
      error: new noflo.Port 'object'

    @inPorts.path.on 'data', (path) =>
      return unless @outPorts.out.isAttached()
      stream = fs.createReadStream(path)

      removeListeners = null
      openListener = (fd) =>
        removeListeners(stream)
        return unless @outPorts.out.isAttached()
        @outPorts.out.send(stream)
        @outPorts.out.disconnect()
      errorListener = (err) =>
        removeListeners(stream)
        return unless @outPorts.error.isAttached()
        @outPorts.error.send(err)
        @outPorts.error.disconnect()
      removeListeners = (stream) =>
        stream.removeListener 'open', openListener
        stream.removeListener 'error', errorListener

      stream.on 'open', openListener
      stream.on 'error', errorListener

exports.getComponent = -> new CreateReadStream
