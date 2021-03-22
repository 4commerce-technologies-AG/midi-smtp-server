## Slack Mail Gateway Service

This is a cookbook recipe that makes use of [midi-smtp-server](https://github.com/4commerce-technologies-AG/midi-smtp-server) and
[slack-ruby-client](https://github.com/slack-ruby/slack-ruby-client) to forward incoming E-Mails into a preferred slack channel.
In addition there is a [Docker](https://www.docker.io/) template to build and run a full service.

<br>

### Settings

The service may be adjusted by some ENV variables:

##### SLACK_API_TOKEN="xoxb-...."

The access api token from your slack app configuration.

##### SLACK_POST_CHANNEL="#name"

The id of the slack channel to post messages to.

##### SLACK_GW_PORTS="2525"

The port(s) the mail gateway is listen on.

##### SLACK_GW_HOSTS="127.0.0.1"

The ip-adress(es) the mail gateway is listen on.

##### SLACK_GW_MAX_PROCESSINGS="4"

The number of simultaniously processes.

##### SLACK_GW_DEBUG="1"

Show some extended debug information.

<br>

### Usage

```sh
export SLACK_API_TOKEN="xoxb-..."
export SLACK_POST_CHANNEL)="#random"
ruby service/midi-smtp-server-recipe-slack-mta.rb
```

<br>

### Usage with Docker

```sh
docker build --tag recipe-slack-mailgw .
docker run -ti --name recipe-slack-mailgw --publish 2525:2525 \
  --env SLACK_API_TOKEN="xoxb-..." --env SLACK_POST_CHANNEL="#random" \
  --env SLACK_GW_HOSTS="0.0.0.0" --hostname="slack-gw.local" \
  --env SLACK_GW_DEBUG=1 recipe-slack-mailgw
```

<br>

### Author & Credits

Author: [Tom Freudenberg](http://about.me/tom.freudenberg)

Copyright (c) 2021 [Tom Freudenberg, 4commerce technologies AG](http://www.4commerce.de/), released under the MIT license
