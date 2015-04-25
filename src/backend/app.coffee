fs = require 'fs'
SerialPort = require("serialport").SerialPort
CONFIGS = JSON.parse fs.readFileSync './settings.json', 'utf8'
DbController = require './db-controller'

SERIALPORT = CONFIGS.serialport

serialPort = new SerialPort SERIALPORT.path, SERIALPORT.options
code = ''
timer = null


onData = (d) ->
    code += d.toString('hex')
    clearTimeout(timer) if timer
    timer = setTimeout () ->
        console.log "Data Received: '#{code}'"
        DbController.historyLog code
        code = ''
    , CONFIGS.chunksReceiveTimeout

serialPort.on 'open', ->
    console.log "Serial port opened on #{SERIALPORT.path}"
    serialPort.on 'data', onData

serialPort.on 'error', (error) ->
    console.log "Error occurred: #{error}"
