readenv = require "../components/CreateWriteStream"
socket = require('noflo').internalSocket
fs = require 'fs'

setupComponent = ->
  c = readenv.getComponent()
  path = socket.createSocket()
  out = socket.createSocket()
  error = socket.createSocket()
  c.inPorts.path.attach path
  c.outPorts.out.attach out
  [path, out]

exports['test write stream creation'] = (test) ->
  [path, out] = setupComponent()
  out.once 'data', (stream) ->
    test.ok true
    test.done()
    fs.unlinkSync 'test/CreateWriteStream.output'
  path.send 'test/CreateWriteStream.output'
