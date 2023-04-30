FROM postgres:latest

ARG CONTAINER_PORT=${CONTAINER_PORT}

# This copied the files inside the homework/your_username/ folder
COPY queries/ /docker-entrypoint-initdb.d/queries/

# This copies the data.dump file from the build context to the /docker-entrypoint-initdb.d/ directory in the container image.
# This dir will used by the Postgres image to run any scripts that should be executed when the container is started for the first time.
COPY data.dump /docker-entrypoint-initdb.d/

# This copies the run-postgres.sh script from the build context to the /docker-entrypoint-initdb.d/ directory in the container image. 
# The script will be executed by the Postgres image when the container is started for the first time.
COPY scripts/run-postgres.sh /docker-entrypoint-initdb.d/

# This sets the execute permission on the run-postgres.sh script so it can b run as a command.
RUN chmod +x /docker-entrypoint-initdb.d/run-postgres.sh

# This sets the default command to the Postgres server process (postgres)
CMD ["postgres"]

EXPOSE $CONTAINER_PORT