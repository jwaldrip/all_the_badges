require 'simplecov'
SimpleCov.start 'rails'
ENV["RAILS_ENV"] ||= ENV['CI'] ? 'ci' : 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :faraday
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false

  # Clean the db
  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation, except: %w(permissions role_permissions roles)
  end

  config.before(:each) do
    if example.metadata[:clean_db]
      DatabaseCleaner.clean_with :truncation, except: %w(permissions role_permissions roles)
      DatabaseCleaner.start
    end
  end

  config.after(:each) do
    DatabaseCleaner.clean if example.metadata[:clean_db]
  end
end

def github_cassette
  { cassette_name: :github, record: :new_episodes }
end