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
echo "DOCKER_IMAGE=${DOCKER_IMAGE}"
echo "POSTGRES_USER=${POSTGRES_USER}"
echo "POSTGRES_PASSWORD=${POSTGRES_PASSWORD}"
echo "POSTGRES_DB=${POSTGRES_DB}"
echo "HOST_PORT=${HOST_PORT}"
echo "CONTAINER_PORT=${CONTAINER_PORT}"

# stop and remove the container if it is running
if [[ "$(docker ps -q -f name=$DOCKER_CONTAINER)" ]]; then
    docker stop $DOCKER_CONTAINER
    docker rm $DOCKER_CONTAINER
fi

# build the Docker image
echo "Building Docker image..."
docker build -t "$DOCKER_IMAGE" . \
    --build-arg CONTAINER_PORT="$CONTAINER_PORT"
sleep 1

# start a new container from the image
echo "Starting container..."
docker run --name "$DOCKER_CONTAINER" \
    -e POSTGRES_PASSWORD="$POSTGRES_PASSWORD" \
    -d -p "$HOST_PORT:$CONTAINER_PORT" \
    "$DOCKER_IMAGE"
sleep 1

# get the IP address of the container
DOCKER_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$DOCKER_CONTAINER")
DOCKER_PORT=$(docker port $DOCKER_CONTAINER)
echo "Container $DOCKER_CONTAINER running! Forwarding connections from $DOCKER_PORT"


# # (optional) save a dump of the postgres db running inside the Docker container to a file named "data.dump"
# # you can then import the SQL script into any database management tool you'd like
# docker exec ${DOCKER_CONTAINER} \
#   pg_dump -U postgres -t actor_films postgres > data.dump


# # (optional) now that the container is running, execute the psql command inside the container
# docker exec -it ${DOCKER_CONTAINER} \
#     psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}