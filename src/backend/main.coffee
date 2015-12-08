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
    vendorId: CONFIGS.SERIALPORT.vendorId
    productId: CONFIGS.SERIALPORT.productId
    chunksTimeout: CONFIGS.CHUNKS_TIMEOUT

rfid.run()

rfid.on 'data-received', (code) ->

    dataStorage.log(code).then (log) ->
        userId = log.get 'parentId'
        enterTime = log.get 'enterTime'
        exitTime = log.get 'exitTime'
        action = if exitTime then 'exit' else 'enter'
        logger.info "userId(#{userId}) has just #{action}ed"
