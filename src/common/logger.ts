import * as winston from 'winston'
import { config } from './config'

export const log: winston.Logger = winston.createLogger({
  level: config.log.level,
  transports: [
    new winston.transports.Console({
      level: config.log.level,
    }),
  ]
})

export const logStream = {
  write: (message: string) => { log.info(message) }
}
