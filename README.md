## :rocket: Dimensional Data Modeling

This repository uses data on actor films to generate a cumulative table and analyze slowly changing dimensions in a PostgreSQL database running inside Docker.

### :information_source: Prerequisites 
 * [Install Docker](https://docs.docker.com/get-docker)
 * [Install Docker Compose](https://docs.docker.com/compose/install/#installation-scenarios)
 * Install Make (if on Windows, optional)
 * Set up [DataGrip](https://www.jetbrains.com/datagrip/buy/#discounts), [DBeaver](https://dbeaver.io/download/), or your [VS Code extension](https://marketplace.visualstudio.com/items?itemName=cweijan.vscode-postgresql-client2) to point at your locally running Postgres instance

### :pencil: Instructions

1. Start the Docker daemon, open a terminal window, and navigate to the directory where you cloned the repository.

2. Open a terminal and copy `example.env` to `.env` file and adjust the configurations to your liking. 
    
    ```bash
    cp example.env .env
    ```

3. To start the container, run one of these commands:

    ```bash
    docker compose up # to run with log output
    
    docker compose up -d # to run in the background

    make up # if you have make installed
    ```

    &rarr; Congratulations :tada:! as long as your compose stack is running you should be able to connect to your data exploration tool now.

4. When you are finished with the container, you can clean up Docker with the following commands:

    ```bash
    docker compose down # to stop the container
    
    docker compose down -v # to remove volumes as well
    
    make down # if you have make installed
    ```

    &rarr; Using `make down` will **stop and remove the Docker container** named `my-postgres-container`, or whatever you changed it to in the `.env` file, and **remove the Docker image** named `postgres`.


### :electric_plug: Connecting to a database client

To connect a database client to the Postgres instance running in Docker, you can follow these steps:

1. Open the client and create a new PostgreSQL connection.

2. In the "Connection Settings" window, set the following properties:

    * **Host**: The IP address of the Docker container running the PostgreSQL instance. It will most likely be `0.0.0.0` or `localhost`. If neither of those work, run `make ip` to get the IP address the Docker container and go from there.

    * **Port**: The port that you exposed when you started the container. This should be the same as the `$CONTAINER_PORT` variable in your `.env`.

    * **Database**: The name of the database that you want to connect to. This should be the same as the `$POSTGRES_DB` variable in your `.env`.

    * **Username**: The username that you want to use to connect to the database. This should be the same as the `$POSTGRES_USER` variable in your `.env`.

    * **Password**: The password that you want to use to connect to the database. This should be the same as the `$POSTGRES_PASSWORD` variable in your `.env`.

    Once you have filled in these properties, click "Test Connection" to make sure that the client can connect to the database.

3. If the test connection is successful, click "Finish" or "Save" to save the connection. You should now be able to use the database client to manage your PostgreSQL database running in Docker.
