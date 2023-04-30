#!/bin/sh

# stop executing if any command fails or returns an error
set -e

# get the contents of the .env or example.env file into the script
if [ -f .env ]; then
  . .env
else
  . example.env
fi

# echo global variables in terminal
echo "DOCKER_CONTAINER=${DOCKER_CONTAINER}"
echo "POSTGRES_USER=${POSTGRES_USER}"
echo "POSTGRES_DB=${POSTGRES_DB}"


# to run homework
docker exec -it ${DOCKER_CONTAINER} \
  psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} \
  -f /docker-entrypoint-initdb.d/homework/0_drop.sql \
  -f /docker-entrypoint-initdb.d/homework/1_actors.sql \
  -f /docker-entrypoint-initdb.d/homework/2_pipeline_query.sql \
  -f /docker-entrypoint-initdb.d/homework/3_actors_history_scd.sql \
  -f /docker-entrypoint-initdb.d/homework/4_scd_generation_query.sql \
  -f /docker-entrypoint-initdb.d/homework/5_incremental_scd_query.sql 
