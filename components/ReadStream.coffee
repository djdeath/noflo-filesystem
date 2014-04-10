fs = require 'fs'
noflo = require 'noflo'

class ReadStream extends noflo.Component
  constructor: ->
    @inPorts =
      in: new noflo.Port 'object'
    @outPorts =
      out: new noflo.Port 'object'
      end: new noflo.Port 'bang'
      error: new noflo.Port 'object'

    @dataListener = (data) =>
      @data(data)
    @endListener = () =>
      @end()
    @errorListener = (error) =>
      @error(error)

    @inPorts.in.on 'data', (stream) =>
      @updateStream(stream)

  updateStream: (stream) ->
    if @stream
      @stream.removeListener 'data', @dataListener
      @stream.removeListener 'end', @endListener
      @stream.removeListener 'error', @errorListener
    @stream = stream
    if @stream
      @stream.on 'data', @dataListener
      @stream.on 'end', @endListener
      @stream.on 'error', @errorListener

  data: (data) ->
    return unless @outPorts.out.isAttached()
    @outPorts.out.send(data)
    @outPorts.out.disconnect()

  end: () ->
    return unless @outPorts.end.isAttached()
    @outPorts.end.send(true)
    @outPorts.end.disconnect()

  error: (err) ->
    return unless @outPorts.error.isAttached()
    @outPorts.error.send(err)
    @outPorts.error.disconnect()

exports.getComponent = -> new ReadStream
