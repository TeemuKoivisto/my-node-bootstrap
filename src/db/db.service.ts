import { Pool } from 'pg'

import { config } from '../common/config'

const pool = new Pool({
  user: config.db.user,
  host: config.db.host,
  database: config.db.name,
  password: config.db.pass,
  port: config.db.port as number,
})

export const dbService = {
  async queryOne(query: string, params?: any[]) {
    const { rows } = await pool.query(query, params)
    return rows[0]
  },
  async queryMany(query: string, params?: any[]) {
    const { rows } = await pool.query(query, params)
    return rows
  },
}
