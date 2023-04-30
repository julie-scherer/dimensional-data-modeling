-- solutions/players_scd_table.sql
-- DROP TABLE players_scd_table;
CREATE TABLE
	players_scd_table (
		player_name text,
		scoring_class scorer_class,
		is_active boolean,
		start_date integer,
		end_date integer,
		is_current boolean
	);


-- solutions/scd_generation_query.sql
WITH
    streak_started AS (
        SELECT
            player_name
            ,current_season
            ,scoring_class
            ,LAG (scoring_class, 1) OVER (
                PARTITION BY
                    player_name
                ORDER BY
                    current_season
                ) <> scoring_class
            OR LAG (scoring_class, 1) OVER (
                PARTITION BY
                    player_name
                ORDER BY
                    current_season
                ) IS NULL 
            AS did_change
        FROM players
    )
    ,streak_identified AS (
        SELECT
            player_name
            ,scoring_class
            ,current_season
            ,SUM(
                CASE
                    WHEN did_change THEN 1
                    ELSE 0
                END
            ) OVER (
                PARTITION BY
                    player_name
                ORDER BY
                    current_season
            ) AS streak_identifier
        FROM streak_started
    ),
    aggregated AS (
        SELECT
            player_name
            ,scoring_class
            ,streak_identifier
            ,MIN(current_season) AS start_date
            ,MAX(current_season) AS end_date
        FROM streak_identified
        GROUP BY
            1,2,3
    )
SELECT
    player_name
    ,scoring_class
    ,start_date
    ,end_date
FROM
    aggregated;


-- solutions/incremental_scd_query.sql
WITH 
    incoming AS (
        SELECT *
        FROM players
        WHERE current_season = 2022
    )
    ,current_dimensions AS (
        SELECT *
        FROM players_scd_table
        WHERE is_current = true
    )
    ,old_dimensions AS (
        SELECT *
        FROM players_scd_table
        WHERE is_current = false
    )
    ,combined AS (
        SELECT
            COALESCE(cd.player_name, i.player_name) AS player_name,
            cd.scoring_class,
            i.scoring_class,
            cd.is_active,
            i.is_active, (
                UNNEST(
                    CASE
                        WHEN cd.scoring_class = i.scoring_class AND i.is_active = cd.is_active 
                            THEN ARRAY [ROW(
                                cd.scoring_class,
                                cd.is_active,
                                cd.start_date,
                                i.current_season
                            ) :: scd_type]
                        ELSE 
                            ARRAY [ROW(
                                cd.scoring_class,
                                cd.is_active,
                                cd.start_date,
                                cd.end_date
                            ) :: scd_type,
                            ROW(
                                i.scoring_class,
                                i.is_active,
                                i.current_season,
                                i.current_season
                            ) :: scd_type]
                    END
                )
            ) AS change_data
        FROM current_dimensions cd
            FULL OUTER JOIN incoming i ON i.player_name = cd.player_name
    )
    INSERT INTO players_scd_table
    SELECT
        player_name
        ,(change_data :: scd_type).scoring_class
        ,(change_data :: scd_type).is_active
        ,(change_data :: scd_type).start_date
        ,(change_data :: scd_type).end_date
        ,(change_data :: scd_type).end_date = 2022 as is_current
    FROM combined
    UNION ALL
    SELECT
        player_name,
        scoring_class,
        is_active,
        start_date,
        end_date,
        is_current
    FROM old_dimensions;


SELECT * FROM players_scd_table
ORDER BY start_date, end_date;