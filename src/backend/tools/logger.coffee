winston = require 'winston'

logger = new (winston.Logger)(
  transports: [
    new (winston.transports.Console)({ level: 'info' })
  ]
)

module.exports = logger
