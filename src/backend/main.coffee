fs = require 'fs'
path = require "path"
winston = require 'winston'
CONFIGS = JSON.parse fs.readFileSync (path.join(__dirname,'./settings.json')), 'utf8'
DataStorage = require './data-storage/controller'
Rfid = require './rfid/controller'

PNP_ID_REGEXP = new RegExp CONFIGS.SERIALPORT.PNP_ID_REGEXP, 'g'
CHUNKS_TIMEOUT = CONFIGS.CHUNKS_TIMEOUT

rfid = new Rfid
    pnpIdRegexp: PNP_ID_REGEXP
    chunksTimeout: CHUNKS_TIMEOUT
rfid.run()
rfid.onDataReceive.then (code) ->
    # create a user if not exists
    # log the action of the user
    #DataStorage.historyLog code
