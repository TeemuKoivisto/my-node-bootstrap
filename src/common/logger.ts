import * as winston from 'winston'
import { config } from './config'

export const log: winston.Logger = winston.createLogger({
  level: config.log.level,
  format: winston.format.combine(
    winston.format.colorize(),
    winston.format.simple(),
  ),
  transports: [
    new winston.transports.Console({
      level: config.log.level,
    }),
  ],
  exitOnError: false
})

export const logStream = {
  write: (message: string) => { log.info(message) }
}
