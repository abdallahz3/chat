#!/bin/bash
# Docker entrypoint script.

echo $PGPORT

# Wait until Postgres is ready
while ! pg_isready -q -h $PGHOST -p $PGPORT -U $PGUSER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

# Create, migrate, and seed database if it doesn't exist.
# if [[ -z `psql -Atqc "\\list $PGDATABASE"` ]]; then
if [[ -z `psql -h $PGHOST -p $PGPORT  -U $PGUSER -Atqc "\\list $PGDATABASE"` ]]; then
  echo "Database $PGDATABASE does not exist. Creating..."
#   createdb -E UTF8 $PGDATABASE -l en_US.UTF-8 -T template0

  mix ecto.setup
  echo "Database $PGDATABASE created."
fi

PGHOST=$PGHOST PGPORT=$PGPORT PGUSER=$PGUSER PGPASSWORD=$PGPASSWORD PGDATABASE=$PGDATABASE exec mix phx.server
