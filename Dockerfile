FROM ruby:2.7.8-slim-bullseye

# Install OS / Rails dependencies
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

# Build args (injected from CodeBuild)
ARG RAILS_ENV
ARG RAILS_MASTER_KEY
ARG ROLLBAR_ENV

# Set ENV so Rails sees them during asset precompile
ENV RAILS_ENV=${RAILS_ENV}
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
ENV ROLLBAR_ENV=${ROLLBAR_ENV}

# Install gems
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

COPY install_gems.sh install_gems.sh
RUN chmod u+x install_gems.sh && ./install_gems.sh

# Copy app code
COPY . /rails-app

# Precompile assets (this will load Rails & credentials)
COPY precompile_assets.sh precompile_assets.sh
RUN chmod u+x precompile_assets.sh && ./precompile_assets.sh

# Entrypoint
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
