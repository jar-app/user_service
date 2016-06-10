FROM ruby:2.3

RUN apt-get update -qq && apt-get install -y build-essential

# Hits Docker cache only if Gemfile isn't changed
COPY Gemfile* /tmp/
WORKDIR /tmp
RUN bundle install --jobs 4 --retry 3

ENV APP_HOME /usr/src/app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

COPY . $APP_HOME
