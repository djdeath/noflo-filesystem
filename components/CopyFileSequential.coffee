fs = require 'fs'
noflo = require "noflo"

Operation =
  Copy: 0
  Disconnect: 1

class CopyFileSequential extends noflo.Component
  icon: 'copy'
  constructor: ->
    @sourcePath = null
    @destPath = null
    @q = []
    @processing = false

    @inPorts =
      source: new noflo.Port()
      destination: new noflo.Port()
    @outPorts =
      out: new noflo.Port()
      error: new noflo.Port()

    @inPorts.source.on 'data', (data) =>
      if @destPath
        @queueCopy data, @destPath
        @destPath = null
        @processQueue()
        return
      @sourcePath = data
    @inPorts.destination.on 'data', (data) =>
      if @sourcePath
        @queueCopy @sourcePath, data
        @sourcePath = null
        @processQueue()
        return
      @destPath = data

    @inPorts.source.on 'disconnect', =>
      return if @inPorts.destination.isConnected()
      @queueDisconnect()
      @processQueue()

    @inPorts.destination.on 'disconnect', =>
      return if @inPorts.source.isConnected()
      @queueDisconnect()
      @processQueue()

  queueCopy: (source, destination) ->
    op =
      type: Operation.Copy
      source: source
      destination: destination
    @q.push(op)

  queueDisconnect: () ->
    op =
      type: Operation.Disconnect
    @q.push(op)

  processQueue: ->
    while !@processing and @q.length != 0
      item = @q.shift()
      switch item.type
        when Operation.Copy
          @copy item.source, item.destination
        when Operation.Disconnect
          @disconnect()

  copy: (source, destination) ->
    handleError = (err) =>
      @processing = false
      if err.code is 'EMFILE'
        @queueCopy(source, destination)
        process.nextTick => @processQueue()
        return
      return unless @outPorts.error.isAttached()
      @outPorts.error.send err
      @outPorts.error.disconnect()

    @processing = true
    rs = fs.createReadStream source
    ws = fs.createWriteStream destination
    rs.on 'error', handleError
    ws.on 'error', handleError

    rs.pipe ws
    rs.on 'end', =>
      @processing = false
      if @outPorts.out.isAttached()
        @outPorts.out.send destination
      @processQueue()

  disconnect: () ->
    @outPorts.out.disconnect() if @outPorts.out.isConnected()

  shutdown: () ->
    @sourcePath = null
    @destPath = null
    @q = []
    @processing = false

exports.getComponent = -> new CopyFileSequential
