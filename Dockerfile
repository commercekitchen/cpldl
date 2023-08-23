FROM ruby:2.7.7-slim-buster

# install rails dependencies
RUN apt-get clean all && \
  apt-get update -qq && \
  apt-get install -qq -y \
  build-essential \
  libpq-dev \
  curl \
  gnupg2 \
  apt-utils \
  default-libmysqlclient-dev \
  git \
  libcurl3-dev \
  cmake \
  libssl-dev \
  pkg-config \
  openssl \
  imagemagick \
  file \
  nodejs \
  yarn \
  graphviz

# Set working directory
RUN mkdir /rails-app
WORKDIR /rails-app

# Consume build args
ARG RAILS_ENV
ARG RAILS_MASTER_KEY
ARG ROLLBAR_ENV

# Add gems
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

# Install gems
COPY install_gems.sh install_gems.sh
RUN chmod u+x install_gems.sh && ./install_gems.sh

COPY . /rails-app

# Precompile assets
COPY precompile_assets.sh precompile_assets.sh
RUN chmod u+x precompile_assets.sh && ./precompile_assets.sh

# Add entrypoint script
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]