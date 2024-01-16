#!/bin/bash

set -e

gem install bundler -v '~> 2.4.22'

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


