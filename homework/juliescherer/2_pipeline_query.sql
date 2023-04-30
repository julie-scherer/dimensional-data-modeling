-- ! STEP 2: Cumulative table generation query
/*
A cumulative table generation query that populates actors one year at a time
*/

-- Get the min and max year
-- SELECT MIN(year), MAX(year) FROM actor_films;

-- Make sure `actors` table exists
-- SELECT * FROM actors;


-- ** Run cumulative generation query
DO $do$
BEGIN 
    FOR last_year IN 1913..2020 LOOP -- loop through MIN(YEAR)-1 .. MAX(year)-1
            WITH 
                last_year_film AS (
                    SELECT * FROM actors act
                    WHERE year = last_year::int
                )
                ,current_year_film AS (
                    SELECT
                        actor
                        ,actorid
                        ,film
                        ,year
                        ,votes
                        ,rating
                        ,filmid
                        ,ROW_NUMBER() OVER (
                            PARTITION BY actorid
                            ORDER BY year DESC
                        ) AS film_num
                    FROM actor_films af
                    WHERE year = last_year::int + 1
                )
                -- SELECT * FROM current_year_film;
                ,current_year_films AS (
                    SELECT 
                        actor
                        ,actorid
                        ,year
                        ,ARRAY_AGG(
                            ROW(film, votes, rating, filmid)::films_array
                            ORDER BY filmid DESC
                        ) AS films
                    FROM current_year_film cyf
                    GROUP BY actor, actorid, year
                )
                -- SELECT * FROM current_year_films;
                ,recent_film_ratings AS (
                    SELECT 
                        actor
                        ,actorid
                        ,SUM(rating) / COUNT(*) AS avg_rating
                    FROM current_year_film cyf
                    WHERE film_num <= 5
                    GROUP BY actor, actorid
                )
                -- SELECT * FROM recent_film_ratings ORDER BY actorid;

            INSERT INTO actors (actor, actorid, films, avg_rating, quality_class, is_active, year)
            SELECT 
                COALESCE(lf.actor, cf.actor) AS actor
                ,COALESCE(lf.actorid, cf.actorid) AS actorid
                ,COALESCE(lf.films, ARRAY[]::films_array[]) || 
                    CASE WHEN cf.year IS NOT NULL -- if there's film data this year, create a new array with a single row representing this year's film data
                        THEN
                            ARRAY[ ROW(cf.film, cf.votes, cf.rating, cf.filmid)::films_array ] -- ROW creates a new row with the film stats
                        ELSE ARRAY[]::films_array[] -- otherwise, create an empty array
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

            ON CONFLICT DO NOTHING;
    END LOOP;
END $do$;



-- ** Query `actors` table

-- * checking if there are duplicate primary keys in the table
-- SELECT actorid, actor, year, COUNT(*) 
-- FROM actors
-- GROUP BY actorid, actor, year 
-- HAVING COUNT(*) <> 1;

-- * checking avg rating changes with new films
-- SELECT * 
-- FROM actors 
-- ORDER BY films, actorid 
-- LIMIT 20;

-- * checking min and max year
-- SELECT MIN(year), MAX(year) 
-- FROM actors;

-- * checking 1914 only has 1 film in array
-- SELECT * FROM actors
-- WHERE year = 1914
-- LIMIT 5;

-- * checking distinct actorid count in actor films and actors tables
-- SELECT COUNT(DISTINCT actorid) FROM actor_films ORDER BY COUNT(DISTINCT actorid) DESC;
-- SELECT COUNT(DISTINCT actorid) FROM actors ORDER BY COUNT(DISTINCT actorid) DESC;