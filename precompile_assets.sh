#!/bin/bash

set -e

if [ "$RAILS_ENV" != "development" ]
then
  rm -rf /app/public/assets/
  bundle exec rake assets:precompile
fi

exec "$@"
