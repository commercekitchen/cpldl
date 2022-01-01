#!/bin/bash

set -e

gem install bundler

if [ "$RAILS_ENV" = "development" ]
then
  echo "Installing dev gems "
  bundle config unset without
  bundle install
else
  echo "installing staging/prod gems"
  bundle config set without "development test"
  bundle install --quiet --jobs 3 --retry 3
fi

exec "$@"


