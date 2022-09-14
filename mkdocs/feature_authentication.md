## Authentication support

There is built-in authentication support for `AUTH LOGIN` and `AUTH PLAIN` since release `2.1.0`. If you want to enable authentication you have to set the appropriate value to `auth_mode` option.

Allowed values are:

```rb
# no authentication is allowed (mostly for internal services)
auth_mode: :AUTH_FORBIDDEN

# authentication is optional (you may grant higher possibilities if authenticated)
auth_mode: :AUTH_OPTIONAL

# session must be authenticated before service may be used for mail transport
auth_mode: :AUTH_REQUIRED
```

You may initialize your server class like:

```rb
server = MySmtpd.new(ports: 2525, hosts: '127.0.0.1', auth_mode: :AUTH_REQUIRED)
```

If you have enabled authentication you should provide your own user and access methods to grant access to your server. The default event method will deny all access per default.

Your own server class should implement the `on_auth_event`:

```rb
# check the authentication
# if any value returned, that will be used for ongoing processing
# otherwise the original value will be used for authorization_id
def on_auth_event(ctx, authorization_id, authentication_id, authentication)
  if authentication_id == "test" && authentication == "demo"
    return authentication_id
  else
    raise Smtpd535Exception
  end
end
```

Most of the time the `authorization_id` field will be empty. It allows optional (like described in [RFC 4954](http://www.ietf.org/rfc/rfc4954.txt)) to define an _authorization role_ which will be used, when the _authentication id_ has successfully entered. So the `authorization_id` is a request to become a role after authentication. In case that the `authorization_id` is empty it is supposed to be the same as the `authentication_id`.

We suggest you to return the `authentication_id` on a successful auth event if you do not have special interests on other usage.

<br>

### Authentication status in mixed mode

If you have enabled optional authentication like described before, you may access helpers and values from context `ctx` while processing events to check the status of currents session authentication.

```rb
def on_rcpt_to_event(ctx, rcpt_to_data)
  # check if this session was authenticated already
  if authenticated?(ctx)
    # yes
    logger.debug("Proceed with authorized id: #{ctx[:server][:authorization_id]}")
    logger.debug("and authentication id: #{ctx[:server][:authentication_id]}")
  else
    # no
    logger.debug("Proceed with anonymous credentials")
  end
end
```

<br>
