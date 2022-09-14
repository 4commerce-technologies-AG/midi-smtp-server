## 8BITMIME, SMTPUTF8 support

Since version 2.3.0 there is builtin optional internationalization support via SMTP 8BITMIME and SMTPUTF8 extension described in [RFC6152](https://tools.ietf.org/html/rfc6152) and [RFC6531](https://tools.ietf.org/html/rfc6531).

The extensions are disabled by default and could be enabled by:

```rb
# enable internationalization SMTP extensions
internationalization_extensions: true
```

When enabled and sender is using the 8BITMIME and SMTPUTF8 capabilities, the given encoding information about body and message encoding are set by `MAIL FROM` command. The encodings are read by MidiSmtpServer and published at context vars `ctx[:envelope][:encoding_body]` and `ctx[:envelope][:encoding_utf8]`.

Possible values for `ctx[:envelope][:encoding_body]` are:

1. `""` (default, not set by client)
2. `"7bit"` (strictly 7bit)
3. `"8bitmime"` (strictly 8bit)

Possible values for `ctx[:envelope][:encoding_utf8]` are:

1. `""` (default, not set by client)
2. `"utf8"` (utf-8 is enabled for headers and body)

Even when `"8bitmime"` was set, you have to decide the correct encoding like `utf-8` or `iso-8859-1` etc. If also `"utf8"` was set, then encoding should be `utf-8`.

<br>
