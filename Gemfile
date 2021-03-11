source "https://rubygems.org"
ruby RUBY_VERSION
gemspec

# stuff useful while development
group :development do
  gem 'rubocop'
  gem 'rubocop-performance'
  gem 'rubocop-minitest'
end

# stuff useful while testing
group :testing do
  gem 'openssl'
  gem 'minitest'
  gem 'net-smtp', github: 'TomFreudenberg/net-smtp', tag: 'master'
  gem 'mail'
end
