## Extended logging

Starting from version 3.0.1 there are enhanced logging capabilities. Instead only set a individual logger there is a new exposed event method called `on_logging_event`. When using the `logger` property all messages are forwarded to the new event and could be captured from there. As an example you could post additional log content to monitoring services like sentry:

```rb
def on_logging_event(ctx, severity, msg, err: nil)
  # Sentry.capture_message(msg) if !err && msg # just an example
  # And even, do some scoping, tagging etc.
  # As having separate access to logger, now attach individual email data (like user/ email) to the sentry context.
  if err
    Sentry.set_tags(ip: ctx[:server][:remote_ip], from: ctx[:envelope][:from], to: ctx[:envelope][:to])
    # Or use `Sentry.set_extras`
    Sentry.capture_exception(err)
    # or use `Sentry.configure_scope do |scope|...`
  end
  SemanticLogger['Distributor'].error msg, { user: 1, some_ctx_info: {...} }, err if severity >= 1
  super
end
```

To allow complete access to all log messages any logging output has to be send via `logger` property and methods like `logger.info()` or directly as event to `on_logging_event(ctx or nil, severity, msg, error object or nil)`. Checkout also the [Examples](https://github.com/4commerce-technologies-AG/midi-smtp-server/tree/master/examples) and [Cookbook](https://github.com/4commerce-technologies-AG/midi-smtp-server/tree/master/cookbook) sources.

<br>
