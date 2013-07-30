source 'https://rubygems.org'

ruby '2.0.0'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

# haml
gem 'haml-rails'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# Foundation
gem 'zurb-foundation', '~> 4.3.1'

# Github Api
gem 'github_api'

# Navigable Hash
gem 'navigable_hash'

# Use thin
gem "thin"

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

# Cache
gem 'dalli'

# For Heroku
gem 'rails_12factor', group: :production

group 'production' do
  gem 'memcachier'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem "oj"

group :development, :test do
  gem 'dotenv-rails'
  gem "factory_girl_rails", "~> 4.2.1"
  gem "guard", "~> 1.8.0"
  gem "guard-bundler", "~> 1.0.0"
  gem "guard-rspec", "~> 3.0.0"
  gem "pry"
  gem "pry-rails"
  gem "pry-debugger"
  gem "pry-remote"
  gem "rb-inotify", require: false
  gem "rb-fsevent", require: false
  gem "rspec-rails", "~> 2.0"
  gem "terminal-notifier-guard"
end
