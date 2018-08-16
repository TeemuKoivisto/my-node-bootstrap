if (!process.env.NODE_ENV || process.env.NODE_ENV === 'local') {
  require('dotenv').config()
}

export const config = {
  ENV: process.env.NODE_ENV || 'local',
  PORT: process.env.PORT || 8800,
  LOG: {
    LEVEL: process.env.LOG_LEVEL || 'info',
  },
  DB: {
    USER: process.env.DB_USER || 'pg-user',
    PASS: process.env.DB_PASSWORD || 'my-pg-password',
    HOST: process.env.DB_HOST || 'localhost',
    PORT: process.env.DB_PORT || 5440,
    NAME: process.env.DB_NAME || 'my_node_db_local'
  },
  JWT: {
    SECRET: process.env.JWT_SECRET || 'verylongrandomstring',
  }
}
