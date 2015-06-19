fs = require "fs"
path = require "path"
CONFIGS = JSON.parse fs.readFileSync (path.join(__dirname,'./settings.json')), 'utf8'

DataStorage = require './data-storage/controller'
Rfid = require './rfid/controller'

dataStorage = new DataStorage
    parseConfigs: CONFIGS.PARSE
    table: CONFIGS.DATABASE.table

rfid = new Rfid
    pnpIdRegexp: new RegExp CONFIGS.SERIALPORT.PNP_ID_REGEXP, 'g'
    chunksTimeout: CONFIGS.CHUNKS_TIMEOUT

rfid.run()
rfid.onDataReceive.then (code) ->
    # create a user if not exists
    # log the action of the user
    #DataStorage.historyLog code
