CreateReadStream = require '../components/CreateReadStream'
ReadStream = require '../components/ReadStream'
socket = require('noflo').internalSocket
fs = require 'fs'

setupComponent = ->
  create = CreateReadStream.getComponent()
  read = ReadStream.getComponent()

  path = socket.createSocket()
  link = socket.createSocket()
  error = socket.createSocket()
  end = socket.createSocket()
  out = socket.createSocket()
  create.inPorts.path.attach path
  create.outPorts.out.attach link
  read.inPorts.in.attach link
  read.outPorts.out.attach out
  read.outPorts.end.attach end
  read.outPorts.error.attach error
  [path, out, end, error]

exports['test read data from file'] = (test) ->
  [path, out, end, error] = setupComponent()
  fs.writeFileSync('test/ReadStream.input', 'test123')
  out.once 'data', (data) ->
    test.ok data.toString() == 'test123'
  end.once 'data', (data) ->
    test.ok true
    fs.unlinkSync 'test/ReadStream.input'
    test.done()
  error.once 'data', (err) ->
    test.fail err
    fs.unlinkSync 'test/ReadStream.input'
    test.done()
  path.send 'test/ReadStream.input'

exports['test read directory fails'] = (test) ->
  [path, out, end, error] = setupComponent()
  out.once 'data', (data) ->
    test.fail()
    test.done()
  end.once 'data', (data) ->
    test.fail()
    test.done()
  error.once 'data', (err) ->
    test.ok true
    test.done()
  path.send './'
