
FROM ruby:3.2-alpine

# This are the defaults if not overruled by --env VAR="" from docker run
ENV HAPROXY_GW_PORTS="2525"
ENV HAPROXY_GW_HOSTS="*"
ENV HAPROXY_GW_MAX_PROCESSINGS="4"

# Do not show extended debug log
ENV HAPROXY_GW_DEBUG="debug"

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
RUN bundle install --jobs 32 --retry 3

RUN chown -R root:root /app

# Spin up service
CMD ["bundle", "exec", "ruby", "service/midi-smtp-server-recipe-haproxy-mta.rb"]
