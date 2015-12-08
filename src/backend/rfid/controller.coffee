logger = require './../tools/logger'
serialPort = require 'serialport'
Q = require 'q'
events = require 'events'

SerialPort = serialPort.SerialPort
dispatch = new events.EventEmitter()

class Rfid

    constructor: (@configs) ->

        @error = false

        @error = true if \
            not @configs.vendorId or \
            not @configs.productId or \
            not @configs.chunksTimeout

        if @error
            return logger.error "Reader: Error when initializing"
        logger.info "Reader: initialized correctly"

        @_vendorId = @configs.vendorId
        @_productId = @configs.productId

        @_chunksTimeout = @configs.chunksTimeout

        @_code = []
        @_timer = null
        @_rfidReader = null

        @comName = null
        @serialPortOptions = {}

    run: ->

        @_findComName(serialPort, @_vendorId, @_productId)
        .then (comName) =>

            @comName = comName

            @_rfidReader = new SerialPort @comName, @serialPortOptions

            if not @_rfidReader
                return logger.error "Reader: Cannot create serialPort"

            @addEvents()

            return @

    addEvents: ->

        @_rfidReader.on 'open', =>
            logger.info "Reader: Serial port #{@comName} opened"

        @_rfidReader.on 'data', @_onDataReceive

        @_rfidReader.on 'error', (error) ->
            logger.error "Reader: Error on port #{@comName} occurred: #{error}"

        @_rfidReader.on 'close', =>
            logger.info "Reader: Serial port #{@comName} closed."

    on: (eventName, callback) ->

        switch eventName
            when 'data-received' then do ->
                dispatch.on 'data-received', callback
            else return null

    _onDataReceive: (chunk) =>

        @_code.push (chunk.toString 'hex') if chunk?
        clearTimeout @_timer if @_timer

        @_timer = setTimeout =>
            code = @_code.join ''
            logger.debug "Reader: Data Received: '#{code}'"
            dispatch.emit 'data-received', code
            @_code = []
        , @_chunksTimeout

    _findComName: (serial, vendorId, productId) ->
        deferred = Q.defer()

        serial.list (error, ports) ->

            if error
                msg = "Reader: Error occured when listing serialports: #{error}"
                logger.error msg
                return deferred.reject msg

            for i in [0..ports.length]
                port = ports[i]
                if port? and (port.vendorId is vendorId) and (port.productId is productId)
                    return deferred.resolve port.comName

            msg = "Reader: No serialports found with vendorId #{vendorId} and productId #{productId}"
            logger.error msg
            deferred.reject msg

        deferred.promise

module.exports = Rfid
