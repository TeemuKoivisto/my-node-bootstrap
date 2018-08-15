
require('dotenv').config()

const {
  DB_USER,
  DB_HOST,
  DB_PORT,
  DB_NAME,
  DB_PASSWORD
} = process.env

module.exports = {
  url: `jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_NAME}`,
  schemas: 'public',
  locations: 'filesystem:db/migrations',
  user: DB_USER,
  password: DB_PASSWORD,
  sqlMigrationSuffix: '.sql'
}
