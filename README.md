<p align="center" style="margin-bottom: 2em">
  <img src="https://raw.githubusercontent.com/4commerce-technologies-AG/midi-smtp-server/master/mkdocs/img/midi-smtp-server-logo.png" alt="MidiSmtpServer Logo" width="40%"/>
</p>

<h3 align="center">MidiSmtpServer</h3>
<p align="center">
  <strong>The highly customizable ruby SMTP-Service library</strong>
</p>
<p align="center">
-- Mail-Server, SMTP-Service, MTA, Email-Gateway & Router, Mail-Automation --
</p>

<br>


## MidiSmtpServer

MidiSmtpServer is the highly customizable ruby SMTP-Server and SMTP-Service library with builtin support for AUTH and SSL/STARTTLS, 8BITMIME and SMTPUTF8, IPv4 and IPv6 and additional features.

As a library it is mainly designed to be integrated into your projects as serving a SMTP-Server service. The lib will do nothing with your mail and you have to create your own event functions to handle and operate on incoming mails. We are using this in conjunction with [Mikel Lindsaar](https://github.com/mikel) great Mail component (https://github.com/mikel/mail). Time to run your own SMTP-Server service.

Checkout all the features and improvements (3.0.1 Logging enhancement, 2.3.x Multiple ports and addresses, 2.2.x Encryption [StartTLS], 2.1.0 Authentication [AUTH], 2.1.1 significant speed improvement, etc.) and get more details from section [changes and updates](https://github.com/4commerce-technologies-AG/midi-smtp-server#changes-and-updates).

MidiSmtpServer is an extremely flexible library and almost any aspect of SMTP communications can be handled by deriving its events and using its configuration options.

<br>


## Using the library

To derive your own SMTP-Server service with DATA processing simply do:

```ruby
# Server class
class MySmtpd < MidiSmtpServer::Smtpd

  # get each message after DATA <message> .
  def on_message_data_event(ctx)
    # Output for debug
    logger.debug("[#{ctx[:envelope][:from]}] for recipient(s): [#{ctx[:envelope][:to]}]...")

    # Just decode message once to make sure, that this message ist readable
    @mail = Mail.read_from_string(ctx[:message][:data])

    # handle incoming mail, just show the message subject
    logger.debug(@mail.subject)
  end

end
```

Please checkout the source codes from [Examples](https://github.com/4commerce-technologies-AG/midi-smtp-server/tree/master/examples) for working SMTP-Services.

<br>


## Operation purposes

There is an endless field of application for SMTP&nbsp;services. You want to create your own SMTP&nbsp;Server as a mail&nbsp;gateway to clean up routed emails from spam and virus content. Incoming mails may be processed and handled native and by proper functions. A SMTP&nbsp;daemon can receive messages and forward them to a service like Slack, Trello, Redmine, Twitter, Facebook, Instagram and others.

This source code shows the example to receive messages via SMTP and store them to RabbitMQ (Message-Queue-Server) for subsequent processings etc.:

```ruby
  # get each message after DATA <message> .
  def on_message_data_event(ctx)
    # Just decode message once to make sure, that this message ist readable
    @mail = Mail.read_from_string(ctx[:message])

    # Publish to rabbit
    @bunny_exchange.publish(@mail.to_s, :headers => { 'x-smtp' => @mail.header.to_s }, :routing_key => "to_queue")
  end
```

<br>


## Installation

MidiSmtpServer is packaged as a RubyGem so that you can easily install by entering following at your command line:

  `gem install midi-smtp-server`

Use the component in your project sources by:

  `require 'midi-smtp-server'`

<br>


## Library documentation

Read the [MidiSmtpServer Documentation](https://midi-smtp-server.readthedocs.io/) for a complete library documentation.

<br>


## Reliable code

Since version 2.3 implementation and integration tests by minitest framework are added to this repository. While the implementation tests are mostly checking the components, the integration tests try to verify the correct exchange of messages for different scenarios. In addtion all sources are checked by rubocop to ensure they fit to the style guides.

You may run all rubocop tests through the `rake` helper:

``` bash
  bundle exec rake rubocop
```

You may also run all tests through the `rake` helper:

``` bash
  bundle exec rake test:all
```

or with more verbose output:

``` bash
  bundle exec rake test:all v=1
```

To just run just a part of the tests, you may select the `specs`, `unit` or `integration` tests:

``` bash
  bundle exec rake test:specs
```

To just run some selected (by regular expression) tests, you may use the `T=filter` option. The example will run only the tests and specs containing the word _connections_ in their method_name or describe_text:

``` bash
  bundle exec rake test:all v=1 T=connections
```

_Be aware that the parameters and filter are case sensitive._

#### Style guide links

1. [Ruby style guide](https://rubystyle.guide)
2. [Minitest style guide](https://minitest.rubystyle.guide)
3. [Rubocop/Cop documentation](https://docs.rubocop.org)
4. [Rubocop/Minitest](https://docs.rubocop.org/rubocop-minitest/)

<br>


## Changes and updates

We suggest everybody using MidiSmtpServer to switch at least to latest 2.3.y. or best to 3.x. The update is painless and mostly without any source code changes :sunglasses:

For upgrades from previous versions or outdated _MiniSmtpServer_ gem you may follow the guides (see appendix) how to change your existing code to be compatible with the latest releases.

#### Latest release: 3.0.1 (2021-03-12)

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
13. Re-defined arguments of methods `new`, `join`, `stop` as keyword arguments, check [minor incompatability: upgrade to 3.x](https://midi-smtp-server.readthedocs.io/appendix_upgrade/#upgrade-to-3x)
14. Enhance the slack recipe in cookbook for [Docker usage](https://github.com/4commerce-technologies-AG/midi-smtp-server/tree/master/cookbook/recipe-slack)


#### Changelog history

A complete list of updates and features can be read in the [CHANGELOG](https://github.com/4commerce-technologies-AG/midi-smtp-server/blob/master/CHANGELOG.md).

<br>


## Upgrading from previous releases

Checkout the [Appendix Upgrade](https://midi-smtp-server.readthedocs.io/appendix_upgrade/) to get your code ready for the latest releases.

<br>


## Gem Package

You may find, use and download the gem package on [RubyGems.org](http://rubygems.org/gems/midi-smtp-server).

[![Gem Version](https://badge.fury.io/rb/midi-smtp-server.svg)](http://badge.fury.io/rb/midi-smtp-server) &nbsp;

<br>

## Documentation

**[Project homepage](https://4commerce-technologies-ag.github.io/midi-smtp-server)** - you will find a micro-site at [Github](https://4commerce-technologies-ag.github.io/midi-smtp-server)

**[Class documentation](http://www.rubydoc.info/gems/midi-smtp-server/MidiSmtpServer/Smtpd)** - you will find a detailed description at [RubyDoc](http://www.rubydoc.info/gems/midi-smtp-server/MidiSmtpServer/Smtpd)

**[Library manual](https://midi-smtp-server.readthedocs.io/)** - you will find a manual at [ReadTheDocs](https://midi-smtp-server.readthedocs.io/)

<br>


## Author & Credits

Author: [Tom Freudenberg](http://about.me/tom.freudenberg)

[MidiSmtpServer Class](https://github.com/4commerce-technologies-AG/midi-smtp-server/) is inspired from [MiniSmtpServer Class](https://github.com/aarongough/mini-smtp-server) and code written by [Aaron Gough](https://github.com/aarongough) and [Peter Cooper](http://peterc.org/)

Copyright (c) 2014-2021 [Tom Freudenberg](http://www.4commerce.de/), [4commerce technologies AG](http://www.4commerce.de/), released under the MIT license
