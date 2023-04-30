-- ! STEP 5: Incremental query
/*
An "incremental" query for `actors_history_scd` that combines last years SCD and new incoming data from `actors`
*/

-- Get the max (most recent) year from actors table
-- SELECT MAX(year) FROM actor_films;

-- Check the `actors_history_scd` table exists
-- SELECT * FROM actors_history_scd;


-- ** Create incremental SCD type
CREATE TYPE incremental_scd AS (
    quality_class qual_class
    ,is_active BOOLEAN
    ,start_date INTEGER
    ,end_date INTEGER
);

-- ** Create get_quality function
CREATE FUNCTION get_quality(incremental_scd) 
RETURNS qual_class AS 'SELECT $1.quality_class' 
LANGUAGE SQL;


-- ** Run incremental query
-- DO $$ 
-- DECLARE most_recent_year INT;

-- BEGIN
--     most_recent_year := (SELECT MAX(year) FROM actors);
--     CREATE TABLE incremental_query AS
WITH 
    incoming AS (
        SELECT * FROM actors
        WHERE year = 2021 -- most_recent_year
    )
    ,current_dimensions AS ( -- select all fields from the actors_history_scd where is_active is true 
        SELECT * 
        FROM actors_history_scd
        WHERE is_active = true
    )
    ,old_dimensions AS ( -- select all fields from the actors_history_scd where is_active is false
        SELECT *
        FROM actors_history_scd
        WHERE is_active = false
    )
    ,combined AS ( -- combine the current_dimensions and incoming data based on the actor
        SELECT
            COALESCE(cd.actor, i.actor) AS actor
            ,COALESCE(cd.actorid, i.actorid) AS actorid
            ,cd.quality_class -- quality_class from the current dimensions table
            ,i.quality_class -- quality_class from the incoming table
            ,cd.is_active -- active status from the current dimensions table
            ,i.is_active -- active status from the incoming table
            ,(UNNEST(
                CASE WHEN cd.quality_class = i.quality_class AND i.is_active = cd.is_active -- if quality class and active status are same in both tables
                    THEN -- return SCD array from the current dimensions table 
                        ARRAY[ 
                            ROW(
                                cd.quality_class
                                ,cd.is_active
                                ,cd.start_date
                                ,i.year
                            )::incremental_scd
                        ]
                    ELSE -- otherwise, return SCD from current dimensions table AND incoming table
                        ARRAY[ 
                            ROW(
                                cd.quality_class
                                ,cd.is_active
                                ,cd.start_date
                                ,cd.end_date
                            )::incremental_scd
                            ,ROW(
                                i.quality_class
                                ,i.is_active
                                ,i.year
                                ,i.year
                            )::incremental_scd 
                        ]
                END
            )) AS change_data
        FROM current_dimensions cd
        FULL OUTER JOIN incoming i
            ON i.actor = cd.actor
    )

INSERT INTO actors_history_scd
    SELECT
        actor
        ,actorid
        ,(change_data :: incremental_scd).quality_class
        ,(change_data :: incremental_scd).is_active
        ,(change_data :: incremental_scd).start_date
        ,(change_data :: incremental_scd).end_date
        ,(change_data :: incremental_scd).end_date = 2021 AS is_current
    FROM combined
    UNION ALL
    SELECT
        actor
        ,actorid
        ,quality_class
        ,is_active
        ,start_date
        ,end_date
        ,is_current
    FROM old_dimensions;    

-- END $$;


-- ** Query `actors_history_scd` table
-- SELECT * FROM actors_history_scd 
-- ORDER BY start_date, end_date;