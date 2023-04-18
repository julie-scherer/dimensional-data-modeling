# Week 1 Dimensional Data Modeling
This week is the code we'll be using for dimensional data modeling. It contains data for every NBA game and player for the last 15ish years!

Generally you will need (specific instructions below):
- Postgres installed 
- A database management environment (DataGrip, DBeaver, VS Code with extensions) that allows you to edit SQL & visualize tables

## Base Data Model (getting started)

1. Install Postgres locally (Homebrew is really nice for installing on Mac)
-  Mac
-- This [tutorial](https://daily-dev-tips.com/posts/installing-postgresql-on-a-mac-with-homebrew/) is what I used
- Windows
-- This [tutorial](https://www.sqlshack.com/how-to-install-postgresql-on-windows/) is what I used
- [Dockerfile + bash script](#rocket-run-dockerfile-in-shell-script--connect-to-dbeaver) made by @schererjulie
-- You can skip step 3 if you use this method. 
- [Docker compose](#docker-compose-setup) made by @sreeladas
-- This allows you to use the interactive Postgres shell inside a Docker container (Terminal).
2. Use the data dump at the root of this directory and run this command. Make sure to replace <username> with your computer's username
```
psql -U <username> postgres < data.dump
```
3. Set up DataGrip to point at your locally running Postgres instance
4. Have fun querying!

## :rocket: Run Dockerfile in Shell Script & Connect to DBeaver

### :information_source: Prerequisites 
* [DBeaver](https://dbeaver.io/download/) installed
* [Docker](https://docs.docker.com/get-docker/) installed
* Make installed (optional)
* The instructions below assume you have an `.env` file in the root directory with the following environment variables defined. Otherwise, it will use the `example.env` file.

    ```
    DOCKER_CONTAINER=my-postgres-container
    DOCKER_IMAGE=my-postgres-image
    POSTGRES_USER=my-user
    POSTGRES_PASSWORD=my-password
    POSTGRES_DB=my-db
    HOST_PORT=5432
    CONTAINER_PORT=5432
    ```

### :pencil: Instructions

1. Start the Docker daemon, open a terminal window, and navigate to the project root directory.

2. Run the following commands to make the script file executable and run the script:
    
    ```
    chmod +x scripts/run-docker.sh
    ./scripts/run-docker.sh

    # or, run this command if you have Make:
    # make up
    ```

    &rarr; The `run-docker.sh` script will build a Docker image using the postgres image on [Docker Hub](https://hub.docker.com/_/postgres), start a new container from the image, and output the IP address and port number of the container. You can then use the IP address and port number to connect to the Postgres database in the container.


3. When you are finished with the container, you can clean up Docker with the following commands:

    ```
    docker stop my-postgres-container \
    && docker rm my-postgres-container \
    && docker rmi my-postgres-image

    # alternatively, if you have Make:
    # make down
    ```

    &rarr; This will stop and remove the Docker container named `my-postgres-container`, and remove the Docker image named `postgres`.

### :electric_plug: Connecting to DBeaver

To connect DBeaver to the Postgres instance running in Docker, you can follow these steps:

1. Open DBeaver and create a new PostgreSQL connection. In the "New Connection" window, select "PostgreSQL" and click "Next".

2. In the "Connection Settings" window, set the following properties:

    * **Host**: The IP address of the Docker container running the PostgreSQL instance. You can find this printed in the terminal from when you ran the `run-docker.sh` script. It will most likely be `0.0.0.0` or `localhost`.

    * **Port**: The port that you exposed when you started the container. This should be the same as the `$CONTAINER_PORT` variable in your `.env` or `example.env` file.

    * **Database**: The name of the database that you want to connect to. This should be the same as the `$POSTGRES_DB` variable in your `.env` or `example.env` file.

    * **Username**: The username that you want to use to connect to the database. This should be the same as the `$POSTGRES_USER` variable in your `.env` or `example.env` file.

    * **Password**: The password that you want to use to connect to the database. This should be the same as the `$POSTGRES_PASSWORD` variable in your `.env` or `example.env` file.

    Once you have filled in these properties, click "Test Connection" to make sure that DBeaver can connect to the database.

3. If the test connection is successful, click "Finish" to save the connection. You should now be able to use DBeaver to manage your PostgreSQL database running in Docker.

## Docker Compose Setup

### Prerequisites
 * [Install Docker](https://docs.docker.com/get-docker)
 * [Install docker compose](https://docs.docker.com/compose/install/#installation-scenarios)

**Note:** This is an **alternative** to the setup above using [Dockerfile, bash and DBeaver](#rocket-run-dockerfile-in-shell-script--connect-to-dbeaver)

Once you have docker and docker compose installed, you can open a terminal in the directory where you cloned this repo and run:

```bash
cp example.env .env # Edit the password in this file if you want
docker compose up -d
docker exec -it postgres bash # This will create an interactive shell for you within docker
psql -U ${POSTGRES_USER} ${POSTGRES_SCHEMA} < /bootcamp/data.dump
```
Congratulations :tada:! as long as your compose stack is running you should be able to connect to your data exploration tool now

## Specific Trainings
