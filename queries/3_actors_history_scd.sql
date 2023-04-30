-- ! STEP 3: Create actors_history_scd table
/*
- A DDL for an `actors_history_scd` table that has:
    - type 2 dimension modeling (i.e. start_date and end_date)
    - tracks `quality_class` and `is_active` for each actor in `actors`
*/

-- Preview `actors` table
-- SELECT * FROM actors LIMIT 5;


-- ** Create `actors_history_scd` table
CREATE TABLE actors_history_scd (
    actor TEXT
    ,actorid TEXT
    ,quality_class qual_class
    ,is_active BOOLEAN
    ,start_date INT
    ,end_date INT
    ,is_current BOOLEAN
);
