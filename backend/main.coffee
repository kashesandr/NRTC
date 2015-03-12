fs = require 'fs'
SerialPort = require("serialport").SerialPort
Configs = require "./configs"
GlobalConfigs = JSON.parse fs.readFileSync './../settings.json', 'utf8'
DB = require './db'

serialPort = new SerialPort Configs.serialport.path, Configs.serialport.options
timer = {}

serialPort.on 'open', ->
    console.log "Serial port opened on #{Configs.serialport.path}"
    serialPort.on 'data', onData

serialPort.on 'error', (error) ->
    console.log "Error occurred: #{error}"

code = ''
onData = (d) ->
    code += d.toString('hex')
    clearTimeout(timer) if timer
    timer = setTimeout () ->
        console.log "Data Received: '#{code}'"
        DB.insert( GlobalConfigs.database.table.history , {code: code})
        DB.toggleActive( GlobalConfigs.database.table.tags, {code: code})
        code = ''
    , Configs.timeout