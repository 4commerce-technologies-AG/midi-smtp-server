<p align="center" style="margin-bottom: 2em">
  <img src="https://cdn.haproxy.com/assets/our_logos/haproxy-icon.svg" alt="HAProxy Logo" width="40%"/>
</p>

<br>

## HAProxy Cookbook

This is a cookbook recipe that makes use of [midi-smtp-server](https://github.com/4commerce-technologies-AG/midi-smtp-server) and
[HAProxy](http://www.haproxy.org/) to load-balance incoming connections across multiple smtp backends.
In addition there is a [Docker](https://www.docker.io/) template to build and run a full service.

Note: `haproxy` instances that are proxying smtp connections from upstream proxies, should be configured with
`accept-proxy` directive. take a look at the master and chain configurations in the [data](./data) folder.
### Settings

##### PROXY_GW_PORTS="2525"

The port(s) the mail gateway will listen on.

##### PROXY_GW_HOSTS="127.0.0.1"

The ip-address(es) the mail gateway will listen on.

##### PROXY_GW_MAX_PROCESSINGS="4"

The number of simultaneous processed connections.

##### PROXY_GW_DEBUG="debug"

Show some extended debug information.

<br>

### Usage with Docker Compose

Bring up the `haproxy-mater`, `haproxy-chain` and `smtp` services with:
```sh
docker compose up --build
```

Send test email using `haproxy-master`:
```sh
curl -v --url 'smtp://localhost:5555' -k --mail-from test@test.com --mail-rcpt test@test.com -F '='
```

Send test email directly to `smtp` service:
```sh
curl -v --url 'smtp://localhost:2525' -k --mail-from test@test.com --mail-rcpt test@test.com -F '='
```

### Author & Credits

Author: [Iuri G.](https://github.com/iuri-gg)
