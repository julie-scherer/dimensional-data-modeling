-- ! STEP 1: Create actors table
/*
A DDL for an actors table that has:
- a films array of struct
- a quality_class field that is based on up to their most recent 5 films
- a is_active field that describes if an actor is making films this year
*/

-- ** Create `qual_class` and `films_array` types
CREATE TYPE qual_class AS ENUM (
    'bad'
    ,'average'
    ,'good'
    ,'star'
);
CREATE TYPE films_array AS (
    film TEXT
    ,votes INT
    ,rating REAL
    ,filmid TEXT
);


-- ** Create `actors` table **
CREATE TABLE actors (
    actor TEXT
    ,actorid TEXT
    ,year INT
    ,films films_array[]
    ,avg_rating REAL
    ,quality_class qual_class -- a single value from the qual_class type
    ,is_active BOOLEAN
    ,PRIMARY KEY (actorid, actor, year)
);
