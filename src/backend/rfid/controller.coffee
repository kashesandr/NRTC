logger = require './../logger'
serialPort = require 'serialport'
Q = require 'q'

SerialPort = serialPort.SerialPort

class Rfid

    constructor: (@configs) ->

        @_pnpIdRegexp = @configs.pnpIdRegexp
        @_chunksTimeout = @configs.chunksTimeout

        @_code = ''
        @_timer = null
        @_rfidReader = null

        @comName = null
        @serialPortOptions = {}

    run: ->

        @_findComName(serialPort, @_pnpIdRegexp)
        .then (comName) =>

            @comName = comName

            @_rfidReader = new SerialPort @comName, @serialPortOptions

            if not @_rfidReader
                return logger.error "Cannot create serialPort"

            @addEvents()

    addEvents: ->

        @_rfidReader.on 'open', =>
            logger.info "Serial port #{@comName} opened"

        @_rfidReader.on 'data', @onDataReceive

        @_rfidReader.on 'error', (error) ->
            logger.error "Error on port #{@comName} occurred: #{error}"

        @_rfidReader.on 'close', =>
            logger.info "Serial port #{@comName} closed."

    onDataReceive: (d = '') =>
        deferred = Q.defer()

        @_code += d.toString 'hex'
        clearTimeout @_timer if @_timer

        @_timer = setTimeout =>
            logger.info "Data Received from the reader: '#{@_code}'"
            deferred.resolve @_code
            @_code = ''
        , @_chunksTimeout

        deferred.promise

    _findComName: (serial, pnpIdRegexp) ->
        deferred = Q.defer()

        serial.list (error, ports) ->

            if error
                msg = "Error occured when listing serialports: #{error}"
                logger.error msg
                deferred.reject msg

            for i in [0..ports.length]
                port = ports[i]
                if port?.pnpId.match pnpIdRegexp
                    return deferred.resolve port.comName

            msg = "No serialports found with pnp like: #{pnpIdRegexp}"
            logger.error msg
            deferred.reject msg

        deferred.promise

module.exports = Rfid
