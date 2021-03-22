
FROM ruby:3.0-alpine

# These must be given on container / service start
# --env SLACK_API_TOKEN="your-slack-api-token"
ENV SLACK_API_TOKEN=""
# --env SLACK_POST_CHANNEL="#channel"
ENV SLACK_POST_CHANNEL=""

# This are the defaults if not overruled by --env VAR="" from docker run
ENV SLACK_GW_PORTS="2525"
ENV SLACK_GW_HOSTS="127.0.0.1"
ENV SLACK_GW_MAX_PROCESSINGS="4"

# Do not show extended debug log
ENV SLACK_GW_DEBUG=""

######################################################

RUN apk update
RUN apk upgrade --force
RUN apk add alpine-sdk
RUN apk add git
RUN apk add openssl-dev

ADD ./src/ /app/

WORKDIR /app

RUN ruby -v
RUN gem update --system | head -n 8
RUN bundle config set --local path '.ruby/gems'
RUN export GEMRC="Gemrc.yml"
RUN bundle install

RUN chown -R root:root /app

# Spin up service
CMD ["bundle", "exec", "ruby", "service/midi-smtp-server-recipe-slack-mta.rb"]
