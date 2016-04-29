winston = require 'winston'

logLevel = process.env.LOG_LEVEL or 'info'

logger = new (winston.Logger)(
  transports: [
    new (winston.transports.Console)({ level: logLevel })
  ]
)

module.exports = logger
