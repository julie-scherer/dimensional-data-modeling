#!/bin/bash
set -e

# Import the data dump
psql \
    -v ON_ERROR_STOP=1 \
    --username $POSTGRES_USER \
    --dbname $POSTGRES_DB \
    < /docker-entrypoint-initdb.d/data.dump


# Check if the path is a directory using the -d flag (the [] brackets are used for conditional expressions)
if [ -d /docker-entrypoint-initdb.d/queries ]; then 
    # Run any additional initialization scripts
    for f in /docker-entrypoint-initdb.d/queries/*.sql; do
        psql -U $POSTGRES_USER -d $POSTGRES_DB -f $f
    done
fi
