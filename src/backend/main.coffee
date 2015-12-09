fs = require "fs"
path = require "path"
CONFIGS = JSON.parse fs.readFileSync (path.join(__dirname,'./settings.json')), 'utf8'
logger = require './tools/logger'

DataStorage = require './data-storage/controller'
Rfid = require './rfid/controller'

express = require 'express'
bodyParser = require 'body-parser'
morgan = require 'morgan'

###
  Setup Data Storage
###
dataStorage = new DataStorage
    parse: CONFIGS.PARSE
    className: CONFIGS.DATABASE.className

###
  Setup Rfid Reader
###
rfid = new Rfid
    manufacturer: CONFIGS.SERIALPORT.manufacturer
    chunksTimeout: CONFIGS.SERIALPORT.CHUNKS_TIMEOUT

rfid
.run()
.on 'data-received', (code) ->

    dataStorage.log(code).then (log) ->
        userId = log.get 'parentId'
        enterTime = log.get 'enterTime'
        exitTime = log.get 'exitTime'
        action = if exitTime then 'exit' else 'enter'
        logger.info "userId(#{userId}) has just #{action}ed"


###
  Setup HTTP Server
###
SERVER_CONFGS = CONFIGS.SERVER
PORT = process.argv[2] || SERVER_CONFGS.port
HOST = SERVER_CONFGS.host
rootPath = path.join __dirname, ".."
frontEndPath = path.join rootPath, 'frontend'

app = express()
app.use bodyParser()
app.use bodyParser.urlencoded extended: true
app.use express.static frontEndPath
app.use morgan('tiny')
app.listen PORT, HOST

logger.info "HTTP server opened: http://#{HOST}:#{PORT}"