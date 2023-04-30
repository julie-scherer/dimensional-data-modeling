-- SELECT COUNT(*) 
-- FROM players
-- WHERE player_name='Michael Jordan';


-- ** CREATING TABLE ** --
-- DROP TABLE players_scd_table;
CREATE TABLE players_scd_table AS -- create a new table called "players_scd_table"

    WITH 
        -- create a CTE "lagged" selecting data from players
        lagged AS (    
            -- select relevant columns from "players" table
            SELECT
                player_name,
                current_season,
                
                -- apply LAG window function to previous season's active status
                is_active,
                LAG(is_active, 1)
                    OVER (
                        PARTITION BY player_name
                        ORDER BY current_season)
                        AS is_active_last_season,
                
                -- apply LAG window function to previous season's scoring class
                scoring_class,
                LAG(scoring_class, 1)
                    OVER (
                            PARTITION BY player_name
                            ORDER BY current_season)
                        AS scoring_class_last_season
            
            FROM players 
        )

        -- create a CTE "identified" selecting data from lagged
        ,identified AS (
            SELECT
                player_name,
                current_season,
                scoring_class,
                is_active,
                -- create a new column called "did_change" 
                -- to identify if there was a change in active 
                -- status or scoring class from the last season
                CASE
                    WHEN is_active <> is_active_last_season THEN 1
                    WHEN scoring_class <> scoring_class_last_season THEN 1
                    WHEN scoring_class_last_season IS NULL THEN 1
                    ELSE 0
                END as did_change
            FROM lagged
        )
            
        -- create a CTE "streaks" selecting data from identified
        ,streaks AS (
            SELECT
                player_name,
                current_season,
                scoring_class,
                is_active,
                -- create a new column called "streak_identifier" 
                -- to group streaks of consecutive seasons with 
                -- same active status and scoring class together
                SUM(did_change) OVER (
                    PARTITION BY player_name 
                    ORDER BY current_season
                ) AS streak_identifier
            FROM identified
        )
            
        -- create a CTE "aggregated" selecting data from streaks
        ,aggregated AS (
            SELECT
                player_name,
                scoring_class,
                is_active,
                streak_identifier,
                MIN(current_season) AS start_date,
                MAX(current_season) AS end_date
            FROM streaks

            -- aggregate the data and find the start and end dates of each streak
            GROUP BY
                player_name,
                scoring_class,
                is_active,
                streak_identifier
        )

    -- select all columns from the "aggregated" table and 
    -- insert them into the new "players_scd_table" table
    SELECT * FROM aggregated;


-- ~ alternative select statements ~
SELECT * FROM players_scd_table;

-- SELECT 
-- 	ps.player_name, 
-- 	ps.pts,
-- 	ps.season,
-- 	a.scoring_class,
-- 	a.start_date,
-- 	a.end_date
-- FROM player_seasons ps
-- 	JOIN aggregated a
-- 		ON a.player_name = ps.player_name 
-- 		AND ps.season BETWEEN a.start_date and a.end_date;



-- ** ADVANCED BS - DONT WORRY ABOUT IT ** --
/*
CREATE UNIQUE INDEX creates an index on one or more columns of a table.
players_scd_index is the name given to the index being created.
ON players_scd(player_name, start_date) specifies that the index is being created 
    on the player_name and start_date columns of the players_scd table.
UNIQUE specifies that the values in the indexed columns must be unique.
*/
-- CREATE UNIQUE INDEX players_scd_index
-- 	ON players_scd(player_name, start_date); 

/*
CREATE MATERIALIZED VIEW creates a materialized view, 
    which is a precomputed result set that is stored as a physical table.
players_scd is the name given to the materialized view being created.
REFRESH MATERIALIZED VIEW refreshes the materialized view to ensure that its data is up to date with the underlying tables. 
    This line of code is telling PostgreSQL to refresh the players_scd materialized view.
*/
-- CREATE MATERIALIZED VIEW players_scd AS
-- REFRESH MATERIALIZED VIEW players_scd;




-- ** CREATING SCD TYPE ** --
-- ~ example ~
-- CREATE TYPE myrowtype AS (f1 int, f2 text, f3 numeric);
-- DROP TYPE scd_type;
CREATE TYPE scd_type AS (
    -- f1 int,
    scoring_class scorer_class,
    is_active BOOLEAN,
    start_date INTEGER,
    end_date INTEGER
);


-- ** CREATING FUNCTION **
-- ~ example ~
-- CREATE FUNCTION getf1(myrowtype) RETURNS int AS 'SELECT $1.f1' LANGUAGE SQL;
-- DROP FUNCTION getf1;
CREATE FUNCTION getf1(scd_type) 
RETURNS scorer_class AS 'SELECT $1.scoring_class' 
LANGUAGE SQL;



-- ** MAIN CTE ** --
WITH 
    incoming AS (
        SELECT * FROM players
        WHERE current_season = 2022
    )

    -- Select all the metrics and properties that are current from the scd_table
    ,current_dimensions AS (
        SELECT * 
        FROM players_scd_table
        WHERE is_active = true
    )

    -- Select all the metrics and properties that are not current from the scd_table
    ,old_dimensions AS (
        SELECT *
        FROM players_scd_table
        WHERE is_active = false
    )

    -- Combine the current_dimensions and incoming data based on the player_name
    -- Return the scoring class, active status, start and end date for each row
    ,combined AS (
        SELECT
            COALESCE(cd.player_name, i.player_name) AS player_name -- Coalesce handles NULL values to give a non-NULL value
            ,cd.scoring_class -- Scoring class from the current dimensions table
            ,i.scoring_class -- Scoring class from the incoming table
            ,cd.is_active -- Active status from the current dimensions table
            ,i.is_active -- Active status from the incoming table
            ,(UNNEST(
                -- If the scoring class and active status are same in both tables
                CASE WHEN 
                    cd.scoring_class = i.scoring_class
                    AND i.is_active = cd.is_active
                
                -- Return scoring class, active status, start date from the current dimensions table 
                -- and the current season from the incoming table
                THEN ARRAY[
                    ROW(
                        cd.scoring_class,
                        cd.is_active,
                        cd.start_date,
                        i.current_season
                    )::scd_type] 
                
                -- Otherwise
                -- Return scoring class, active status, start date, and end date from the current dimensions table
                -- Return scoring class, active status, start date, and end date as current season from the incoming table
                ELSE ARRAY[
                    ROW(
                        cd.scoring_class,
                        cd.is_active,
                        cd.start_date,
                        cd.end_date
                    )::scd_type, 
                    ROW(
                        i.scoring_class,
                        i.is_active,
                        i.current_season,
                        i.current_season
                    )::scd_type 
                ]
                END
            )).scoring_class AS change_data -- Combine the arrays of data and return only the scoring class
        
        FROM current_dimensions cd
        FULL OUTER JOIN incoming i
            ON i.player_name = cd.player_name
    )

-- Return the results of the combined data
SELECT * FROM combined;



-- ** VIEWING CUMULATIVE TABLE AND SCD TABLE **
SELECT 
    -- *
    player_name
    ,draft_number
    ,current_season
    ,seasons
    ,scoring_class
    ,is_active
FROM players LIMIT 5;

SELECT * FROM players_scd_table LIMIT 5;