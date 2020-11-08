FROM ruby:2.5.7
RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*
RUN apt-get update && apt-get install sqlite3 libsqlite3-dev -y
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

WORKDIR /cook_log

ADD Gemfile /cook_log/Gemfile
ADD Gemfile.lock /cook_log/Gemfile.lock

RUN gem install bundler
RUN bundle install

ADD . /cook_log