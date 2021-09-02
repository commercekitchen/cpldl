FROM ruby:2.7.4-slim-buster

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
  yarn

RUN mkdir /rails-app
WORKDIR /rails-app

ARG RAILS_ENV
ARG RAILS_MASTER_KEY

# Adding gems
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

COPY . /rails-app

COPY gem_install.sh gem_install.sh
RUN chmod u+x gem_install.sh && ./gem_install.sh

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]