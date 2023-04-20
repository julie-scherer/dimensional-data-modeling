# Week 1 Dimensional Data Modeling
The homework this week will be using the `actor_films` dataset

Construct the following queries:
- A DDL for an `actors` table that has:
  - a `films` array of `struct`
  - a `quality_class` field that is based on up to their most recent 5 films
  - a `is_active` field that describes if an actor is making films this year

- A cumulative table generation query that populates `actors` one year at a time

- A DDL for an `actors_history_scd` table that has:
    - type 2 dimension modeling (i.e. start_date and end_date)
    - tracks `quality_class` and `is_active` for each actor in `actors`

- A "backfill" query for `actors_history_scd` that can populate all of it in 1 query

- An "incremental" query for `actors_history_scd` that combines last years SCD and new incoming data from `actors`

Please add these queries into a folder `homework/<discord-username>`