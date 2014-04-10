readenv = require "../components/CreateReadStream"
socket = require('noflo').internalSocket
fs = require 'fs'

setupComponent = ->
  c = readenv.getComponent()
  path = socket.createSocket()
  out = socket.createSocket()
  error = socket.createSocket()
  c.inPorts.path.attach path
  c.outPorts.out.attach out
  c.outPorts.error.attach error
  [path, out, error]

exports['test read stream creation'] = (test) ->
  [path, out, error] = setupComponent()
  out.once 'data', (stream) ->
    test.ok true
    test.done()
  error.once 'data', (err) ->
    test.fail err
    test.done()
    fs.unlinkSync 'test/CreateReadStream.coffee'
  path.send 'test/CreateReadStream.coffee'

exports['test read stream creation fails on missing file'] = (test) ->
  [path, out, error] = setupComponent()
  out.once 'data', (stream) ->
    test.fail()
    test.done()
  error.once 'data', (err) ->
    test.ok true
    test.done()
  path.send 'test/NonexistentCreateReadStream.coffee'
