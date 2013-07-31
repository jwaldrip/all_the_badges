source 'https://rubygems.org'

ruby '2.0.0'

# Core Frameworks
gem 'rails', '4.0.0'
gem "thin"
# gem 'turbolinks'
gem "oj"

# Cache
gem 'dalli'

# Data
gem 'github_api'
gem 'typhoeus'

# Assets & Views
gem 'haml-rails'
gem 'sass-rails', '~> 4.0.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'zurb-foundation', '~> 4.3.1'
gem 'jquery-rails'

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
  gem 'dotenv-rails'
  gem "factory_girl_rails", "~> 4.2.1"
  gem "guard", "~> 1.8.0"
  gem "guard-bundler", "~> 1.0.0"
  gem "guard-rspec", "~> 3.0.0"
  gem "pry-debugger"
  gem "pry-remote"
  gem "rb-inotify", require: false
  gem "rb-fsevent", require: false
  gem "rspec-rails", "~> 2.0"
  gem "terminal-notifier-guard"
end
