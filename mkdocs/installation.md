<h2>Installation</h2>

Installation of **MidiSmtpServer** library is pretty standard:

MidiSmtpServer is packaged as a RubyGem so that you can easily install it by entering following at your command line:

```sh
$ gem install midi-smtp-server
```

If you'd rather install MidiSmtpServer using `bundler`, you may require it in your `Gemfile`:

```rb
gem 'midi-smtp-server', '~> 3.0.1'
```

In case that you want to enable TLS support or run tests, you may have to add also the `openssl` gem to your environment:

```sh
$ gem install openssl
```

or your `Gemfile`:

```rb
gem 'openssl', '~> 2.1.0'
```

<br>

!!! Note

    We suggest everybody using MidiSmtpServer to switch at least to latest 2.3.y. or best to 3.x. The update is painless and if already using some 2.x release, it's mostly full compatible to your existing source codes.

<br>

!!! Warning

    Starting with release 2.3.0 the third (3rd) initialize argument has changed its name from `max_connections` to `max_processings`. This was already the long existing origin intent of that argument and is now also reflected by its naming.

<br>
