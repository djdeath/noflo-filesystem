copy = require '../components/CopyFileSequential'
socket = require('noflo').internalSocket
fs = require 'fs'

setupComponent = ->
  c = copy.getComponent()
  source = socket.createSocket()
  destination = socket.createSocket()
  out = socket.createSocket()
  err = socket.createSocket()
  c.inPorts.source.attach source
  c.inPorts.destination.attach destination
  c.outPorts.out.attach out
  c.outPorts.error.attach err
  return [c, source, destination, out, err]

exports['copy file and disconnect at the end'] = (test) ->
  [c, source, destination, out, err] = setupComponent()
  err.once 'data', (err) ->
    test.fail(err)
    test.done()
  out.once 'data', (path) ->
    test.ok path == 'test/copy'
  out.once 'disconnect', () ->
    test.ok true
    fs.unlinkSync 'test/copy'
    test.done()
  source.send 'test/CopyFileSequential.coffee'
  source.disconnect()
  destination.send 'test/copy'
  destination.disconnect()

exports['copy file to 2 places with disconnect in between copy'] = (test) ->
  [c, source, destination, out, err] = setupComponent()
  err.once 'data', (err) ->
    test.fail(err)
    test.done()
  out.once 'data', (path) ->
    test.ok path == 'test/copy1'
    out.once 'data', (path) ->
      test.ok path == 'test/copy2'
  out.once 'disconnect', () ->
    test.ok true
    out.once 'disconnect', () ->
      test.ok true
      fs.unlinkSync 'test/copy1'
      fs.unlinkSync 'test/copy2'
      test.done()
  source.send 'test/CopyFileSequential.coffee'
  source.disconnect()
  destination.send 'test/copy1'
  destination.disconnect()
  source.send 'test/CopyFileSequential.coffee'
  source.disconnect()
  destination.send 'test/copy2'
  destination.disconnect()

exports['copy file to 2 places with no disconnect in between copy'] = (test) ->
  [c, source, destination, out, err] = setupComponent()
  gotCopy2 = false
  err.once 'data', (err) ->
    test.fail(err)
    test.done()
  out.once 'data', (path) ->
    test.equal path, 'test/copy1'
    out.once 'data', (path) ->
      test.equal path, 'test/copy2'
      fs.unlinkSync 'test/copy1'
      fs.unlinkSync 'test/copy2'
      gotCopy2 = true
    out.once 'disconnect', () ->
      test.ok gotCopy2 == true
      test.done()
  source.send 'test/CopyFileSequential.coffee'
  destination.send 'test/copy1'
  source.send 'test/CopyFileSequential.coffee'
  destination.send 'test/copy2'
  source.disconnect()
  destination.disconnect()

exports['copy file fails because missing file'] = (test) ->
  [c, source, destination, out, err] = setupComponent()
  err.once 'data', (err) ->
    test.equal err.errno, 34
    test.equal err.code, 'ENOENT'
    test.equal err.path, 'test/doesnotexist'
    test.ok true
    fs.unlinkSync 'test/copy'
    test.done()
  out.once 'data', (path) ->
    console.log('got data')
    test.fail()
    test.done()
  source.send 'test/doesnotexist'
  destination.send 'test/copy'
