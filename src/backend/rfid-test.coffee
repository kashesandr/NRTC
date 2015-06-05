require 'coffee-script'
should = require "should"

Rfid = require './rfid'

describe 'Rfid', ->

  it 'should exist', ->
    Rfid.should.exists

  describe 'has method', ->

    rfid = null

    beforeEach ->

      configs =
        _pnpIdRegexp: new RegExp '.*', 'g'
        _chunksTimeout: 250

      rfid = new Rfid configs

    it 'run', ->
      rfid.run.should.exists

    it '_findComName', ->
      rfid._findComName.should.exists

    it 'onDataReceive', (done) ->
      rfid.onDataReceive.should.exists
      rfid.onDataReceive('123').then (d) ->
        d.should.equal '123'
        done()

