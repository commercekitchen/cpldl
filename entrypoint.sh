#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /rails-app/tmp/pids/server.pid

# Ensure db exists, run migrations
bundle exec rake db:migrate

exec "$@"