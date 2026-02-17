#!/bin/bash

set -e

if [ "$RAILS_ENV" != "development" ]
then
  rm -rf public/assets
  bundle exec rails assets:precompile
fi
