#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /rails-app/tmp/pids/server.pid

echo "Container starting (RAILS_ENV=$RAILS_ENV)"

# Migrations block
if [ "$SKIP_MIGRATIONS" = "true" ]; then
  echo "SKIP_MIGRATIONS=true → Skipping db:create and db:migrate"
else
  echo "Creating and migrating db…"
  # Ensure DB exists, then run migrations with_data
  SKIP_SCHEMA_DUMP=true bundle exec rake db:create db:migrate:with_data
fi

echo "Starting main process: $@"
exec "$@"