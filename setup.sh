#!/bin/bash

export CONTAINER_NAME='my-postgres-container'
export PG_PASSWORD='secretpassword'

docker pull postgres
docker run \
    --name ${CONTAINER_NAME} \
    -e POSTGRES_PASSWORD=${CONTAINER_NAME} \
    -p 5432:5432 \
    -d postgres

sleep 2

docker exec -i ${CONTAINER_NAME} psql -U postgres < data.dump

# docker logs ${CONTAINER_NAME}