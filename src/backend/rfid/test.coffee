require 'coffee-script'
should = require "should"
chai = require 'chai'
expect = chai.expect
async = require 'async'

Rfid = require './controller'

class SerialportMock
  constructor: () ->
    @ports = [
      {pnpId: 'PL2303', comName: 'COM1'},
      {pnpId: 'PL2304', comName: 'COM2'},
      {pnpId: 'PL2305', comName: 'COM3'}
    ]
  list: (callback) ->
    callback null, @ports

describe 'Rfid', ->

  it 'should exist', ->
    Rfid.should.exists

  describe 'should', ->

    rfid = null

    beforeEach ->
      configs =
        pnpIdRegexp: new RegExp 'pnp', 'g'
        chunksTimeout: 250
      rfid = new Rfid configs

    it 'be initialized correctly', ->
      expect(rfid._pnpIdRegexp).to.deep.equal new RegExp('pnp', 'g')
      rfid._chunksTimeout.should.equal 250

    describe 'have working method', ->

      xit 'run', ->
        rfid.run.should.exists

      it 'findComName', (done) ->

        rfid._findComName.should.exists

        serialport = new SerialportMock()

        async.parallel(
          [
            (callback) ->
              rfid._findComName(serialport, new RegExp("PL2303", 'g'))
              .then (comName) -> callback null, comName
            (callback) ->
              rfid._findComName(serialport, new RegExp("PL2304", 'g'))
              .then (comName) -> callback null, comName
            (callback) ->
              rfid._findComName(serialport, new RegExp("pnp", 'g'))
              .catch (error) -> callback null, error
          ], (error, results) ->
            results[0].should.equal 'COM1'
            results[1].should.equal 'COM2'
            expect(results[2]).to.deep.equal "No serialports found with pnp like: /pnp/g"
            done()
        )

      it 'onDataReceive', (done) ->
        rfid.onDataReceive.should.exists
        rfid.onDataReceive('123').then (d) ->
          d.should.equal '123'
          done()