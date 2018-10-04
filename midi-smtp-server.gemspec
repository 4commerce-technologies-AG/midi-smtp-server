$LOAD_PATH.unshift File.expand_path('lib', __dir__)
require 'midi-smtp-server/version'

Gem::Specification.new do |s|
  s.name        = 'midi-smtp-server'
  s.version     = MidiSmtpServer::VERSION::STRING
  s.date        = MidiSmtpServer::VERSION::DATE
  s.summary     = 'MidiSmtpServer Class'
  s.description = 'A small and highly customizable ruby SMTP-Server class with builtin support for AUTH and SSL/STARTTLS.'
  s.authors     = ['Tom Freudenberg']
  s.email       = 'develop.rb.midi-smtp-server@4commerce.net'
  s.files       = [
    'README.md',
    'MIT-LICENSE.txt',
    'lib/midi-smtp-server.rb',
    'lib/midi-smtp-server/version.rb',
    'lib/midi-smtp-server/exceptions.rb',
    'lib/midi-smtp-server/tls-transport.rb'
  ]
  s.homepage    = 'https://github.com/4commerce-technologies-AG/midi-smtp-server/'
  s.license     = 'MIT'
end
