#!/bin/bash

docker pull postgres
docker run \
    --name my-postgres-container \
    -e POSTGRES_PASSWORD=secretpassword \
    -p 5432:5432 \
    -d postgres
docker logs my-postgres-container

docker exec -i my-postgres-container psql -U postgres < data.dump

# chmod +x setup.sh 
# /bin/bash setup.sh

# docker exec -it my-postgres-container psql -U postgres
