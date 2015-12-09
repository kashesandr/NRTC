require 'coffee-script'
should = require "should"
chai = require 'chai'
expect = chai.expect
async = require 'async'

Rfid = require './controller'

###
for MAC the USB device looks like:
  {
    comName: '/dev/cu.usbserial',
    manufacturer: 'Prolific Technology Inc.',
    serialNumber: '',
    pnpId: '',
    locationId: '0x14200000',
    vendorId: '0x067b',
    productId: '0x2303'
  }
###

class SerialportMock
  constructor: () ->
    @ports = [
      {
        comName: '/dev/cu.usbserial1',
        manufacturer: 'Prolific Technology Inc.',
        serialNumber: '',
        pnpId: '',
        locationId: '0x14200000',
        vendorId: '0x067b',
        productId: '0x2303'
      },
      {
        comName: '/dev/cu.usbserial2',
        manufacturer: 'Prolific Technology Inc.',
        serialNumber: '',
        pnpId: '',
        locationId: '0x14200000',
        vendorId: '0x067a',
        productId: '0x2304'
      },
      {
        comName: '/dev/cu.usbserial3',
        manufacturer: 'Prolific Technology Inc.',
        serialNumber: '',
        pnpId: '',
        locationId: '0x14200000',
        vendorId: '0x067h',
        productId: '0x2300'
      }
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
        vendorId: '0x067b'
        productId: '0x2303'
        chunksTimeout: 250
      rfid = new Rfid configs

    it 'be initialized correctly', ->
      expect(rfid._vendorId).to.equal '0x067b'
      expect(rfid._productId).to.equal '0x2303'
      rfid._chunksTimeout.should.equal 250

    describe 'have working method', ->

      it 'run', ->
        rfid.run.should.exists

      it '_findComName', (done) ->
        rfid._findComName.should.exists
        serialport = new SerialportMock()
        async.parallel [
          (callback) ->
            rfid._findComName(serialport, '0x067b', '0x2303')
            .then (comName) -> callback null, comName
          (callback) ->
            rfid._findComName(serialport, '0x067a', '0x2304')
            .then (comName) -> callback null, comName
          (callback) ->
            rfid._findComName(serialport, '0x067t', '0x2304')
            .catch (error) -> callback null, error
        ], (error, results) ->
          results[0].should.equal '/dev/cu.usbserial1'
          results[1].should.equal '/dev/cu.usbserial2'
          expect(results[2]).to.deep.equal "Reader: No serialports found with vendorId 0x067t and productId 0x2304"
          done()

      it "'data-received' event", (done) ->
        rfid.on 'data-received', (d) ->
          d.should.equal '123'
          done()
        setTimeout (-> rfid._onDataReceive('123')), 250