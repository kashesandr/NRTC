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

for Win the USB device looks like:
  {
    comName: 'COM3',
    manufacturer: 'Prolific',
    serialNumber: '',
    pnpId: 'USB\\VID_067B&PID_2303\\6&29E6B3C2&0&4',
    locationId: '',
    vendorId: '',
    productId: ''
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
        comName: 'COM3',
        manufacturer: 'Prolific2',
        serialNumber: '',
        pnpId: 'USB\\VID_067B&PID_2303\\6&29E6B3C2&0&4',
        locationId: '',
        vendorId: '',
        productId: ''
      }
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
        manufacturer: 'prolific'
        chunksTimeout: 250
      rfid = new Rfid configs

    it 'be initialized correctly', ->
      expect(rfid._manufacturer).to.equal 'prolific'
      rfid._chunksTimeout.should.equal 250

    describe 'have working method', ->

      it 'run', ->
        rfid.run.should.exists

      describe '_findComName', ->

        serialport = null

        beforeEach ->
          serialport = new SerialportMock()

        it 'exists', ->
          rfid._findComName.should.exists

        it 'for MAC', (done) ->
          rfid._findComName(serialport, 'prolific')
          .then (comName) ->
            comName.should.equal '/dev/cu.usbserial1', '/dev/cu.usbserial1'
            done()

        it 'for Windows', (done) ->
          rfid._findComName(serialport, 'prolific2')
          .then (comName) ->
            comName.should.equal 'COM3', 'COM3'
            done()

        it 'throws error', (done) ->
          rfid._findComName(serialport, 'prolific3')
          .catch (error) ->
            expect(error).to.deep.equal "Reader: No serialports found with manufacturer = prolific3"
            done()

      it "'data-received' event", (done) ->
        rfid.on 'data-received', (d) ->
          d.should.equal '123'
          done()
        setTimeout (-> rfid._onDataReceive('123')), 250