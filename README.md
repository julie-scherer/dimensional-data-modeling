# Week 1 Dimensional Data Modeling
This week is the code we'll be using for dimensional data modeling. It contains data for every NBA game and player for the last 15ish years!

## Base Data Model (getting started)

1. Install Postgres locally (Homebrew is really nice for installing on Mac)
-  Mac
-- This [tutorial](https://daily-dev-tips.com/posts/installing-postgresql-on-a-mac-with-homebrew/) is what I used
- Window
-- This [tutorial](https://www.sqlshack.com/how-to-install-postgresql-on-windows/) is what I used
- [Docker bash script w/ make commands](#docker-bash-script-w-make-commands)
- [Docker compose](#docker-compose-setup)
2. Use the data dump at the root of this directory and run this command. Make sure to replace <username> with your computer's username
```
psql -U <username> postgres < data.dump
```
3. Set up DataGrip to point at your locally running Postgres instance
4. Have fun querying!

## Docker Bash Script w/ Make Commands

### Prerequisites 
* [Install Docker](https://docs.docker.com/get-docker/)
* Open Docker desktop to start the daemon

Next, open a terminal, navigate to the project folder, and run the `make` commands below:

1. **To run the `setup.sh` script:**

    ```
    make up
    ```

    &rarr; This will pull the latest postgres image from [Docker Hub](https://hub.docker.com/_/postgres), start a container named `my-postgres-container` using the `docker run` command, and then inside the docker container, execute the psql command with the `data.dump` file.

2. **To start and run postgres locally:**

    ```
    make start
    ```

    &rarr; This will first start the docker container and then execute the `psql` command inside the running container to connect to the postgres server as the `postgres` user.


3. **To stop and clean container:**

    ```
    make down
    ```

    &rarr; This will stop and remove the Docker container named `my-postgres-container`, and remove the Docker image named `postgres`.

## Docker Compose Setup

### Prerequisites
 * [Install Docker](https://docs.docker.com/get-docker)
 * [Install docker compose](https://docs.docker.com/compose/install/#installation-scenarios)

Once you have docker and docker compose installed, you can open a terminal in the directory where you cloned this repo and run:

```bash
cp example.env .env # Edit the password in this file if you want
docker compose up -d
docker exec -it postgres bash # This will create an interactive shell for you within docker
psql -U ${POSTGRES_USER} ${POSTGRES_SCHEMA} < /bootcamp/data.dump
```
Congratulations :tada:! as long as your compose stack is running you should be able to connect to your data exploration tool now

## Specific Trainings
