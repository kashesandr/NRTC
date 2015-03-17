fs = require 'fs'
SerialPort = require("serialport").SerialPort
Configs = require "./configs"
DbController = require './db-controller'

SERIALPORT = Configs.serialport

serialPort = new SerialPort SERIALPORT.path, SERIALPORT.options

serialPort.on 'open', ->
    console.log "Serial port opened on #{SERIALPORT.path}"
    serialPort.on 'data', onData

serialPort.on 'error', (error) ->
    console.log "Error occurred: #{error}"

code = ''
timer = {}
onData = (d) ->
    code += d.toString('hex')
    clearTimeout(timer) if timer
    timer = setTimeout () ->
        console.log "Data Received: '#{code}'"
        DbController.historyLog code
        code = ''
    , Configs.timeout