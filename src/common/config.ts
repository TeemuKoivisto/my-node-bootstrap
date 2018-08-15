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
    user: process.env.DB_USER || 'pg-user',
    pass: process.env.DB_PASSWORD || 'my-pg-password',
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5440,
    name: process.env.DB_NAME || 'my_node_db_local'
  },
}
