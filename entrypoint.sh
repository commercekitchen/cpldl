#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /rails-app/tmp/pids/server.pid

echo "Creating and migrating db"
# Ensure db exists, run migrations
SKIP_SCHEMA_DUMP=true bundle exec rake db:create db:migrate:with_data

exec "$@"