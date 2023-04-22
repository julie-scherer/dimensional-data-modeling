-- ** Setup Queries ** 
CREATE TYPE season_stats AS (
				season integer,
				pts REAL,
				ast REAL,
				reb REAL,
				weight integer
);


CREATE TYPE scorer_class AS 
ENUM ('bad','average','good','star');


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
PRIMARY KEY (player_name,
current_season)
);


-- ** Exploration queries **
SELECT
    *
FROM
    players ps
WHERE
    player_name = 'Michael Jordan';



SELECT
    player_name,
    seasons[1] AS first_season,
    CASE
        WHEN (seasons[1]::season_stats).pts > 0 
				THEN (seasons[CARDINALITY(seasons)]::season_stats).pts /(seasons[1]::season_stats).pts
    END AS ratio_most_recent_to_first,
    scoring_class
FROM
    players
WHERE
    current_season = 1996
    AND scoring_class > 'average';


-- ** Data population query **
DO
$do$
BEGIN 
	
FOR last_year IN 1995..1997 LOOP

WITH last_season AS (
	SELECT * FROM players ps
					WHERE current_season = last_year
), this_season AS (
	SELECT * FROM player_seasons ps2
					WHERE season = last_year + 1
)

INSERT INTO players
SELECT
    COALESCE(ls.player_name, ts.player_name) AS player_name,
    COALESCE(ls.height, ts.height) AS height,
    COALESCE(ls.college, ts.college) AS college,
    COALESCE(ls.country, ts.country) AS country,
    COALESCE(ls.draft_year, ts.draft_year) AS draft_year,
    COALESCE(ls.draft_round, ts.draft_round) AS draft_round,
    COALESCE(ls.draft_number, ts.draft_number) AS draft_number,
    COALESCE(ls.seasons, 
				ARRAY[]::season_stats[]
				) || CASE WHEN ts.season IS NOT NULL THEN 
				ARRAY[ROW(ts.season,
        ts.pts,
        ts.ast,
        ts.reb,
        ts.weight)::season_stats]
        ELSE ARRAY[]::season_stats[]
    END AS seasons,
    CASE
        WHEN ts.season IS NOT NULL THEN
            (CASE
            WHEN ts.pts > 20 THEN 'star'
            WHEN ts.pts > 15 THEN 'good'
            WHEN ts.pts > 10 THEN 'average'
            ELSE 'bad'
        END)::scorer_class
        ELSE ls.scoring_class
    END AS scoring_class,
    last_year + 1 AS current_season
FROM
    last_season ls
FULL OUTER JOIN this_season ts ON
    ls.player_name = ts.player_name;
END LOOP;

END
$do$;