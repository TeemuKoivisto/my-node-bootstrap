// const { Pool } = require('pg')
// const { db } = require('./config')

// const pool = new Pool({
//   user: db.user,
//   host: db.host,
//   database: db.name,
//   password: db.pass,
//   port: db.port,
// })

// export const dbService = {
//   async queryOne(query, params) {
//     const { rows } = await pool.query(query, params)
//     return rows[0]
//   },
//   async queryMany(query, params) {
//     const { rows } = await pool.query(query, params)
//     return rows
//   },
// }
