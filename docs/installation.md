Installation of **MidiSmtpServer** library is pretty standard:

MidiSmtpServer is packaged as a RubyGem so that you can easily install it vi ..by entering following at your command line:

```sh
$ gem install midi-smtp-server
```

If you'd rather install MidiSmtpServer using `bundler`, you may require it in your `Gemfile`:

```rb
gem 'midi-smtp-server', '~> 2.3.0'
```

<br>

!!! Note

    We suggest everybody using MidiSmtpServer 1.x or 2.x to switch at least to latest 2.3.y. The update is always painless. If already using some 2.x release, it's fully compatible to your existing source codes.

<br>

!!! Warning

    Starting with release 2.3.0 the third (3rd) initialize argument has changed its name of from `max_connections` to `max_processings`. This was already the long existing origin intent of that argument and is now also reflected by its naming.
