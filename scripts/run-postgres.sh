#!/bin/bash

# exit immediately if an error occurs or any command exits with a non-zero status
set -e

# run the psql command with the following options:
#   -v ON_ERROR_STOP=1: tells psql to stop executing the script if an error occurs
#   --username "$POSTGRES_USER": specifies the database user to connect as
#   --dbname "$POSTGRES_DB": specifies the name of the database to connect to
#   < /docker-entrypoint-initdb.d/data.dump: specifies the data to import the data from into the container
psql \
    -v ON_ERROR_STOP=1 \
    --username "$POSTGRES_USER" \
    --dbname "$POSTGRES_DB" \
    < /docker-entrypoint-initdb.d/data.dump
