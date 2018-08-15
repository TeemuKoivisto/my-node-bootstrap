if (!process.env.NODE_ENV || process.env.NODE_ENV === 'local') {
  require('dotenv').config()
}

export const config = {
  env: process.env.NODE_ENV || 'local',
  port: process.env.PORT || 8800,
  log: {
    level: process.env.LOG_LEVEL || 'info',
  },
  db: {
    user: process.env.DB_USER,
    pass: process.env.DB_PASSWORD,
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    name: process.env.DB_NAME
  },
}
