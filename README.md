# Week 1 Dimensional Data Modeling
This week is the code we'll be using for dimensional data modeling. It contains data for every NBA game and player for the last 15ish years!

## Base Data Model (getting started)

### My instructions

Open a terminal and run the `make` commands below:

```
make up
```
_^this will run the `setup.sh` script, which will pull and run the latest postgres image in dockerhub, and execute the psql cmd using the `data.dump` file inside the docker container_

```
make start
```

_^this will start the postgres container and run the psql command in the docker container_

```
make down
```

_^this will stop the postgres container, delete it, and delete the image as well_


------

### Zach's instructions

1. Install Postgres locally (Homebrew is really nice for installing on Mac)
-  Mac
-- This [tutorial](https://daily-dev-tips.com/posts/installing-postgresql-on-a-mac-with-homebrew/) is what I used
- Window
-- This [tutorial](https://www.sqlshack.com/how-to-install-postgresql-on-windows/) is what I used
2. Use the data dump at the root of this directory and run this command. Make sure to replace <username> with your computer's username
```
psql -U <username> postgres < data.dump
```
3. Set up DataGrip to point at your locally running Postgres instance
4. Have fun querying!

## Specific Trainings
