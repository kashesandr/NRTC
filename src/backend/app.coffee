fs = require 'fs'
path = require "path"
winston = require 'winston'
serialPort = require 'serialport'
CONFIGS = JSON.parse fs.readFileSync (path.join(__dirname,'./settings.json')), 'utf8'
DbController = require './db-controller'
Rfid = require './rfid'
Q = require 'q'

PNP_ID_REGEXP = new RegExp CONFIGS.SERIALPORT.PNP_ID_REGEXP, 'g'
CHUNKS_TIMEOUT = CONFIGS.CHUNKS_TIMEOUT

rfidConfigs =
    _pnpIdRegexp: PNP_ID_REGEXP
    _chunksTimeout: CHUNKS_TIMEOUT

rfid = new Rfid rfidConfigs
rfid.run()
