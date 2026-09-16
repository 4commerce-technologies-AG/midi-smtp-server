source 'https://rubygems.org'
ruby RUBY_VERSION
gemspec

# stuff useful while development
group :development do
  gem 'bundler'
  gem 'rake'
  gem 'rubocop', '~> 1.91.0'
  gem 'rubocop-minitest', '~> 0.40.0'
  gem 'rubocop-performance', '~> 1.27.0'
end

# stuff useful while testing
group :testing do
  gem 'mail', '>= 2.9.1'
  gem 'minitest'
  gem 'net-smtp', '>= 0.3.1'
  gem 'openssl'
end
