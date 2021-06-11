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
  s.license     = 'MIT'
  s.files       = [
    'README.md',
    'CHANGELOG.md',
    'MIT-LICENSE.txt',
    'lib/midi-smtp-server.rb',
    'lib/midi-smtp-server/version.rb',
    'lib/midi-smtp-server/exceptions.rb',
    'lib/midi-smtp-server/logger.rb',
    'lib/midi-smtp-server/tls-transport.rb'
  ]
  s.metadata = {
    'homepage_uri'      => 'https://4commerce-technologies-ag.github.io/midi-smtp-server',
    'source_code_uri'   => 'https://github.com/4commerce-technologies-AG/midi-smtp-server',
    'changelog_uri'     => 'https://github.com/4commerce-technologies-AG/midi-smtp-server#changes-and-updates',
    'bug_tracker_uri'   => 'https://github.com/4commerce-technologies-AG/midi-smtp-server/issues',
    'documentation_uri' => "https://www.rubydoc.info/gems/midi-smtp-server/#{MidiSmtpServer::VERSION::STRING}",
    'wiki_uri'          => 'https://midi-smtp-server.readthedocs.io/'
  }
  s.required_ruby_version = '>= 2.6.0'
end
