-- ! STEP 4: Backfill query
/*
A "backfill" query for actors_history_scd that can populate all of it in 1 query
*/

CREATE TABLE actors_backfill_scd AS
    WITH 
        streak_started AS (
            SELECT
                actorid
                ,actor
                ,year
                ,quality_class
                ,LAG(quality_class, 1) -- apply LAG window function to last year's quality class
                    OVER (
                        PARTITION BY actorid
                        ORDER BY year
                    ) <> quality_class
                OR LAG(quality_class, 1)
                    OVER (
                        PARTITION BY actorid
                        ORDER BY year
                    ) IS NULL
                AS did_change
            FROM actors
        )
        -- SELECT * FROM streak_started;
        ,streak_identified AS (
            SELECT
                actorid
                ,actor
                ,quality_class
                ,year
                ,SUM(
                    CASE 
                        WHEN did_change THEN 1
                        ELSE 0
                    END
                ) OVER (
                    PARTITION BY actorid
                    ORDER BY year
                ) AS streak_identifier
            FROM streak_started
        )
        -- SELECT * FROM streak_identified;
        ,aggregated AS (
            SELECT
                actorid
                ,actor
                ,quality_class
                ,streak_identifier
                ,MIN(year) AS start_date -- find the start and end dates of each streak
                ,MAX(year) AS end_date
            FROM streak_identified
            GROUP BY 
                actorid
                ,actor
                ,quality_class
                ,streak_identifier
        )
        -- SELECT * FROM aggregated;

    SELECT
        actor
        ,actorid
        ,start_date
        ,end_date
    FROM aggregated
    ORDER BY start_date, end_date;


-- ** Query `actors_backfill_scd` table
-- SELECT * FROM actors_backfill_scd;