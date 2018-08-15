#!bin/bash

DB_HOST=localhost
DB_PORT=5440
DB_USER=pg-user
DB_PASSWORD=my-pg-password
DB_NAME=my_node_db_local

psql postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}:${DB_PORT}/${DB_NAME} < ./db/scripts/add_test_data.sql