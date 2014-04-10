fs = require 'fs'
noflo = require 'noflo'

class WriteStream extends noflo.Component
  icon: 'save'
  constructor: ->
    @inPorts =
      stream: new noflo.Port 'object'
      encoding: new noflo.Port 'string'
      in: new noflo.Port 'object'
    @outPorts =
      out: new noflo.Port 'bang'
      drain: new noflo.Port 'bang'
      error: new noflo.Port 'object'

    @encoding = null
    @drainListener = () =>
      @drain()
    @errorListener = (err) =>
      @error(err)

    @inPorts.stream.on 'data', (stream) =>
      @updateStream(stream)
    @inPorts.in.on 'data', (data) =>
      @write(data)

  updateStream: (stream) ->
    if @stream
      @stream.removeListener 'error', @errorListener
      @stream.removeListener 'drain', @drainListener
    @stream = stream
    if @stream
      @stream.on 'drain', @drainListener
      @stream.on 'error', @errorListener

  write: (data) ->
    return unless @stream
    stream = @stream
    @stream.write(data, @encoding, (err) =>
      return if err
      return unless @stream == stream
      return unless @outPorts.out.isAttached()
      @outPorts.out.send(data)
      @outPorts.out.disconnect())

  drain: () ->
    return unless @output.drain.isAttached()
    @output.drain.send(true)
    @output.drain.disconnect()

  error: (err) ->
    return unless @outPorts.error.isAttached()
    @outPorts.error.send(err)
    @outPorts.error.disconnect()

exports.getComponent = -> new WriteStream
