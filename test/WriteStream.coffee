CreateWriteStream = require '../components/CreateWriteStream'
WriteStream = require '../components/WriteStream'
socket = require('noflo').internalSocket
fs = require 'fs'

setupComponent = ->
  create = CreateWriteStream.getComponent()
  write = WriteStream.getComponent()

  path = socket.createSocket()
  link = socket.createSocket()
  error = socket.createSocket()
  data = socket.createSocket()
  out = socket.createSocket()
  create.inPorts.path.attach path
  create.outPorts.out.attach link
  write.inPorts.stream.attach link
  write.inPorts.in.attach data
  write.outPorts.out.attach out
  [path, data, out, error]

exports['test write data to file'] = (test) ->
  [path, data, out, error] = setupComponent()
  out.once 'data', (data) ->
    test.ok 'plop' == fs.readFileSync('test/WriteStream.output').toString()
    fs.unlinkSync 'test/WriteStream.output'
    test.done()
  error.once 'data', (err) ->
    test.fail err
    fs.unlinkSync 'test/WriteStream.output'
    test.done()
  path.send 'test/WriteStream.output'
  setTimeout(() ->
    data.send 'plop'
    , 500)
