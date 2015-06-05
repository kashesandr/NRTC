winston = require 'winston'
serialPort = require 'serialport'
Q = require 'q'

SerialPort = serialPort.SerialPort

class Rfid

    constructor: (@configs) ->

        @_code = ''
        @_timer = null
        @_pnpIdRegexp = @configs.pnpIdRegexp
        @_chunksTimeout = @configs.chunksTimeout
        @_rfidReader = null

        @comName = null
        @serialPortOptions = {}

    run: ->

        @_findComName(serialPort, @_pnpIdRegexp)
        .then (comName) =>

            @comName = comName

            @_rfidReader = new SerialPort @comName, @serialPortOptions

            if not @_rfidReader
                return winston.error "Cannot create serialPort"

            @addEvents()

    addEvents: ->

        @_rfidReader.on 'open', =>
            winston.info "Serial port opened on #{@comName}"

        @_rfidReader.on 'data', @onDataReceive

        @_rfidReader.on 'error', (error) ->
            winston.error "Error occurred: #{error}"

        @_rfidReader.on 'close', =>
            winston.info "Serial port closed: #{@comName}"

    onDataReceive: (d) ->
        deferred = Q.defer()

        @_code += d.toString 'hex'
        clearTimeout @_timer if @_timer
        @_timer = setTimeout =>
            winston.info "Data Received from the reader: '#{@_code}'"
            deferred.resolve @_code
            @_code = ''
        , @_chunksTimeout

        deferred.promise

    _findComName: (serial, pnpIdRegexp) ->
        deferred = Q.defer()

        serial.list (error, ports) ->

            if error
                msg = "Error occured when listing serialports: #{error}"
                winston.error msg
                deferred.reject msg

            for i in [0..ports.length]
                port = ports[i]
                if port?.pnpId.match _pnpIdRegexp
                    deferred.resolve port.comName

            msg = "No serialports found with such #{_pnpIdRegexp}: #{error}"
            winston.error msg
            deferred.reject msg

        deferred.promise

module.exports = Rfid
