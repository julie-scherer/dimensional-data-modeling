WITH incoming AS (

    SELECT * FROM players
    WHERE current_season = 2022
),
     current_dimensions AS (
         SELECT * FROM players_scd_table
         WHERE is_current = true
     ),
     old_dimensions AS (
         SELECT * FROM players_scd_table
         WHERE is_current = false
     ),
     combined AS (
         SELECT
    COALESCE(cd.player_name, i.player_name)
        AS player_name,
       cd.scoring_class,
       i.scoring_class,
       cd.is_active,
       i.is_active,
       (UNNEST(
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
        END)) as change_data
    FROM current_dimensions cd
    FULL OUTER JOIN incoming i
        ON i.player_name = cd.player_name
     )
INSERT INTO players_scd_table

SELECT player_name,
       (change_data::scd_type).scoring_class,
       (change_data::scd_type).is_active,
       (change_data::scd_type).start_date,
       (change_data::scd_type).end_date,
       (change_data::scd_type).end_date = 2022 as is_current
    FROM combined
UNION ALL
    SELECT player_name, scoring_class,
           is_active, start_date, end_date, is_current FROM old_dimensions
