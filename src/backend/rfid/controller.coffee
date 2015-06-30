logger = require './../tools/logger'
serialPort = require 'serialport'
Q = require 'q'
events = require 'events'

eventEmitter = new events.EventEmitter()

SerialPort = serialPort.SerialPort

class Rfid

    constructor: (@configs) ->

        @error = false

        @error = true if \
            not @configs?.pnpIdRegexp or \
            not @configs.chunksTimeout

        if @error
            return logger.error(
                "Error when initializing Rfid controller"
            )

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

            return @

    addEvents: ->

        @_rfidReader.on 'open', =>
            logger.info "Serial port #{@comName} opened"

        @_rfidReader.on 'data', @_onDataReceive

        @_rfidReader.on 'error', (error) ->
            logger.error "Error on port #{@comName} occurred: #{error}"

        @_rfidReader.on 'close', =>
            logger.info "Serial port #{@comName} closed."

        eventEmitter.on 'data-received', (code) =>
            @when('data-received') = do ->
                deferred = Q.defer()
                deferred.resolve code
                deferred.promise

    when: (event) ->
        switch event
            when 'data-received' then return
            else return null

    _onDataReceive: (d = '') =>

        @_code += d.toString 'hex' if d?
        clearTimeout @_timer if @_timer

        @_timer = setTimeout =>
            logger.info "Data Received from the reader: '#{@_code}'"
            eventEmitter.emit 'data-received', @_code
            @_code = ''
        , @_chunksTimeout


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
