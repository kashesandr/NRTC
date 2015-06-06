fs = require 'fs'
path = require "path"
winston = require 'winston'
serialPort = require 'serialport'
CONFIGS = JSON.parse fs.readFileSync (path.join(__dirname,'./settings.json')), 'utf8'
DbController = require './data-storage/controller'
Rfid = require './rfid/controller'

PNP_ID_REGEXP = new RegExp CONFIGS.SERIALPORT.PNP_ID_REGEXP, 'g'
CHUNKS_TIMEOUT = CONFIGS.CHUNKS_TIMEOUT

rfidConfigs =
    pnpIdRegexp: PNP_ID_REGEXP
    chunksTimeout: CHUNKS_TIMEOUT

rfid = new Rfid rfidConfigs
rfid.run()
