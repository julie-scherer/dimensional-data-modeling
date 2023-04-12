# Week 1 Dimensional Data Modeling
This week is the code we'll be using for dimensional data modeling. It contains data for every NBA game and player for the last 15ish years!

## Base Data Model (getting started)

1. Install Postgres locally (Homebrew is really nice for installing on Mac)
-  Mac
-- This [tutorial](https://daily-dev-tips.com/posts/installing-postgresql-on-a-mac-with-homebrew/) is what I used
- Window
-- This [tutorial](https://www.sqlshack.com/how-to-install-postgresql-on-windows/) is what I used
2. Use the data dump at the root of this directory and pg_restore to create a new database. 
```
psql -U <username> postgres < data.dump
```
3. Set up DataGrip to point at your locally running Postgres instance
4. Have fun querying!

## Specific Trainings
