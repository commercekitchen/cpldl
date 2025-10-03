FROM ruby:2.7.8-slim-bullseye

# install rails dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libpq-dev \
      curl \
      gnupg2 \
      git \
      cmake \
      libssl-dev \
      pkg-config \
      openssl \
      imagemagick \
      file \
      graphviz \
      default-libmysqlclient-dev \
      libcurl4-openssl-dev \
      shared-mime-info \
    && rm -rf /var/lib/apt/lists/*

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