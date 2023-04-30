## :rocket: Create cumulative actors table and slowly changing dimension in PostgreSQL

### :information_source: Prerequisites 
* [Docker](https://docs.docker.com/get-docker/) installed
* Make installed (optional)
* Database client installed (optional)

The instructions below assume you have an `.env` file in the root directory with the following environment variables defined. Otherwise, it will use the `example.env` file.

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


3. Run the following commands to execute the SQL files in the `queries/` directory inside the Docker container:
    
    ```
    chmod +x scripts/run-queries.sh
	./scripts/run-queries.sh

    # or, simply run this Make command:
    # make sql
    ```

    &rarr; This will create the `actors`, `actors_backfill_scd`, and `actors_history_scd` tables in the Postgres database.

4. When you are finished with the Postgres container, you can clean up Docker with the following commands:

    ```
    docker stop my-postgres-container \
    && docker rm my-postgres-container \
    && docker rmi my-postgres-image

    # alternatively, if you have Make:
    # make down
    ```

    &rarr; This will **stop and remove the Docker container** named `my-postgres-container`, and **remove the Docker image** named `postgres`. 


### :electric_plug: Connecting to a database client

To connect a database client to the Postgres instance running in Docker, you can follow these steps:

1. Open the client and create a new PostgreSQL connection.

2. In the "Connection Settings" window, set the following properties:

    * **Host**: The IP address of the Docker container running the PostgreSQL instance. You can find this printed in the terminal from when you ran the `run-docker.sh` script. It will most likely be `0.0.0.0` or `localhost`.

    * **Port**: The port that you exposed when you started the container. This should be the same as the `$CONTAINER_PORT` variable in your `.env` or `example.env` file. Default port is `5432`.

    * **Database**: The name of the database that you want to connect to. This should be the same as the `$POSTGRES_DB` variable in your `.env` or `example.env` file. Default is `postgres`.

    * **Username**: The username that you want to use to connect to the database. This should be the same as the `$POSTGRES_USER` variable in your `.env` or `example.env` file. Default is `postgres`.

    * **Password**: The password that you want to use to connect to the database. This should be the same as the `$POSTGRES_PASSWORD` variable in your `.env` or `example.env` file. Default is `postgres`.

    Once you have filled in these properties, click "Test Connection" to make sure that client can connect to the database.

3. If the test connection is successful, click "Finish" or "Save" to save the connection. You should now be able to use the database client to manage your PostgreSQL database running in Docker.
