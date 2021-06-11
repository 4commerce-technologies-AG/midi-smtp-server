## StartTLS support

Since release `2.2.1` the SMTP-Server supports STARTTLS by using `openssl` gem.
If you want to enable encryption you have to set the appropriate value to `tls_mode` option.

Allowed values are:

```rb
# no encryption is allowed (mostly for internal services)
tls_mode: :TLS_FORBIDDEN

# encryption is optional
tls_mode: :TLS_OPTIONAL

# client must initialize encryption before service may be used for mail exchange
tls_mode: :TLS_REQUIRED
```

You may enable TLS on your server class like:

```rb
server = MySmtpd.new(ports: 2525, hosts: '127.0.0.1', tls_mode: :TLS_OPTIONAL)
```

Do not forget to also install or require the `openssl` gem if you want to enable encryption.

When using `tls_mode: :TLS_REQUIRED` your server will enforce the client to always use STARTTLS before accepting transmission of data like described in [RFC 3207](https://tools.ietf.org/html/rfc3207).

For security reasons check the "Table of the ciphers (and their priorities)" on [OWASP Foundation](https://www.owasp.org/index.php/TLS_Cipher_String_Cheat_Sheet). Per default the `Advanced+ (A+)` cipher-string will be used as well as `TLSv1.2 only`.

You may change ciphers and methods on your server class like:

```rb
server = MySmtpd.new(
  ports: 2525,
  hosts: '127.0.0.1',
  tls_mode: :TLS_OPTIONAL,
  tls_ciphers: TLS_CIPHERS_ADVANCED_PLUS,
  tls_methods: TLS_METHODS_ADVANCED
)
```

Predefined ciphers and methods strings are available as CONSTs:

```rb
# Advanced+ (A+) _Default_
tls_ciphers: TLS_CIPHERS_ADVANCED_PLUS
tls_methods: TLS_METHODS_ADVANCED

# Advanced (A)
tls_ciphers: TLS_CIPHERS_ADVANCED
tls_methods: TLS_METHODS_ADVANCED

# Broad Compatibility (B)
tls_ciphers: TLS_CIPHERS_BROAD
tls_methods: TLS_METHODS_ADVANCED

# Widest Compatibility (C)
tls_ciphers: TLS_CIPHERS_WIDEST
tls_methods: TLS_METHODS_LEGACY

# Legacy (C-)
tls_ciphers: TLS_CIPHERS_LEGACY
tls_methods: TLS_METHODS_LEGACY
```

<br>

### Certificates

As long as `tls_mode` is set to `:TLS_OPTIONAL` or `:TLS_REQUIRED` and no certificate or key path is given on class initialization, the internal TlsTransport class will create a certificate by itself. This should be only used for testing or debugging purposes and not in production environments. The memory only certificate is valid for 90 days from instantiating the class.

To prevent client errors like `hostname does not match` the certificate is enriched by `subjectAltNames` and will include all hostnames and addresses which were identified on initialization. The automatic certificate subject and subjectAltName may also be manually set by `tls_cert_cn` and `tls_cert_san` parameter.

In general and for production you better should generate a certificate by your own authority or use a professional trust-center like [LetsEncrypt](https://letsencrypt.org/) and more.

<br>

### Quick guide to create a certificate

If interested in detail, read the whole story at [www.thenativeweb.io](https://www.thenativeweb.io/blog/2017-12-29-11-51-the-openssl-beginners-guide-to-creating-ssl-certificates/). Please check also the information about SSL-SAN like [support.dnsimple.com](https://support.dnsimple.com/articles/what-is-ssl-san/).

```bash
# create a private key
openssl genrsa -out key.pem 4096
# create a certificate signing request (CSR)
openssl req -new -key key.pem -out csr.pem
# create a SSL certificate
openssl x509 -in csr.pem -out cert.pem -req -signkey key.pem -days 90
```

You may use your certificate and key on your server class like:

```rb
server = MySmtpd.new(
  ports: 2525,
  hosts: '127.0.0.1',
  tls_mode: :TLS_OPTIONAL,
  tls_cert_path: 'cert.pem',
  tls_key_path: 'key.pem'
)
```

<br>

### Using .pem with trust chain and private key

Since release 3.0.2 the parameter `tls_cert_path` allows usage of combined .pem certificates with optional included private keys like described on [digicert](https://www.digicert.com/kb/ssl-support/pem-ssl-creation.htm). In the case of an already included private key, the paramter `tls_key_path` may be left `nil`.

<br>

### Expose active SSLContext

To access the current daemon´s SSL-Context (OpenSSL::SSL::SSLContext), e.g. for inspecting the self signed certificate, this object is exposed as property `ssl_context`.

```ruby
  cert = my_smtpd.ssl_context&.cert
```

<br>

### Test encrypted communication

While working with encrypted communication it is sometimes hard to test and check during development or debugging. Therefore you should look at the GNU tool `gnutls-cli`. Use this tool to connect to your running SMTP-server and proceed with encrypted communication.

```bash
# use --insecure when using self created certificates
gnutls-cli --insecure -s -p 2525 127.0.0.1
```

After launching `gnutls-cli` start the SMTP dialog by sending `EHLO` and `STARTSSL` commands. Next press Ctrl-D on your keyboard to run the handshake for SSL communication between `gnutls-cli` and your server. When ready you may follow up with the delivery dialog for SMTP.

<br>
