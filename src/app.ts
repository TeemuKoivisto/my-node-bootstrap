import * as express from 'express'
import * as morgan from 'morgan'
import publicRoutes from './routes/public.routes'
import * as cors from 'cors'
import * as bodyParser from 'body-parser'

import { errorHandler, logStream, config } from './common'

const app = express()

const corsOptions: cors.CorsOptions = {
  origin(origin, callback) {
    if (config.env === 'local') {
      callback(null, true)
    } else {
      callback(null, false)
    }
  },
  methods: ['GET', 'POST', 'PUT', 'OPTIONS']
}

app.use(cors(corsOptions))
app.use(bodyParser.urlencoded({
  extended: true,
}))
app.use(bodyParser.json())

app.use(morgan('short', { stream: logStream }))

app.use('', publicRoutes)
app.use(errorHandler)

export { app }
