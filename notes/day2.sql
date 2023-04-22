-- SELECT COUNT(*) 
-- FROM players
-- WHERE player_name='Michael Jordan';


-- ** CREATING TABLE ** --
-- DROP TABLE players_scd_table;
CREATE TABLE players_scd_table AS
WITH lagged AS (
    SELECT
    	player_name,
       current_season,
       is_active,
       LAG(is_active, 1)
           OVER (
               PARTITION BY player_name
               ORDER BY current_season)
       AS is_active_last_season,
       scoring_class,
       LAG(scoring_class, 1)
           OVER (
           PARTITION BY player_name
           ORDER BY current_season)
        AS scoring_class_last_season
	FROM players
	),
	
	 identified AS (
	     SELECT
	        player_name,
	        current_season,
	        scoring_class,
	        is_active,
	        CASE
	            WHEN is_active <> is_active_last_season THEN 1
	            WHEN scoring_class <> scoring_class_last_season THEN 1
	            WHEN scoring_class_last_season IS NULL THEN 1
	            ELSE 0
	        END as did_change
	     FROM lagged
	     
	 ),
     
	 streaks AS (
	     SELECT
	        player_name,
	        current_season,
	        scoring_class,
	        is_active,
	        SUM(did_change) OVER (PARTITION BY player_name ORDER BY current_season) AS streak_identifier
	     FROM identified
	 ),
	 aggregated AS (
	    SELECT
	        player_name,
	        scoring_class,
	        is_active,
	        streak_identifier,
	        MIN(current_season) AS start_date,
	        MAX(current_season) AS end_date
	    FROM streaks
	    GROUP BY
	    	player_name,
			scoring_class,
			is_active,
			streak_identifier
	 )

SELECT * FROM aggregated;

--SELECT * FROM players_scd;

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
--CREATE UNIQUE INDEX players_scd_index 
--	ON players_scd(player_name, start_date); 

-- CREATE MATERIALIZED VIEW players_scd AS
-- REFRESH MATERIALIZED VIEW players_scd;



-- ** SOLUTION EXAMPLE ** --
-- CREATE TYPE myrowtype AS (
--     f1 int, 
--     f2 text, 
--     f3 numeric
-- );
-- CREATE FUNCTION getf1(myrowtype) RETURNS int AS 'SELECT $1.f1' LANGUAGE SQL;



-- ** CREATING SCD TYPE ** --
DROP TYPE scd_type;
CREATE TYPE scd_type AS (
    -- f1 int,
    scoring_class scorer_class,
    is_active BOOLEAN,
    start_date INTEGER,
    end_date INTEGER
);



-- ** CREATING TABLE ** --
-- DROP FUNCTION getf1;
CREATE FUNCTION getf1(scd_type) RETURNS scorer_class AS 'SELECT $1.scoring_class' LANGUAGE SQL;

-- main CTE
WITH incoming AS (
    SELECT * FROM players
    WHERE current_season = 2022
    ),
        -- give me all the metrics and properties that are current
        current_dimensions AS (
            SELECT 
                * 
            FROM players_scd_table
            WHERE is_active = true
        ),
        old_dimensions AS (
            SELECT
                *
            FROM players_scd_table
            WHERE is_active = false
        ),
        combined AS (
            SELECT
                COALESCE(cd.player_name, i.player_name) AS player_name
                ,cd.scoring_class
                ,i.scoring_class
                ,cd.is_active
                ,i.is_active
                ,(
                    UNNEST(
                        CASE WHEN cd.scoring_class = i.scoring_class
                        AND i.is_active = cd.is_active
                        THEN ARRAY[ROW(
                            cd.scoring_class,
                            cd.is_active,
                            cd.start_date,
                            i.current_season)::scd_type]
                        ELSE
                        ARRAY[
                            ROW(
                                cd.scoring_class,
                                cd.is_active,
                                cd.start_date,
                                cd.end_date)::scd_type,
                            ROW(
                                i.scoring_class,
                                i.is_active,
                                i.current_season,
                                i.current_season)::scd_type
                        ]
                        END
                    )
                ).scoring_class AS change_data
            FROM current_dimensions cd
            FULL OUTER JOIN incoming i
                ON i.player_name = cd.player_name
            )

SELECT 
    *
    -- player_name,
    -- change_data.*
FROM combined;