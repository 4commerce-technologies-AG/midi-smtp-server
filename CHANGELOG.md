## Changes and updates

We suggest everybody using MidiSmtpServer to switch at least to latest 2.3.y. or best to 3.x. The update is painless and mostly without any source code changes :sunglasses:

For upgrades from previous versions or outdated _MiniSmtpServer_ gem you may follow the guides at [Appendix Upgrade](https://midi-smtp-server.readthedocs.io/appendix_upgrade/) to get your code ready for the latest releases.


#### 3.1.1 (2023-02-21)

1. Add option to additional activate [pre-forking workers](https://midi-smtp-server.readthedocs.io/feature_load_balancing/#pre-forking) (beta) ([check issue 42](https://github.com/4commerce-technologies-AG/midi-smtp-server/issues/42))
2. Adjust sleep idle time while in command and data loop to speedup processing ([check issue 47](https://github.com/4commerce-technologies-AG/midi-smtp-server/issues/47))
3. Modify github workflow and apply testing of ruby 3.1 and ruby 3.2
4. Generate updated openssl test certificates for TLS tests


#### 3.0.3 (2022-02-12)

1. Critical fix for thread safety ([check issue 39](https://github.com/4commerce-technologies-AG/midi-smtp-server/issues/39))
2. Fix tests using net/smtp '>= 0.3.1'


#### 3.0.2 (2021-06-11)

1. Enable support for certificate chain PEM files


#### 3.0.1 (2021-03-12)

1. Enable support for Ruby 3.0
2. Bound to ruby 2.6+
3. New [extended logging capabilities](https://midi-smtp-server.readthedocs.io/feature_logging/)
4. Updated rubocop linter and code styles
5. Fix tests for Net/Smtp of Ruby 3.0 ([check PR 22 on Net/Smtp](https://github.com/ruby/net-smtp/pull/22))
6. Fix tests for minitest 6 deprecated warnings `obj.must_equal`
7. New exposed [active SSLContext](https://midi-smtp-server.readthedocs.io/feature_encryption/#expose-active-sslcontext)
8. Dropped deprecated method `host` - please use `hosts.join(', ')` instead
9. Dropped deprecated method `port` - please use `ports.join(', ')` instead
10. Dropped deprecated empty wildcard `""` support on initialize - please use specific hostnames and / or ip-addresses or star wildcard `"*"` only
11. Align tests with Rubocop style and coding enforcements
12. Added `rake` tasks for testing and linting, checkout `bundle exec rake -T`
13. Re-defined arguments of methods `new`, `join`, `stop` as keyword arguments, check [minor incompatibility: upgrade to 3.x](https://midi-smtp-server.readthedocs.io/appendix_upgrade/#upgrade-to-3x)
14. Enhance the slack recipe in cookbook for [Docker usage](https://github.com/4commerce-technologies-AG/midi-smtp-server/tree/master/cookbook/recipe-slack)


#### 2.3.3 (2022-02-12)

1. Critical fix for thread safety ([check issue 39](https://github.com/4commerce-technologies-AG/midi-smtp-server/issues/39))


#### 2.3.2 (2020-01-21)

1. New [hosts wildcard and interface detection](https://midi-smtp-server.readthedocs.io/instantiate/#hosts-wildcard-interface-detection)
2. Extended [Certificates](https://midi-smtp-server.readthedocs.io/feature_encryption/#certificates) with subjectAltName
3. Bound to ruby 2.3+
4. Full support for `# frozen_string_literal: true` optimization
5. Updated rubocop linter
6. Rich enhancements to tests


#### 2.3.1 (2018-11-01)

1. New [events for header inspection and addons](https://midi-smtp-server.readthedocs.io/using_events/#adding-and-testing-headers)
2. New [MidiSmtpServer micro homepage](https://4commerce-technologies-ag.github.io/midi-smtp-server/)
3. New [ReadTheDocs manual](https://midi-smtp-server.readthedocs.io/)
4. New [Recipe for Slack MTA](https://midi-smtp-server.readthedocs.io/cookbook_recipe_slack_mta/)


#### 2.3.0 (2018-10-17)

1. Support [IPv4 and IPv6 (documentation)](https://midi-smtp-server.readthedocs.io/instantiate/#ipv4-and-ipv6-ready)
2. Support binding of [multiple ports and hosts / ip addresses](https://midi-smtp-server.readthedocs.io/instantiate/#ports-and-addresses)
3. Handle [utilization of connections and processings](https://midi-smtp-server.readthedocs.io/feature_load_balancing/)
4. Support of RFC(2)822 [CR LF modes](https://midi-smtp-server.readthedocs.io/feature_cr_lf_modes/)
5. Support (optionally) SMTP [PIPELINING](https://tools.ietf.org/html/rfc2920) extension
6. Support (optionally) SMTP [8BITMIME](https://midi-smtp-server.readthedocs.io/feature_8bitmime_smtputf8/) extension
7. Support (optionally) SMTP [SMTPUTF8](https://midi-smtp-server.readthedocs.io/feature_8bitmime_smtputf8/) extension
8. SMTP PIPELINING, 8BITMIME and SMTPUTF8 extensions are _disabled_ by default
9. Support modification of local welcome and greeting messages
10. Documentation and Links about security and [email attacks](https://midi-smtp-server.readthedocs.io/appendix_security/#attacks-on-email-communication)
11. Added [implementation and integration testing](https://github.com/4commerce-technologies-AG/midi-smtp-server#reliable-code)


#### 2.2.3

1. Control and validation on incoming data [see Incoming data validation](https://midi-smtp-server.readthedocs.io/using_events/#incoming-data-validation)


#### 2.2.1

1. Builtin optional support of STARTTLS encryption
2. Added examples for a simple midi-smtp-server with TLS support


#### 2.2.x

1. Rubocop configuration and passed source code verification
2. Modified examples for a simple midi-smtp-server with and without auth
3. Enhanced `serve_service` (previously `start`)
4. Optionally gracefully shutdown when service `stop` (default gracefully)


#### 2.1.1

1. Huge speed improvement on receiving large message data (1.000+ faster)


#### 2.1.0

1. Authentication PLAIN, LOGIN
2. Safe `join` will catch and rescue `Interrupt`


#### 2.x

1. Modularized
2. Removed dependency to GServer
3. Additional events to interact with
4. Use logger to log several messages from severity :debug up to :fatal

<br>
