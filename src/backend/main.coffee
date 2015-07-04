fs = require "fs"
path = require "path"
CONFIGS = JSON.parse fs.readFileSync (path.join(__dirname,'./settings.json')), 'utf8'
logger = require './tools/logger'

DataStorage = require './data-storage/controller'
Rfid = require './rfid/controller'

dataStorage = new DataStorage
    parse: CONFIGS.PARSE
    className: CONFIGS.DATABASE.className

rfid = new Rfid
    pnpIdRegexp: new RegExp CONFIGS.SERIALPORT.PNP_ID_REGEXP, 'g'
    chunksTimeout: CONFIGS.CHUNKS_TIMEOUT

rfid.run()

rfid.on 'data-received', (code) ->
    dataStorage.log(code).then (log) ->
       userId = log.get 'parentId'
       action = log.get 'action'
       logger.info "userId(#{userId}) has just #{action}ed"
