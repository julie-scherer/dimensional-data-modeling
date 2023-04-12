# Week 1 Dimensional Data Modeling
This is the repo that has all the queries and data for my Serious SQL video game training series!

The portfolio project for these trainings is located at https://www.halogods.com

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