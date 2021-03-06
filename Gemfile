source 'https://rubygems.org'

ruby File.read(File.expand_path '../.ruby-version', __FILE__).strip.sub /\-p[0-9]+$/, ''

# Core Frameworks
gem 'rails', '~> 4.0.4'
gem 'puma'
gem 'pg'

# Cache
gem 'dalli'

# Data
gem 'github_api'
gem 'faraday'
gem 'faraday_middleware'
gem 'typhoeus'
gem 'em-synchrony'
gem 'em-http-request'

# Assets & Views
gem 'haml-rails'
gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'foundation-rails', '~> 5.0.0'
gem 'jquery-rails'
gem 'def_cache'

# For Heroku
group 'production' do
  gem 'rails_12factor'
  gem 'memcachier'
end

# Better IRB
gem "pry"
gem "pry-rails"

# Testing
group :development, :test do
  gem 'travis'
  gem 'dotenv-rails'
  gem "factory_girl_rails", "~> 4.3.0"
  gem "guard", "~> 2.3.0"
  gem "guard-bundler", "~> 2.0.0"
  gem "guard-rspec", "~> 4.2.5"
  gem "shoulda-matchers"
  gem "vcr"
  gem "database_cleaner"
  gem "pry-nav"
  gem "pry-remote"
  gem "rb-inotify", require: false
  gem "rb-fsevent", require: false
  gem "rspec-rails", "~> 2.14"
  gem "simplecov", require: false
  gem "coveralls", require: false
  gem "terminal-notifier-guard"
end
