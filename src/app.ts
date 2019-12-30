import * as express from 'express'
import * as morgan from 'morgan'
import publicRoutes from './routes/public.routes'
import * as cors from 'cors'

import { errorHandler, logStream, config } from './common'

const app = express()

const corsOptions: cors.CorsOptions = {
  origin(origin, callback) {
    if (config.CORS_SAME_ORIGIN === 'false') {
      callback(null, true)
    } else {
      callback(null, false)
    }
  },
  methods: ['GET', 'POST', 'PUT', 'OPTIONS']
}

app.use(cors(corsOptions))
app.use(express.urlencoded({ extended: true }))
app.use(express.json())

app.use(morgan('short', { stream: logStream }))

app.get('/health', (req: any, res: any) => { res.sendStatus(200) })

app.use('/api', publicRoutes)
app.use(errorHandler)

export { app }
