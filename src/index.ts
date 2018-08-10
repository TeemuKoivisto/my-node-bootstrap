import { app } from './app'
import { config, log } from './common'

app.listen(config.port, () => {
  log.info(`My Node bootstrap started at port: ${config.port}`)
})

process.on('exit', () => {
  log.info('Shutting down server')
})
