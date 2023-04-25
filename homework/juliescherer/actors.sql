/*
DROP TABLE actors;
DROP TYPE film_stats;
DROP TYPE qual_class;
*/

-- ** CREATE TYPES **
CREATE TYPE qual_class AS ENUM (
    'bad'
    ,'average'
    ,'good'
    ,'star'
);

CREATE TYPE film_stats AS (
    film TEXT
    ,votes INTEGER
    ,rating REAL
    ,filmid TEXT
);

-- ** CREATE `actors` TABLE **
CREATE TABLE actors (
    actor TEXT
    ,actorid TEXT
    ,year INTEGER
    ,films film_stats[]
    ,avg_rating REAL
    ,quality_class qual_class -- a single value from the qual_class type
    ,is_active BOOLEAN
    ,PRIMARY KEY (actorid, year)
);



-- ** CUMULATIVE TABLE **
DO $do$
BEGIN 
FOR last_year IN 2008..2010 LOOP

WITH last_year_film AS (
    SELECT * FROM actors act
    WHERE year = last_year::int
)
,current_year_film AS (
    SELECT * FROM actor_films af
    WHERE year = last_year::int + 1
)
,current_year_films AS (
    SELECT 
        actorid
        ,year
        ,ARRAY_AGG(
            ROW(film, votes, rating, filmid)::film_stats
            ORDER BY filmid DESC
        ) AS films
    FROM current_year_film
    GROUP BY 
        actorid
        ,year
)
,films_numbered as (
    SELECT 
        actor
        ,actorid
        ,rating
        ,ROW_NUMBER() OVER (
            PARTITION BY actorid 
            ORDER BY year DESC
        ) AS film_num
    FROM current_year_film
)
,recent_film_ratings as (
    SELECT 
        actorid
        ,SUM(rating) / COUNT(*) AS avg_rating
    FROM films_numbered as fn
    WHERE film_num <= 5
    GROUP BY
        actorid
)

INSERT INTO actors (actor, actorid, films, avg_rating, quality_class, is_active, year)
SELECT 
    COALESCE(lf.actor, cf.actor) AS actor
    ,COALESCE(lf.actorid, cf.actorid) AS actorid
    ,COALESCE(lf.films, ARRAY[]::film_stats[]) || 
        CASE WHEN cf.year IS NOT NULL THEN -- if there's film data this year, create a new array with a single row representing this year's film data
            ARRAY[ ROW(cf.film, cf.votes, cf.rating, cf.filmid)::film_stats ] -- ROW creates a new row with the film stats
        ELSE ARRAY[]::film_stats[] -- otherwise, create an empty array
    END AS films
    ,COALESCE(fr.avg_rating, lf.avg_rating) AS avg_rating
    ,(CASE 
        WHEN COALESCE(fr.avg_rating, lf.avg_rating) > 8 THEN 'star'
        WHEN COALESCE(fr.avg_rating, lf.avg_rating) > 5 THEN 'good'
        WHEN COALESCE(fr.avg_rating, lf.avg_rating) > 3 THEN 'average'
        ELSE 'bad'
    END)::qual_class AS quality_class
    ,(CASE WHEN cf.film IS NOT NULL
            THEN TRUE
            ELSE FALSE
    END)::boolean AS is_active
    ,last_year::int + 1 AS year

FROM last_year_film lf
FULL OUTER JOIN current_year_film cf
ON lf.actorid = cf.actorid
LEFT JOIN recent_film_ratings fr
ON lf.actorid = fr.actorid
   OR cf.actorid = fr.actorid

ON CONFLICT DO NOTHING
;

END LOOP;
END $do$;


-- ** QUERY TABLE **
SELECT * 
FROM actors
ORDER BY 
    films
LIMIT 20;
