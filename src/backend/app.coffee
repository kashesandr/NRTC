fs = require 'fs'
path = require "path"
winston = require 'winston'
serialPort = require 'serialport'
CONFIGS = JSON.parse fs.readFileSync (path.join(__dirname,'./settings.json')), 'utf8'
DbController = require './db-controller'

PNP_ID_REGEXP = new RegExp CONFIGS.SERIALPORT.PNP_ID_REGEXP, 'g'
CHUNKS_TIMEOUT = CONFIGS.CHUNKS_TIMEOUT

code = ''
timer = null
rfidReader = null
serialPortOptions = {}
SerialPort = serialPort.SerialPort

findComNameAsync = (serial, pnpIdRegexp, callback) ->
    serial.list (error, ports) ->
        return winston.error "Error occured when listing through serialports: #{error}" if error
        for i in [0..ports.length]
            port = ports[i]
            if port?.pnpId.match pnpIdRegexp
                return callback null, port.comName
        return callback "The device #{pnpIdRegexp} isn't connected", null

onDataReceive = (d) ->
    code += d.toString 'hex'
    clearTimeout timer if timer
    timer = setTimeout ->
        winston.info "Data Received from the reader: '#{code}'"
        DbController.historyLog code
        code = ''
    , CHUNKS_TIMEOUT

findComNameAsync serialPort, PNP_ID_REGEXP, (error, comName) ->

    return winston.error error if error

    rfidReader = new SerialPort comName, serialPortOptions

    rfidReader.on 'open', ->
        winston.info "Serial port opened on #{comName}"

    rfidReader.on 'data', onDataReceive

    rfidReader.on 'error', (error) ->
        winston.error "Error occurred: #{error}"

    rfidReader.on 'close', ->
        winston.info "Serial port closed: #{comName}"