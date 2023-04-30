-- ** Setup Queries ** 

/* 
This creates a new data type called season_stats, which consists of an integer season, and three REAL (floating point) values for points, assists, and rebounds, as well as an integer weight.
*/
CREATE TYPE season_stats AS (
    season integer,
    pts REAL,
    ast REAL,
    reb REAL,
    weight integer
);

/* 
This creates a new data type called scorer_class, which is an enumerated type with four possible values: 'bad', 'average', 'good', or 'star'.
*/
CREATE TYPE scorer_class AS 
    ENUM ('bad','average','good','star');

/* 
This creates a new table called "players" with several columns: 
    player_name (a string),
    height (a string),
    college (a string),
    country (a string),
    draft_year (a string),
    draft_round (a string),
    draft_number (a string),
    seasons (an array of season_stats objects),
    scoring_class (a single value from the scorer_class type), and 
    current_season (an integer).

The PRIMARY KEY constraint ensures that each combination of player_name and current_season is unique, so that there can't be multiple rows for the same player in the same season.
*/
CREATE TABLE players (
    player_name TEXT,
    height TEXT,
    college TEXT,
    country TEXT,
    draft_year TEXT,
    draft_round TEXT,
    draft_number TEXT,
    seasons season_stats[],
    scoring_class scorer_class,
    current_season integer,
    PRIMARY KEY (player_name, current_season)
);



-- ** Exploration queries **
-- SELECT *
-- FROM players ps
-- WHERE player_name = 'Michael Jordan';

/*
The SELECT statement retrieves four columns: 
    - player_name, 
    - the first element of the "seasons" array (aliased as "first_season"), 
    - a calculated ratio between the most recent season's points and 
        the first season's points (aliased as "ratio_most_recent_to_first"), and 
    - the player's scoring_class.

The "CASE" statement checks if the first season had any points 
(i.e., if (seasons[1]::season_stats).pts is greater than 0), and if so, 
calculates the ratio of the most recent season's points to the first season's points.

The CARDINALITY function is used to determine the length of the "seasons" array. 

The "::" notation is used to cast the first and last elements of the "seasons" array 
to the "season_stats" type, so that their "pts" values can be accessed. 

The query filters the results to only include players with a current_season of 1996, 
and whose scoring_class is greater than 'average'.
*/
SELECT
    player_name
    ,seasons[1] AS first_season
    -- When the first season's points are greater than 0
    ,CASE WHEN (seasons[1]::season_stats).pts > 0 
            -- Divide the most recent season's points by the first season's points
            THEN (seasons[CARDINALITY(seasons)]::season_stats).pts /   
                    (seasons[1]::season_stats).pts
        -- Rename the column as ratio_most_recent_to_first
        END AS ratio_most_recent_to_first    
    ,scoring_class -- Select the scoring_class column

FROM players
WHERE
    current_season = 1996
    AND scoring_class > 'average'; 




-- ** Data population query **
/*
This is a data population query that inserts new player data for the next season, 
based on information from the previous season and the upcoming season.
*/	

DO
$do$
BEGIN 

-- The query uses a loop to iterate over a range of years from 1995 to 1997.
FOR last_year IN 1995..1997 LOOP

-- Select player data from the previous season
-- These CTEs are used in a full outer join to combine data from the two seasons.
WITH last_season AS (
	SELECT * FROM players ps
    WHERE current_season = last_year
),

-- Select player data from the upcoming season
this_season AS (
    SELECT * FROM player_seasons ps2
    WHERE season = last_year + 1
)

-- Insert combined player data into the "players" table
-- If a player does not have data in the previous season but has data in 
-- the upcoming season, the data from the upcoming season is used. 
INSERT INTO players
SELECT
    -- The COALESCE function is used to select the non-null value 
    -- between the two seasons for each column.
    COALESCE(ls.player_name, ts.player_name) AS player_name
    ,COALESCE(ls.height, ts.height) AS height
    ,COALESCE(ls.college, ts.college) AS college
    ,COALESCE(ls.country, ts.country) AS country
    ,COALESCE(ls.draft_year, ts.draft_year) AS draft_year
    ,COALESCE(ls.draft_round, ts.draft_round) AS draft_round
    ,COALESCE(ls.draft_number, ts.draft_number) AS draft_number
    -- The seasons column is constructed by concatenating (||) the previous season 
    -- array with a new season_stats array for the upcoming season, if there's one. 
    -- If there's no upcoming season data, an empty array is used.
    ,COALESCE(ls.seasons, ARRAY[]::season_stats[]) || 
        CASE 
            -- if there is upcoming season data
            WHEN ts.season IS NOT NULL THEN 
                -- create a new array with a single row representing the upcoming season data
                ARRAY[ 
                    -- The ROW function creates a new row with the values for the season, pts, 
                    -- assists, rebounds, and weight, and casts it as a season_stats type. 
                    ROW(ts.season, ts.pts, ts.ast, ts.reb, ts.weight)::season_stats
                ]
            -- if there is no upcoming season data, create an empty array
            ELSE ARRAY[]::season_stats[] 
        END AS seasons
    -- Determine scoring_class for the upcoming season
    ,CASE
        -- If there's upcoming season data, the scoring_class is based on the player's pts per game. 
        WHEN ts.season IS NOT NULL 
            THEN
                (CASE
                -- If the player scores more than 20 points per game, their scoring_class is 'star'
                WHEN ts.pts > 20 THEN 'star'
                -- If they score between 15 and 20 points per game, their scoring_class is 'good'
                WHEN ts.pts > 15 THEN 'good'
                -- If they score between 10 and 15 points per game, their scoring_class is 'average'
                WHEN ts.pts > 10 THEN 'average'
                -- If they score less than 10 points per game, their scoring_class is 'bad'
                ELSE 'bad'
            END)::scorer_class
        -- If there's no upcoming season data, use the scoring_class from the previous season
        ELSE ls.scoring_class
    END AS scoring_class

    -- Set the current season to the year after the last season
    ,last_year + 1 AS current_season

-- Combine data from the previous season and the upcoming season using a full outer join
FROM last_season ls
    FULL OUTER JOIN this_season ts
        ON ls.player_name = ts.player_name;

-- End the loop that iterates over the years from 1995 to 1997
END LOOP;

-- End the DO block
END $do$;


SELECT * FROM players
ORDER BY player_name
LIMIT 10;


-- ** ANALYTICAL QUERY **
SELECT 
	player_name  -- Select the player name
	,(seasons[cardinality(seasons)]::season_stats).pts /  -- Divide the points of the most recent season by
		CASE 
			WHEN (seasons[1]::season_stats).pts = 0  -- If the points of the first season is zero,
				THEN 1  -- then return 1 to avoid dividing by zero
			ELSE 
				(seasons[1]::season_stats).pts  -- otherwise, return the points of the first season
		END AS ratio_most_recent_to_first  -- Name the calculated ratio
FROM players  -- Select from the players table
WHERE current_season = 1998;  -- Filter for players whose current season is 1998

SELECT UNNEST(seasons)
FROM UNNEST(players);