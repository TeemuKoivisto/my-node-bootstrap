if (!process.env.NODE_ENV || process.env.NODE_ENV === 'local') {
  require('dotenv').config()
}

export const config = {
  env: process.env.NODE_ENV || 'local',
  port: process.env.PORT || 8800,
  log: {
    level: process.env.LOG_LEVEL || 'info',
    colorized: process.env.LOG_COLORS || true
  },
}
